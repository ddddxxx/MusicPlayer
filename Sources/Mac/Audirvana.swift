//
//  Audirvana.swift
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

public final class Audirvana {
    
    public weak var delegate: MusicPlayerDelegate?
    
    private var _audirvana: AudirvanaApplication
    private var _currentTrack: MusicTrack?
    private var _playbackState: MusicPlaybackState = .stopped
    private var _startTime: Date?
    private var _pausePosition: Double?
    
    private var observer: [NSObjectProtocol] = []
    
    public init?() {
        guard let audirvana = SBApplication(bundleIdentifier: Audirvana.name.bundleID) else {
            return nil
        }
        _audirvana = audirvana
        if isRunning {
            _playbackState = _audirvana._playbackState
            _currentTrack = _audirvana._currentTrack
            _startTime = _audirvana._startTime
            
            _audirvana.setEventTypesReported?(.trackChanged)
        }
        
        observer += [
            DistributedNotificationCenter.default.addObserver(forName: .AudirvanaPlayerInfo, object: nil, queue: nil) { [unowned self] n in self.playerInfoNotification(n) },
            NSWorkspace.shared.notificationCenter.addObserver(forName: NSWorkspace.didLaunchApplicationNotification, object: nil, queue: nil) { [unowned self] n in
                guard let userInfo = n.userInfo else { return }
                if userInfo["NSApplicationBundleIdentifier"] as? String == MusicPlayerName.audirvana.bundleID {
                    self._audirvana.setEventTypesReported?(.trackChanged)
                }
            }
        ]
    }
    
    deinit {
        observer.forEach(DistributedNotificationCenter.default.removeObserver)
    }
    
    func playerInfoNotification(_ n: Notification) {
        guard isRunning else { return }
        let id = _audirvana._currentTrackID ?? nil
        let state: MusicPlaybackState
        switch n.userInfo?["PlayerStatus"] as? String {
        case "Playing"?:    state = .playing
        case "Paused"?:     state = .paused
        case "Stopped"?, _: state = .stopped
        }
        if id != _currentTrack?.id {
            var track = _audirvana._currentTrack
            if let loc = n.userInfo?["PlayingTrackURL"] as? String {
                track?.url = URL(string: loc)
            }
            _currentTrack = track
            //_playbackState = state
            _startTime = _audirvana._startTime
            delegate?.currentTrackChanged(track: track, from: self)
            //return
        }
        if state != _playbackState {
            _playbackState = state
            _startTime = _audirvana._startTime
            _pausePosition = playerPosition
            delegate?.playbackStateChanged(state: state, from: self)
            //return
        }
        updatePlayerPosition()
    }
    
    func updatePlayerPosition() {
        guard isRunning else { return }
        if _playbackState.isPlaying {
            if let _startTime = _startTime,
                let startTime = _audirvana._startTime,
                abs(startTime.timeIntervalSince(_startTime)) > positionMutateThreshold {
                self._startTime = startTime
                delegate?.playerPositionMutated(position: playerPosition, from: self)
            }
        } else {
            if let _pausePosition = _pausePosition,
                let pausePosition = _audirvana.playerPosition,
                abs(_pausePosition - pausePosition) > positionMutateThreshold {
                self._pausePosition = pausePosition
                self.playerPosition = pausePosition
                delegate?.playerPositionMutated(position: playerPosition, from: self)
            }
        }
    }
}

extension Audirvana: MusicPlayer {
    
    public static var name: MusicPlayerName = .audirvana
    
    public static var needsUpdateIfNotSelected = false
    
    public var playbackState: MusicPlaybackState {
        return _playbackState
    }
    
    public var currentTrack: MusicTrack? {
        return _currentTrack
    }
    
    public var playerPosition: TimeInterval {
        get {
            guard _playbackState.isPlaying else { return _pausePosition ?? 0 }
            guard isRunning else { return 0 }
            guard let _startTime = _startTime else { return 0 }
            return -_startTime.timeIntervalSinceNow
        }
        set {
            guard isRunning else { return }
            originalPlayer.setValue(newValue, forKey: "playerPosition")
            _startTime = Date().addingTimeInterval(-newValue)
        }
    }
    
    public func updatePlayerState() {
        updatePlayerPosition()
    }
    
    public func resume() {
        _audirvana.resume?()
    }
    
    public func pause() {
        _audirvana.pause?()
    }
    
    public func playPause() {
        _audirvana.playpause?()
    }
    
    public func skipToNextItem() {
        _audirvana.nextTrack?()
    }
    
    public func skipToPreviousItem() {
        _audirvana.previousTrack?()
    }
    
    public var originalPlayer: SBApplication {
        return _audirvana as! SBApplication
    }
}

extension AudirvanaApplication {
    
    var _currentTrackID: String? {
        guard let title = playingTrackTitle ?? nil else { return nil }
        let album = (playingTrackAlbum ?? nil) ?? ""
        let duration = playingTrackDuration?.description ?? ""
        return "Audirvana-" + title + "-" + album + "-" + duration
    }
    
    var _currentTrack: MusicTrack? {
        guard let id = _currentTrackID else { return nil }
        return MusicTrack(id: id,
                          title: playingTrackTitle ?? nil,
                          album: playingTrackAlbum ?? nil,
                          artist: playingTrackArtist ?? nil,
                          duration: playingTrackDuration.map(TimeInterval.init),
                          url: nil,
                          artwork: playingTrackAirfoillogo ?? nil,
                          originalTrack: nil)
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
        }
    }
}
