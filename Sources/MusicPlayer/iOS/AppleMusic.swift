//
//  AppleMusic.swift
//
//  This file is part of LyricsX - https://github.com/ddddxxx/LyricsX
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

#if false

import UIKit
import MediaPlayer

public final class AppleMusic {
    
    public weak var delegate: MusicPlayerDelegate?
    
    private let musicPlayer = MPMusicPlayerController.systemMusicPlayer
    
    public var currentTrack: MusicTrack?
    public var playbackState: MusicPlaybackState = .stopped
    
    private var _startTime: Date?
    private var _pausePosition: Double?
    
    public init() {
        let nc = NotificationCenter.default
        
        nc.addObserver(self, selector: #selector(updateFullPlayerState), name: UIApplication.didBecomeActiveNotification, object: nil)
        nc.addObserver(self, selector: #selector(updateFullPlayerState), name: UIApplication.willEnterForegroundNotification, object: nil)
        
        musicPlayer.beginGeneratingPlaybackNotifications()
        
        nc.addObserver(forName: .MPMusicPlayerControllerPlaybackStateDidChange, object: musicPlayer, queue: nil) { [weak self] _ in
            self?.updateFullPlayerState()
        }
        nc.addObserver(forName: .MPMusicPlayerControllerNowPlayingItemDidChange, object: musicPlayer, queue: nil) { [weak self] _ in
            self?.updateFullPlayerState()
        }
        nc.addObserver(forName: UIApplication.didBecomeActiveNotification, object: nil, queue: nil) { [weak self] _ in
            self?.updateFullPlayerState()
        }
        nc.addObserver(forName: UIApplication.willEnterForegroundNotification, object: nil, queue: nil) { [weak self] _ in
            self?.updateFullPlayerState()
        }
        
        updateFullPlayerState()
    }
    
    deinit {
        musicPlayer.endGeneratingPlaybackNotifications()
    }
    
    // MARK: - Update
    
    @objc private func updateFullPlayerState() {
        guard isAuthorized else { return }
        updateCurrentTrack()
        updatePlaybackState()
        updatePlayerPosition()
    }
    
    private func updateCurrentTrack() {
        guard isAuthorized else { return }
        if currentTrack?.id != musicPlayer.nowPlayingItem?.idString {
            currentTrack = musicPlayer.currentTrack
            delegate?.currentTrackChanged(track: currentTrack, from: self)
        }
    }
    
    private func updatePlaybackState() {
        guard isAuthorized else { return }
        if musicPlayer._playbackState != playbackState {
            playbackState = musicPlayer._playbackState
            delegate?.playbackStateChanged(state: playbackState, from: self)
        }
    }
    
    private func updatePlayerPosition() {
        guard isAuthorized else { return }
        if playbackState.isPlaying {
            let startTimeNew = musicPlayer.startTime
            if let _startTime = _startTime,
                abs(startTimeNew.timeIntervalSince(_startTime)) > positionMutateThreshold {
                self._startTime = startTimeNew
                delegate?.playerPositionMutated(position: playerPosition, from: self)
            } else {
                self._startTime = startTimeNew
            }
        } else {
            let pausePositionNew = musicPlayer.currentPlaybackTime
            if let _pausePosition = _pausePosition,
                abs(_pausePosition - pausePositionNew) > positionMutateThreshold {
                self._pausePosition = pausePositionNew
                delegate?.playerPositionMutated(position: playerPosition, from: self)
            } else {
                self._pausePosition = pausePositionNew
            }
        }
    }
}

extension AppleMusic: MusicPlayerProtocol {
    
    public static let name = MusicPlayerName.appleMusic
    public static var needsUpdateIfNotSelected = false
    
    
    public var isAuthorized: Bool {
        return MPMediaLibrary.authorizationStatus() == .authorized
    }
    
    public func requestAuthorizationIfNeeded() {
        switch MPMediaLibrary.authorizationStatus() {
        case .notDetermined:
            MPMediaLibrary.requestAuthorization() { [weak self] _ in
                self?.updateFullPlayerState()
            }
        case .denied, .restricted:
            break
//            if let settingsURL = URL(string: UIApplication.openSettingsURLString) {
//                UIApplication.shared.open(settingsURL)
//            }
        case .authorized:
            break
        @unknown default:
            break
        }
    }
    
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
    
    public func updatePlayerState() {
        guard isAuthorized else { return }
        updateFullPlayerState()
    }
    
    public func resume() {
        musicPlayer.play()
    }
    
    public func pause() {
        musicPlayer.pause()
    }
    
    public func playPause() {
        if playbackState.isPlaying {
            musicPlayer.pause()
        } else {
            musicPlayer.play()
        }
    }
    
    public func skipToNextItem() {
        musicPlayer.skipToNextItem()
    }
    
    public func skipToPreviousItem() {
        musicPlayer.skipToPreviousItem()
    }
}

extension AppleMusic: PlaybackModeSettable {
    
    public var repeatMode: MusicRepeatMode {
        get {
            return musicPlayer.repeatMode.mode
        }
        set {
            musicPlayer.repeatMode = MPMusicRepeatMode(newValue)
        }
    }
    
    public var shuffleMode: MusicShuffleMode {
        get {
            return musicPlayer.shuffleMode.mode
        }
        set {
            musicPlayer.shuffleMode = MPMusicShuffleMode(newValue)
        }
    }
}

// MARK: - Extension

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
        @unknown default: return .stopped
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
                          fileURL: nil,
                          artwork: artwork)
    }
    
    var startTime: Date {
        return Date(timeIntervalSinceNow: -currentPlaybackTime)
    }
}

private extension MPMusicRepeatMode {
    
    var mode: MusicRepeatMode {
        switch self {
        case .none: return .off
        case .one:  return .one
        case .all:  return .all
        // FIXME: What Mode?
        case .default: return .off
        @unknown default: return .off
        }
    }
    
    init(_ mode: MusicRepeatMode) {
        switch mode {
        case .off: self = .none
        case .one: self = .one
        case .all: self = .all
        }
    }
}

private extension MPMusicShuffleMode {
    
    var mode: MusicShuffleMode {
        switch self {
        case .off: return .off
        case .songs: return .songs
        case .albums: return .albums
        // FIXME: What Mode?
        case .default: return .off
        @unknown default: return .off
        }
    }
    
    init(_ mode: MusicShuffleMode) {
        switch mode {
        case .off: self = .off
        case .songs: self = .songs
        case .albums: self = .albums
        case .groupings: self = .albums
        }
    }
}

#endif
