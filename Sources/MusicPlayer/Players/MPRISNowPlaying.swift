//
//  MPRISNowPlaying.swift
//  LyricsX - https://github.com/ddddxxx/LyricsX
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import DBus
import Foundation
import MPRIS

extension MusicPlayers {
    /// Just like `NowPlaying`, but automatically find available MPRIS players.
    public final class MPRISNowPlaying: Agent {
        private let sessionManager: MediaPlayer2.SessionManager
        private var disposables: [() -> Void] = []

        init(sessionManager: MediaPlayer2.SessionManager) throws {
            self.sessionManager = sessionManager
            super.init()
            if let player = sessionManager.activePlayer {
                designatedPlayer = try MPRIS(player: player)
            }
            let stopObserve = sessionManager.observeActivePlayer { [weak self] player in
                guard let self = self else { return }
                self.designatedPlayer = player.flatMap { try? MPRIS(player: $0) }
            }
            disposables.append(stopObserve)
        }

        deinit {
            disposables.forEach { $0() }
        }
    }
}

extension MusicPlayers.MPRISNowPlaying {
    /// Initializes a new MPRIS now playing player.
    ///
    /// - Parameters:
    ///   - queue: The dispatch queue for the D-Bus method calls.
    public convenience init(queue: DispatchQueue? = nil) throws {
        let connection = try Connection(type: .session, private: true)
        try connection.setupDispatch(with: queue ?? .playerUpdate)
        try self.init(connection: connection)
    }

    /// Initializes a new MPRIS now playing player.
    ///
    /// - Parameters:
    ///   - connection: The connection to the D-Bus.
    ///   - timeout: The timeout interval for the D-Bus method calls.
    public convenience init(connection: Connection, timeout: TimeoutInterval = .useDefault) throws {
        let sessionManager = try MediaPlayer2.SessionManager(
            connection: connection, timeout: timeout)
        try self.init(sessionManager: sessionManager)
    }
}
