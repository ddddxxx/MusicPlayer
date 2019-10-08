//
//  Audirvana.swift
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

#if USE_COMBINEX
import CXFoundation
#else
import CXCompatible
#endif

public final class Audirvana: MusicPlayerController {
    
    override public class var name: MusicPlayerName {
        return .audirvana
    }
    
    private var _app: AudirvanaApplication {
        return originalPlayer
    }
    
    public override var currentTrack: MusicTrack? {
        get { super.currentTrack }
        set { super.currentTrack = newValue }
    }
    public override var playbackState: PlaybackState {
        get { super.playbackState }
        set { super.playbackState = newValue }
    }
    
    required init?() {
        super.init()
        if isRunning {
            playbackState = _app._playbackState
            currentTrack = _app._currentTrack
            
            _app.setEventTypesReported?(.trackChanged)
        }
        
        updatePlaybackTime = { [unowned self] in
            guard self.isRunning else { return }
            self.setPlaybackState(self._app._playbackState)
        }
        
        distributedNC.cx.publisher(for: .audirvanaPlayerInfo)
            .sink { [unowned self] n in
                self.playerInfoNotification(n)
            }.store(in: &cancelBag)
        $isRunning.filter { $0 == true }
            .sink { [unowned self] _ in
                self._app.setEventTypesReported?(.trackChanged)
            }.store(in: &cancelBag)
    }
    
    func playerInfoNotification(_ n: Notification) {
        guard isRunning else { return }
        let id = _app._currentTrackID ?? nil
        guard id == currentTrack?.id else {
            var track = _app._currentTrack
            if let path = n.userInfo?["PlayingTrackURL"] as? String {
                track?.fileURL = URL(fileURLWithPath: path)
            }
            currentTrack = track
            playbackState = _app._playbackState
            return
        }
        setPlaybackState(_app._playbackState)
    }
    
    override public var playbackTime: TimeInterval {
        get {
            return playbackState.time
        }
        set {
            guard isRunning else { return }
            originalPlayer.setValue(newValue, forKey: "playerPosition")
            playbackState.time = newValue
        }
    }
    
    override public func resume() {
        _app.resume?()
    }
    
    override public func pause() {
        _app.pause?()
    }
    
    override public func playPause() {
        _app.playpause?()
    }
    
    override public func skipToNextItem() {
        _app.nextTrack?()
    }
    
    override public func skipToPreviousItem() {
        _app.previousTrack?()
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
                          fileURL: nil,
                          artwork: playingTrackAirfoillogo ?? nil,
                          originalTrack: nil)
    }
    
    var _playbackState: PlaybackState {
        guard let state = playerState, let position = playerPosition else {
            return .stopped
        }
        switch state {
        case .stopped: return .stopped
        case .playing: return .playing(time: position)
        case .paused:  return .paused(time: position)
        }
    }
}

#endif
