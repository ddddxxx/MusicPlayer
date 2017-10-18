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

import Cocoa
import ScriptingBridge

public final class iTunes {
    
    public struct Track {
        
        public var url: URL?
        
        private var _iTunesTrack: iTunesTrack
        
        init(_ track: iTunesTrack) {
            _iTunesTrack = track
        }
    }
    
    public weak var delegate: MusicPlayerDelegate?
    
    public var autoLaunch = false
    
    private var _iTunes: iTunesApplication
    private var _currentTrack: Track?
    private var _playbackState: MusicPlaybackState = .stopped
    private var _startTime: Date?
    
    public init?() {
        guard let iTunes = SBApplication(bundleIdentifier: "com.apple.iTunes") else {
            return nil
        }
        _iTunes = iTunes
        if isRunning {
            _playbackState = _iTunes.playerState?.state ?? .stopped
            _currentTrack = _iTunes.currentTrack.map(Track.init)
            _startTime = _iTunes.startTime
        }
        
        DistributedNotificationCenter.default.addObserver(forName: .iTunesPlayerInfo, object: nil, queue: notificationQueue, using: playerInfoNotification)
    }
    
    func playerInfoNotification(_ n: Notification) {
        guard autoLaunch || isRunning else { return }
        var track = _iTunes.currentTrack.map(Track.init)
        let state = _iTunes.playerState?.state ?? .stopped
        guard track?._id != _currentTrack?._id else {
            if let loc = n.userInfo?["Location"] as? String {
                track?.url = URL(string: loc)
            }
            _currentTrack = track
            _playbackState = state
            _startTime = _iTunes.startTime
            delegate?.currentTrackChanged(track: track, from: self)
            return
        }
        guard state != _playbackState else {
            _playbackState = state
            _startTime = _iTunes.startTime
            delegate?.playbackStateChanged(state: state, from: self)
            return
        }
        updatePlayerPosition()
    }
    
    func updatePlayerPosition() {
        guard autoLaunch || isRunning else { return }
        if let _startTime = _startTime,
            let startTime = _iTunes.startTime,
            abs(startTime.timeIntervalSince(_startTime)) > positionMutateThreshold {
            self._startTime = startTime
            delegate?.playerPositionMutated(position: playerPosition, from: self)
        }
    }
}
    
extension iTunes: MusicPlayer {
    
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

extension iTunesEPlS {
    
    var state: MusicPlaybackState {
        switch self {
        case .playing:          return .playing
        case .paused:           return .paused
        case .stopped:          return .stopped
        case .fastForwarding:   return .fastForwarding
        case .rewinding:        return .playing
        }
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

extension iTunes.Track: MusicTrack {
    
    var _id: Int {
        return _iTunesTrack.id?() ?? 0
    }
    
    public var id: String {
        return "\(_id)"
    }
    
    public var title: String? {
        return _iTunesTrack.name ?? nil
    }
    
    public var album: String? {
        return _iTunesTrack.album ?? nil
    }
    
    public var artist: String? {
        return _iTunesTrack.artist ?? nil
    }
    
    public var duration: TimeInterval? {
        return _iTunesTrack.duration
    }
    
    public var artwork: NSImage? {
        get {
            return _iTunesTrack.artworks?().first?.data
        }
        set {
            (_iTunesTrack.artworks?().first as! SBObject?)?.setValue(newValue, forKey: "data")
        }
    }
    
    public var lyrics: String? {
        get {
            return _iTunesTrack.lyrics ?? nil
        }
        set {
            originalTrack?.setValue(newValue, forKey: "lyrics")
        }
    }
    
    public var originalTrack: SBObject? {
        return (_iTunesTrack as! SBObject)
    }
}

extension iTunesApplication {
    
    var startTime: Date? {
        guard let playerPosition = playerPosition else {
            return nil
        }
        return Date().addingTimeInterval(-playerPosition)
    }
}
