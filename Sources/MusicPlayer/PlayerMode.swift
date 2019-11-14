//
//  PlayerMode.swift
//
//  This file is part of LyricsX - https://github.com/ddddxxx/LyricsX
//  Copyright (C) 2017  Xander Deng. Licensed under GPLv3.
//

public enum RepeatMode: CaseIterable {
    case off
    case one
    case all
}

public enum ShuffleMode: CaseIterable {
    case off
    case on

    public var isEnabled: Bool { return self == .on }
}

public protocol PlaybackModeSettable {
    var availableRepeatMode: [RepeatMode] { get }
    var availableShuffleMode: [ShuffleMode] { get }
    var repeatMode: RepeatMode { get set }
    var shuffleMode: ShuffleMode { get set }
}

public extension PlaybackModeSettable {
    
    var availableRepeatMode: [RepeatMode] {
        return RepeatMode.allCases
    }
    
    var availableShuffleMode: [ShuffleMode] {
        return ShuffleMode.allCases
    }
}
