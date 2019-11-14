//
//  Swinsian.swift
//
//  This file is part of LyricsX - https://github.com/ddddxxx/LyricsX
//  Copyright (C) 2017  Xander Deng. Licensed under GPLv3.
//

#if os(macOS)

import AppKit
import ScriptingBridge
import CXShim

public final class Swinsian: MusicPlayerController, PlaybackTimeUpdating {
    
    override public class var name: MusicPlayerName {
        return .swinsian
    }
    
    private var _app: SwinsianApplication {
        return originalPlayer
    }
    
    required init?() {
        super.init()
        if isRunning {
            playbackState = _app._playbackState
            currentTrack = _app._currentTrack
        }
        
        distributedNC.cx.publisher(for: .swinsianPlaying)
            .sink { [unowned self] _ in
                self.setPlaybackState(self._app._playbackState, tolerate: 1.0)
                self.currentTrack = self._app._currentTrack
            }.store(in: &cancelBag)
        distributedNC.cx.publisher(for: .swinsianPaused)
            .sink { [unowned self] _ in
                self.setPlaybackState(self._app._playbackState, tolerate: 1.0)
            }.store(in: &cancelBag)
        distributedNC.cx.publisher(for: .swinsianStopped)
            .sink { _ in
                self.playbackState = .stopped
                self.currentTrack = nil
            }.store(in: &cancelBag)
    }
    
    func updatePlaybackTime() {
        guard isRunning else { return }
        setPlaybackState(_app._playbackState)
    }
    
    override public var playbackTime: TimeInterval {
        get {
            return playbackState.time
        }
        set {
            guard isRunning else { return }
            originalPlayer.setValue(Int(newValue), forKey: "playerPosition")
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
        _app.nextTrack?()
    }
    
    override public func skipToPreviousItem() {
        _app.previousTrack?()
    }
}

extension SwinsianApplication {
    
    var _currentTrack: MusicTrack? {
        guard let track = currentTrack ?? nil else { return nil }
        let originalTrack = (track as! SBObject).get() as? SBObject
        let url = (track.path ?? nil).map(URL.init(fileURLWithPath:))
        return MusicTrack(id: track.id?() ?? "",
                          title: track.name ?? nil,
                          album: track.album ?? nil,
                          artist: track.artist ?? nil,
                          duration: track.duration ?? nil,
                          fileURL: url,
                          artwork: track.albumArt ?? nil,
                          originalTrack: originalTrack)
    }
    
    var _playbackState: PlaybackState {
        guard let state = playerState, let position = playerPosition else {
            return .stopped
        }
        switch state {
        case .stopped: return .stopped
        case .playing: return .playing(time: TimeInterval(position))
        case .paused:  return .paused(time: TimeInterval(position))
        }
    }
}

#endif
