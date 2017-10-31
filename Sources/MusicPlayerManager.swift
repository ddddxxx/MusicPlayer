//
//  MusicPlayerManager.swift
//
//  This file is part of LyricsX
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

public protocol MusicPlayerManagerDelegate: class {
    
    func runningStateChanged(isRunning: Bool)
    func currentPlayerChanged(player: MusicPlayer?)
    func currentTrackChanged(track: MusicTrack?)
    func playbackStateChanged(state: MusicPlaybackState)
    func playerPositionMutated(position: TimeInterval)
}

public class MusicPlayerManager: MusicPlayerDelegate {
    
    public weak var delegate: MusicPlayerManagerDelegate?
    
    public private(set) var players: [MusicPlayer]
    public private(set) weak var player: MusicPlayer?
    
    public var preferredPlayerName: MusicPlayerName? {
        didSet {
            guard oldValue != preferredPlayerName else { return }
            _ = selectNewPlayer()
        }
    }
    
    private var _timer: Timer!
    
    public init() {
        players = MusicPlayerName.all.flatMap { $0.cls.init() }
        players.forEach { $0.delegate = self }
        _ = selectNewPlayer()
        _timer = Timer.scheduledTimer(timeInterval: manualUpdateInterval, target: self, selector: #selector(update), userInfo: nil, repeats: true)
    }
    
    @objc func update() {
        // TODO: running state change delegate
        for p in players {
            if type(of: p).needsUpdate || p === player {
                p.updatePlayerState()
            }
        }
    }
    
    func selectNewPlayer() -> Bool {
        var newPlayer: MusicPlayer?
        if let name = preferredPlayerName {
            newPlayer = players.first { type(of: $0) == name.cls }
        } else if let playing = players.first(where: { $0.playbackState == .playing }) {
            newPlayer = playing
        } else if player?.isRunning == true {
            newPlayer = player
        } else {
            newPlayer = players.first { $0.isRunning }
        }
        if newPlayer !== player {
            player = newPlayer
            delegate?.currentPlayerChanged(player: player)
            return true
        } else {
            return false
        }
    }
    
    // MARK: - MusicPlayerDelegate
    
    public func currentTrackChanged(track: MusicTrack?, from player: MusicPlayer) {
        guard self.player === player else {
            return
        }
        delegate?.currentTrackChanged(track: track)
    }
    
    public func playbackStateChanged(state: MusicPlaybackState, from player: MusicPlayer) {
        guard self.player === player else {
            if self.player?.playbackState.isPlaying != true, state == .playing {
                self.player = player
                delegate?.currentPlayerChanged(player: player)
            }
            return
        }
        if !selectNewPlayer() {
            delegate?.playbackStateChanged(state: state)
        }
    }
    
    public func playerPositionMutated(position: TimeInterval, from player: MusicPlayer) {
        guard self.player === player else {
            return
        }
        delegate?.playerPositionMutated(position: position)
    }
}
