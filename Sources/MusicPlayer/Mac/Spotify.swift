//
//  Spotify.swift
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

#if os(macOS)

import AppKit
import ScriptingBridge
import CXShim

public final class Spotify: MusicPlayerController, PlaybackTimeUpdating {
    
    override public class var name: MusicPlayerName {
        return .spotify
    }
    
    private var _app: SpotifyApplication {
        return originalPlayer
    }
    
    required init?() {
        super.init()
        if isRunning {
            playbackState = _app._playbackState
            currentTrack = _app._currentTrack
        }
        
        distributedNC.cx.publisher(for: .spotifyPlayerInfo)
            .sink { [unowned self] n in
                self.playerInfoNotification(n)
            }.store(in: &cancelBag)
    }
    
    func updatePlaybackTime() {
        guard isRunning else { return }
        setPlaybackState(_app._playbackState)
    }
    
    func playerInfoNotification(_ n: Notification) {
        guard isRunning else { return }
        let id = n.userInfo?["Track ID"] as? String
        let state: PlaybackState
        if let position = n.userInfo?["Playback Position"] as? TimeInterval {
            switch n.userInfo?["Player State"] as? String {
            case "Playing"?:    state = .playing(time: position)
            case "Paused"?:     state = .paused(time: position)
            case "Stopped"?, _:  state = .stopped
            }
        } else {
            state = .stopped
        }
        if id != currentTrack?.id {
            currentTrack = id.flatMap { _ in _app._currentTrack}
            return
        }
        playbackState = state
    }
    
    override public var playbackTime: TimeInterval {
        get {
            return playbackState.time
        }
        set {
            guard isRunning else { return }
            originalPlayer.setValue(newValue, forKey: "playerPosition")
            playbackState.time = newValue
        }
    }
    
    override public func resume() {
        _app.play?()
    }
    
    override public func pause() {
        _app.pause?()
    }
    
    override public func playPause() {
        _app.playpause?()
    }
    
    override public func skipToNextItem() {
        _app.nextTrack?()
    }
    
    override public func skipToPreviousItem() {
        _app.previousTrack?()
    }
}

extension Spotify: PlaybackModeSettable {
    
    public var availableRepeatMode: [RepeatMode] {
        return [.off, .all]
    }
    
    public var repeatMode: RepeatMode {
        get {
            return _app.repeating == true ? .all : .off
        }
        set {
            originalPlayer.setValue(newValue != .off, forKey: "repeating")
        }
    }
    
    public var shuffleMode: ShuffleMode {
        get {
            return _app.shuffling == true ? .on : .off
        }
        set {
            originalPlayer.setValue(newValue.isEnabled, forKey: "shuffling")
        }
    }
}

extension SpotifyApplication {
    
    var _currentTrack: MusicTrack? {
        guard let track = currentTrack else { return nil }
        let originalTrack = (track as! SBObject).get() as? SBObject
        return MusicTrack(id: track.id?() ?? "",
                          title: track.name ?? nil,
                          album: track.album ?? nil,
                          artist: track.artist ?? nil,
                          duration: track.duration.map(TimeInterval.init),
                          fileURL: nil,
                          artwork: nil,
                          originalTrack: originalTrack)
    }
    
    var _playbackState: PlaybackState {
        guard let state = playerState, let position = playerPosition else {
            return .stopped
        }
        switch state {
        case .stopped: return .stopped
        case .playing: return .playing(time: position)
        case .paused:  return .paused(time: position)
        }
    }
}

#endif
