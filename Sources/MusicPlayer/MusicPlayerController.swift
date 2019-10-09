//
//  MusicPlayerController.swift
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

#if os(macOS)
import AppKit
import ScriptingBridge
#endif

public class MusicPlayerController {
    
    public class var name: MusicPlayerName { fatalError() }
    
    #if os(macOS)
    
    public let originalPlayer: SBApplication
    
    public let playerBundleID: String
    
    public var isRunning: Bool {
        didSet {
            defaultNC.post(name: MusicPlayerController.runningStateDidChangeNotification, object: self)
        }
    }
    
    var cancelBag = Set<AnyCancellable>()
    
    required public init?() {
        for bundleID in Self.name.candidateBundleID {
            if let app = SBApplication(bundleIdentifier: bundleID) {
                playerBundleID = bundleID
                originalPlayer = app
                isRunning = app.isRunning
                
                workspaceNC.cx.publisher(for: NSWorkspace.didLaunchApplicationNotification)
                    .compactMap { $0.userInfo?["NSApplicationBundleIdentifier"] as? String }
                    .filter { $0 == bundleID }
                    .sink { [unowned self] _ in
                        self.isRunning = true
                    }.store(in: &cancelBag)
                workspaceNC.cx.publisher(for: NSWorkspace.didTerminateApplicationNotification)
                    .compactMap { $0.userInfo?["NSApplicationBundleIdentifier"] as? String }
                    .filter { $0 == bundleID }
                    .sink { [unowned self] _ in
                        self.isRunning = false
                    }.store(in: &cancelBag)
                return
            }
        }
        return nil
    }
    
    #endif
    
    // not settable outside the class
    public var currentTrack: MusicTrack? = nil {
        didSet {
            defaultNC.post(name: MusicPlayerController.currentTrackDidChangeNotification, object: self)
        }
    }
    
    public var playbackState: PlaybackState = .stopped {
        didSet {
            defaultNC.post(name: MusicPlayerController.playbackStateDidChangeNotification, object: self)
        }
    }
    
    public var playbackTime: TimeInterval {
        get { fatalError() }
        set { fatalError() }
    }
    
    public func resume() {}
    public func pause() {}
    public func playPause() {}
    
    public func skipToNextItem() {}
    public func skipToPreviousItem() {}
}

protocol PlaybackTimeUpdating {
    func updatePlaybackTime()
}

extension MusicPlayerController {
    
    static let playbackTimeMutateThreshold = 1.5
    
    func setPlaybackState(_ state: PlaybackState, tolerate: TimeInterval = MusicPlayerController.playbackTimeMutateThreshold) {
        func setWithDiff(_ diff: TimeInterval) {
            if diff.magnitude > tolerate {
                playbackState = state
            }
        }
        switch (playbackState, state) {
        case (.stopped, .stopped): break
        case let (.playing(d1), .playing(d2)): setWithDiff(d1.timeIntervalSince(d2))
        case let (.paused(d1), .paused(d2)): setWithDiff(d1 - d2)
        case let (.fastForwarding(d1), .fastForwarding(d2)): setWithDiff(d1 - d2)
        case let (.rewinding(d1), .rewinding(d2)): setWithDiff(d1 - d2)
        case _: playbackState = state
        }
    }
}
