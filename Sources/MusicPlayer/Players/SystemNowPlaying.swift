//
//  SystemNowPlaying.swift
//  LyricsX - https://github.com/ddddxxx/LyricsX
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

#if os(macOS)

import Foundation
import AppKit
import MediaRemotePrivate
import CXShim

extension MusicPlayers {
    
    public final class SystemNowPlaying: ObservableObject {
        
        @Published public private(set) var currentTrack: MusicTrack?
        @Published public private(set) var playbackState: PlaybackState = .stopped
        
        private var systemPlaybackState: SystemPlaybackState?
        
        public init?() {
            guard let register = MRMediaRemoteRegisterForNowPlayingNotifications_ else {
                return nil
            }
            register(DispatchQueue.global())
            
            let nc = NotificationCenter.default
            nc.addObserver(forName: .mediaRemoteNowPlayingApplicationPlaybackStateDidChange, object: nil, queue: nil) { [weak self] n in
                self?.mediaRemoteNowPlayingApplicationPlaybackStateDidChange(n: n)
            }
            nc.addObserver(forName: .mediaRemoteNowPlayingInfoDidChange, object: nil, queue: nil) { [weak self] n in
                self?.mediaRemoteNowPlayingInfoDidChange(n: n)
            }
            
            MRMediaRemoteGetNowPlayingApplicationIsPlaying_?(DispatchQueue.global()) { [weak self] isPlaying in
                self?.systemPlaybackState = isPlaying.boolValue ? .playing : .paused
                self?.updatePlayerState()
            }
        }
        
        deinit {
            MRMediaRemoteUnregisterForNowPlayingNotifications_?()
        }
        
        private func getNowPlayingInfoCallback(_ infoDict: CFDictionary?) {
            guard let infoDict = infoDict as NSDictionary? else {
                playbackState = .stopped
                currentTrack = nil
                return
            }
            let info = MRNowPlayingInfo(dict: infoDict)
            let newState: PlaybackState
            switch systemPlaybackState {
            case .playing:
                newState = info.startTime.map(PlaybackState.playing) ?? .stopped
            case .paused:
                newState = info._elapsedTime.map(PlaybackState.paused) ?? .stopped
            default:
                newState = .stopped
            }
            if !playbackState.approximateEqual(to: newState) {
                playbackState = newState
            }
            
            let newTrack = info.track
            if newTrack?.id != currentTrack?.id {
                currentTrack = newTrack
            }
        }
        
        private func mediaRemoteNowPlayingApplicationPlaybackStateDidChange(n: Notification) {
            guard let info = n.userInfo as! [String: Any]? else {
                playbackState = .stopped
                currentTrack = nil
                return
            }
            
            systemPlaybackState = (info["kMRMediaRemotePlaybackStateUserInfoKey"] as? Int).flatMap(SystemPlaybackState.init)
            if systemPlaybackState == .playing || systemPlaybackState == .paused {
                updatePlayerState()
            } else {
                playbackState = .stopped
                currentTrack = nil
            }
        }
        
        private func mediaRemoteNowPlayingInfoDidChange(n: Notification) {
            // TODO: extract track info from notification
            updatePlayerState()
        }
    }
}

extension MusicPlayers.SystemNowPlaying: MusicPlayerProtocol {
    
    public var currentTrackWillChange: AnyPublisher<MusicTrack?, Never> {
        return $currentTrack.eraseToAnyPublisher()
    }
    
    public var playbackStateWillChange: AnyPublisher<PlaybackState, Never> {
        return $playbackState.eraseToAnyPublisher()
    }
    
    public var name: MusicPlayerName? {
        return nil
    }
    
    public var playbackTime: TimeInterval {
        get {
            return playbackState.time
        }
        set {
            MRMediaRemoteSetElapsedTime_?(newValue)
            playbackState = playbackState.withTime(newValue)
        }
    }
    
    public func resume() {
        _ = MRMediaRemoteSendCommand_?(.play, nil)
    }
    
    public func pause() {
        _ = MRMediaRemoteSendCommand_?(.pause, nil)
    }
    
    public func playPause() {
        _ = MRMediaRemoteSendCommand_?(.togglePlayPause, nil)
    }
    
    public func skipToNextItem() {
        _ = MRMediaRemoteSendCommand_?(.nextTrack, nil)
    }
    
    public func skipToPreviousItem() {
        _ = MRMediaRemoteSendCommand_?(.previousTrack, nil)
    }
    
    public func updatePlayerState() {
        MRMediaRemoteGetNowPlayingInfo_?(DispatchQueue.global()) { [weak self] info in
            self?.getNowPlayingInfoCallback(info)
        }
    }
}

private extension MusicPlayers.SystemNowPlaying {
    
    enum SystemPlaybackState: Int {
        case terminated = 0
        case playing = 1
        case paused = 2
        case stopped = 3
    }
}

private extension Notification.Name {
    
    static let mediaRemoteNowPlayingInfoDidChange = Notification.Name("kMRMediaRemoteNowPlayingInfoDidChangeNotification")
    static let mediaRemoteNowPlayingApplicationPlaybackStateDidChange = Notification.Name("kMRMediaRemoteNowPlayingApplicationPlaybackStateDidChangeNotification")
}

#endif
