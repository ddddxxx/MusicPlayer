//
//  LXPlayerAudirvana.m
//  This file is part of LyricsX - https://github.com/ddddxxx/LyricsX
//
//  Copyright (C) 2017  Xander Deng
//  Licensed under GPL v3 - https://www.gnu.org/licenses/gpl-3.0.html
//

#if OS_MACOS || (TARGET_OS_MAC && !TARGET_OS_IPHONE)

#import "LXScriptingMusicPlayer+Private.h"
#import "LXMusicTrack+Private.h"
#import "Audirvana.h"

static LXMusicTrack* currentTrack(AudirvanaApplication *app) {
    NSString *title = app.playingTrackTitle;
    NSString *album = app.playingTrackAlbum;
    NSInteger duration = app.playingTrackDuration;
    if (!title) {
        return nil;
    }
    NSString *persistentID = [NSString stringWithFormat:@"Audirvana-%@-%@-%ld", title, album, duration];
    LXMusicTrack *track = [[LXMusicTrack alloc] initWithPersistentID:persistentID];
    track.title = title;
    track.album = album;
    track.artist = app.playingTrackArtist;
    track.duration = @(duration);
    NSData *artworkData = app.playingTrackAirfoillogo;
    if (artworkData) {
        track.artwork = [[NSImage alloc] initWithData:artworkData];
    }
    return track;
}

static LXPlaybackState playbackState(AudirvanaApplication *app) {
    switch (app.playerState) {
        case AudirvanaPlayerStatusStopped: return LXPlaybackStateStopped;
        case AudirvanaPlayerStatusPlaying: return LXPlaybackStatePlaying;
        case AudirvanaPlayerStatusPaused: return LXPlaybackStatePaused;
        default: return LXPlaybackStateStopped;
    }
}

static LXPlayerState* playerState(AudirvanaApplication *app) {
    return [LXPlayerState state:playbackState(app) playbackTime:app.playerPosition];
}

@implementation LXPlayerAudirvana

+ (LXMusicPlayerName)playerName {
    return LXMusicPlayerNameAudirvana;
}

- (AudirvanaApplication *)app {
    return (AudirvanaApplication *)super.originalPlayer;
}

- (instancetype)init {
    if ((self = [super init])) {
        if (self.isRunning) {
            self.currentTrack = currentTrack(self.app);
            self.playerState = playerState(self.app);
            [self.app setEventTypesReported:AudirvanaPlayerStatusEventTypesReportedTrackChanged];
        }
        [NSDistributedNotificationCenter.defaultCenter addObserver:self selector:@selector(playerInfoNotification:) name:@"com.audirvana.audirvana-plus.playerStatus" object:nil];
        [NSWorkspace.sharedWorkspace.notificationCenter addObserver:self selector:@selector(appDidLaunchNotification) name:NSWorkspaceDidLaunchApplicationNotification object:nil];
    }
    return self;
}

- (void)dealloc {
    [NSDistributedNotificationCenter.defaultCenter removeObserver:self];
}

- (void)playerInfoNotification:(NSNotification *)notification {
    if (!self.isRunning) { return; }
    LXMusicTrack *track = currentTrack(self.app);
    if (![self.currentTrack.persistentID isEqualToString:track.persistentID]) {
        NSString *path = notification.userInfo[@"PlayingTrackURL"];
        if (path) {
            // TODO: is this file URL?
            track.fileURL = [NSURL URLWithString:path];
        }
        self.currentTrack = track;
        self.playerState = playerState(self.app);
    } else {
        [self setPlayerState:playerState(self.app) tolerate:1.5];
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

- (void)updatePlayerState {
    if (!self.isRunning) { return; }
    LXMusicTrack *track = currentTrack(self.app);
    LXPlayerState *state = playerState(self.app);
    if ([self.currentTrack.persistentID isEqualToString:track.persistentID]) {
        [self setPlayerState:state tolerate:1.5];
    } else {
        self.currentTrack = track;
        self.playerState = state;
    }
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

#endif
