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

public enum MusicPlayerName: String {
    
    case nowPlaying    = "Now Playing"
    
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

import LXMusicPlayer

extension MusicPlayerName {
    
    init?(lxName: LXScriptingMusicPlayer.Name) {
        switch lxName {
        case .appleMusic: self = .itunes
        case .spotify: self = .spotify
        case .vox: self = .vox
        case .audirvana: self = .audirvana
        case .swinsian: self = .swinsian
        default: return nil
        }
    }
    
    var lxName: LXScriptingMusicPlayer.Name? {
        switch self {
        case .itunes: return .appleMusic
        case .spotify: return .spotify
        case .vox: return .vox
        case .audirvana: return .audirvana
        case .swinsian: return .swinsian
        default: return nil
        }
    }
    
    static var scriptingPlayerNames: [MusicPlayerName] = [.itunes, .spotify, .vox, .audirvana, .swinsian]
}

#endif
