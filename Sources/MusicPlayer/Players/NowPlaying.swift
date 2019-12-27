//
//  NowPlaying.swift
//
//  This file is part of LyricsX - https://github.com/ddddxxx/LyricsX
//  Copyright (C) 2017  Xander Deng. Licensed under GPLv3.
//

import Foundation
import CXShim

extension MusicPlayers {
    
    public final class NowPlaying: ObservableObject {
        
        public let objectWillChange = ObservableObjectPublisher()
        
        public let players: [MusicPlayerProtocol]
        
        @Published public private(set) var currentPlayer: MusicPlayerProtocol?
        
        private var cancelBag = Set<AnyCancellable>()

        public init(players: [MusicPlayerProtocol]) {
            self.players = players
            selectNewPlayer()
            $currentPlayer
                .map { $0?.objectWillChange.eraseToAnyPublisher() ?? Just(()).eraseToAnyPublisher() }
                .switchToLatest()
                .sink { [weak self] _ in
                    self?.objectWillChange.send()
                    DispatchQueue.global().async {
                        self?.selectNewPlayer()
                    }
                }
                .store(in: &cancelBag)
        }
        
        #if os(macOS)
        
        public convenience init() {
            let players = MusicPlayerName.scriptingPlayerNames.compactMap(MusicPlayers.ScriptingBridged.init)
            self.init(players: players)
        }
        
        #endif
        
        private func selectNewPlayer() {
            var newPlayer: MusicPlayerProtocol?
            if currentPlayer?.playbackState.isPlaying == true {
                newPlayer = currentPlayer
            } else if let playing = players.first(where: { $0.playbackState.isPlaying }) {
                newPlayer = playing
            } else if let running = players.first(where: { $0.playbackState != .stopped }) {
                newPlayer = running
            }
            if newPlayer !== currentPlayer {
                currentPlayer = newPlayer
            }
        }
    }
}

extension MusicPlayers.NowPlaying: MusicPlayerProtocol {
    
    public var name: MusicPlayerName? {
        return currentPlayer?.name
    }
    
    public var currentTrack: MusicTrack? {
        return currentPlayer?.currentTrack
    }
    
    public var playbackState: PlaybackState {
        return currentPlayer?.playbackState ?? .stopped
    }
    
    public var playbackTime: TimeInterval {
        get { return currentPlayer?.playbackTime ?? 0 }
        set { currentPlayer?.playbackTime = newValue }
    }
    
    public var currentTrackWillChange: AnyPublisher<MusicTrack?, Never> {
        return $currentPlayer.map { $0?.currentTrackWillChange ?? Just(nil).eraseToAnyPublisher() }
            .switchToLatest()
            .eraseToAnyPublisher()
    }
    
    public var playbackStateWillChange: AnyPublisher<PlaybackState, Never> {
        return $currentPlayer.map { $0?.playbackStateWillChange ?? Just(.stopped).eraseToAnyPublisher() }
        .switchToLatest()
        .eraseToAnyPublisher()
    }
    
    public func resume() {
        currentPlayer?.resume()
    }
    
    public func pause() {
        currentPlayer?.pause()
    }
    
    public func playPause() {
        currentPlayer?.playPause()
    }
    
    public func skipToNextItem() {
        currentPlayer?.skipToNextItem()
    }
    
    public func skipToPreviousItem() {
        currentPlayer?.skipToPreviousItem()
    }
    
    public func updatePlayerState() {
        currentPlayer?.updatePlayerState()
    }
}
