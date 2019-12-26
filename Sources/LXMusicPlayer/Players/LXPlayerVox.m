//
//  LXPlayerVox.m
//  This file is part of LyricsX - https://github.com/ddddxxx/LyricsX
//
//  Copyright (C) 2017  Xander Deng
//  Licensed under GPL v3 - https://www.gnu.org/licenses/gpl-3.0.html
//

#import "LXScriptingMusicPlayer+Private.h"
#import "LXMusicTrack+Private.h"
#import "Vox.h"

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
    dispatch_source_t _timer;
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
        
        dispatch_queue_global_t globalQueue = dispatch_get_global_queue(QOS_CLASS_UTILITY, 0);
        _timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, globalQueue);
        dispatch_source_set_timer(_timer, DISPATCH_TIME_NOW, 1 * NSEC_PER_SEC, 0.1 * NSEC_PER_SEC);
        __weak LXPlayerVox *weakSelf = self;
        dispatch_source_set_event_handler(_timer, ^{
            LXPlayerVox *strongSelf = weakSelf;
            if (!strongSelf.isRunning) { return; }
            [strongSelf setPlayerState:playerState(strongSelf.app) tolerate:1.5];
        });
        dispatch_resume(_timer);
    }
    return self;
}

- (void)dealloc {
    [NSDistributedNotificationCenter.defaultCenter removeObserver:self];
    dispatch_cancel(_timer);
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
