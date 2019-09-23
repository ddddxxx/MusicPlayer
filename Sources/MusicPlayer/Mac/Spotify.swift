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
import MusicPlayerBridge

public final class Spotify: MusicPlayerController {
    
    override public class var name: MusicPlayerName {
        return .spotify
    }
    
    private var _app: SpotifyApplication {
        return originalPlayer as! SpotifyApplication
    }
    
    public override var currentTrack: MusicTrack? {
        get { super.currentTrack }
        set { super.currentTrack = newValue }
    }
    public override var playbackState: PlaybackState {
        get { super.playbackState }
        set { super.playbackState = newValue }
    }
    
    required init?() {
        super.init()
        if isRunning {
            playbackState = _app._playbackState
            currentTrack = _app._currentTrack
        }
        
        updatePlaybackTime = { [unowned self] in
            guard self.isRunning else { return }
            self.setPlaybackState(self._app._playbackState)
        }
        
        distributedNC.cx.publisher(for: .spotifyPlayerInfo)
            .sink { [unowned self] n in
                self.playerInfoNotification(n)
            }.store(in: &cancelBag)
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
            _app.playerPosition = newValue
            playbackState.time = newValue
        }
    }
    
    override public func resume() {
        _app.play()
    }
    
    override public func pause() {
        _app.pause()
    }
    
    override public func playPause() {
        _app.playpause()
    }
    
    override public func skipToNextItem() {
        _app.nextTrack()
    }
    
    override public func skipToPreviousItem() {
        _app.previousTrack()
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
            _app.repeating = newValue != .off
        }
    }
    
    public var shuffleMode: ShuffleMode {
        get {
            return _app.shuffling == true ? .on : .off
        }
        set {
            _app.shuffling = newValue.isEnabled
        }
    }
}

extension SpotifyApplication {
    
    var _currentTrack: MusicTrack? {
        guard let track = currentTrack.evaluated() else { return nil }
        return MusicTrack(id: track.id(),
                          title: track.name,
                          album: track.album,
                          artist: track.artist,
                          duration: TimeInterval(track.duration),
                          url: nil,
                          artwork: nil,
                          originalTrack: track)
    }
    
    var _playbackState: PlaybackState {
        switch playerState {
        case .stopped: return .stopped
        case .playing: return .playing(time: playerPosition)
        case .paused:  return .paused(time: playerPosition)
        @unknown default: return .stopped
        }
    }
}

#endif
