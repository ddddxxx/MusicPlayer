//
//  PlayerName.swift
//
//  This file is part of LyricsX - https://github.com/ddddxxx/LyricsX
//  Copyright (C) 2017  Xander Deng. Licensed under GPLv3.
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
