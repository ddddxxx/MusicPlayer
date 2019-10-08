//
//  Global.swift
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

public typealias Published = CXShim.Published

#if os(macOS)

import AppKit

let distributedNC = DistributedNotificationCenter.default()
let workspaceNC = NSWorkspace.shared.notificationCenter

extension Notification.Name {
    static let iTunesPlayerInfo = Notification.Name("com.apple.iTunes.playerInfo")
    
    static let spotifyPlayerInfo = Notification.Name("com.spotify.client.PlaybackStateChanged")
    
    static let voxTrackChanged = Notification.Name("com.coppertino.Vox.trackChanged")
    
    static let audirvanaPlayerInfo = Notification.Name("com.audirvana.audirvana-plus.playerStatus")
    static let audirvanaPlayerPosition = Notification.Name("com.audirvana.audirvana-plus.playerPosition")
    
    static let swinsianPlaying = Notification.Name("com.swinsian.Swinsian-Track-Playing")
    static let swinsianPaused = Notification.Name("com.swinsian.Swinsian-Track-Paused")
    static let swinsianStopped = Notification.Name("com.swinsian.Swinsian-Track-Stopped")
}

#endif
