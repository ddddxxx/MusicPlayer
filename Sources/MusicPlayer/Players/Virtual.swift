//
//  Virtual.swift
//  LyricsX - https://github.com/ddddxxx/LyricsX
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation
import CXShim

extension MusicPlayers {
    
    open class Virtual: ObservableObject {
        
        @Published public var currentTrack: MusicTrack?
        @Published public var playbackState: PlaybackState
        
        public init(track: MusicTrack? = nil, state: PlaybackState = .stopped) {
            currentTrack = track
            playbackState = state
        }
        
        /* open */ private func stop() {
            currentTrack = nil
            playbackState = .stopped
        }
    }
}

extension MusicPlayers.Virtual: MusicPlayerProtocol {
    
    public var currentTrackWillChange: AnyPublisher<MusicTrack?, Never> {
        return $currentTrack.eraseToAnyPublisher()
    }
    
    public var playbackStateWillChange: AnyPublisher<PlaybackState, Never> {
        return $playbackState.eraseToAnyPublisher()
    }
    
    public var name: MusicPlayerName? {
        return nil
    }
    
    public var playbackTime: TimeInterval {
        get {
            return playbackState.time
        }
        set {
            playbackState = playbackState.withTime(newValue)
        }
    }
    
    public func resume() {
        if case let .paused(time: time) = playbackState {
            playbackState = .playing(time: time)
        }
    }
    
    public func pause() {
        if playbackState.isPlaying {
            playbackState = .paused(time: playbackState.time)
        }
    }
    
    public func skipToNextItem() {
        stop()
    }
    
    public func skipToPreviousItem() {
        stop()
    }
    
    public func updatePlayerState() {}
}
