//
//  MusicTrack.swift
//  LyricsX - https://github.com/ddddxxx/LyricsX
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at https://mozilla.org/MPL/2.0/.
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
    
    #if canImport(Darwin)
    public var artwork: Image?
    #endif
    
    public var originalTrack: AnyObject? = nil
    
    public init(id: String, title: String?, album: String?, artist: String?, duration: TimeInterval? = nil, fileURL: URL? = nil, artwork: Image? = nil, originalTrack: AnyObject? = nil) {
        self.id = id
        self.title = title
        self.album = album
        self.artist = artist
        self.duration = duration
        self.fileURL = fileURL
        self.artwork = artwork
        self.originalTrack = originalTrack
    }
    
    #if os(macOS)
    public var originalSBTrack: SBObject? {
        return originalTrack as? SBObject
    }
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
