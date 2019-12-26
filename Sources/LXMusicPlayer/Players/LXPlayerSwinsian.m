//
//  LXPlayerSwinsian.m
//  This file is part of LyricsX - https://github.com/ddddxxx/LyricsX
//
//  Copyright (C) 2017  Xander Deng
//  Licensed under GPL v3 - https://www.gnu.org/licenses/gpl-3.0.html
//

#import "LXScriptingMusicPlayer+Private.h"
#import "LXMusicTrack+Private.h"
#import "Swinsian.h"

NSNotificationName const SwinsianPlayingNotification = @"com.swinsian.Swinsian-Track-Playing";
NSNotificationName const SwinsianPausedNotification = @"com.swinsian.Swinsian-Track-Paused";
NSNotificationName const SwinsianStoppedNotification = @"com.swinsian.Swinsian-Track-Stopped";

@implementation SwinsianApplication (LXObject)

- (LXMusicTrack *)_currentTrack {
    SwinsianTrack *t = self.currentTrack;
    if (t) {
        return [[LXSwinsianTrack alloc] initWithSBTrack:t];
    } else {
        return nil;
    }
}

- (LXPlaybackState)_playbackState {
    switch (self.playerState) {
        case SwinsianPlayerStateStopped: return LXPlaybackStateStopped;
        case SwinsianPlayerStatePlaying: return LXPlaybackStatePlaying;
        case SwinsianPlayerStatePaused: return LXPlaybackStatePaused;
        default: return LXPlaybackStateStopped;
    }
}

- (LXPlayerState *)_playerState {
    return [LXPlayerState state:self._playbackState playbackTime:self.playerPosition];
}

@end

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
            self.currentTrack = self.app._currentTrack;
            self.playerState = self.app._playerState;
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
        LXMusicTrack *track = self.app._currentTrack;
        if (![self.currentTrack.persistentID isEqualToString:track.persistentID]) {
            self.currentTrack = track;
            self.playerState = self.app._playerState;
        }
    } else if ([notification.name isEqualToString:SwinsianPausedNotification]) {
        self.playerState = self.app._playerState;
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
    LXMusicTrack *track = self.app._currentTrack;
    LXPlayerState *state = self.app._playerState;
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
