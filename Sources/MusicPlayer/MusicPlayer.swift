//
//  MusicPlayer.swift
//
//  This file is part of LyricsX - https://github.com/ddddxxx/LyricsX
//  Copyright (C) 2017  Xander Deng. Licensed under GPLv3.
//

import Foundation
import CXShim

public protocol MusicPlayerProtocol: AnyObject {
    
    var name: MusicPlayerName? { get }
    var currentTrack: MusicTrack? { get }
    var playbackState: PlaybackState { get }
    var playbackTime: TimeInterval { get set }
    
    var objectWillChange: ObservableObjectPublisher { get }
    var currentTrackWillChange: AnyPublisher<MusicTrack?, Never> { get }
    var playbackStateWillChange: AnyPublisher<PlaybackState, Never> { get }
    
    func resume()
    func pause()
    func playPause()
    
    func skipToNextItem()
    func skipToPreviousItem()
    
    func updatePlayerState()
}

public enum MusicPlayers {}
