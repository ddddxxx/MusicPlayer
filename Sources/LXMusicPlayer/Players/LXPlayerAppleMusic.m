//
//  LXPlayerAppleMusic.m
//  LyricsX - https://github.com/ddddxxx/LyricsX
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

#import "LXScriptingMusicPlayer+Private.h"
#import "LXMusicTrack+Private.h"
#import "Music.h"

static LXMusicTrack* currentTrack(MusicApplication *app) {
    MusicTrack *t = app.currentTrack;
    if (t && (t.mediaKind==MusicEMdKSong || t.mediaKind==MusicEMdKMusicVideo || t.mediaKind==0) && app.currentStreamURL==nil) {
        return [[LXAppleMusicTrack alloc] initWithSBTrack:t];
    } else {
        return nil;
    }
}

static LXPlaybackState playbackState(MusicApplication *app) {
    switch (app.playerState) {
        case MusicEPlSStopped: return LXPlaybackStateStopped;
        case MusicEPlSPlaying: return LXPlaybackStatePlaying;
        case MusicEPlSPaused: return LXPlaybackStatePaused;
        case MusicEPlSFastForwarding: return LXPlaybackStateFastForwarding;
        case MusicEPlSRewinding: return LXPlaybackStateRewinding;
        default: return LXPlaybackStateStopped;
    }
}

static LXPlayerState* playerState(MusicApplication *app) {
    return [LXPlayerState state:playbackState(app) playbackTime:app.playerPosition];
}

@implementation LXPlayerAppleMusic

+ (LXMusicPlayerName)playerName {
    return LXMusicPlayerNameAppleMusic;
}

- (MusicApplication *)app {
    return (MusicApplication *)super.originalPlayer;
}

- (instancetype)init {
    if ((self = [super init])) {
        if (self.isRunning) {
            self.currentTrack = currentTrack(self.app);
            self.playerState = playerState(self.app);
        }
        [NSDistributedNotificationCenter.defaultCenter addObserver:self selector:@selector(playerInfoNotification:) name:@"com.apple.iTunes.playerInfo" object:nil];
    }
    return self;
}

- (void)dealloc {
    [NSDistributedNotificationCenter.defaultCenter removeObserver:self];
}

- (void)playerInfoNotification:(NSNotification *)notification {
    if (!self.isRunning) { return; }
    NSString *persistentID = [NSString stringWithFormat:@"%08lX", (unsigned long)[notification.userInfo[@"PersistentID"] unsignedIntegerValue]];
    if (notification.userInfo[@"PersistentID"] &&
        ![self.currentTrack.persistentID isEqualToString:persistentID] &&
        ![[self.currentTrack.persistentID substringFromIndex:8] isEqualToString:persistentID]) {
        self.currentTrack = currentTrack(self.app);
        self.playerState = playerState(self.app);
        return;
    }
    NSString *stateDesc = notification.userInfo[@"Player State"];
    LXPlayerState *state;
    if ([stateDesc isEqualToString:@"Stopped"]) {
        state = LXPlayerState.stopped;
    } else if ([stateDesc isEqualToString:@"Paused"]) {
        state = [LXPlayerState state:LXPlaybackStatePaused playbackTime:self.playerState.playbackTime];
    } else {
        state = playerState(self.app);
    }
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
