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

import AppKit
import ScriptingBridge

public enum MusicPlaybackState {
    case stopped
    case playing
    case paused
    case fastForwarding
    case rewinding
}

public enum MusicRepeatMode {
    case off
    case one
    case all
}

public enum MusicShuffleMode {
    case off
    case songs
    case albums
    case groupings
}

public enum MusicPlayerName: String {
    
    case itunes     = "iTunes"
    case spotify    = "Spotify"
    case vox        = "Vox"
    case audirvana  = "Audirvana Plus"
    
    var bundleID: String {
        switch self {
        case .itunes:    return "com.apple.iTunes"
        case .spotify:   return "com.spotify.client"
        case .vox:       return "com.coppertino.Vox"
        case .audirvana: return "com.audirvana.Audirvana-Plus"
        }
    }
    
    var cls: MusicPlayer.Type {
        switch self {
        case .itunes:    return iTunes.self
        case .spotify:   return Spotify.self
        case .vox:       return Vox.self
        case .audirvana: return Audirvana.self
        }
    }
    
    static let all: [MusicPlayerName] = [.itunes, .spotify, .vox, .audirvana]
}

// MARK: -

public protocol MusicPlayerDelegate: class {
    
    func currentTrackChanged(track: MusicTrack?, from player: MusicPlayer)
    func playbackStateChanged(state: MusicPlaybackState, from player: MusicPlayer)
    func playerPositionMutated(position: TimeInterval, from player: MusicPlayer)
}

public protocol MusicPlayer: class {
    
    static var name: MusicPlayerName { get }
    static var needsUpdate: Bool { get }
    
    init?()
    
    var delegate: MusicPlayerDelegate? { get set }
    
    var playbackState: MusicPlaybackState { get }
    
    var currentTrack: MusicTrack? { get }
    var playerPosition: TimeInterval { get set }
    
    func updatePlayerState()
    
    // To prevent property/method name conflict, player should not be extended directly.
    var originalPlayer: SBApplication { get }
}

public struct MusicTrack {
    
    public var id:     String
    public var title:   String?
    public var album:  String?
    public var artist: String?
    public var duration: TimeInterval?
    public var url:    URL?
    public var artwork: NSImage?
}

// MARK: -

extension MusicPlaybackState {
    
    var isPlaying: Bool {
        switch self {
        case .playing, .fastForwarding, .rewinding:
            return true
        case .paused, .stopped:
            return false
        }
    }
}

extension MusicPlayer {
    
    public var isRunning: Bool {
        return originalPlayer.isRunning
    }
    
    public func activate() {
        originalPlayer.activate()
    }
}
