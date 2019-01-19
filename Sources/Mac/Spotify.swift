//
//  Spotify.swift
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

public final class Spotify {
    
    public weak var delegate: MusicPlayerDelegate?
    
    private var _spotify: SpotifyApplication
    private var _currentTrack: MusicTrack?
    private var _playbackState: MusicPlaybackState = .stopped
    private var _startTime: Date?
    private var _pausePosition: Double?
    
    private var observer: NSObjectProtocol?
    
    public init?() {
        guard let spotify = SBApplication(bundleIdentifier: Spotify.name.bundleID) else {
            return nil
        }
        _spotify = spotify
        if isRunning {
            _playbackState = _spotify._playbackState
            _currentTrack = _spotify._currentTrack
            _startTime = _spotify._startTime
        }
        
        observer = DistributedNotificationCenter.default.addObserver(forName: .SpotifyPlayerInfo, object: nil, queue: nil) { [unowned self] n in self.playerInfoNotification(n) }
    }
    
    deinit {
        observer.map(DistributedNotificationCenter.default.removeObserver)
    }
    
    func playerInfoNotification(_ n: Notification) {
        guard isRunning else { return }
        let id = n.userInfo?["Track ID"] as? String
        let state: MusicPlaybackState
        switch n.userInfo?["Player State"] as? String {
        case "Playing"?:    state = .playing
        case "Paused"?:     state = .paused
        case "Stopped"?, _:  state = .stopped
        }
        let position = n.userInfo?["Playback Position"] as? TimeInterval
        let startTime = position.map { Date().addingTimeInterval(-$0) }
        guard id == _currentTrack?.id else {
            let track = id == nil ? nil : _spotify._currentTrack
            _currentTrack = track
            _playbackState = state
            _startTime = startTime
            delegate?.currentTrackChanged(track: track, from: self)
            return
        }
        guard state == _playbackState else {
            _playbackState = state
            _startTime = startTime
            _pausePosition = position
            delegate?.playbackStateChanged(state: state, from: self)
            return
        }
        updatePlayerPosition()
    }
    
    func updatePlayerPosition() {
        guard isRunning else { return }
        if _playbackState.isPlaying {
            if let _startTime = _startTime,
                let startTime = _spotify._startTime,
                abs(startTime.timeIntervalSince(_startTime)) > positionMutateThreshold {
                self._startTime = startTime
                delegate?.playerPositionMutated(position: playerPosition, from: self)
            }
        } else {
            if let _pausePosition = _pausePosition,
                let pausePosition = _spotify.playerPosition,
                abs(_pausePosition - pausePosition) > positionMutateThreshold {
                self._pausePosition = pausePosition
                self.playerPosition = pausePosition
                delegate?.playerPositionMutated(position: playerPosition, from: self)
            }
        }
    }
}

extension Spotify: MusicPlayer {
    
    public static var name: MusicPlayerName = .spotify
    
    public static var needsUpdateIfNotSelected = false
    
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
//            _spotify.playerPosition = newValue
            _startTime = Date().addingTimeInterval(-newValue)
        }
    }
    
    public func updatePlayerState() {
        updatePlayerPosition()
    }
    
    public func resume() {
        _spotify.play?()
    }
    
    public func pause() {
        _spotify.pause?()
    }
    
    public func playPause() {
        _spotify.playpause?()
    }
    
    public func skipToNextItem() {
        _spotify.nextTrack?()
    }
    
    public func skipToPreviousItem() {
        _spotify.previousTrack?()
    }
    
    public var originalPlayer: SBApplication {
        return _spotify as! SBApplication
    }
}

extension Spotify: PlaybackModeSettable {
    
    public var repeatMode: MusicRepeatMode {
        get {
            return _spotify.repeating == true ? .all : .off
        }
        set {
            originalPlayer.setValue(newValue != .off, forKey: "repeating")
        }
    }
    
    public var shuffleMode: MusicShuffleMode {
        get {
            return _spotify.shuffling == true ? .groupings : .off
        }
        set {
//            _spotify.shuffling = newValue != .off
            originalPlayer.setValue(newValue != .off, forKey: "shuffling")
        }
    }
    
    
}

extension SpotifyApplication {
    
    var _currentTrack: MusicTrack? {
        guard let track = currentTrack else { return nil }
        let originalTrack = (track as! SBObject).get()
        return MusicTrack(id: track.id?() ?? "",
                          title: track.name ?? nil,
                          album: track.album ?? nil,
                          artist: track.artist ?? nil,
                          duration: track.duration.map(TimeInterval.init),
                          url: nil,
                          artwork: track.artwork,
                          originalTrack: (originalTrack as! SBObject))
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
        case .stopped?, nil, _: return .stopped
        }
    }
}
