//
//  MusicTrack.swift
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
    
    public var id:     String
    public var title:   String?
    public var album:  String?
    public var artist: String?
    public var duration: TimeInterval?
    public var url:    URL?
    public var artwork: Image?
    
    #if os(macOS)
    public var originalTrack: SBObject?
    #endif
}
