//
//  LXPlayerState.m
//  This file is part of LyricsX - https://github.com/ddddxxx/LyricsX
//
//  Copyright (C) 2017  Xander Deng
//  Licensed under GPL v3 - https://www.gnu.org/licenses/gpl-3.0.html
//

#import "LXPlayerState.h"

@interface LXPlayerState()

@property (nonatomic) NSTimeInterval currentTime;
@property (nonatomic, nullable) NSDate *startTime;

- (instancetype)initWithState:(LXPlaybackState)state currentTime:(NSTimeInterval)time startTime:(nullable NSDate *)date NS_DESIGNATED_INITIALIZER;

@end

@implementation LXPlayerState

- (nonnull id)copyWithZone:(nullable NSZone *)zone {
    return [[[self class] allocWithZone:zone] initWithState:_state currentTime:_currentTime startTime:[_startTime copyWithZone:zone]];
}

- (instancetype)initWithState:(LXPlaybackState)state currentTime:(NSTimeInterval)time startTime:(NSDate *)date {
    self = [super init];
    _state = state;
    _currentTime = time;
    _startTime = date;
    return self;
}

+ (instancetype)stopped {
    return [[self alloc] initWithState:LXPlaybackStateStopped currentTime:0 startTime:nil];
}

+ (instancetype)playingWithStartTime:(NSDate *)date {
    return [[self alloc] initWithState:LXPlaybackStatePlaying currentTime:0 startTime:date];
}

+ (instancetype)state:(LXPlaybackState)state playbackTime:(NSTimeInterval)time {
    switch (state) {
        case LXPlaybackStateStopped:
            return [self stopped];
        case LXPlaybackStatePlaying:
            return [self playingWithStartTime:[NSDate.date dateByAddingTimeInterval:-time]];
        default:
            return [[self alloc] initWithState:state currentTime:time startTime:nil];
    }
}

- (BOOL)isPlaying {
    switch (_state) {
        case LXPlaybackStatePaused:
        case LXPlaybackStateStopped:
            return NO;
        case LXPlaybackStatePlaying:
        case LXPlaybackStateFastForwarding:
        case LXPlaybackStateRewinding:
            return YES;
        default:
            return NO;
    }
}

- (NSTimeInterval)playbackTime {
    switch (_state) {
        case LXPlaybackStateStopped:
            return 0;
        case LXPlaybackStatePlaying:
            return -_startTime.timeIntervalSinceNow;
        default:
            return _currentTime;
    }
}

- (BOOL)isEqual:(id)object {
    return [object isKindOfClass:LXPlayerState.class] && [self isEqualToState:object];
}

- (BOOL)isEqualToState:(LXPlayerState *)state {
    return [self isApproximateEqualToState:state tolerate:0];
}

- (BOOL)isApproximateEqualToState:(LXPlayerState *)state tolerate:(NSTimeInterval)tolerate {
    if (_state != state.state) {
        return NO;
    }
    switch (_state) {
        case LXPlaybackStateStopped:
            return YES;
        case LXPlaybackStatePlaying:
            return fabs([_startTime timeIntervalSinceDate:state.startTime]) < tolerate;
        default:
            return fabs(_currentTime - state.currentTime) < tolerate;
    }
}

@end
