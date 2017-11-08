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
    
    public var autoLaunch = false
    
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
        
        observer = DistributedNotificationCenter.default.addObserver(forName: .iTunesPlayerInfo, object: nil, queue: nil, using: playerInfoNotification)
    }
    
    deinit {
        if let observer = observer {
            DistributedNotificationCenter.default.removeObserver(observer)
        }
    }
    
    func playerInfoNotification(_ n: Notification) {
        guard autoLaunch || isRunning else { return }
        var track = _iTunes._currentTrack
        let state = _iTunes._playbackState
        guard track?.id == _currentTrack?.id else {
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
        guard autoLaunch || isRunning else { return }
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
    
    public var repeatMode: MusicRepeatMode {
        get {
            guard autoLaunch || isRunning else { return .off }
            return _iTunes.songRepeat?.mode ?? .off
        }
        set {
            guard autoLaunch || isRunning else { return }
            originalPlayer.setValue(iTunesERpt(newValue), forKey: "songRepeat")
//            _iTunes.songRepeat = iTunesERpt(newValue)
        }
    }
    
    public var shuffleMode: MusicShuffleMode {
        get {
            guard autoLaunch || isRunning else { return .off }
            guard _iTunes.shuffleEnabled == true, let mode = _iTunes.shuffleMode else {
                return .off
            }
            switch mode {
            case .songs:        return .songs
            case .albums:       return .albums
            case .groupings:    return .groupings
            }
        }
        set {
            guard autoLaunch || isRunning else { return }
            originalPlayer.setValue(newValue != .off, forKey: "shuffleEnabled")
//            _iTunes.shuffleEnabled = newValue != .off
            switch newValue {
            case .off:
                originalPlayer.setValue(false, forKey: "shuffleEnabled")
            case .songs:
                originalPlayer.setValue(true, forKey: "shuffleEnabled")
                originalPlayer.setValue(MusicShuffleMode.songs, forKey: "shuffleMode")
//                _iTunes.shuffleMode = .songs
            case .albums:
                originalPlayer.setValue(true, forKey: "shuffleEnabled")
                originalPlayer.setValue(MusicShuffleMode.albums, forKey: "shuffleMode")
//                _iTunes.shuffleMode = .albums
            case .groupings:
                originalPlayer.setValue(true, forKey: "shuffleEnabled")
                originalPlayer.setValue(MusicShuffleMode.groupings, forKey: "shuffleMode")
//                _iTunes.shuffleMode = .groupings
            }
        }
    }
    
    public var currentTrack: MusicTrack? {
        return _currentTrack
    }
    
    public var playerPosition: TimeInterval {
        get {
            guard let _startTime = _startTime else { return 0 }
            return -_startTime.timeIntervalSinceNow
        }
        set {
            guard autoLaunch || isRunning else { return }
            originalPlayer.setValue(newValue, forKey: "playerPosition")
//            _iTunes.playerPosition = newValue
            _startTime = Date().addingTimeInterval(-newValue)
        }
    }
    
    public func playpause() {
        guard autoLaunch || isRunning else { return }
        _iTunes.playpause?()
    }
    
    public func stop() {
        guard autoLaunch || isRunning else { return }
        _iTunes.pause?()
    }
    
    public func skipToNext() {
        guard autoLaunch || isRunning else { return }
        _iTunes.nextTrack?()
    }
    
    public func skipToPrevious() {
        guard autoLaunch || isRunning else { return }
        _iTunes.previousTrack?()
    }
    
    public func updatePlayerState() {
        updatePlayerPosition()
    }
    
    public var originalPlayer: SBApplication {
        return _iTunes as! SBApplication
    }
}

extension iTunesERpt {
    
    var mode: MusicRepeatMode {
        switch self {
        case .off:  return .off
        case .one:  return .one
        case .all:  return .all
        }
    }
    
    init(_ mode: MusicRepeatMode) {
        switch mode {
        case .off:  self = .off
        case .one:  self = .one
        case .all:  self = .all
        }
    }
}

extension iTunesApplication {
    
    var _currentTrack: MusicTrack? {
        guard let t = currentTrack, t.mediaKind == .song else { return nil }
        guard currentStreamURL ?? nil == nil else { return nil }
        return MusicTrack(id: t.id?().description ?? "",
                          title: t.name ?? nil,
                          album: t.album ?? nil,
                          artist: t.artist ?? nil,
                          duration: t.duration,
                          url: nil)
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
