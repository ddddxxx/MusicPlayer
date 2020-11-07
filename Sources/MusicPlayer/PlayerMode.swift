//
//  PlayerMode.swift
//  LyricsX - https://github.com/ddddxxx/LyricsX
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

#if false // TODO: PlaybackModeSettable

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

#endif
