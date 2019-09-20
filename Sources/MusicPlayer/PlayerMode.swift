//
//  PlayerMode.swift
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
