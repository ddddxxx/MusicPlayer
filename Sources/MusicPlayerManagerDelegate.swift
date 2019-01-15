//
//  MusicPlayerManagerDelegate.swift
//  MusicPlayer
//
//  Created by 邓翔 on 2019/1/8.
//

import Foundation

public protocol MusicPlayerManagerDelegate: class {
    
    func currentPlayerChanged(player: MusicPlayer?)
    func currentTrackChanged(track: MusicTrack?)
    func playbackStateChanged(state: MusicPlaybackState)
    func playerPositionMutated(position: TimeInterval)
    
    #if os(macOS)
    func runningStateChanged(isRunning: Bool)
    #endif
}
