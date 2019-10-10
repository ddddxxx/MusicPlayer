//
//  LXMusicPlayerController.m
//  This file is part of LyricsX - https://github.com/ddddxxx/LyricsX
//
//  Copyright (C) 2017  Xander Deng
//  Licensed under GPL v3 - https://www.gnu.org/licenses/gpl-3.0.html
//

#import "LXScriptingMusicPlayer+Private.h"

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
        return nil;
    } else if ([name isEqualToString:LXMusicPlayerNameSwinsian]) {
        return nil;
    } else {
        return nil;
    }
}

- (instancetype)init {
    assert([self isMemberOfClass:[LXScriptingMusicPlayer class]]);
    self = [super init];
    _playerState = LXPlayerState.stopped;
    NSArray *ids = LXMusicPlayerNameGetCandidateBundleID(self.class.playerName);
    for (NSString *bundleID in ids) {
        SBApplication *app = [[SBApplication alloc] initWithBundleIdentifier:bundleID];
        if (app) {
            _originalPlayer = app;
            _playerBundleID = bundleID;
            return self;
        }
    }
    return nil;
}

- (LXMusicPlayerName)playerName {
    return self.class.playerName;
}

- (BOOL)isRunning {
    return self.originalPlayer.isRunning;
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

@end
