//
//  MusicTrack.swift
//
//  This file is part of LyricsX - https://github.com/ddddxxx/LyricsX
//  Copyright (C) 2017  Xander Deng. Licensed under GPLv3.
//

import Foundation

#if os(macOS)
import ScriptingBridge
#endif

#if canImport(AppKit)
import AppKit
public typealias Image = NSImage
#elseif canImport(UIKit)
import UIKit
public typealias Image = UIImage
#endif

public struct MusicTrack {
    
    public var id: String
    public var title: String?
    public var album: String?
    public var artist: String?
    public var duration: TimeInterval?
    public var fileURL: URL?
    public var artwork: Image?
    
    #if os(macOS)
    public var originalTrack: SBObject?
    #endif
}

#if os(macOS)

extension MusicTrack: Equatable, Hashable {
    
}

import LXMusicPlayer

extension MusicTrack: ReferenceConvertible {
    
    public typealias ReferenceType = LXMusicTrack
    
    public var debugDescription: String {
        return description
    }
    
    public var description: String {
        return "MusicTrack name: \(title ?? "-")"
    }
    
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

#endif
