//
//  Global.swift
//
//  This file is part of LyricsX - https://github.com/ddddxxx/LyricsX
//  Copyright (C) 2017  Xander Deng. Licensed under GPLv3.
//

import Foundation
import CXShim

public typealias Published = CXShim.Published

let defaultNC = NotificationCenter.default

public extension MusicPlayers {
    static let currentTrackDidChangeNotification = Notification.Name("ddddxxx.LyricsX.currentTrackDidChange")
    static let playbackStateDidChangeNotification = Notification.Name("ddddxxx.LyricsX.playbackStateDidChange")
    static let currentPlayerDidChangeNotification = Notification.Name("ddddxxx.LyricsX.currentPlayerDidChange")
}

#if os(macOS)

import AppKit

let distributedNC = DistributedNotificationCenter.default()
let workspaceNC = NSWorkspace.shared.notificationCenter

#endif
