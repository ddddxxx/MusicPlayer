//
//  MPRISNowPlaying.swift
//  LyricsX - https://github.com/ddddxxx/LyricsX
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

#if os(Linux)

import playerctl

extension MusicPlayers {
    
    public final class MPRISNowPlaying: NowPlaying {
        
        private let manager: UnsafeMutablePointer<PlayerctlPlayerManager>
        private var signals: [gulong] = []
        
        public init?() {
            guard let manager = playerctl_player_manager_new(nil) else {
                return nil
            }
            self.manager = manager
            
            var players: [MusicPlayerProtocol] = []
            let playerNames: UnsafeMutablePointer<GList>? = playerctl_list_players(nil)
            var cur = playerNames
            while (cur != nil) {
                let playerName = cur!.pointee.data.assumingMemoryBound(to: PlayerctlPlayerName.self)
                let name = String(cString: playerName.pointee.name)
                let player = playerctl_player_new_from_name(playerName, nil)
                playerctl_player_name_free(playerName)
                if player == nil {
                    continue
                }
                playerctl_player_manager_manage_player(manager, player)
                players.append(MPRIS(player: player!, name: name))
                cur = cur!.pointee.next
            }
            g_list_free(playerNames)
            
            super.init(players: players)
            
            let onNameAppeared: @convention(c) (UnsafeMutablePointer<PlayerctlPlayerManager>?,
                                                UnsafeMutablePointer<PlayerctlPlayerName>?,
                                                UnsafeMutableRawPointer?) -> Void
                = { manager, name, data in
                    let `self`: MPRISNowPlaying = Unmanaged.fromOpaque(data!).takeUnretainedValue()
                    if let player = playerctl_player_new_from_name(name, nil) {
                        playerctl_player_manager_manage_player(`self`.manager, player)
                        `self`.players.append(MPRIS(player: player, name: String(cString: name!.pointee.name)))
                    }
                }
            
            let onPlayerVanished: @convention(c) (UnsafeMutablePointer<PlayerctlPlayerManager>?,
                                                  UnsafeMutablePointer<PlayerctlPlayer>?,
                                                  UnsafeMutableRawPointer?) -> Void
                = { manager, player, data in
                    if player == nil {
                        return
                    }
                    data?.unretainedCast(to: MPRISNowPlaying.self).players.removeAll { ($0 as? MPRIS)?.player == player }
                }
            
            let pself = Unmanaged.passUnretained(self).toOpaque()
            signals.append(
                g_signal_connect_data(manager, "name-appeared", unsafeBitCast(onNameAppeared, to: GCallback?.self), pself, nil, G_CONNECT_AFTER)
            )
            signals.append(
                g_signal_connect_data(manager, "player-vanished", unsafeBitCast(onPlayerVanished, to: GCallback?.self), pself, nil, G_CONNECT_AFTER)
            )
        }
        
        deinit {
            for var signal in signals {
                g_clear_signal_handler(&signal, manager)
            }
            g_object_unref(manager)
        }
    }
}

#endif
