//
//  iTunes.swift
//
//  This file is part of LyricsX
//  Copyright (C) 2017  Xander Deng
//
//  This program is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.
//
//  This program is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with this program.  If not, see <http://www.gnu.org/licenses/>.
//

import AppKit
import ScriptingBridge

public final class iTunes {
    
    public weak var delegate: MusicPlayerDelegate?
    
    private var _iTunes: MusicApplication
    private var _currentTrack: MusicTrack?
    private var _playbackState: MusicPlaybackState = .stopped
    private var _startTime: Date?
    private var _pausePosition: Double?
    
    private var observer: NSObjectProtocol?
    
    public init?() {
        guard let iTunes = iTunes.makeScriptingApplication() else {
            return nil
        }
        _iTunes = iTunes
        if isRunning {
            _playbackState = _iTunes._playbackState
            _currentTrack = _iTunes._currentTrack
            _startTime = _iTunes._startTime
        }
        
        observer = DistributedNotificationCenter.default.addObserver(forName: .iTunesPlayerInfo, object: nil, queue: nil) { [unowned self] n in self.playerInfoNotification(n) }
    }
    
    deinit {
        observer.map(DistributedNotificationCenter.default.removeObserver)
    }
    
    func playerInfoNotification(_ n: Notification) {
        guard isRunning else { return }
        // iTunes will send notification before quit. if we send
        // apple event here, iTunes will be restarted immediately
        let id = (n.userInfo?["PersistentID"] as? Int).map { String(format: "%08X", arguments: [UInt(bitPattern: $0)]) }
        let state: MusicPlaybackState
        switch n.userInfo?["Player State"] as? String {
        case "Playing"?: state = .playing
        case "Paused"?:  state = .paused
        case "Stopped"?, _: state = .stopped
        }
        // Int64 hex uppercased persistent id from notification
        // But iTunesTrack.persistentID is Int128. truncate first 8 characters
        guard id == (_currentTrack?.id.dropFirst(8)).map(String.init) else {
            let track = _iTunes._currentTrack
            _currentTrack = track
            _playbackState = state
            _startTime = _iTunes._startTime
            delegate?.currentTrackChanged(track: track, from: self)
            return
        }
        guard state == _playbackState else {
            _playbackState = state
            _startTime = _iTunes._startTime
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
                let startTime = _iTunes._startTime,
                abs(startTime.timeIntervalSince(_startTime)) > positionMutateThreshold {
                self._startTime = startTime
                delegate?.playerPositionMutated(position: playerPosition, from: self)
            }
        } else {
            if let _pausePosition = _pausePosition,
                let pausePosition = _iTunes.playerPosition,
                abs(_pausePosition - pausePosition) > positionMutateThreshold {
                self._pausePosition = pausePosition
                self.playerPosition = pausePosition
                delegate?.playerPositionMutated(position: playerPosition, from: self)
            }
        }
    }
}
    
extension iTunes: MusicPlayer {
    
    public static var name: MusicPlayerName = .itunes
    
    public static var needsUpdateIfNotSelected = false
    
    public var currentTrack: MusicTrack? {
        return _currentTrack
    }
    
    public var playbackState: MusicPlaybackState {
        return _playbackState
    }
    
    public var playerPosition: TimeInterval {
        get {
            guard _playbackState.isPlaying else { return _pausePosition ?? 0 }
            guard let _startTime = _startTime else { return 0 }
            return -_startTime.timeIntervalSinceNow
        }
        set {
            guard isRunning else { return }
            originalPlayer.setValue(newValue, forKey: "playerPosition")
//            _iTunes.playerPosition = newValue
            _startTime = Date().addingTimeInterval(-newValue)
        }
    }
    
    public func updatePlayerState() {
        updatePlayerPosition()
    }
    
    public func resume() {
        _iTunes.resume?()
    }
    
    public func pause() {
        _iTunes.pause?()
    }
    
    public func playPause() {
        _iTunes.playpause?()
    }
    
    public func skipToNextItem() {
        _iTunes.nextTrack?()
    }
    
    public func skipToPreviousItem() {
        _iTunes.previousTrack?()
    }
    
    public var originalPlayer: SBApplication {
        return _iTunes as! SBApplication
    }
}

extension iTunes: PlaybackModeSettable {
    
    public var repeatMode: MusicRepeatMode {
        get {
            return _iTunes.songRepeat?.mode ?? .off
        }
        set {
//            _iTunes.songRepeat = MusicERpt(newValue)
            originalPlayer.setValue(MusicERpt(newValue), forKey: "songRepeat")
        }
    }
    
    public var shuffleMode: MusicShuffleMode {
        get {
            if _iTunes.shuffleEnabled != true {
                return .off
            }
            switch _iTunes.shuffleMode {
            case .songs?: return .songs
            case .albums?: return .albums
            case .groupings?: return .groupings
            default: return .off
            }
        }
        set {
            let app = originalPlayer
            switch newValue {
            case .off:
                app.setValue(false, forKey: "shuffleEnabled")
            case .songs:
                app.setValue(true, forKey: "shuffleEnabled")
                app.setValue(MusicEShM.songs, forKey: "shuffleMode")
            case .albums:
                app.setValue(true, forKey: "shuffleEnabled")
                app.setValue(MusicEShM.albums, forKey: "shuffleMode")
            case .groupings:
                app.setValue(true, forKey: "shuffleEnabled")
                app.setValue(MusicEShM.groupings, forKey: "shuffleMode")
            }
        }
    }
    
    
}

extension MusicApplication {
    
    var _currentTrack: MusicTrack? {
        guard let track = currentTrack,
            let originalTrack = (track as! SBObject).get() as? SBObject,
            track.mediaKind == .song || track.mediaKind == .musicVideo || track.mediaKind?.rawValue == 0,
            currentStreamURL ?? nil == nil else {
                return nil
        }
        // conditional casting originalTrack to iTunesFileTrack causes crash.
        var url: URL?
        if originalTrack.responds(to: #selector(getter: NSTextTab.location)) {
            url = originalTrack.perform(#selector(getter: NSTextTab.location))?.takeUnretainedValue() as? URL
        }
        let artwork = track.artworks?().first?.data
        return MusicTrack(id: (track.persistentID ?? "") ?? "",
                          title: track.name ?? nil,
                          album: track.album ?? nil,
                          artist: track.artist ?? nil,
                          duration: track.duration,
                          url: url,
                          artwork: artwork ?? nil,
                          originalTrack: originalTrack)
    }
    
    var _startTime: Date? {
        guard let playerPosition = playerPosition else {
            return nil
        }
        return Date().addingTimeInterval(-playerPosition)
    }
    
    var _playbackState: MusicPlaybackState {
        switch playerState {
        case .playing?:         return .playing
        case .paused?:          return .paused
        case .fastForwarding?:  return .fastForwarding
        case .rewinding?:       return .playing
        case .stopped?, nil, _: return .stopped
        }
    }
}

private extension MusicERpt {
    
    var mode: MusicRepeatMode {
        switch self {
        case .off: return .off
        case .one: return .one
        case .all: return .all
        }
    }
    
    init(_ mode: MusicRepeatMode) {
        switch mode {
        case .off: self = .off
        case .one: self = .one
        case .all: self = .all
        }
    }
}
