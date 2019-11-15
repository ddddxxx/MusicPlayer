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
