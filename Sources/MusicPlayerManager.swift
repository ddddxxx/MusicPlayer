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

class MusicPlayerManager {
    
    public static let shared = MusicPlayerManager()
    
    public weak var delegate: MusicPlayerManagerDelegate?
    
    public private(set) var players: [MusicPlayer]
    public private(set) weak var player: MusicPlayer?
    
    public var preferredPlayerName: MusicPlayerName? {
        didSet {
            guard let name = preferredPlayerName,
                oldValue != name else {
                    return
            }
            player = players.first { type(of: $0) == name.cls }
            delegate?.currentPlayerChanged(player: player)
        }
    }
    
    private var _timer: Timer!
    
    private init() {
        players = MusicPlayerName.all.flatMap { $0.cls.init() }
        _timer = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(update), userInfo: nil, repeats: true)
    }
    
    @objc func update() {
        player?.updatePlayerState()
    }
    
    func updateSelectedPlayer() {
        guard preferredPlayerName == nil else { return }
    }

}
