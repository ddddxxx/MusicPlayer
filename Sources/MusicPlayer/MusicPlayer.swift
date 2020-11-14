//
//  MusicPlayer.swift
//  LyricsX - https://github.com/ddddxxx/LyricsX
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at https://mozilla.org/MPL/2.0/.
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

public extension MusicPlayerProtocol {
    func playPause() {
        if playbackState.isPlaying {
            pause()
        } else {
            resume()
        }
    }
}
