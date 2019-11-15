//
//  AudirvanaBridge.swift
//
//  This file is part of LyricsX - https://github.com/ddddxxx/LyricsX
//  Copyright (C) 2017  Xander Deng. Licensed under GPLv3.
//

#if os(macOS)

import AppKit
import ScriptingBridge


@objc enum AudirvanaPlayerStatus: AEKeyword {
    case stopped = 0x6b505353 /* Playback Stopped */
    case playing = 0x6b505350 /* Playing */
    case paused = 0x6b505370 /* Playback Paused */
}


@objc enum AudirvanaPlayerControlType: AEKeyword {
    case library = 0x6b434c62 /* Library mode no external control */
    case iTunesIntegrated = 0x6b436954 /* iTunes integrated mode fully controlled by iTunes */
    
    // removed in Audirvana 3.5
    case standalone = 0x6b435374 /* Standalone mode no external control */
    case slave = 0x6b43536c /* Slave mode fully controlled by Apple Events */
}

@objc enum AudirvanaPlayerStatusEventTypesReported: AEKeyword {
    case none = 0x6b45764e
    /* No event reported/pushed */
    case trackChanged = 0x6b457654
    /* Tracks change playback status pushed as events
    Reported in notification com.audirvana.audirvana-plus.playerStatus with info dictionary containing:
    player status (Stopped Playing Paused) in key PlayerStatus
    Playing track URL (if not stopped) in key PlayingTrackURL */
    case trackAndPosition = 0x6b457650
    /* Tracks playback status and play position (every second) pushed as events
    Play position is reported in notification com.audirvana.audirvana-plus.playerPosition as a double (posInSec key) */
}


@objc enum AudirvanaTrackType: AEKeyword {
    case audioFile = 0x6b54466c /* Audio file locally (file://) or http (http://) readable */
    case qobuzTrack = 0x6b545142 /* Qobuz track streamed from qobuz.com */
    
    // added in Audirvana 3.5
    case tidalTrack = 0x6b545444 /* Tidal track, streamed from tidal.com */
    case hraTrack = 0x6b544852 /* Qobuz track, streamed from highresaudio.com */
}


/*
 * Audirvana Plus Scripting Suite
 */
// Audirvana Plus application class.
@objc protocol AudirvanaApplication {
    @objc optional var playerState: AudirvanaPlayerStatus {get}
    // Playback engine state (stopped, playing, ...)
    @objc optional var controlType: AudirvanaPlayerControlType {get set}
    // Player control type (standalone, by iTunes, by Apple Events)
    @objc optional var eventTypesReported: AudirvanaPlayerStatusEventTypesReported {get set}
    // Type of events (playback status, track change, player position within track (only in slave mode)) to be pushed
    @objc optional var playerPosition: Double {get set}
    // player position in the track in seconds
    @objc optional var version: String? {get}
    // Version of Audirvana Plus
    @objc optional var playingTrackTitle: String? {get}
    // Title of currently playing track.
    @objc optional var playingTrackArtist: String? {get}
    // Artist of currently playing track.
    @objc optional var playingTrackAlbum: String? {get}
    // Album of currently playing track.
    @objc optional var playingTrackDuration: Int {get}
    // Duration of currently playing track.
    @objc optional var playingTrackAirfoillogo: NSImage? {get}
    // Logo for the currently playing track.
    @objc optional func playpause()
    // Start playback, toggle play pause mode
    @objc optional func stop()
    // Stop playback
    @objc optional func pause()
    // Pause playback
    @objc optional func resume()
    // Resume playback
    @objc optional func nextTrack()
    // Seek to next track
    @objc optional func previousTrack()
    // Seek to previous track
    @objc optional func backTrack()
    // move to beginning of the track, or go to previous track if already at beginning
    @objc optional func setPlayingTrackType(type: AudirvanaTrackType, URL: String!, trackID: Int)
    // set/change playing track (in slave mode). trackID is optional and needed only for Qobuz tracks
    @objc optional func setNextTrackType(type: AudirvanaTrackType, URL: String!, trackID: Int)
    // set/change track to be played after current one (in slave mode). trackID is optional and needed only for Qobuz tracks
    @objc optional func setEventTypesReported(_ eventTypesReported: AudirvanaPlayerStatusEventTypesReported)
}
extension SBApplication: AudirvanaApplication{}

#endif
