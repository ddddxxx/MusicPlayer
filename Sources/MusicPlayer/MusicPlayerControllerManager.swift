//
//  MusicPlayerControllerManager.swift
//
//  This file is part of LyricsX - https://github.com/ddddxxx/LyricsX
//  Copyright (C) 2017  Xander Deng. Licensed under GPLv3.
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
        defaultNC.cx.publisher(for: MusicPlayerController.currentTrackDidChangeNotification)
            .filter { [unowned self] n in self.player === (n.object as AnyObject?) }
            .sink {
                defaultNC.post(name: $0.name, object: self)
            }.store(in: &cancelBag)
        defaultNC.cx.publisher(for: MusicPlayerController.runningStateDidChangeNotification)
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
        let i: CXWrappers.DispatchQueue.SchedulerTimeType.Stride = .seconds(manualUpdateInterval)
        scheduleCanceller = q.schedule(after: q.now.advanced(by: i), interval: i, tolerance: i * 0.1, options: nil) { [unowned self] in
            // TODO: disable timer if the player does not conforms to PlaybackTimeUpdating
            (self.player as? PlaybackTimeUpdating)?.updatePlaybackTime()
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
