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
        
        @Published public var currentPlayer: MusicPlayerProtocol?
        
        public let objectWillChange = ObservableObjectPublisher()
        
        private var objectWillChangeCanceller: AnyCancellable?
        
        public init() {
            objectWillChangeCanceller = $currentPlayer
                .map { $0?.objectWillChange.eraseToAnyPublisher() ?? Just(()).eraseToAnyPublisher() }
                .switchToLatest()
                .sink { [weak self] _ in self?.objectWillChange.send() }
        }
    }
}

extension MusicPlayers.Delegate: MusicPlayerProtocol {
    
    public var name: MusicPlayerName? {
        return currentPlayer?.name
    }
    
    public var currentTrack: MusicTrack? {
        return currentPlayer?.currentTrack
    }
    
    public var playbackState: PlaybackState {
        return currentPlayer?.playbackState ?? .stopped
    }
    
    public var playbackTime: TimeInterval {
        get { return currentPlayer?.playbackTime ?? 0 }
        set { currentPlayer?.playbackTime = newValue }
    }
    
    public var currentTrackWillChange: AnyPublisher<MusicTrack?, Never> {
        return $currentPlayer.map { $0?.currentTrackWillChange ?? Just(nil).eraseToAnyPublisher() }
            .switchToLatest()
            .eraseToAnyPublisher()
    }
    
    public var playbackStateWillChange: AnyPublisher<PlaybackState, Never> {
        return $currentPlayer.map { $0?.playbackStateWillChange ?? Just(.stopped).eraseToAnyPublisher() }
        .switchToLatest()
        .eraseToAnyPublisher()
    }
    
    public func resume() {
        currentPlayer?.resume()
    }
    
    public func pause() {
        currentPlayer?.pause()
    }
    
    public func playPause() {
        currentPlayer?.playPause()
    }
    
    public func skipToNextItem() {
        currentPlayer?.skipToNextItem()
    }
    
    public func skipToPreviousItem() {
        currentPlayer?.skipToPreviousItem()
    }
    
    public func updatePlayerState() {
        currentPlayer?.updatePlayerState()
    }
}
