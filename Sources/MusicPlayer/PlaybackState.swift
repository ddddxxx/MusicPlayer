//
//  PlaybackState.swift
//
//  This file is part of LyricsX - https://github.com/ddddxxx/LyricsX
//  Copyright (C) 2017  Xander Deng. Licensed under GPLv3.
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
    
    func withTime(_ time: TimeInterval) -> PlaybackState {
        switch self {
        case .stopped:  return .stopped
        case .playing:  return .playing(time: time)
        case .paused:   return .paused(time: time)
        case .fastForwarding:   return .fastForwarding(time: time)
        case .rewinding:        return .rewinding(time: time)
        }
    }
    
    public func approximateEqual(to state: PlaybackState, tolerate: TimeInterval = 1.5) -> Bool {
        switch (self, state) {
        case (.stopped, .stopped):
            return true
        case (.playing, .playing),
             (.paused, .paused),
             (.fastForwarding, .fastForwarding),
             (.rewinding, .rewinding):
            return abs(time - state.time) < tolerate
        default:
            return false
        }
    }
}

extension PlaybackState: CustomStringConvertible, CustomDebugStringConvertible {
    
    public var description: String {
        switch self {
        case .stopped:  return "stopped"
        case .playing:  return "playing at \(time)"
        case .paused:   return "paused at \(time)"
        case .fastForwarding:   return "fast forwarding at \(time)"
        case .rewinding:        return "rewinding at \(time)"
        }
    }
    
    public var debugDescription: String {
        return description
    }
}
