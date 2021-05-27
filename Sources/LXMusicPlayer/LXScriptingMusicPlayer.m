//
//  LXMusicPlayerController.m
//  LyricsX - https://github.com/ddddxxx/LyricsX
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

#import <AppKit/AppKit.h>
#import "LXScriptingMusicPlayer+Private.h"
#import "LXWeakProxy.h"

@implementation LXScriptingMusicPlayer

+ (LXMusicPlayerName)playerName {
    [self doesNotRecognizeSelector:_cmd];
}

+ (instancetype)playerWithName:(LXMusicPlayerName)name {
    if ([name isEqualToString:LXMusicPlayerNameAppleMusic]) {
        return [[LXPlayerAppleMusic alloc] init];
    } else if ([name isEqualToString:LXMusicPlayerNameSpotify]) {
        return [[LXPlayerSpotify alloc] init];
    } else if ([name isEqualToString:LXMusicPlayerNameVox]) {
        return [[LXPlayerVox alloc] init];
    } else if ([name isEqualToString:LXMusicPlayerNameAudirvana]) {
        return [[LXPlayerAudirvana alloc] init];
    } else if ([name isEqualToString:LXMusicPlayerNameSwinsian]) {
        return [[LXPlayerSwinsian alloc] init];
    } else {
        return nil;
    }
}

- (instancetype)init {
    assert(![self isMemberOfClass:[LXScriptingMusicPlayer class]]);
    self = [super init];
    _playerState = LXPlayerState.stopped;
    NSArray *ids = LXMusicPlayerNameGetCandidateBundleID(self.class.playerName);
    for (NSString *bundleID in ids) {
        SBApplication *app = [[SBApplication alloc] initWithBundleIdentifier:bundleID];
        if (app) {
            _originalPlayer = app;
            _playerBundleID = bundleID;
            _running = app.isRunning;
            [NSWorkspace.sharedWorkspace.notificationCenter addObserver:self selector:@selector(didTerminateApplication:) name:NSWorkspaceDidTerminateApplicationNotification object:nil];
            [NSWorkspace.sharedWorkspace.notificationCenter addObserver:self selector:@selector(didLaunchApplication:) name:NSWorkspaceDidLaunchApplicationNotification object:nil];
            return self;
        }
    }
    return nil;
}

- (void)dealloc {
    [NSNotificationCenter.defaultCenter removeObserver:self];
    [self.nextTrackUpdatingTimer invalidate];
}

- (void)didTerminateApplication:(NSNotification *)notification {
    NSRunningApplication *app = notification.userInfo[NSWorkspaceApplicationKey];
    if ([app.bundleIdentifier isEqualToString:self.playerBundleID]) {
        self.running = false;
        self.playerState = LXPlayerState.stopped;
        self.currentTrack = nil;
    }
}

- (void)didLaunchApplication:(NSNotification *)notification {
    NSRunningApplication *app = notification.userInfo[NSWorkspaceApplicationKey];
    if ([app.bundleIdentifier isEqualToString:self.playerBundleID]) {
        self.running = true;
    }
}

- (LXMusicPlayerName)playerName {
    return self.class.playerName;
}

- (NSTimeInterval)playbackTime {
    return self.playerState.playbackTime;
}

- (void)setPlaybackTime:(NSTimeInterval)playbackTime {}

- (void)setPlayerState:(LXPlayerState *)playerState tolerate:(NSTimeInterval)tolerate {
    if (![self.playerState isApproximateEqualToState:playerState tolerate:tolerate]) {
        self.playerState = playerState;
    }
}

- (void)updatePlayerState {}

// Force update at the end of the track

- (void)rescheduleNextTrackUpdating {
    [self.nextTrackUpdatingTimer invalidate];
    NSNumber *duration = self.currentTrack.duration;
    if (self.playerState.isPlaying && duration) {
        NSTimeInterval dt = duration.doubleValue - self.playerState.playbackTime;
        self.nextTrackUpdatingTimer = [NSTimer scheduledTimerWithTimeInterval:dt target:[[LXWeakProxy alloc] initWithObject:self] selector:@selector(updatePlayerState) userInfo:nil repeats:false];
        self.nextTrackUpdatingTimer.tolerance = 1.5;
    }
}

- (void)setCurrentTrack:(LXMusicTrack *)currentTrack {
    _currentTrack = currentTrack;
    [self rescheduleNextTrackUpdating];
}

- (void)setPlayerState:(LXPlayerState *)playerState {
    _playerState = playerState;
    [self rescheduleNextTrackUpdating];
}

@end
