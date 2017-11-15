import AppKit
import ScriptingBridge

public final class Audirvana {
    public weak var delegate: MusicPlayerDelegate?
    
    private var _audirvana: AudirvanaApplication
    private var _currentTrack: MusicTrack?
    private var _playbackState: MusicPlaybackState = .stopped
    private var _startTime: Date?
    private var _pausePosition: Double?
    
    private var observer: NSObjectProtocol?
    
    public init?() {
        guard let audirvana = SBApplication(bundleIdentifier: Audirvana.name.bundleID) else {
            return nil
        }
        _audirvana = audirvana
        if isRunning {
            reportAudirvanaTrackChange()
            
            _playbackState = _audirvana._playbackState
            _currentTrack = _audirvana._currentTrack
            _startTime = _audirvana._startTime
        }
        
        observer = DistributedNotificationCenter.default.addObserver(forName: .AudirvanaPlayerInfo, object: nil, queue: nil) { [unowned self] n in self.playerInfoNotification(n) }
    }
    
    deinit {
        observer.map(DistributedNotificationCenter.default.removeObserver)
    }
    
    func playerInfoNotification(_ n: Notification) {
        guard isRunning else { return }
        let id = _audirvana._id ?? nil
        let state: MusicPlaybackState
        switch n.userInfo?["PlayerStatus"] as? String {
        case "Playing"?:    state = .playing
        case "Paused"?:     state = .paused
        case "Stopped"?, _: state = .stopped
        }
        guard id == _currentTrack?.id else {
            var track = _audirvana._currentTrack
            if let loc = n.userInfo?["PlayingTrackURL"] as? String {
                track?.url = URL(string: loc)
            }
            _currentTrack = track
            _playbackState = state
            _startTime = _audirvana._startTime
            delegate?.currentTrackChanged(track: track, from: self)
            return
        }
        guard state == _playbackState else {
            _playbackState = state
            _startTime = _audirvana._startTime
            _pausePosition = playerPosition
            delegate?.playbackStateChanged(state: state, from: self)
            return
        }
        updatePlayerPosition()
    }
    
    func updatePlayerPosition() {
        guard isRunning else { return }
        if _playbackState.isPlaying {
            if let _startTime = _startTime,
                let startTime = _audirvana._startTime,
                abs(startTime.timeIntervalSince(_startTime)) > positionMutateThreshold {
                self._startTime = startTime
                delegate?.playerPositionMutated(position: playerPosition, from: self)
            }
        } else {
            if let _pausePosition = _pausePosition,
                let pausePosition = _audirvana.playerPosition,
                abs(_pausePosition - pausePosition) > positionMutateThreshold {
                self._pausePosition = pausePosition
                self.playerPosition = pausePosition
                delegate?.playerPositionMutated(position: playerPosition, from: self)
            }
        }
    }
}

extension Audirvana: MusicPlayer {
    public static var name: MusicPlayerName = .audirvana
    
    public static var needsUpdate = false
    
    public var playbackState: MusicPlaybackState {
        return _playbackState
    }
    
    public var currentTrack: MusicTrack? {
        return _currentTrack
    }
    
    public var playerPosition: TimeInterval {
        get {
            guard _playbackState.isPlaying else { return _pausePosition ?? 0 }
            guard isRunning else { return 0 }
            guard let _startTime = _startTime else { return 0 }
            return -_startTime.timeIntervalSinceNow
        }
        set {
            guard isRunning else { return }
            originalPlayer.setValue(newValue, forKey: "playerPosition")
            _startTime = Date().addingTimeInterval(-newValue)
        }
    }
    
    public func updatePlayerState() {
        updatePlayerPosition()
    }
    
    public var originalPlayer: SBApplication {
        return _audirvana as! SBApplication
    }
}

extension AudirvanaApplication {
    var _id: String? {
        guard let title = playingTrackTitle else { return nil }
        return [title, playingTrackAlbum ?? nil, playingTrackArtist ?? nil, (playingTrackDuration ?? nil).map(String.init)].flatMap{$0}.joined(separator: ":")
    }
    var _currentTrack: MusicTrack? {
        guard let id = _id else { return nil }
        return MusicTrack(id: id,
                          title: playingTrackTitle ?? nil,
                          album: playingTrackAlbum ?? nil,
                          artist: playingTrackArtist ?? nil,
                          duration: playingTrackDuration.map(TimeInterval.init),
                          url: nil)
    }
    
    var _startTime: Date? {
        guard let playerPosition = playerPosition else {
            return nil
        }
        return Date().addingTimeInterval(-playerPosition)
    }
    
    var _playbackState: MusicPlaybackState {
        switch playerState {
        case .stopped?, nil:    return .stopped
        case .playing?:         return .playing
        case .paused?:          return .paused
        }
    }
}

public func reportAudirvanaTrackChange() {
    guard let audirvana: AudirvanaApplication = SBApplication(bundleIdentifier: Audirvana.name.bundleID) else {
        return
    }
    audirvana.setEventTypesReported?(.trackChanged)
}
