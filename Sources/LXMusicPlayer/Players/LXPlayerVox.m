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

@implementation VoxApplication (LXObject)

- (LXMusicTrack *)_currentTrack {
    NSString *persistentID = self.uniqueID;
    if (!persistentID) {
        return nil;
    }
    LXMusicTrack *track = [[LXMusicTrack alloc] initWithPersistentID:persistentID];
    track.title = self.track;
    track.album = self.album;
    track.artist = self.artist;
    track.duration = @(self.totalTime);
    NSString *url = self.trackUrl;
    if (url) {
        // TODO: is this file URL?
        track.fileURL = [NSURL URLWithString:url];
    }
    track.artwork = self.artworkImage;
    return track;
}

- (LXPlaybackState)_playbackState {
    if (self.playerState) {
        return LXPlaybackStatePlaying;
    } else if (self.uniqueID) {
        return LXPlaybackStatePaused;
    } else {
        return LXPlaybackStateStopped;
    }
}

- (LXPlayerState *)_playerState {
    return [LXPlayerState state:self._playbackState playbackTime:self.currentTime];
}

@end

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
            self.currentTrack = self.app._currentTrack;
            self.playerState = self.app._playerState;
        }
        [NSDistributedNotificationCenter.defaultCenter addObserver:self selector:@selector(trackChangedNotification:) name:@"com.coppertino.Vox.trackChanged" object:nil];
        
        dispatch_queue_global_t globalQueue = dispatch_get_global_queue(QOS_CLASS_UTILITY, 0);
        _timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, globalQueue);
        dispatch_source_set_timer(_timer, DISPATCH_TIME_NOW, 1 * NSEC_PER_SEC, 0.1 * NSEC_PER_SEC);
        __weak LXPlayerVox *weakSelf = self;
        dispatch_source_set_event_handler(_timer, ^{
            LXPlayerVox *strongSelf = weakSelf;
            if (!strongSelf.isRunning) { return; }
            [strongSelf setPlayerState:strongSelf.app._playerState tolerate:1.5];
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
    LXMusicTrack *track = self.app._currentTrack;
    if (![self.currentTrack.persistentID isEqualToString:track.persistentID]) {
        self.currentTrack = track;
        self.playerState = self.app._playerState;
    } else {
        [self setPlayerState:self.app._playerState tolerate:1.5];
    }
}

- (void)setPlaybackTime:(NSTimeInterval)playbackTime {
    if (!self.isRunning) { return; }
    self.app.currentTime = playbackTime;
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
    [self.app next];
}

- (void)skipToPreviousItem {
    if (!self.isRunning) { return; }
    [self.app previous];
}

@end
