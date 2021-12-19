//
//  ObjCBridge.swift
//  LyricsX - https://github.com/ddddxxx/LyricsX
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

#if os(macOS)

import Foundation
import LXMusicPlayer

// MARK: - MusicTrack

extension MusicTrack {
    
    init(lxTrack t: LXMusicTrack) {
        self.init(id: t.persistentID,
                  title: t.title,
                  album: t.album,
                  artist: t.artist,
                  duration: t.duration?.doubleValue,
                  fileURL: t.fileURL,
                  artwork: t.artwork,
                  originalTrack: t.originalTrack)
    }
    
    var lxTrack: LXMusicTrack {
        let t = LXMusicTrack(persistentID: id)
        t.title = title
        t.album = album
        t.artist = artist
        t.duration = duration as NSNumber?
        t.fileURL = fileURL
        t.artwork = artwork
        return t
    }
}

// MARK: - PlaybackState

extension PlaybackState {
    
    init(lxState s: LXPlayerState) {
        switch s.state() {
        case .stopped: self = .stopped
        case .playing: self = .playing(start: s.startTime()!)
        case .paused: self = .paused(time: s.playbackTime())
        case .fastForwarding: self = .fastForwarding(time: s.playbackTime())
        case .rewinding: self = .rewinding(time: s.playbackTime())
        @unknown default:
            fatalError()
        }
    }
    
    var lxState: LXPlayerState {
        switch self {
        case .stopped: return .stopped()
        case .playing(let start): return .playing(withStartTime: start)
        case .paused(let time): return .init(.paused, playbackTime: time)
        case .fastForwarding(let time): return .init(.fastForwarding, playbackTime: time)
        case .rewinding(let time): return .init(.rewinding, playbackTime: time)
        }
    }
}

// MARK: - MusicPlayerName

extension MusicPlayerName {
    
    init?(lxName: LXScriptingMusicPlayer.Name) {
        switch lxName {
        case .appleMusic: self = .appleMusic
        case .spotify: self = .spotify
        case .vox: self = .vox
        case .audirvana: self = .audirvana
        case .swinsian: self = .swinsian
        default: return nil
        }
    }
    
    var lxName: LXScriptingMusicPlayer.Name? {
        switch self {
        case .appleMusic: return .appleMusic
        case .spotify: return .spotify
        case .vox: return .vox
        case .audirvana: return .audirvana
        case .swinsian: return .swinsian
        }
    }
    
    static var scriptingPlayerNames: [MusicPlayerName] = [.appleMusic, .spotify, .vox, .audirvana, .swinsian]
}

#endif
