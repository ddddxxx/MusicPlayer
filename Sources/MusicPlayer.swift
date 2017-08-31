//
//  MusicPlayer.swift
//
//  This file is part of LyricsX
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

import Cocoa
import ScriptingBridge

public enum MusicPlaybackState {
    case stopped
    case playing
    case paused
    case fastForwarding
    case rewinding
}

public enum MusicRepeatMode {
    case none
    case one
    case all
}

public enum MusicShuffleMode {
    case off
    case songs
    case albums
}

// MARK: -

public protocol MusicPlyer {
    
    init()
    
    var playbackState: MusicPlaybackState { get }
    var repeatMode: MusicRepeatMode { get set }
    var shuffleMode: MusicShuffleMode { get set }
    
    var currentTrack: MusicTrack? { get }
    var playerPosition: TimeInterval { get set }
    
    func play()
    func pause()
    func stop()
    func skipToNext()
    func skipToPrevious()
    
    // To prevent property/method name conflict, player should not be extended directly.
    var originalPlayer: SBApplication { get }
}

public protocol MusicTrack {
    
    var id:     String { get }
    var title:  String { get }
    var album:  String? { get }
    var artist: String? { get }
    var duration: TimeInterval? { get }
    var artwork:  NSImage? { get set }
    var lyrics: String { get set }
    var url:    URL? { get }
    
    // To prevent property/method name conflict, track should not be extended directly.
    var originalTrack: SBObject { get }
}

// MARK: -

extension MusicPlyer {
    
    public var isRunning: Bool {
        return originalPlayer.isRunning
    }
    
    public func activate() {
        originalPlayer.activate()
    }
}
