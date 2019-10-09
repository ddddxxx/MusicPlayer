//
//  Vox.swift
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

#if os(macOS)

import AppKit
import ScriptingBridge
import CXShim

public final class Vox: MusicPlayerController, PlaybackTimeUpdating {
    
    override public class var name: MusicPlayerName {
        return .spotify
    }
    
    private var _app: VoxApplication {
        return originalPlayer
    }
    
    required init?() {
        super.init()
        if isRunning {
            playbackState = _app._playbackState
            currentTrack = _app._currentTrack
        }
        
        distributedNC.cx.publisher(for: .voxTrackChanged)
            .sink { [unowned self] n in
                self.trackChangeNotification(n)
            }.store(in: &cancelBag)
        let q = DispatchQueue.global().cx
        q.schedule(after: q.now.advanced(by: 1), interval: 1, tolerance: 0.1, options: nil) {
            self.updatePlayerState()
        }.store(in: &cancelBag)
    }
    
    func updatePlaybackTime() {
        guard isRunning else { return }
        setPlaybackState(_app._playbackState)
    }
    
    func trackChangeNotification(_ n: Notification) {
        guard isRunning else { return }
        let id = _app.uniqueID ?? nil
        guard id == currentTrack?.id else {
            currentTrack = _app._currentTrack
            playbackState = _app._playbackState
            return
        }
        updatePlayerState()
    }
    
    public func updatePlayerState() {
        guard isRunning else { return }
        setPlaybackState(_app._playbackState)
    }
    
    override public var playbackTime: TimeInterval {
        get {
            return playbackState.time
        }
        set {
            guard isRunning else { return }
            originalPlayer.setValue(newValue, forKey: "currentTime")
            playbackState.time = newValue
        }
    }
    
    override public func resume() {
        _app.play?()
    }
    
    override public func pause() {
        _app.pause?()
    }
    
    override public func playPause() {
        _app.playpause?()
    }
    
    override public func skipToNextItem() {
        _app.next?()
    }
    
    override public func skipToPreviousItem() {
        _app.previous?()
    }
}

extension Vox: PlaybackModeSettable {
    
    public var availableShuffleMode: [ShuffleMode] {
        return [.off]
    }
    
    public var repeatMode: RepeatMode {
        get {
            switch _app.repeatState {
            case 0: return .off
            case 1: return .one
            case 2: return .all
            default: return .off
            }
        }
        set {
            let state = [RepeatMode.off, .one, .all].firstIndex(of: newValue) ?? 0
            originalPlayer.setValue(state, forKey: "repeatState")
        }
    }
    
    public var shuffleMode: ShuffleMode {
        get {
            return .off
        }
        set {}
    }
}

extension VoxApplication {
    
    var _currentTrack: MusicTrack? {
        guard let id = uniqueID ?? nil else {
            return nil
        }
        let url = trackUrl?.flatMap(URL.init(string:))
        return MusicTrack(id: id,
                          title: track ?? nil,
                          album: album ?? nil,
                          artist: artist ?? nil,
                          duration: totalTime,
                          fileURL: url,
                          artwork: artworkImage ?? nil,
                          originalTrack: nil)
    }
        
    var _startTime: Date? {
        guard let currentTime = currentTime else {
            return nil
        }
        return Date().addingTimeInterval(-currentTime)
    }
    
    var _playbackState: PlaybackState {
        if playerState == 1, let position = currentTime {
            return .playing(time: position)
        } else {
            return .stopped
        }
    }
}

#endif
