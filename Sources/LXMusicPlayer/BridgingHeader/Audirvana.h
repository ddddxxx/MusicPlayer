/*
 * Audirvana.h
 */

#if TARGET_OS_MAC

#import <AppKit/AppKit.h>
#import <ScriptingBridge/ScriptingBridge.h>


@class AudirvanaApplication;

typedef NS_ENUM(AEKeyword, AudirvanaPlayerStatus) {
	AudirvanaPlayerStatusStopped = 'kPSS' /* Playback Stopped */,
	AudirvanaPlayerStatusPlaying = 'kPSP' /* Playing */,
	AudirvanaPlayerStatusPaused = 'kPSp' /* Playback Paused */
};

typedef NS_ENUM(AEKeyword, AudirvanaPlayerControlType) {
	AudirvanaPlayerControlTypeLibrary = 'kCLb' /* Library mode, no external control */,
	AudirvanaPlayerControlTypeITunesIntegrated = 'kCiT' /* iTunes integrated mode, fully controlled by iTunes */,
    
    /// unavailable in Audirvana 3.5+
    AudirvanaPlayerControlTypeStandalone = 'kCSt' /* Standalone mode, no external control */,
    /// unavailable in Audirvana 3.5+
    AudirvanaPlayerControlTypeSlave = 'kCSl' /* Slave mode, fully controlled by Apple Events */
};

typedef NS_ENUM(AEKeyword, AudirvanaPlayerStatusEventTypesReported) {
	AudirvanaPlayerStatusEventTypesReportedNone = 'kEvN' /* No event reported/pushed */,
	AudirvanaPlayerStatusEventTypesReportedTrackChanged = 'kEvT' /* Tracks change, playback status pushed as events\nReported in notification com.audirvana.audirvana-plus.playerStatus with info dictionary containing:\nplayer status (Stopped, Playing, Paused) in key PlayerStatus\nPlaying track URL (if not stopped) in key PlayingTrackURL */,
	AudirvanaPlayerStatusEventTypesReportedTrackAndPosition = 'kEvP' /* Tracks, playback status, and play position (every second) pushed as events\nPlay position is reported in notification com.audirvana.audirvana-plus.playerPosition as a double (posInSec key) */
};

typedef NS_ENUM(AEKeyword, AudirvanaTrackType) {
	AudirvanaTrackTypeAudioFile = 'kTFl' /* Audio file, locally (file://) or http (http://) readable */,
	AudirvanaTrackTypeQobuzTrack = 'kTQB' /* Qobuz track, streamed from qobuz.com */,
    
    /// only available in Audirvana 3.5+
	AudirvanaTrackTypeTidalTrack = 'kTTD' /* Tidal track, streamed from tidal.com */,
    /// only available in Audirvana 3.5+
	AudirvanaTrackTypeHraTrack = 'kTHR' /* Qobuz track, streamed from highresaudio.com */
};



/*
 * Audirvana Scripting Suite
 */

// Audirvana application class.
@interface AudirvanaApplication : SBApplication

@property (readonly) AudirvanaPlayerStatus playerState;  // Playback engine state (stopped, playing, ...)
@property AudirvanaPlayerControlType controlType;  // Player control type (standalone, by iTunes, by Apple Events)
@property AudirvanaPlayerStatusEventTypesReported eventTypesReported;  // Type of events (playback status, track change, player position within track (only in slave mode)) to be pushed
@property double playerPosition;  // player position in the track in seconds
@property (copy, readonly) NSString *version;  // Version of Audirvana
@property (copy, readonly) NSString *playingTrackTitle;  // Title of currently playing track.
@property (copy, readonly) NSString *playingTrackArtist;  // Artist of currently playing track.
@property (copy, readonly) NSString *playingTrackAlbum;  // Album of currently playing track.
@property (readonly) NSInteger playingTrackDuration;  // Duration of currently playing track.
@property (copy, readonly) NSData *playingTrackAirfoillogo;  // Logo for the currently playing track.

- (void) playpause;  // Start playback, toggle play pause mode
- (void) stop;  // Stop playback
- (void) pause;  // Pause playback
- (void) resume;  // Resume playback
- (void) nextTrack;  // Seek to next track
- (void) previousTrack;  // Seek to previous track
- (void) backTrack;  // move to beginning of the track, or go to previous track if already at beginning
- (void) setPlayingTrackType:(AudirvanaTrackType)type URL:(NSString *)URL trackID:(NSInteger)trackID;  // set/change playing track (in slave mode). trackID is optional and needed only for Qobuz tracks
- (void) setNextTrackType:(AudirvanaTrackType)type URL:(NSString *)URL trackID:(NSInteger)trackID;  // set/change track to be played after current one (in slave mode). trackID is optional and needed only for Qobuz tracks

@end

#endif
