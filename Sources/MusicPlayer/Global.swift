//
//  Global.swift
//
//  This file is part of LyricsX - https://github.com/ddddxxx/LyricsX
//  Copyright (C) 2017  Xander Deng. Licensed under GPLv3.
//

import Foundation
import CXShim

#if os(macOS)

import AppKit

let defaultNC = NotificationCenter.default
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

public extension MusicPlayerController {
    static let currentTrackDidChangeNotification = Notification.Name("ddddxxx.LyricsX.currentTrackDidChange")
    static let playbackStateDidChangeNotification = Notification.Name("ddddxxx.LyricsX.playbackStateDidChange")
    static let runningStateDidChangeNotification = Notification.Name("ddddxxx.LyricsX.runningStateDidChange")
}

public extension MusicPlayerControllerManager {
    static let currentPlayerDidChangeNotification = Notification.Name("ddddxxx.LyricsX.currentPlayerDidChange")
}

#endif
