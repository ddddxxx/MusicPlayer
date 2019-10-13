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
    
    public final class NowPlaying {
        
        public let players: [MusicPlayerProtocol]
        
        public private(set) var player: MusicPlayerProtocol? {
            didSet {
                defaultNC.post(name: MusicPlayers.currentPlayerDidChangeNotification, object: self)
                defaultNC.post(name: MusicPlayers.currentTrackDidChangeNotification, object: self)
                defaultNC.post(name: MusicPlayers.playbackStateDidChangeNotification, object: self)
            }
        }
        
        public var manualUpdateInterval: TimeInterval = 1.0 {
            didSet {
                scheduleManualUpdate()
            }
        }
        
        var cancelBag = Set<AnyCancellable>()

        public init(players: [MusicPlayerProtocol]) {
            self.players = players
            selectNewPlayer()
            defaultNC.cx.publisher(for: MusicPlayers.playbackStateDidChangeNotification)
                .filter { n in players.contains { $0 === (n.object as AnyObject?) } }
                .sink { [unowned self] n in
                    self.selectNewPlayer()
                    if self.player === (n.object as AnyObject?) {
                        defaultNC.post(name: n.name, object: self)
                    }
                }.store(in: &cancelBag)
            defaultNC.cx.publisher(for: MusicPlayers.currentTrackDidChangeNotification)
                .sink { [unowned self] n in
                    if self.player === (n.object as AnyObject?) {
                        defaultNC.post(name: n.name, object: self)
                    }
                }.store(in: &cancelBag)
            scheduleManualUpdate()
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
            let i: DispatchQueue.DispatchQueueCXWrapper.SchedulerTimeType.Stride = .seconds(manualUpdateInterval)
            scheduleCanceller = q.schedule(after: q.now.advanced(by: i), interval: i, tolerance: i * 0.1, options: nil) { [unowned self] in
                // TODO: disable timer if the player does not conforms to PlaybackTimeUpdating
                (self.player as? PlaybackTimeUpdating)?.updatePlaybackTime()
            }
        }
        
        func selectNewPlayer() {
            var newPlayer: MusicPlayerProtocol?
            if player?.playbackState.isPlaying == true {
                newPlayer = player
            } else if let playing = players.first(where: { $0.playbackState.isPlaying }) {
                newPlayer = playing
            } else if let running = players.first(where: { $0.playbackState == .stopped }) {
                newPlayer = running
            }
            if newPlayer !== player {
                player = newPlayer
            }
        }
    }
}

extension MusicPlayers.NowPlaying: MusicPlayerProtocol {
    
    public var name: MusicPlayerName {
        return .nowPlaying
    }
    
    public var currentTrack: MusicTrack? {
        return player?.currentTrack
    }
    
    public var playbackState: PlaybackState {
        return player?.playbackState ?? .stopped
    }
    
    public var playbackTime: TimeInterval {
        get { return player?.playbackTime ?? 0 }
        set { player?.playbackTime = newValue }
    }
    
    public func resume() {
        player?.resume()
    }
    
    public func pause() {
        player?.pause()
    }
    
    public func playPause() {
        player?.playPause()
    }
    
    public func skipToNextItem() {
        player?.skipToNextItem()
    }
    
    public func skipToPreviousItem() {
        player?.skipToPreviousItem()
    }
}
