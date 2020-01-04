//
//  LXPlayerSpotify.m
//  This file is part of LyricsX - https://github.com/ddddxxx/LyricsX
//
//  Copyright (C) 2017  Xander Deng
//  Licensed under GPL v3 - https://www.gnu.org/licenses/gpl-3.0.html
//

#if TARGET_OS_MAC

#import "LXScriptingMusicPlayer+Private.h"
#import "LXMusicTrack+Private.h"
#import "Spotify.h"

static LXMusicTrack* currentTrack(SpotifyApplication *app) {
    SpotifyTrack *t = app.currentTrack;
    if (t) {
        return [[LXSpotifyTrack alloc] initWithSBTrack:t];
    } else {
        return nil;
    }
}

static LXPlaybackState playbackState(SpotifyApplication *app) {
    switch (app.playerState) {
        case SpotifyEPlSStopped: return LXPlaybackStateStopped;
        case SpotifyEPlSPlaying: return LXPlaybackStatePlaying;
        case SpotifyEPlSPaused: return LXPlaybackStatePaused;
        default: return LXPlaybackStateStopped;
    }
}

static LXPlayerState* playerState(SpotifyApplication *app) {
    return [LXPlayerState state:playbackState(app) playbackTime:app.playerPosition];
}

@implementation LXPlayerSpotify

+ (LXMusicPlayerName)playerName {
    return LXMusicPlayerNameSpotify;
}

- (SpotifyApplication *)app {
    return (SpotifyApplication *)super.originalPlayer;
}

- (instancetype)init {
    if ((self = [super init])) {
        if (self.isRunning) {
            self.currentTrack = currentTrack(self.app);
            self.playerState = playerState(self.app);
        }
        [NSDistributedNotificationCenter.defaultCenter addObserver:self selector:@selector(playerInfoNotification:) name:@"com.spotify.client.PlaybackStateChanged" object:nil];
    }
    return self;
}

- (void)dealloc {
    [NSDistributedNotificationCenter.defaultCenter removeObserver:self];
}

- (void)playerInfoNotification:(NSNotification *)notification {
    if (!self.isRunning) { return; }
    NSString *persistentID = notification.userInfo[@"Track ID"];
    if (![self.currentTrack.persistentID isEqualToString:persistentID]) {
        self.currentTrack = currentTrack(self.app);
    }
    LXPlaybackState playbackState;
    NSString *stateStr = notification.userInfo[@"Player State"];
    NSTimeInterval position = [notification.userInfo[@"Playback Position"] doubleValue];
    if ([stateStr isEqualToString:@"Playing"]) {
        playbackState = LXPlaybackStatePlaying;
    } else if ([stateStr isEqualToString:@"Paused"]) {
        playbackState = LXPlaybackStatePaused;
    } else {
        playbackState = LXPlaybackStateStopped;
    }
    LXPlayerState *state = [LXPlayerState state:playbackState playbackTime:position];
    [self setPlayerState:state tolerate:1.5];
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
    [self.app play];
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
