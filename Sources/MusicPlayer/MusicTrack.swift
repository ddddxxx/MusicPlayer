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

public struct MusicTrack {
    
    public var id: String
    public var title: String?
    public var album: String?
    public var artist: String?
    public var duration: TimeInterval?
    public var fileURL: URL?
    public var artwork: Image?
    
    public init(id: String, title: String?, album: String?, artist: String?, duration: TimeInterval, fileURL: URL? = nil, artwork: Image? = nil) {
        self.id = id
        self.title = title
        self.album = album
        self.artist = artist
        self.duration = duration
        self.fileURL = fileURL
        self.artwork = artwork
    }
    
    #if os(macOS)
    public var originalTrack: SBObject? = nil
    #endif
}

extension MusicTrack: Equatable, Hashable {
    
    public static func == (lhs: Self, rhs: Self) -> Bool {
        return lhs.id == rhs.id
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

extension MusicTrack: CustomStringConvertible, CustomDebugStringConvertible {
    
    public var description: String {
        return "MusicTrack id: \(id), name: \(title ?? "-")"
    }
    
    public var debugDescription: String {
        return description
    }
}
