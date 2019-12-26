//
//  ScriptingBridgedPlayer.swift
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

#if os(macOS)

import Foundation
import LXMusicPlayer
import CXShim

extension MusicPlayers {
    
    public final class ScriptingBridged: ObservableObject {
        
        private var player: LXScriptingMusicPlayer
        private var observations: [NSKeyValueObservation] = []
        
        @Published public private(set) var currentTrack: MusicTrack?
        @Published public private(set) var playbackState: PlaybackState
        
        public init?(name: MusicPlayerName) {
            guard let lxNmae = name.lxName, let player = LXScriptingMusicPlayer(name: lxNmae) else {
                return nil
            }
            self.player = player
            self.currentTrack = player.currentTrack as MusicTrack?
            self.playbackState = player.playerState as PlaybackState
            observations += [
                player.observe(\.currentTrack, options: [.new]) { [unowned self] (_, change) in
                    self.currentTrack = change.newValue! as MusicTrack?
                },
                player.observe(\.playerState, options: [.new]) { [unowned self] (_, change) in
                    self.playbackState = change.newValue! as PlaybackState
                }
            ]
        }
    }
}

extension MusicPlayers.ScriptingBridged: MusicPlayerProtocol, PlaybackTimeUpdating {
    
    public var currentTrackWillChange: AnyPublisher<MusicTrack?, Never> {
        return $currentTrack.eraseToAnyPublisher()
    }
    
    public var playbackStateWillChange: AnyPublisher<PlaybackState, Never> {
        return $playbackState.eraseToAnyPublisher()
    }
    
    public var name: MusicPlayerName {
        return MusicPlayerName(lxName: player.playerName)!
    }
    
    public var playbackTime: TimeInterval {
        get { return player.playbackTime }
        set { player.playbackTime = newValue }
    }
    
    public func resume() {
        player.resume()
    }
    
    public func pause() {
        player.pause()
    }
    
    public func playPause() {
        player.playPause()
    }
    
    public func skipToNextItem() {
        player.skipToNextItem()
    }
    
    public func skipToPreviousItem() {
        player.skipToPreviousItem()
    }
    
    public func updatePlaybackTime() {
        player.updatePlaybackTime()
    }
}

#endif
