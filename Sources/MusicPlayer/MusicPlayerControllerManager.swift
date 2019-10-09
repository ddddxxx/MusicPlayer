//
//  MusicPlayerControllerManager.swift
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

public final class MusicPlayerControllerManager {

    public let players: [MusicPlayerController]
    
    public private(set) var player: MusicPlayerController? {
        didSet {
            defaultNC.post(name: MusicPlayerControllerManager.currentPlayerDidChangeNotification, object: self)
            defaultNC.post(name: MusicPlayerController.currentTrackDidChangeNotification, object: self)
            defaultNC.post(name: MusicPlayerController.playbackStateDidChangeNotification, object: self)
        }
    }
    
    public var manualUpdateInterval: TimeInterval = 1.0 {
        didSet {
            scheduleManualUpdate()
        }
    }
    
    public var preferredPlayerName: MusicPlayerName? {
        didSet {
            guard oldValue != preferredPlayerName else { return }
            selectNewPlayer()
        }
    }
    
    var cancelBag = Set<AnyCancellable>()

    public init(players: [MusicPlayerController]) {
        self.players = players
        selectNewPlayer()
        defaultNC.cx.publisher(for: MusicPlayerController.playbackStateDidChangeNotification)
            .filter { n in players.contains { $0 === (n.object as AnyObject?) } }
            .throttle(for: .seconds(0.1), scheduler: DispatchQueue.global().cx, latest: true)
            .sink { [unowned self] _ in
                self.selectNewPlayer()
            }.store(in: &cancelBag)
        defaultNC.cx.publisher(for: MusicPlayerController.playbackStateDidChangeNotification)
            .filter { [unowned self] n in self.player === (n.object as AnyObject?) }
            .sink {
                defaultNC.post(name: $0.name, object: self)
            }.store(in: &cancelBag)
        defaultNC.cx.publisher(for: MusicPlayerController.playbackStateDidChangeNotification)
            .filter { [unowned self] n in self.player === (n.object as AnyObject?) }
            .sink {
                defaultNC.post(name: $0.name, object: self)
            }.store(in: &cancelBag)
        scheduleManualUpdate()
    }
    
    #if os(macOS)
    
    public convenience init() {
        let players = MusicPlayerName.allCases.compactMap { $0.cls.init() }
        self.init(players: players)
    }
    
    #endif
    
    private var scheduleCanceller: Cancellable?
    func scheduleManualUpdate() {
        scheduleCanceller?.cancel()
        let q = DispatchQueue.global().cx
        let i = manualUpdateInterval
        scheduleCanceller = q.schedule(after: q.now.advanced(by: .seconds(i)), interval: .seconds(i), tolerance: .seconds(i * 0.1), options: nil) { [unowned self] in
            self.player?.updatePlaybackTime?()
        }
    }
    
    func selectNewPlayer() {
        var newPlayer: MusicPlayerController?
        if let name = preferredPlayerName {
            newPlayer = players.first { type(of: $0).name == name }
        } else if player?.playbackState.isPlaying == true {
            newPlayer = player
        } else if let playing = players.first(where: { $0.playbackState.isPlaying }) {
            newPlayer = playing
        } else {
            #if os(macOS)
            if player?.isRunning == true {
                newPlayer = player
            } else {
                newPlayer = players.first { $0.isRunning }
            }
            #elseif os(iOS)
            let defaultPlayerName = MusicPlayerName.appleMusic
            newPlayer = player ?? players.first { type(of: $0).name == defaultPlayerName }
            #endif
        }
        
        if newPlayer !== player {
            player = newPlayer
        }
    }
}
