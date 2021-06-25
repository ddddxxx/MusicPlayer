//
//  MPRIS.swift
//  LyricsX - https://github.com/ddddxxx/LyricsX
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

#if os(Linux)

import Foundation
import CXShim
import playerctl

extension UnsafeMutableRawPointer {
    
    func unretainedCast<T: AnyObject>(to: T.Type) -> T {
        Unmanaged.fromOpaque(self).takeUnretainedValue()
    }
}

extension MusicPlayers {
    
    public final class MPRIS: ObservableObject {
        
        let player: UnsafeMutablePointer<PlayerctlPlayer>
        
        public var name: MusicPlayerName? = MusicPlayerName.mpris
        
        @Published public private(set) var currentTrack: MusicTrack?
        @Published public private(set) var playbackState: PlaybackState = .stopped
        
        private var signals: [gulong] = []
        
        public private(set) lazy var playerName: String? = gproperty(player, name: "player-name") { val in
            g_value_get_pointer(val).map { name in
                String(cString: name.assumingMemoryBound(to: CChar.self))
            }
        }
        
        public convenience init?(name: String) {
            guard let player = playerctl_player_new(name, nil) else {
                return nil
            }
            self.init(player: player)
            self.playerName = name
        }
        
        public convenience init?(name: UnsafeMutablePointer<PlayerctlPlayerName>) {
            guard let player = playerctl_player_new_from_name(name, nil) else {
                return nil
            }
            self.init(player: player)
        }
        
        init(player: UnsafeMutablePointer<PlayerctlPlayer>) {
            self.player = player
            
            let onPlayStatusChanged: @convention(c) (UnsafeMutablePointer<PlayerctlPlayer>?,
                                                     gint /* PlayerctlPlaybackStatus */,
                                                     UnsafeMutableRawPointer?) -> Void
                = { player, status, data in
                    data?.unretainedCast(to: MPRIS.self).updatePlayerState()
                }
            
            let onSeeked: @convention(c) (UnsafeMutablePointer<PlayerctlPlayer>?,
                                          gint64,
                                          UnsafeMutableRawPointer?) -> Void
                = { player, position, data in
                    data?.unretainedCast(to: MPRIS.self).updatePlayerState()
                }
            
            let onMetadataChanged: @convention(c) (UnsafeMutablePointer<PlayerctlPlayer>?,
                                                   OpaquePointer? /* GVariant* */,
                                                   UnsafeMutableRawPointer?) -> Void
                = { player, metadata, data in
                    data?.unretainedCast(to: MPRIS.self).updatePlayerState()
                }
            
            let pself = Unmanaged.passUnretained(self).toOpaque()
            signals.append(
                g_signal_connect_data(player, "playback-status",
                                      unsafeBitCast(onPlayStatusChanged, to: GCallback?.self), pself, nil, G_CONNECT_AFTER)
            )
            signals.append(
                g_signal_connect_data(player, "seeked", unsafeBitCast(onSeeked, to: GCallback?.self), pself, nil, G_CONNECT_AFTER)
            )
            signals.append(
                g_signal_connect_data(player, "metadata", unsafeBitCast(onMetadataChanged, to: GCallback?.self), pself, nil, G_CONNECT_AFTER)
            )
            updatePlayerState()
        }
        
        deinit {
            for var signal in signals {
                g_clear_signal_handler(&signal, player)
            }
            g_object_unref(player)
        }
    }
}

extension MusicPlayers.MPRIS {
    
    public class var names: [UnsafeMutablePointer<PlayerctlPlayerName>] {
        let playerNames = playerctl_list_players(nil)
        var result: [UnsafeMutablePointer<PlayerctlPlayerName>] = []
        var cur = playerNames
        while cur != nil {
            result.append(cur!.pointee.data.assumingMemoryBound(to: PlayerctlPlayerName.self))
            cur = cur!.pointee.next
        }
        g_list_free(playerNames)
        return result
    }
}

extension MusicPlayers.MPRIS: MusicPlayerProtocol {
    
    public var currentTrackWillChange: AnyPublisher<MusicTrack?, Never> {
        $currentTrack.eraseToAnyPublisher()
    }
    
    public var playbackStateWillChange: AnyPublisher<PlaybackState, Never> {
        $playbackState.eraseToAnyPublisher()
    }
    
    public var playbackTime: TimeInterval {
        get {
            Double(playerctl_player_get_position(player, nil)) / 1_000_000
        }
        set {
            playerctl_player_set_position(player, Int(newValue * 1_000_000), nil)
        }
    }
    
    public func resume() {
        playerctl_player_play(player, nil)
    }
    
    public func pause() {
        playerctl_player_pause(player, nil)
    }
    
    public func playPause() {
        playerctl_player_play_pause(player, nil)
    }
    
    public func skipToNextItem() {
        playerctl_player_next(player, nil)
    }
    
    public func skipToPreviousItem() {
        playerctl_player_previous(player, nil)
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
        gproperty(player, name: "playback-status") { val in
            switch PlayerctlPlaybackStatus(UInt32(g_value_get_enum(val))) {
            case PLAYERCTL_PLAYBACK_STATUS_PLAYING:
                return .playing(time: playbackTime)
            case PLAYERCTL_PLAYBACK_STATUS_PAUSED:
                return .paused(time: playbackTime)
            case PLAYERCTL_PLAYBACK_STATUS_STOPPED:
                return .stopped
            default:
                return .stopped
            }
        }
    }
    
    private var track: MusicTrack? {
        guard let metadata = (gproperty(player, name: "metadata") { g_value_get_variant($0) }) else {
            return nil
        }
        
        let metadataString: (String) -> String? = { key in
            g_variant_lookup_value(metadata, key, nil).map { g_variant_get_string($0, nil) }.map { String(cString: $0) }
        }
        
        guard let id = metadataString("mpris:trackid") else {
            return nil
        }
        let title = playerctl_player_get_title(player, nil).map { String(cString: $0) }
        let album = playerctl_player_get_album(player, nil).map { String(cString: $0) }
        let artist = playerctl_player_get_artist(player, nil).map { String(cString: $0) }
        let length = g_variant_lookup_value(metadata, "mpris:length", nil).map { g_variant_get_int64($0) } ?? 0
        let duration = Double(length) / 1_000_000
        return MusicTrack(id: id, title: title, album: album, artist: artist, duration: duration,
                          fileURL: metadataString("xesam:url").flatMap { URL(string: $0) },
                          artwork: metadataString("mpris:artUrl").flatMap { URL(string: $0) })
    }
}

#endif
