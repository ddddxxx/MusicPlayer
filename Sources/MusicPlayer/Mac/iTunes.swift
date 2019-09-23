//
//  iTunes.swift
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

public final class iTunes: MusicPlayerController {
    
    override public class var name: MusicPlayerName {
        return .itunes
    }
    
    private var _app: MusicApplication {
        return originalPlayer as! MusicApplication
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
        
        distributedNC.cx.publisher(for: .iTunesPlayerInfo)
            .sink { [unowned self] n in
                self.playerInfoNotification(n)
            }.store(in: &cancelBag)
    }
    
    func playerInfoNotification(_ n: Notification) {
        guard isRunning else { return }
        // iTunes will send notification before quit. if we send
        // apple event here, iTunes will be restarted immediately
        let id = (n.userInfo?["PersistentID"] as? Int).map { String(format: "%08X", arguments: [UInt(bitPattern: $0)]) }
        // Int64 hex uppercased persistent id from notification
        // But iTunesTrack.persistentID is Int128. truncate first 8 characters
        if id != (currentTrack?.id.dropFirst(8)).map(String.init) {
            currentTrack = _app._currentTrack
        }
        if (n.userInfo?["Player State"] as? String) == "Stopped" {
            playbackState = .stopped
        } else {
            playbackState = _app._playbackState
        }
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
        _app.resume()
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

extension iTunes: PlaybackModeSettable {
    
    public var repeatMode: RepeatMode {
        get {
            return _app.songRepeat.mode
        }
        set {
            _app.songRepeat = MusicERpt(newValue)
        }
    }
    
    public var shuffleMode: ShuffleMode {
        get {
            return _app.shuffleEnabled ? .on : .off
        }
        set {
            _app.shuffleEnabled = newValue.isEnabled
        }
    }
}

extension MusicApplication {
    
    var _currentTrack: MusicTrack? {
        guard let track = currentTrack.evaluated(),
            track.mediaKind == .song || track.mediaKind == .musicVideo || track.mediaKind.rawValue == 0,
            currentStreamURL == nil else {
                return nil
        }
        // conditional casting originalTrack to iTunesFileTrack causes crash.
//        var url: URL?
//        if originalTrack.responds(to: #selector(getter: NSTextTab.location)) {
//            url = originalTrack.perform(#selector(getter: NSTextTab.location))?.takeUnretainedValue() as? URL
//        }
        let url = (track as? MusicFileTrack)?.location
        let artwork = (track.artworks()?.firstObject as! MusicArtwork?)?.data
        return MusicTrack(id: track.persistentID,
                          title: track.name,
                          album: track.album,
                          artist: track.artist,
                          duration: track.duration,
                          url: url,
                          artwork: artwork,
                          originalTrack: track)
    }
    
    var _playbackState: PlaybackState {
        switch playerState {
        case .stopped: return .stopped
        case .playing: return .playing(time: playerPosition)
        case .paused:  return .paused(time: playerPosition)
        case .fastForwarding: return .fastForwarding(time: playerPosition)
        case .rewinding: return .playing(time: playerPosition)
        @unknown default: return .stopped
        }
    }
}

private extension MusicERpt {
    
    var mode: RepeatMode {
        switch self {
        case .off: return .off
        case .one: return .one
        case .all: return .all
        @unknown default: return .off
        }
    }
    
    init(_ mode: RepeatMode) {
        switch mode {
        case .off: self = .off
        case .one: self = .one
        case .all: self = .all
        }
    }
}

#endif
