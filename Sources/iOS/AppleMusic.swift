//
//  AppleMusic.swift
//  MusicPlayer
//
//  Created by 邓翔 on 2019/1/8.
//

import UIKit
import MediaPlayer

public final class AppleMusic: MusicPlayer {
    
    public static let name = MusicPlayerName.appleMusic
    public static var needsUpdate = false
    
    public weak var delegate: MusicPlayerDelegate?
    
    private let musicPlayer = MPMusicPlayerController.systemMusicPlayer
    public var currentTrack: MusicTrack?
    public var playbackState: MusicPlaybackState = .stopped
    
    private var _startTime: Date?
    private var _pausePosition: Double?
    
    public var playerPosition: TimeInterval {
        get {
            guard playbackState.isPlaying else { return _pausePosition ?? 0 }
            guard let _startTime = _startTime else { return 0 }
            return -_startTime.timeIntervalSinceNow
        }
        set {
            guard isAuthorized else { return }
            musicPlayer.currentPlaybackTime = newValue
            _startTime = Date().addingTimeInterval(-newValue)
        }
    }
    
    public var isAuthorized: Bool = false
    
    public init?() {
        let nc = NotificationCenter.default
        
        nc.addObserver(self, selector: #selector(applicationDidBecomeActive), name: UIApplication.didBecomeActiveNotification, object: nil)
        nc.addObserver(self, selector: #selector(applicationDidBecomeActive), name: UIApplication.willEnterForegroundNotification, object: nil)
        
        musicPlayer.beginGeneratingPlaybackNotifications()
        
        nc.addObserver(forName: .MPMusicPlayerControllerPlaybackStateDidChange, object: musicPlayer, queue: nil) { [weak self] _ in
            self?.updatePlaybackState()
            self?.updatePlayerPosition()
        }
        nc.addObserver(forName: .MPMusicPlayerControllerNowPlayingItemDidChange, object: musicPlayer, queue: nil) { [weak self] _ in
            self?.updatePlayerState()
        }
    }
    
    deinit {
        musicPlayer.endGeneratingPlaybackNotifications()
    }
    
    public func updatePlayerState() {
        guard checkAuthorization() else { return }
        updatePlayerPosition()
    }
    
    @objc private func applicationDidBecomeActive() {
        guard checkAuthorization() else { return }
        updateCurrentTrack()
        updatePlaybackState()
        updatePlayerPosition()
    }
    
    private func checkAuthorization() -> Bool {
        let newAuth = MPMediaLibrary.authorizationStatus() == .authorized
        let needsUpdate = isAuthorized != newAuth
        isAuthorized = newAuth
        if needsUpdate {
            updateCurrentTrack()
            updatePlaybackState()
            updatePlayerPosition()
        }
        return isAuthorized
    }
    
    private func updateCurrentTrack() {
        guard checkAuthorization() else { return }
        if currentTrack?.id != musicPlayer.nowPlayingItem?.idString {
            currentTrack = musicPlayer.currentTrack
            delegate?.currentTrackChanged(track: currentTrack, from: self)
        }
    }
    
    private func updatePlaybackState() {
        guard checkAuthorization() else { return }
        if musicPlayer._playbackState != playbackState {
            playbackState = musicPlayer._playbackState
            delegate?.playbackStateChanged(state: playbackState, from: self)
        }
    }
    
    private func updatePlayerPosition() {
        guard isAuthorized else { return }
        if playbackState.isPlaying {
            let startTime = musicPlayer.startTime
            if let _startTime = _startTime,
                abs(startTime.timeIntervalSince(_startTime)) > positionMutateThreshold {
                self._startTime = startTime
                delegate?.playerPositionMutated(position: playerPosition, from: self)
            }
        } else {
            let pausePosition = musicPlayer.currentPlaybackTime
            if let _pausePosition = _pausePosition,
                abs(_pausePosition - pausePosition) > positionMutateThreshold {
                self._pausePosition = pausePosition
                self.playerPosition = pausePosition
                delegate?.playerPositionMutated(position: playerPosition, from: self)
            }
        }
    }
}

private extension MPMediaItem {
    
    var idString: String {
        return String(format: "%X", [persistentID])
    }
}

private extension MPMusicPlayerController {
    
    var _playbackState: MusicPlaybackState {
        switch playbackState {
        case .stopped: return .stopped
        case .playing: return .playing
        case .paused: return .paused
        case .interrupted: return .paused
        case .seekingForward: return .fastForwarding
        case .seekingBackward: return .rewinding
        }
    }
    
    var currentTrack: MusicTrack? {
        guard MPMediaLibrary.authorizationStatus() == .authorized,
            let track = nowPlayingItem else {
            return nil
        }
        let imageSize = CGSize(width: 600, height: 600)
        let artwork = track.artwork?.image(at: imageSize)
        return MusicTrack(id: track.idString,
                          title: track.title,
                          album: track.albumTitle,
                          artist: track.artist,
                          duration: track.playbackDuration,
                          url: nil,
                          artwork: artwork)
    }
    
    var startTime: Date {
        return Date(timeIntervalSinceNow: -currentPlaybackTime)
    }
}
