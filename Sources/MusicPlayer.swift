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

import Foundation

#if os(macOS)
import AppKit
import ScriptingBridge
#endif

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

public enum MusicPlayerName: String, CaseIterable {
    
    #if os(macOS)
    
    case itunes     = "iTunes"
    case spotify    = "Spotify"
    case vox        = "Vox"
    case audirvana  = "Audirvana Plus"
    
    #elseif os(iOS)
    
    case appleMusic = "Apple Music"
    case spotify    = "Spotify"
    
    #endif
}

// MARK: -

public protocol MusicPlayerDelegate: class {
    
    func currentTrackChanged(track: MusicTrack?, from player: MusicPlayer)
    func playbackStateChanged(state: MusicPlaybackState, from player: MusicPlayer)
    func playerPositionMutated(position: TimeInterval, from player: MusicPlayer)
}

public protocol MusicPlayer: class {
    
    static var name: MusicPlayerName { get }
    static var needsUpdateIfNotSelected: Bool { get }
    
    var delegate: MusicPlayerDelegate? { get set }
    
    var currentTrack: MusicTrack? { get }
    var playbackState: MusicPlaybackState { get }
    var playerPosition: TimeInterval { get set }
    
    func updatePlayerState()
    
    func resume()
    func pause()
    func playPause()
    
    func skipToNextItem()
    func skipToPreviousItem()
    
    #if os(macOS)
    
    init?()
    // To prevent property/method name conflict, player should not be extended directly.
    var originalPlayer: SBApplication { get }
    
    #elseif os(iOS)
    
    var isAuthorized: Bool { get }
    func requestAuthorizationIfNeeded()
    
    #endif
}

public protocol PlaybackModeSettable {
    var repeatMode: MusicRepeatMode { get set }
    var shuffleMode: MusicShuffleMode { get set }
}

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

// MARK: -

extension MusicPlaybackState {
    
    public var isPlaying: Bool {
        switch self {
        case .playing, .fastForwarding, .rewinding:
            return true
        case .paused, .stopped:
            return false
        }
    }
}

#if os(macOS)

extension MusicPlayerName {
    
    public var bundleID: String {
        switch self {
        case .itunes:    return "com.apple.iTunes"
        case .spotify:   return "com.spotify.client"
        case .vox:       return "com.coppertino.Vox"
        case .audirvana: return "com.audirvana.Audirvana-Plus"
        }
    }
    
    public var cls: MusicPlayer.Type {
        switch self {
        case .itunes:    return iTunes.self
        case .spotify:   return Spotify.self
        case .vox:       return Vox.self
        case .audirvana: return Audirvana.self
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

#endif
