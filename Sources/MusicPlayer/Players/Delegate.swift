//
//  Delegate.swift
//
//  This file is part of LyricsX - https://github.com/ddddxxx/LyricsX
//  Copyright (C) 2017  Xander Deng. Licensed under GPLv3.
//

import Foundation
import CXShim

extension MusicPlayers {
    
    /// Delegate events to another player
    open class Delegate: ObservableObject {
        
        @Published public var designatedPlayer: MusicPlayerProtocol?
        
        public let objectWillChange = ObservableObjectPublisher()
        
        private var objectWillChangeCanceller: AnyCancellable?
        
        public init() {
            objectWillChangeCanceller = $designatedPlayer
                .map { $0?.objectWillChange.eraseToAnyPublisher() ?? Just(()).eraseToAnyPublisher() }
                .switchToLatest()
                .sink { [weak self] _ in self?.objectWillChange.send() }
        }
    }
}

extension MusicPlayers.Delegate: MusicPlayerProtocol {
    
    public var name: MusicPlayerName? {
        return designatedPlayer?.name
    }
    
    public var currentTrack: MusicTrack? {
        return designatedPlayer?.currentTrack
    }
    
    public var playbackState: PlaybackState {
        return designatedPlayer?.playbackState ?? .stopped
    }
    
    public var playbackTime: TimeInterval {
        get { return designatedPlayer?.playbackTime ?? 0 }
        set { designatedPlayer?.playbackTime = newValue }
    }
    
    public var currentTrackWillChange: AnyPublisher<MusicTrack?, Never> {
        return $designatedPlayer.map { $0?.currentTrackWillChange ?? Just(nil).eraseToAnyPublisher() }
            .switchToLatest()
            .eraseToAnyPublisher()
    }
    
    public var playbackStateWillChange: AnyPublisher<PlaybackState, Never> {
        return $designatedPlayer.map { $0?.playbackStateWillChange ?? Just(.stopped).eraseToAnyPublisher() }
        .switchToLatest()
        .eraseToAnyPublisher()
    }
    
    public func resume() {
        designatedPlayer?.resume()
    }
    
    public func pause() {
        designatedPlayer?.pause()
    }
    
    public func playPause() {
        designatedPlayer?.playPause()
    }
    
    public func skipToNextItem() {
        designatedPlayer?.skipToNextItem()
    }
    
    public func skipToPreviousItem() {
        designatedPlayer?.skipToPreviousItem()
    }
    
    public func updatePlayerState() {
        designatedPlayer?.updatePlayerState()
    }
}
