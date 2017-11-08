//
//  Vox.swift
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

final public class Vox {
    
    public weak var delegate: MusicPlayerDelegate?
    
    public var autoLaunch = false
    
    private var _vox: VoxApplication
    private var _currentTrack: MusicTrack?
    private var _playbackState: MusicPlaybackState = .stopped
    private var _startTime: Date?
    private var _pausePosition: Double?
    
    private var observer: NSObjectProtocol?
    
    public init?() {
        guard let vox = SBApplication(bundleIdentifier: Vox.name.bundleID) else {
            return nil
        }
        _vox = vox
        if isRunning {
            _playbackState = _vox.playerState == 1 ? .playing : .paused
            _currentTrack = _vox.currentTrack
            _startTime = _vox.startTime
        }
        
        observer = DistributedNotificationCenter.default.addObserver(forName: .VoxTrackChanged, object: nil, queue: nil, using: trackChangeNotification)
    }
    
    deinit {
        if let observer = observer {
            DistributedNotificationCenter.default.removeObserver(observer)
        }
    }
    
    func trackChangeNotification(_ n: Notification) {
        guard autoLaunch || isRunning else { return }
        let id = _vox.uniqueID ?? nil
        guard id == _currentTrack?.id else {
            _currentTrack = _vox.currentTrack
            _playbackState = _vox.playerState == 1 ? .playing : .paused
            _startTime = _vox.startTime
            delegate?.currentTrackChanged(track: _currentTrack, from: self)
            return
        }
        updatePlayerState()
    }
    
    public func updatePlayerState() {
        guard autoLaunch || isRunning else { return }
        let state: MusicPlaybackState = _vox.playerState == 1 ? .playing : .paused
        guard state == _playbackState else {
            _playbackState = state
            _startTime = _vox.startTime
            _pausePosition = playerPosition
            delegate?.playbackStateChanged(state: state, from: self)
            return
        }
        if _playbackState.isPlaying {
            if let _startTime = _startTime,
                let startTime = _vox.startTime,
                abs(startTime.timeIntervalSince(_startTime)) > positionMutateThreshold {
                self._startTime = startTime
                delegate?.playerPositionMutated(position: playerPosition, from: self)
            }
        } else {
            if let _pausePosition = _pausePosition,
                let pausePosition = _vox.currentTime,
                abs(_pausePosition - pausePosition) > positionMutateThreshold {
                self._pausePosition = pausePosition
                self.playerPosition = pausePosition
                delegate?.playerPositionMutated(position: playerPosition, from: self)
            }
        }
    }
}

extension Vox: MusicPlayer {
    
    public static var name: MusicPlayerName = .vox
    
    public static var needsUpdate = true
    
    public var playbackState: MusicPlaybackState {
        guard autoLaunch || isRunning else { return .stopped }
        return _playbackState
    }
    
    public var repeatMode: MusicRepeatMode {
        get {
            guard autoLaunch || isRunning else { return .off }
            switch _vox.repeatState {
            case 1?: return .one
            case 2?: return .all
            case _:  return .off
            }
        }
        set {
            guard autoLaunch || isRunning else { return }
            switch newValue {
            case .off:
                originalPlayer.setValue(0, forKey: "repeatState")
//                _vox.repeatState = 0
            case .one:
                originalPlayer.setValue(1, forKey: "repeatState")
//                _vox.repeatState = 1
            case .all:
                originalPlayer.setValue(2, forKey: "repeatState")
//                _vox.repeatState = 2
            }
        }
    }
    
    public var shuffleMode: MusicShuffleMode {
        get {
            return .off
        }
        set {
            // NOTE: not support
        }
    }
    
    public var currentTrack: MusicTrack? {
        guard autoLaunch || isRunning else { return nil }
        return _currentTrack
    }
    
    public var playerPosition: TimeInterval {
        get {
            guard autoLaunch || isRunning else { return 0 }
            guard let _startTime = _startTime else { return 0 }
            return -_startTime.timeIntervalSinceNow
        }
        set {
            guard autoLaunch || isRunning else { return }
            originalPlayer.setValue(newValue, forKey: "currentTime")
//            _vox.currentTime = newValue
            _startTime = Date().addingTimeInterval(-newValue)
        }
    }
    
    public func playpause() {
        guard autoLaunch || isRunning else { return }
        _vox.playpause?()
    }
    
    public func stop() {
        guard autoLaunch || isRunning else { return }
        // NOTE: not support
        _vox.pause?()
    }
    
    public func skipToNext() {
        guard autoLaunch || isRunning else { return }
        _vox.next?()
    }
    
    public func skipToPrevious() {
        guard autoLaunch || isRunning else { return }
        _vox.previous?()
    }
    
    public var originalPlayer: SBApplication {
        return _vox as! SBApplication
    }
}

extension VoxApplication {
    
    var currentTrack: MusicTrack {
        let id = (uniqueID ?? "") ?? ""
        let url = trackUrl?.flatMap(URL.init(string:))
        return MusicTrack(id: id,
                          title: track ?? nil,
                          album: album ?? nil,
                          artist: artist ?? nil,
                          duration: totalTime,
                          url: url)
    }
        
    var startTime: Date? {
        guard let currentTime = currentTime else {
            return nil
        }
        return Date().addingTimeInterval(-currentTime)
    }
}
