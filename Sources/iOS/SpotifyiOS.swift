//
//  SpotifyiOS.swift
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

import UIKit

public final class SpotifyiOS: NSObject, SPTAppRemoteDelegate, SPTAppRemotePlayerStateDelegate {
    
    public weak var delegate: MusicPlayerDelegate?
    
    let appRemote: SPTAppRemote
    var playerState: SPTAppRemotePlayerState?
    
    private var _startTime: Date?
    private var _pausePosition: Double?
    
    public init(clientID: String, redirectURL: URL, accessToken: String) {
        let configuration = SPTConfiguration(clientID: clientID, redirectURL: redirectURL)
        appRemote = SPTAppRemote(configuration: configuration, logLevel: .debug)
        appRemote.connectionParameters.accessToken = accessToken
        super.init()
        appRemote.delegate = self
        SPTAppRemote.checkIfSpotifyAppIsActive { active in
            if active {
                self.appRemote.connect()
            }
        }
    }
    
    // MARK: - SPTAppRemoteDelegate
    
    public func appRemoteDidEstablishConnection(_ appRemote: SPTAppRemote) {
        appRemote.playerAPI?.delegate = self
    }
    
    public func appRemote(_ appRemote: SPTAppRemote, didFailConnectionAttemptWithError error: Error?) {
        
    }
    
    public func appRemote(_ appRemote: SPTAppRemote, didDisconnectWithError error: Error?) {
        
    }
    
    // MARK: SPTAppRemotePlayerStateDelegate
    
    public func playerStateDidChange(_ playerState: SPTAppRemotePlayerState) {
        if playerState.track.uri != self.playerState?.track.uri {
            delegate?.currentTrackChanged(track: playerState.track.track, from: self)
        } else if playerState.isPaused != self.playerState?.isPaused {
            if playbackState.isPlaying {
                let startTimeNew = playerState.startTime
                if let _startTime = _startTime,
                    abs(startTimeNew.timeIntervalSince(_startTime)) > positionMutateThreshold {
                    self._startTime = startTimeNew
                    delegate?.playerPositionMutated(position: playerPosition, from: self)
                } else {
                    self._startTime = startTimeNew
                }
            } else {
                let pausePositionNew = playerState.position
                if let _pausePosition = _pausePosition,
                    abs(_pausePosition - pausePositionNew) > positionMutateThreshold {
                    self._pausePosition = pausePositionNew
                    delegate?.playerPositionMutated(position: playerPosition, from: self)
                } else {
                    self._pausePosition = pausePositionNew
                }
            }
        } else if playerState.startTime != self.playerState?.startTime {
            delegate?.playerPositionMutated(position: playerState.position, from: self)
        }
        self.playerState = playerState
    }
}

extension SpotifyiOS: MusicPlayer {
    
    public static let name: MusicPlayerName = .appleMusic
    public static var needsUpdateIfNotSelected = false
    
    public var isAuthorized: Bool {
        return appRemote.isConnected
    }
    
    public func requestAuthorizationIfNeeded() {
        appRemote.authorizeAndPlayURI("")
    }
    
    public var currentTrack: MusicTrack? {
        return playerState?.track.track
    }
    
    public var playbackState: MusicPlaybackState {
        return playerState?.playbackState ?? .stopped
    }
    
    public var playerPosition: TimeInterval {
        get {
            guard playbackState.isPlaying else { return _pausePosition ?? 0 }
            guard let _startTime = _startTime else { return 0 }
            return -_startTime.timeIntervalSinceNow
        }
        set {
            guard isAuthorized else { return }
            _startTime = Date().addingTimeInterval(-newValue)
            let positionInMilliseconds = Int(newValue * 1000)
            appRemote.playerAPI?.seek(toPosition: positionInMilliseconds, callback: nil)
        }
    }
    
    public func updatePlayerState() {
        appRemote.playerAPI?.getPlayerState { state, error in
            if let state = state as? SPTAppRemotePlayerState {
                self.playerStateDidChange(state)
            }
        }
    }
    
    public func resume() {
        appRemote.playerAPI?.resume(nil)
    }
    
    public func pause() {
        appRemote.playerAPI?.pause(nil)
    }
    
    public func playPause() {
        if playbackState.isPlaying {
            pause()
        } else {
            resume()
        }
    }
    
    public func skipToNextItem() {
        appRemote.playerAPI?.skip(toNext: nil)
    }
    
    public func skipToPreviousItem() {
        appRemote.playerAPI?.skip(toPrevious: nil)
    }
}

extension SpotifyiOS: PlaybackModeSettable {
    
    public var repeatMode: MusicRepeatMode {
        get {
            // TODO: get repeat mode
            return .off
        }
        set {
            appRemote.playerAPI?.setRepeatMode(SPTAppRemotePlaybackOptionsRepeatMode(newValue), callback: nil)
        }
    }
    
    public var shuffleMode: MusicShuffleMode {
        get {
            // TODO: get repeat mode
            return .off
        }
        set {
            let shuffle = newValue != .off
            appRemote.playerAPI?.setShuffle(shuffle, callback: nil)
        }
    }
}

// MARK: - Extension

extension SPTAppRemoteTrack {
    
    var track: MusicTrack {
        let duration_ = TimeInterval(duration) / 1000
        // TODO: Artwork
        return MusicTrack(id: uri, title: name, album: album.name, artist: artist.name, duration: duration_, url: nil, artwork: nil)
    }
}

extension SPTAppRemotePlayerState {
    
    var playbackState: MusicPlaybackState {
        return isPaused ? .paused : .playing
    }
    
    var position: TimeInterval {
        return TimeInterval(playbackPosition) / 1000
    }
    
    var startTime: Date {
        return Date(timeIntervalSinceNow: -position)
    }
}

extension SPTAppRemotePlaybackOptionsRepeatMode {
    
    var mode: MusicRepeatMode {
        switch self {
        case .off: return .off
        case .track: return .one
        case .context: return .all
        }
    }
    
    init(_ mode: MusicRepeatMode) {
        switch mode {
        case .off: self = .off
        case .one: self = .track
        case .all: self = .context
        }
    }
}
