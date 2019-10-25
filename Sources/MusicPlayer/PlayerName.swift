//
//  PlayerName.swift
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

public enum MusicPlayerName: String, CaseIterable {
    
    #if os(macOS)
    
    case itunes     = "iTunes"
    case spotify    = "Spotify"
    case vox        = "Vox"
    case audirvana  = "Audirvana"
    case swinsian   = "Swinsian"
    
    #elseif os(iOS)
    
    case appleMusic = "Apple Music"
    case spotify    = "Spotify"
    
    #endif
}

#if os(macOS)

extension MusicPlayerName {
    
    public var candidateBundleID: [String] {
        switch self {
        case .itunes:    return ["com.apple.Music", "com.apple.iTunes"]
        case .spotify:   return ["com.spotify.client"]
        case .vox:       return ["com.coppertino.Vox"]
        case .audirvana: return ["com.audirvana.Audirvana", "com.audirvana.Audirvana-Plus"]
        case .swinsian:  return ["com.swinsian.Swinsian"]
        }
    }
    
    public var cls: MusicPlayerController.Type {
        switch self {
        case .itunes:    return iTunes.self
        case .spotify:   return Spotify.self
        case .vox:       return Vox.self
        case .audirvana: return Audirvana.self
        case .swinsian:  return Swinsian.self
        }
    }
}

#endif
