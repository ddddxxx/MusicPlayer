//
//  iTunes.swift
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

import AppKit
import ScriptingBridge

public final class iTunes {
    
    public weak var delegate: MusicPlayerDelegate?
    
    private var _iTunes: iTunesApplication
    private var _currentTrack: MusicTrack?
    private var _playbackState: MusicPlaybackState = .stopped
    private var _startTime: Date?
    private var _pausePosition: Double?
    
    private var observer: NSObjectProtocol?
    
    public init?() {
        guard let iTunes = SBApplication(bundleIdentifier: iTunes.name.bundleID) else {
            return nil
        }
        _iTunes = iTunes
        if isRunning {
            _playbackState = _iTunes._playbackState
            _currentTrack = _iTunes._currentTrack
            _startTime = _iTunes._startTime
        }
        
        observer = DistributedNotificationCenter.default.addObserver(forName: .iTunesPlayerInfo, object: nil, queue: nil) { [unowned self] n in self.playerInfoNotification(n) }
    }
    
    deinit {
        observer.map(DistributedNotificationCenter.default.removeObserver)
    }
    
    func playerInfoNotification(_ n: Notification) {
        guard isRunning else { return }
        // iTunes will send notification before quit. if we send
        // apple event here, iTunes will be restarted immediately
        let id = (n.userInfo?["PersistentID"] as? Int).map { String(format: "%08X", arguments: [UInt(bitPattern: $0)]) }
        let state: MusicPlaybackState
        switch n.userInfo?["Player State"] as? String {
        case "Playing"?: state = .playing
        case "Paused"?:  state = .paused
        case "Stopped"?, _: state = .stopped
        }
        // Int64 hex uppercased persistent id from notification
        // But iTunesTrack.persistentID is Int128. truncate first 8 characters
        guard id == (_currentTrack?.id.dropFirst(8)).map(String.init) else {
            var track = _iTunes._currentTrack
            if let loc = n.userInfo?["Location"] as? String {
                track?.url = URL(string: loc)
            }
            _currentTrack = track
            _playbackState = state
            _startTime = _iTunes._startTime
            delegate?.currentTrackChanged(track: track, from: self)
            return
        }
        guard state == _playbackState else {
            _playbackState = state
            _startTime = _iTunes._startTime
            _pausePosition = playerPosition
            delegate?.playbackStateChanged(state: state, from: self)
            return
        }
        updatePlayerPosition()
    }
    
    func updatePlayerPosition() {
        guard isRunning else { return }
        if _playbackState.isPlaying {
            if let _startTime = _startTime,
                let startTime = _iTunes._startTime,
                abs(startTime.timeIntervalSince(_startTime)) > positionMutateThreshold {
                self._startTime = startTime
                delegate?.playerPositionMutated(position: playerPosition, from: self)
            }
        } else {
            if let _pausePosition = _pausePosition,
                let pausePosition = _iTunes.playerPosition,
                abs(_pausePosition - pausePosition) > positionMutateThreshold {
                self._pausePosition = pausePosition
                self.playerPosition = pausePosition
                delegate?.playerPositionMutated(position: playerPosition, from: self)
            }
        }
    }
}
    
extension iTunes: MusicPlayer {
    
    public static var name: MusicPlayerName = .itunes
    
    public static var needsUpdate = false
    
    public var playbackState: MusicPlaybackState {
        return _playbackState
    }
    
    public var currentTrack: MusicTrack? {
        return _currentTrack
    }
    
    public var playerPosition: TimeInterval {
        get {
            guard _playbackState.isPlaying else { return _pausePosition ?? 0 }
            guard let _startTime = _startTime else { return 0 }
            return -_startTime.timeIntervalSinceNow
        }
        set {
            guard isRunning else { return }
            originalPlayer.setValue(newValue, forKey: "playerPosition")
//            _iTunes.playerPosition = newValue
            _startTime = Date().addingTimeInterval(-newValue)
        }
    }
    
    public func updatePlayerState() {
        updatePlayerPosition()
    }
    
    public var originalPlayer: SBApplication {
        return _iTunes as! SBApplication
    }
}

extension iTunes {
    
    public var currentLyrics: String? {
        get {
            guard isRunning else { return nil }
            return _iTunes.currentTrack?.lyrics ?? nil
        }
        set {
            guard isRunning else { return }
            (_iTunes.currentTrack as? SBObject)?.setValue(newValue ?? "", forKey: "lyrics")
//            _iTunes.currentTrack?.lyrics = newValue
        }
    }
}

extension iTunesApplication {
    
    var _currentTrack: MusicTrack? {
        guard let t = currentTrack,
            t.mediaKind == .song || t.mediaKind == .musicVideo,
            currentStreamURL ?? nil == nil else {
                return nil
        }
        return MusicTrack(id: (t.persistentID ?? "") ?? "",
                          title: t.name ?? nil,
                          album: t.album ?? nil,
                          artist: t.artist ?? nil,
                          duration: t.duration,
                          url: nil,
                          artwork: nil)
    }
    
    var _startTime: Date? {
        guard let playerPosition = playerPosition else {
            return nil
        }
        return Date().addingTimeInterval(-playerPosition)
    }
    
    var _playbackState: MusicPlaybackState {
        switch playerState {
        case .stopped?, nil:    return .stopped
        case .playing?:         return .playing
        case .paused?:          return .paused
        case .fastForwarding?:  return .fastForwarding
        case .rewinding?:       return .playing
        }
    }
}
