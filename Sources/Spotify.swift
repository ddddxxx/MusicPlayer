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

import Cocoa
import ScriptingBridge

final public class Spotify {
    
    public struct Track {
        
        private var _spotifyTrack: SpotifyTrack
        
        init(_ track: SpotifyTrack) {
            _spotifyTrack = track
        }
    }
    
    public weak var delegate: MusicPlayerDelegate?
    
    public var autoLaunch = false
    
    private var _spotify: SpotifyApplication
    private var _currentTrack: Track?
    private var _playbackState: MusicPlaybackState = .stopped
    private var _startTime: Date?
    private var _pausePosition: Double?
    
    public init?() {
        guard let spotify = SBApplication(bundleIdentifier: Spotify.name.bundleID) else {
            return nil
        }
        _spotify = spotify
        if isRunning {
            _playbackState = _spotify.playerState?.state ?? .stopped
            _currentTrack = _spotify.currentTrack.map(Track.init)
            _startTime = _spotify.startTime
        }
        
        DistributedNotificationCenter.default.addObserver(forName: .SpotifyPlayerInfo, object: nil, queue: notificationQueue, using: playerInfoNotification)
    }
    
    func playerInfoNotification(_ n: Notification) {
        guard autoLaunch || isRunning else { return }
        let track = _spotify.currentTrack.map(Track.init)
        let state = _spotify.playerState?.state ?? .stopped
        guard track?.id == _currentTrack?.id else {
            _currentTrack = track
            _playbackState = state
            _startTime = _spotify.startTime
            delegate?.currentTrackChanged(track: track, from: self)
            return
        }
        guard state == _playbackState else {
            _playbackState = state
            _startTime = _spotify.startTime
            _pausePosition = playerPosition
            delegate?.playbackStateChanged(state: state, from: self)
            return
        }
        updatePlayerPosition()
    }
    
    func updatePlayerPosition() {
        guard autoLaunch || isRunning else { return }
        if _playbackState.isPlaying {
            if let _startTime = _startTime,
                let startTime = _spotify.startTime,
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
    
    public static var needsUpdate = false
    
    public var playbackState: MusicPlaybackState {
        return _playbackState
    }
    
    public var repeatMode: MusicRepeatMode {
        get {
            guard autoLaunch || isRunning else { return .off }
            return _spotify.repeating == true ? .all : .off
        }
        set {
            guard autoLaunch || isRunning else { return }
            originalPlayer.setValue(newValue != .off, forKey: "repeating")
//            _spotify.repeating = newValue != .off
        }
    }
    
    public var shuffleMode: MusicShuffleMode {
        get {
            guard autoLaunch || isRunning else { return .off }
            return _spotify.shuffling == true ? .groupings : .off
        }
        set {
            guard autoLaunch || isRunning else { return }
            originalPlayer.setValue(newValue != .off, forKey: "shuffling")
//            _spotify.shuffling = newValue != .off
        }
    }
    
    public var currentTrack: MusicTrack? {
        return _currentTrack
    }
    
    public var playerPosition: TimeInterval {
        get {
            guard autoLaunch || isRunning else { return 0 }
            guard let _startTime = _startTime else { return 0 }
            return -_startTime.timeIntervalSinceNow
        }
        set {
            guard autoLaunch || isRunning else { return }
            originalPlayer.setValue(newValue, forKey: "playerPosition")
//            _spotify.playerPosition = newValue
            _startTime = Date().addingTimeInterval(-newValue)
        }
    }
    
    public func playpause() {
        guard autoLaunch || isRunning else { return }
        _spotify.playpause?()
    }
    
    public func stop() {
        guard autoLaunch || isRunning else { return }
        // NOTE: not support
        _spotify.pause?()
    }
    
    public func skipToNext() {
        guard autoLaunch || isRunning else { return }
        _spotify.nextTrack?()
    }
    
    public func skipToPrevious() {
        guard autoLaunch || isRunning else { return }
        _spotify.previousTrack?()
    }
    
    public func updatePlayerState() {
        updatePlayerPosition()
    }
    
    public var originalPlayer: SBApplication {
        return _spotify as! SBApplication
    }
}

extension SpotifyEPlS {
    
    var state: MusicPlaybackState {
        switch self {
        case .stopped:  return .stopped
        case .playing:  return .playing
        case .paused:   return .paused
        }
    }
}

extension Spotify.Track: MusicTrack {
    
    public var id: String {
        return _spotifyTrack.id?() ?? ""
    }
    
    public var title: String? {
        return _spotifyTrack.name ?? nil
    }
    
    public var album: String? {
        return _spotifyTrack.album ?? nil
    }
    
    public var artist: String? {
        return _spotifyTrack.artist ?? nil
    }
    
    public var duration: TimeInterval? {
        return _spotifyTrack.duration.map(TimeInterval.init)
    }
    
    public var artwork: NSImage? {
        get {
            return _spotifyTrack.artwork
        }
        set {
            // NOTE: not support
        }
    }
    
    // NOTE: not support
    public var lyrics: String? {
        get { return nil }
        set {}
    }
    
    public var url: URL? {
        return nil
    }
    
    public var originalTrack: SBObject? {
        return (_spotifyTrack as! SBObject)
    }
}

extension SpotifyApplication {
    
    var startTime: Date? {
        guard let playerPosition = playerPosition else {
            return nil
        }
        return Date().addingTimeInterval(-playerPosition)
    }
}
