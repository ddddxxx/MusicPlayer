//
//  MPRIS.swift
//  LyricsX - https://github.com/ddddxxx/LyricsX
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import CXShim
import DBus
import Foundation
import MPRIS

extension MusicPlayers {
    /// Represents a [MPRIS](https://specifications.freedesktop.org/mpris-spec/latest/) music player.
    public final class MPRIS: ObservableObject {
        private let player: MediaPlayer2
        private var disposables: [() throws -> Void] = []
        @Published public private(set) var currentTrack: MusicTrack?
        @Published public private(set) var playbackState: PlaybackState = .stopped

        init(player: MediaPlayer2) throws {
            self.player = player
            let updatePlayerState: () -> Void = { [weak self] in self?.updatePlayerState() }
            disposables.append(try player.player.playbackStatus.observe(updatePlayerState))
            disposables.append(try player.player.metadata.observe(updatePlayerState))
            disposables.append(try player.player.seeked { _ in updatePlayerState() })
            updatePlayerState()
        }

        deinit {
            disposables.forEach { try? $0() }
        }
    }
}

extension MusicPlayers.MPRIS {
    /// Initializes a new MPRIS music player.
    ///
    /// - Parameters:
    ///   - name: The name of the media player.
    ///   - instance: The instance name of the media player, if any.
    ///   - queue: The dispatch queue for the D-Bus method calls.
    public convenience init(
        name: String, instance: String? = nil, queue: DispatchQueue? = nil
    ) throws {
        let connection = try Connection(type: .session, private: true)
        try connection.setupDispatch(with: queue ?? .playerUpdate)
        try self.init(name: name, instance: instance, connection: connection)
    }

    /// Initializes a new MPRIS music player.
    ///
    /// - Parameters:
    ///   - name: The name of the media player.
    ///   - instance: The instance name of the media player, if any.
    ///   - connection: The connection to the D-Bus.
    ///   - timeout: The timeout interval for the D-Bus method calls.
    public convenience init(
        name: String, instance: String? = nil,
        connection: Connection, timeout: TimeoutInterval = .useDefault
    ) throws {
        let player = MediaPlayer2(
            connection: connection, name: name, instance: instance, timeout: timeout)
        try self.init(player: player)
    }
}

extension MusicPlayers.MPRIS: MusicPlayerProtocol {
    public var name: MusicPlayerName? { nil }

    public var currentTrackWillChange: AnyPublisher<MusicTrack?, Never> {
        $currentTrack.eraseToAnyPublisher()
    }

    public var playbackStateWillChange: AnyPublisher<PlaybackState, Never> {
        $playbackState.eraseToAnyPublisher()
    }

    public var playbackTime: TimeInterval {
        get {
            (try? player.player.position.get()).map { Double($0) / 1_000_000 } ?? 0
        }
        set {
            if let trackId = self.track?.id {
                let trackId = TrackId(rawValue: trackId)
                let newValue = Int64(newValue * 1_000_000)
                try? player.player.setPosition(trackId: trackId, position: newValue)
            }
        }
    }

    public func resume() {
        try? player.player.play()
    }

    public func pause() {
        try? player.player.pause()
    }

    public func playPause() {
        try? player.player.playPause()
    }

    public func skipToNextItem() {
        try? player.player.next()
    }

    public func skipToPreviousItem() {
        try? player.player.previous()
    }

    public func updatePlayerState() {
        let state = self.state
        let track = self.track
        if currentTrack?.id != track?.id {
            currentTrack = track
            playbackState = state
        } else if !playbackState.approximateEqual(to: state) {
            playbackState = state
        }
    }

    private var state: PlaybackState {
        let playbackStatus = try? player.player.playbackStatus.get()
        switch playbackStatus {
        case .playing:
            return .playing(time: playbackTime)
        case .paused:
            return .paused(time: playbackTime)
        case .stopped:
            return .stopped
        default:
            return .stopped
        }
    }

    private var track: MusicTrack? {
        guard let metadata = try? player.player.metadata.get() else {
            return nil
        }
        return MusicTrack(
            id: metadata.trackId.rawValue,
            title: metadata.title,
            album: metadata.album,
            artist: metadata.artist?.first,
            duration: metadata.length.map { Double($0) / 1_000_000 },
            fileURL: metadata.url.flatMap { URL(string: $0) },
            originalTrack: metadata as AnyObject)
    }
}
