//
//  PlaybackState.swift
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

import Foundation

public enum PlaybackState: Equatable, Hashable {
    
    case stopped
    case playing(start: Date)
    case paused(time: TimeInterval)
    case fastForwarding(time: TimeInterval)
    case rewinding(time: TimeInterval)
    
    public static func playing(time: TimeInterval) -> PlaybackState {
        return .playing(start: Date(timeIntervalSinceNow: -time))
    }
    
    public var isPlaying: Bool {
        switch self {
        case .playing, .fastForwarding, .rewinding:
            return true
        case .paused, .stopped:
            return false
        }
    }
    
    public var time: TimeInterval {
        get {
            switch self {
            case .stopped: return 0
            case .playing(let start): return -start.timeIntervalSinceNow
            case .paused(let time): return time
            case .fastForwarding(let time): return time
            case .rewinding(let time): return time
            }
        }
        set {
            switch self {
            case .stopped: break
            case .playing: self = .playing(time: newValue)
            case .paused: self = .paused(time: newValue)
            case .fastForwarding: self = .fastForwarding(time: newValue)
            case .rewinding: self = .rewinding(time: newValue)
            }
        }
    }
}

#if os(macOS)

import LXMusicPlayer

extension PlaybackState: ReferenceConvertible {
    
    public typealias ReferenceType = LXPlayerState
    
    public var debugDescription: String {
        return description
    }
    
    public var description: String {
        switch self {
        case .stopped: return "stopped"
        case .playing(let start): return "playing start at \(start)"
        case .paused(let time): return "paused at \(time)"
        case .fastForwarding(let time): return "fastForwarding at \(time)"
        case .rewinding(let time): return "rewinding at \(time)"
        }
    }
    
    public func _bridgeToObjectiveC() -> LXPlayerState {
        switch self {
        case .stopped: return .stopped()
        case .playing(let start): return .playing(withStartTime: start)
        case .paused(let time): return .init(.paused, playbackTime: time)
        case .fastForwarding(let time): return .init(.fastForwarding, playbackTime: time)
        case .rewinding(let time): return .init(.rewinding, playbackTime: time)
        }
    }
    
    public static func _forceBridgeFromObjectiveC(_ source: LXPlayerState, result: inout PlaybackState?) {
        result = _unconditionallyBridgeFromObjectiveC(source)
    }
    
    public static func _conditionallyBridgeFromObjectiveC(_ source: LXPlayerState, result: inout PlaybackState?) -> Bool {
        result = _unconditionallyBridgeFromObjectiveC(source)
        return true
    }
    
    public static func _unconditionallyBridgeFromObjectiveC(_ source: LXPlayerState?) -> PlaybackState {
        guard let source = source else { fatalError() }
        switch source.state() {
        case .stopped: return .stopped
        case .playing: return .playing(start: source.startTime()!)
        case .paused: return .paused(time: source.playbackTime())
        case .fastForwarding: return .fastForwarding(time: source.playbackTime())
        case .rewinding: return .rewinding(time: source.playbackTime())
        @unknown default:
            fatalError()
        }
    }
}

#endif
