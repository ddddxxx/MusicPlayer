//
//  OCBridge.swift
//
//  This file is part of LyricsX - https://github.com/ddddxxx/LyricsX
//  Copyright (C) 2017  Xander Deng. Licensed under GPLv3.
//

#if os(macOS)

import Foundation
import LXMusicPlayer

// MARK: - MusicTrack

extension MusicTrack: ReferenceConvertible {
    
    public typealias ReferenceType = LXMusicTrack
    
    public func _bridgeToObjectiveC() -> LXMusicTrack {
        let t = LXMusicTrack(persistentID: id)
        t.title = title
        t.album = album
        t.artist = artist
        t.duration = duration as NSNumber?
        t.fileURL = fileURL
        t.artwork = artwork
        return t
    }
    
    public static func _forceBridgeFromObjectiveC(_ source: LXMusicTrack, result: inout MusicTrack?) {
        result = _unconditionallyBridgeFromObjectiveC(source)
    }
    
    public static func _conditionallyBridgeFromObjectiveC(_ source: LXMusicTrack, result: inout MusicTrack?) -> Bool {
        result = _unconditionallyBridgeFromObjectiveC(source)
        return true
    }
    
    public static func _unconditionallyBridgeFromObjectiveC(_ source: LXMusicTrack?) -> MusicTrack {
        guard let t = source else { fatalError() }
        return MusicTrack(id: t.persistentID,
                          title: t.title,
                          album: t.album,
                          artist: t.artist,
                          duration: t.duration?.doubleValue,
                          fileURL: t.fileURL,
                          artwork: t.artwork,
                          originalTrack: t.originalTrack)
    }
}

// MARK: - PlaybackState

extension PlaybackState: ReferenceConvertible {
    
    public typealias ReferenceType = LXPlayerState
    
    public func _bridgeToObjectiveC() -> LXPlayerState {
        switch self {
        case .stopped: return .stopped()
        case .playing(let start): return .playing(withStartTime: start)
        case .paused(let time): return .init(.paused, playbackTime: time)
        case .fastForwarding(let time): return .init(.fastForwarding, playbackTime: time)
        case .rewinding(let time): return .init(.rewinding, playbackTime: time)
        }
    }
    
    public static func _forceBridgeFromObjectiveC(_ source: LXPlayerState, result: inout PlaybackState?) {
        result = _unconditionallyBridgeFromObjectiveC(source)
    }
    
    public static func _conditionallyBridgeFromObjectiveC(_ source: LXPlayerState, result: inout PlaybackState?) -> Bool {
        result = _unconditionallyBridgeFromObjectiveC(source)
        return true
    }
    
    public static func _unconditionallyBridgeFromObjectiveC(_ source: LXPlayerState?) -> PlaybackState {
        guard let source = source else { fatalError() }
        switch source.state() {
        case .stopped: return .stopped
        case .playing: return .playing(start: source.startTime()!)
        case .paused: return .paused(time: source.playbackTime())
        case .fastForwarding: return .fastForwarding(time: source.playbackTime())
        case .rewinding: return .rewinding(time: source.playbackTime())
        @unknown default:
            fatalError()
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
