//
//  Scriptable.swift
//  LyricsX - https://github.com/ddddxxx/LyricsX
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

#if os(macOS)

import Foundation
import LXMusicPlayer
import CXShim
import CXExtensions

extension MusicPlayers {
    
    public final class Scriptable: ObservableObject {
        
        private var player: LXScriptingMusicPlayer
        private var cancellers: Set<AnyCancellable> = []
        
        @Published public private(set) var currentTrack: MusicTrack?
        @Published public private(set) var playbackState: PlaybackState
        
        public var playerBundleID: String {
            return player.playerBundleID
        }
        
        public init?(name: MusicPlayerName) {
            guard let lxNmae = name.lxName, let player = LXScriptingMusicPlayer(name: lxNmae) else {
                return nil
            }
            self.player = player
            self.currentTrack = player.currentTrack as MusicTrack?
            self.playbackState = player.playerState as PlaybackState
            player.cx
                .publisher(for: \.currentTrack)
                .map { $0 as MusicTrack? }
                .receive(on: DispatchQueue.playerUpdate.cx)
                .assign(to: \.currentTrack, weaklyOn: self)
                .store(in: &cancellers)
            player.cx
                .publisher(for: \.playerState)
                .map { $0 as PlaybackState }
                .receive(on: DispatchQueue.playerUpdate.cx)
                .assign(to: \.playbackState, weaklyOn: self)
                .store(in: &cancellers)
        }
    }
}

extension MusicPlayers.Scriptable: MusicPlayerProtocol {
    
    public var currentTrackWillChange: AnyPublisher<MusicTrack?, Never> {
        return $currentTrack.eraseToAnyPublisher()
    }
    
    public var playbackStateWillChange: AnyPublisher<PlaybackState, Never> {
        return $playbackState.eraseToAnyPublisher()
    }
    
    public var name: MusicPlayerName? {
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
    
    public func updatePlayerState() {
        player.updatePlayerState()
    }
}

extension MusicPlayerName {
    
    public static let scriptableCases: [MusicPlayerName] = [.appleMusic, .spotify, .vox, .audirvana, .swinsian]
}

#endif
