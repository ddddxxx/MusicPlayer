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
    
    public static let shared = MusicPlayerManager()
    
    public var delegate: MusicPlayerManagerDelegate?
    
    public private(set) var players: [MusicPlayer]
    public private(set) weak var player: MusicPlayer?
    
    public var preferredPlayerName: MusicPlayerName? {
        didSet {
            guard oldValue != preferredPlayerName else { return }
            let newPlayer: MusicPlayer?
            if let name = preferredPlayerName {
                newPlayer = players.first { type(of: $0) == name.cls }
            } else {
                newPlayer = players.first { $0.playbackState == .playing }
            }
            if newPlayer !== player {
                player = newPlayer
                delegate?.currentPlayerChanged(player: player)
            }
        }
    }
    
    private var _timer: Timer!
    
    private init() {
        players = MusicPlayerName.all.flatMap { $0.cls.init() }
        players.forEach { $0.delegate = self }
        player = players.first { $0.playbackState == .playing }
        _timer = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(update), userInfo: nil, repeats: true)
    }
    
    @objc func update() {
        // TODO: running state change delegate
        if player?.playbackState.isPlaying == true {
            player?.updatePlayerState()
        } else {
            players.filter { type(of: $0).needsUpdate }.forEach { $0.updatePlayerState() }
        }
    }
    
    // MARK: - MusicPlayerDelegate
    
    public func currentTrackChanged(track: MusicTrack?, from player: MusicPlayer) {
        if self.player === player {
            delegate?.currentTrackChanged(track: track)
        }
    }
    
    public func playbackStateChanged(state: MusicPlaybackState, from player: MusicPlayer) {
        if self.player === player {
            delegate?.playbackStateChanged(state: state)
            return
        }
        if self.player?.playbackState.isPlaying != true, state == .playing {
            self.player = player
            delegate?.currentPlayerChanged(player: player)
        }
    }
    
    public func playerPositionMutated(position: TimeInterval, from player: MusicPlayer) {
        if self.player === player {
            delegate?.playerPositionMutated(position: position)
        }
    }
}
