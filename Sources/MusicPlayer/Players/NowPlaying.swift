//
//  NowPlaying.swift
//  LyricsX - https://github.com/ddddxxx/LyricsX
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation
import CXShim

extension MusicPlayers {
    
    public class NowPlaying: Agent {
        
        override public var designatedPlayer: MusicPlayerProtocol? {
            get { return super.designatedPlayer }
            set { preconditionFailure("setting currentPlayer for MusicPlayers.NowPlaying is forbidden") }
        }
        
        public var players: [MusicPlayerProtocol] {
            didSet {
                selectNewPlayer()
            }
        }
        
        private var selectNewPlayerCanceller: AnyCancellable?
        
        public init(players: [MusicPlayerProtocol]) {
            self.players = players
            super.init()
            selectNewPlayer()
            selectNewPlayerCanceller = $designatedPlayer
                .map {
                    $0?.objectWillChange.eraseToAnyPublisher() ??
                        Publishers.MergeMany(players.map { $0.objectWillChange }).eraseToAnyPublisher()
                }
                .switchToLatest()
                .receive(on: DispatchQueue.playerUpdate.cx)
                .sink { [weak self] _ in
                    self?.selectNewPlayer()
                }
        }
        
        private func selectNewPlayer() {
            var newPlayer: MusicPlayerProtocol?
            if designatedPlayer?.playbackState.isPlaying == true {
                newPlayer = designatedPlayer
            } else if let playing = players.first(where: { $0.playbackState.isPlaying }) {
                newPlayer = playing
            } else if let running = players.first(where: { $0.playbackState != .stopped }) {
                newPlayer = running
            }
            if newPlayer !== designatedPlayer {
                super.designatedPlayer = newPlayer
            }
        }
    }
}
