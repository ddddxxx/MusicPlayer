//
//  LXPlayerVox.m
//  LyricsX - https://github.com/ddddxxx/LyricsX
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

#if OS_MACOS || (TARGET_OS_MAC && !TARGET_OS_IPHONE)

#import "LXScriptingMusicPlayer+Private.h"
#import "LXMusicTrack+Private.h"
#import "Vox.h"
#import "LXWeakProxy.h"

#define VOX_INTERNAL_UPDATE_INTERVAL 2.0

static LXMusicTrack* currentTrack(VoxApplication *app) {
    NSString *persistentID = app.uniqueID;
    if (!persistentID) {
        return nil;
    }
    LXMusicTrack *track = [[LXMusicTrack alloc] initWithPersistentID:persistentID];
    track.title = app.track;
    track.album = app.album;
    track.artist = app.artist;
    track.duration = @(app.totalTime);
    NSString *url = app.trackUrl;
    if (url) {
        // TODO: is this file URL?
        track.fileURL = [NSURL URLWithString:url];
    }
    track.artwork = app.artworkImage;
    return track;
}

static LXPlaybackState playbackState(VoxApplication *app) {
    if (app.playerState) {
        return LXPlaybackStatePlaying;
    } else if (app.uniqueID) {
        return LXPlaybackStatePaused;
    } else {
        return LXPlaybackStateStopped;
    }
}

static LXPlayerState* playerState(VoxApplication *app) {
    return [LXPlayerState state:playbackState(app) playbackTime:app.currentTime];
}

@implementation LXPlayerVox {
    NSTimer *_timer;
}

+ (LXMusicPlayerName)playerName {
    return LXMusicPlayerNameVox;
}

- (VoxApplication *)app {
    return (VoxApplication *)super.originalPlayer;
}

- (instancetype)init {
    if ((self = [super init])) {
        if (self.isRunning) {
            self.currentTrack = currentTrack(self.app);
            self.playerState = playerState(self.app);
        }
        [NSDistributedNotificationCenter.defaultCenter addObserver:self selector:@selector(trackChangedNotification:) name:@"com.coppertino.Vox.trackChanged" object:nil];
        
        _timer = [NSTimer scheduledTimerWithTimeInterval:VOX_INTERNAL_UPDATE_INTERVAL target:[[LXWeakProxy alloc] initWithObject:self] selector:@selector(updatePlayback) userInfo:nil repeats:YES];
        [self rescheduleInternalUpdate];
    }
    return self;
}

- (void)dealloc {
    [NSDistributedNotificationCenter.defaultCenter removeObserver:self];
    [_timer invalidate];
}

- (void)setRunning:(BOOL)running {
    [super setRunning:running];
    [self rescheduleInternalUpdate];
}

- (void)rescheduleInternalUpdate {
    if (self.isRunning) {
        _timer.fireDate = [NSDate dateWithTimeIntervalSinceNow:VOX_INTERNAL_UPDATE_INTERVAL];
    } else {
        _timer.fireDate = NSDate.distantFuture;
    }
}

- (void)trackChangedNotification:(NSNotification *)notification {
    if (!self.isRunning) { return; }
    LXMusicTrack *track = currentTrack(self.app);
    if (![self.currentTrack.persistentID isEqualToString:track.persistentID]) {
        self.currentTrack = track;
        self.playerState = playerState(self.app);
    } else {
        [self setPlayerState:playerState(self.app) tolerate:1.5];
    }
}

- (void)setPlaybackTime:(NSTimeInterval)playbackTime {
    if (!self.isRunning) { return; }
    self.app.currentTime = playbackTime;
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
    [self rescheduleInternalUpdate];
}

- (void)updatePlayback {
    if (!self.isRunning) { return; }
    LXPlayerState *state = playerState(self.app);
    [self setPlayerState:state tolerate:1.5];
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
    [self.app next];
}

- (void)skipToPreviousItem {
    if (!self.isRunning) { return; }
    [self.app previous];
}

@end

#endif
