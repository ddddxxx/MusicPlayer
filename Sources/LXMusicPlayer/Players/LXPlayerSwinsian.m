//
//  LXPlayerSwinsian.m
//  LyricsX - https://github.com/ddddxxx/LyricsX
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

#import "LXScriptingMusicPlayer+Private.h"
#import "LXMusicTrack+Private.h"
#import "Swinsian.h"

NSNotificationName const SwinsianPlayingNotification = @"com.swinsian.Swinsian-Track-Playing";
NSNotificationName const SwinsianPausedNotification = @"com.swinsian.Swinsian-Track-Paused";
NSNotificationName const SwinsianStoppedNotification = @"com.swinsian.Swinsian-Track-Stopped";

static LXMusicTrack* currentTrack(SwinsianApplication *app) {
    SwinsianTrack *t = app.currentTrack;
    if (t) {
        return [[LXSwinsianTrack alloc] initWithSBTrack:t];
    } else {
        return nil;
    }
}

static LXPlaybackState playbackState(SwinsianApplication *app) {
    switch (app.playerState) {
        case SwinsianPlayerStateStopped: return LXPlaybackStateStopped;
        case SwinsianPlayerStatePlaying: return LXPlaybackStatePlaying;
        case SwinsianPlayerStatePaused: return LXPlaybackStatePaused;
        default: return LXPlaybackStateStopped;
    }
}

static LXPlayerState* playerState(SwinsianApplication *app) {
    return [LXPlayerState state:playbackState(app) playbackTime:app.playerPosition];
}

@implementation LXPlayerSwinsian

+ (LXMusicPlayerName)playerName {
    return LXMusicPlayerNameSwinsian;
}

- (SwinsianApplication *)app {
    return (SwinsianApplication *)super.originalPlayer;
}

- (instancetype)init {
    if ((self = [super init])) {
        if (self.isRunning) {
            self.currentTrack = currentTrack(self.app);
            self.playerState = playerState(self.app);
        }
        [NSDistributedNotificationCenter.defaultCenter addObserver:self selector:@selector(playerInfoNotification:) name:SwinsianPlayingNotification object:nil];
        [NSDistributedNotificationCenter.defaultCenter addObserver:self selector:@selector(playerInfoNotification:) name:SwinsianPausedNotification object:nil];
        [NSDistributedNotificationCenter.defaultCenter addObserver:self selector:@selector(playerInfoNotification:) name:SwinsianStoppedNotification object:nil];
    }
    return self;
}

- (void)dealloc {
    [NSDistributedNotificationCenter.defaultCenter removeObserver:self];
}

- (void)playerInfoNotification:(NSNotification *)notification {
    if (!self.isRunning) { return; }
    if ([notification.name isEqualToString:SwinsianPlayingNotification]) {
        LXMusicTrack *track = currentTrack(self.app);
        if (![self.currentTrack.persistentID isEqualToString:track.persistentID]) {
            self.currentTrack = track;
            self.playerState = playerState(self.app);
        }
    } else if ([notification.name isEqualToString:SwinsianPausedNotification]) {
        self.playerState = playerState(self.app);
    } else if ([notification.name isEqualToString:SwinsianStoppedNotification]) {
        self.currentTrack = nil;
        self.playerState = LXPlayerState.stopped;
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
