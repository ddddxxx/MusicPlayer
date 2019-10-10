//
//  LXPlayerAudirvana.m
//  This file is part of LyricsX - https://github.com/ddddxxx/LyricsX
//
//  Copyright (C) 2017  Xander Deng
//  Licensed under GPL v3 - https://www.gnu.org/licenses/gpl-3.0.html
//

#import "LXScriptingMusicPlayer+Private.h"
#import "LXMusicTrack+Private.h"
#import "Audirvana.h"

@implementation AudirvanaApplication (LXObject)

- (LXMusicTrack *)_currentTrack {
    NSString *title = self.playingTrackTitle;
    NSString *album = self.playingTrackAlbum;
    NSInteger duration = self.playingTrackDuration;
    if (!title) {
        return nil;
    }
    NSString *persistentID = [NSString stringWithFormat:@"Audirvana-%@-%@-%ld", title, album, duration];
    LXMusicTrack *track = [[LXMusicTrack alloc] initWithPersistentID:persistentID];
    track.title = title;
    track.album = album;
    track.artist = self.playingTrackArtist;
    track.duration = @(duration);
    NSData *artworkData = self.playingTrackAirfoillogo;
    if (artworkData) {
        track.artwork = [[NSImage alloc] initWithData:artworkData];
    }
    return track;
}

- (LXPlaybackState)_playbackState {
    switch (self.playerState) {
        case AudirvanaPlayerStatusStopped: return LXPlaybackStateStopped;
        case AudirvanaPlayerStatusPlaying: return LXPlaybackStatePlaying;
        case AudirvanaPlayerStatusPaused: return LXPlaybackStatePaused;
        default: return LXPlaybackStateStopped;
    }
}

- (LXPlayerState *)_playerState {
    return [LXPlayerState state:self._playbackState playbackTime:self.playerPosition];
}

@end

@implementation LXPlayerAudirvana {
    dispatch_source_t _timer;
}

+ (LXMusicPlayerName)playerName {
    return LXMusicPlayerNameAudirvana;
}

- (AudirvanaApplication *)app {
    return (AudirvanaApplication *)super.originalPlayer;
}

- (instancetype)init {
    if ((self = [super init])) {
        if (self.isRunning) {
            self.currentTrack = self.app._currentTrack;
            self.playerState = self.app._playerState;
            [self.app setEventTypesReported:AudirvanaPlayerStatusEventTypesReportedTrackChanged];
        }
        [NSDistributedNotificationCenter.defaultCenter addObserver:self selector:@selector(playerInfoNotification:) name:@"com.audirvana.audirvana-plus.playerStatus" object:nil];
        [NSWorkspace.sharedWorkspace.notificationCenter addObserver:self selector:@selector(appDidLaunchNotification) name:NSWorkspaceDidLaunchApplicationNotification object:nil];
    }
    return self;
}

- (void)dealloc {
    [NSDistributedNotificationCenter.defaultCenter removeObserver:self];
    dispatch_cancel(_timer);
}

- (void)playerInfoNotification:(NSNotification *)notification {
    if (!self.isRunning) { return; }
    LXMusicTrack *track = self.app._currentTrack;
    if (![self.currentTrack.persistentID isEqualToString:track.persistentID]) {
        NSString *path = notification.userInfo[@"PlayingTrackURL"];
        if (path) {
            // TODO: is this file URL?
            track.fileURL = [NSURL URLWithString:path];
        }
        self.currentTrack = track;
        self.playerState = self.app._playerState;
    } else {
        [self setPlayerState:self.app._playerState tolerate:1.5];
    }
}

- (void)appDidLaunchNotification:(NSNotification *)notification {
    if ([notification.userInfo[@"NSApplicationBundleIdentifier"] isEqualToString:self.playerBundleID]) {
        [self.app setEventTypesReported:AudirvanaPlayerStatusEventTypesReportedTrackChanged];
    }
}

- (void)setPlaybackTime:(NSTimeInterval)playbackTime {
    if (!self.isRunning) { return; }
    self.app.playerPosition = playbackTime;
    self.playerState = [LXPlayerState state:self.playerState.state playbackTime:playbackTime];
}

- (void)updatePlaybackTime {
    if (!self.isRunning) { return; }
    LXPlayerState *state = self.app._playerState;
    [self setPlayerState:state tolerate:1.5];
}

- (void)resume {
    if (!self.isRunning) { return; }
    [self.app resume];
}

- (void)pause {
    if (!self.isRunning) { return; }
    [self.app pause];
}

- (void)playPause {
    if (!self.isRunning) { return; }
    [self.app playpause];
}

- (void)skipToNextItem {
    if (!self.isRunning) { return; }
    [self.app nextTrack];
}

- (void)skipToPreviousItem {
    if (!self.isRunning) { return; }
    [self.app previousTrack];
}

@end
