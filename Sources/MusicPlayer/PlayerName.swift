//
//  PlayerName.swift
//
//  This file is part of LyricsX - https://github.com/ddddxxx/LyricsX
//  Copyright (C) 2017  Xander Deng. Licensed under GPLv3.
//

public enum MusicPlayerName: String {
    
    #if os(macOS)
    
    case appleMusic = "Music"
    case spotify    = "Spotify"
    case vox        = "Vox"
    case audirvana  = "Audirvana"
    case swinsian   = "Swinsian"
    
    #elseif os(iOS)
    
    case appleMusic = "Music"
    case spotify    = "Spotify"
    
    #endif
}
