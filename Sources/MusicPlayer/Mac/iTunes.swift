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

#if USE_COMBINEX
import CXFoundation
#else
import CXCompatible
#endif

public final class iTunes: MusicPlayerController {
    
    override public class var name: MusicPlayerName {
        return .itunes
    }
    
    private var _app: MusicApplication {
        return originalPlayer
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
            originalPlayer.setValue(newValue, forKey: "playerPosition")
            playbackState.time = newValue
        }
    }
    
    override public func resume() {
        _app.resume?()
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

extension iTunes: PlaybackModeSettable {
    
    public var repeatMode: RepeatMode {
        get {
            return _app.songRepeat?.mode ?? .off
        }
        set {
            originalPlayer.setValue(MusicERpt(newValue), forKey: "songRepeat")
        }
    }
    
    public var shuffleMode: ShuffleMode {
        get {
            return _app.shuffleEnabled == true ? .on : .off
        }
        set {
            originalPlayer.setValue(newValue.isEnabled, forKey: "shuffleEnabled")
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
                          fileURL: url,
                          artwork: artwork ?? nil,
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
        case .fastForwarding: return .fastForwarding(time: position)
        case .rewinding: return .playing(time: position)
        }
    }
}

private extension MusicERpt {
    
    var mode: RepeatMode {
        switch self {
        case .off: return .off
        case .one: return .one
        case .all: return .all
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
