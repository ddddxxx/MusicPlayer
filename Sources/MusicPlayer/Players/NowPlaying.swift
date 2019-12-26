//
//  NowPlayingPlayer.swift
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
import CXShim

extension MusicPlayers {
    
    public final class NowPlaying: ObservableObject {
        
        public let players: [MusicPlayerProtocol]
        
        @Published public private(set) var currentPlayer: MusicPlayerProtocol?
        
        public var manualUpdateInterval: TimeInterval = 1.0 {
            didSet {
                scheduleManualUpdate()
            }
        }
        
        var cancelBag = Set<AnyCancellable>()

        public init(players: [MusicPlayerProtocol]) {
            self.players = players
            selectNewPlayer()
            scheduleManualUpdate()
            currentTrackWillChange.sink { [weak self] _ in
                self?.objectWillChange.send()
            }.store(in: &cancelBag)
            playbackStateWillChange.sink { [weak self] _ in
                self?.objectWillChange.send()
            }.store(in: &cancelBag)
        }
        
        #if os(macOS)
        
        public convenience init() {
            let players = MusicPlayerName.scriptingPlayerNames.compactMap(MusicPlayers.ScriptingBridged.init)
            self.init(players: players)
        }
        
        #endif
        
        private var scheduleCanceller: Cancellable?
        func scheduleManualUpdate() {
            scheduleCanceller?.cancel()
            let q = DispatchQueue.global().cx
            let i: CXWrappers.DispatchQueue.SchedulerTimeType.Stride = .seconds(manualUpdateInterval)
            scheduleCanceller = q.schedule(after: q.now.advanced(by: i), interval: i, tolerance: i * 0.1, options: nil) { [unowned self] in
                // TODO: disable timer if the player does not conforms to PlaybackTimeUpdating
                (self.currentPlayer as? PlaybackTimeUpdating)?.updatePlaybackTime()
            }
        }
        
        func selectNewPlayer() {
            var newPlayer: MusicPlayerProtocol?
            if currentPlayer?.playbackState.isPlaying == true {
                newPlayer = currentPlayer
            } else if let playing = players.first(where: { $0.playbackState.isPlaying }) {
                newPlayer = playing
            } else if let running = players.first(where: { $0.playbackState == .stopped }) {
                newPlayer = running
            }
            if newPlayer !== currentPlayer {
                currentPlayer = newPlayer
            }
        }
    }
}

extension MusicPlayers.NowPlaying: MusicPlayerProtocol {
    
    public var name: MusicPlayerName {
        return .nowPlaying
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
}
