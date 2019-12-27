//
//  LXPlayerState.m
//  This file is part of LyricsX - https://github.com/ddddxxx/LyricsX
//
//  Copyright (C) 2017  Xander Deng
//  Licensed under GPL v3 - https://www.gnu.org/licenses/gpl-3.0.html
//

#import "LXPlayerState+Private.h"

@implementation LXPlayerState

- (id)copyWithZone:(NSZone *)zone {
    return [[[self class] allocWithZone:zone] initInternal];
}

- (instancetype)init {
    return [LXStoppedPlayerState stopped];
}

- (instancetype)initInternal {
    self = [super init];
    return self;
}

+ (instancetype)stopped {
    return [LXStoppedPlayerState stopped];
}

+ (instancetype)playingWithStartTime:(NSDate *)date {
    return [[LXStartTimePlayerState alloc] initWithStartTime:date];
}

+ (instancetype)state:(LXPlaybackState)state playbackTime:(NSTimeInterval)time {
    switch (state) {
        case LXPlaybackStateStopped:
            return [self stopped];
        case LXPlaybackStatePlaying:
            return [self playingWithStartTime:[NSDate.date dateByAddingTimeInterval:-time]];
        default:
            return [[LXCurrentTimePlayerState alloc] initWithState:state playbackTime:time];
    }
}

- (LXPlaybackState)state {
    [self doesNotRecognizeSelector:_cmd];
}

- (NSTimeInterval)playbackTime {
    [self doesNotRecognizeSelector:_cmd];
}

- (nullable NSDate *)startTime {
    return nil;
}

- (BOOL)isPlaying {
    switch (self.state) {
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

- (BOOL)isEqual:(id)object {
    return [object isKindOfClass:LXPlayerState.class] && [self isEqualToState:object];
}

- (BOOL)isEqualToState:(LXPlayerState *)state {
    return [self isApproximateEqualToState:state tolerate:0];
}

- (BOOL)isApproximateEqualToState:(LXPlayerState *)state tolerate:(NSTimeInterval)tolerate {
    [self doesNotRecognizeSelector:_cmd];
}

@end

@implementation LXStoppedPlayerState

+ (instancetype)stopped {
    static LXStoppedPlayerState *stopped = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        stopped = [[super allocWithZone:nil] initInternal];
    });
    return stopped;
}

+ (instancetype)allocWithZone:(struct _NSZone *)zone {
    return [self stopped];
}

+ (instancetype)alloc {
    return [self stopped];
}

- (id)copyWithZone:(NSZone *)zone {
    return [LXStoppedPlayerState stopped];
}

- (LXPlaybackState)state {
    return LXPlaybackStateStopped;
}

- (NSTimeInterval)playbackTime {
    return 0;
}

- (BOOL)isPlaying {
    return NO;
}

- (BOOL)isEqual:(id)other {
    return self == other;
}

- (BOOL)isEqualToState:(LXPlayerState *)state {
    return self == state;
}

- (BOOL)isApproximateEqualToState:(LXPlayerState *)state tolerate:(NSTimeInterval)tolerate {
    return self == state;
}

@end

@implementation LXStartTimePlayerState

- (id)copyWithZone:(NSZone *)zone {
    LXStartTimePlayerState *obj = [super copyWithZone:zone];
    obj->_startTime = [_startTime copyWithZone:zone];
    return obj;
}

- (instancetype)initWithStartTime:(NSDate *)date {
    self = [super initInternal];
    _startTime = date;
    return self;
}

- (LXPlaybackState)state {
    return LXPlaybackStatePlaying;
}

- (NSTimeInterval)playbackTime {
    return -_startTime.timeIntervalSinceNow;
}

- (BOOL)isPlaying {
    return YES;
}

- (BOOL)isEqualToState:(LXPlayerState *)state {
    return [state isMemberOfClass:[LXStartTimePlayerState class]] && [self.startTime isEqualToDate:state.startTime];
}

- (BOOL)isApproximateEqualToState:(LXPlayerState *)state tolerate:(NSTimeInterval)tolerate {
    return [state isMemberOfClass:[LXStartTimePlayerState class]] && fabs([_startTime timeIntervalSinceDate:state.startTime]) < tolerate;
}

@end

@implementation LXCurrentTimePlayerState

- (id)copyWithZone:(NSZone *)zone {
    LXCurrentTimePlayerState *obj = [super copyWithZone:zone];
    obj->_state = _state;
    obj->_currentTime = _currentTime;
    return obj;
}

- (instancetype)initWithState:(LXPlaybackState)state playbackTime:(NSTimeInterval)time {
    assert(state == LXPlaybackStatePaused || state == LXPlaybackStateFastForwarding || state == LXPlaybackStateRewinding);
    self = [super initInternal];
    _state = state;
    _currentTime = time;
    return self;
}

- (NSTimeInterval)playbackTime {
    return _currentTime;
}

- (BOOL)isEqualToState:(LXPlayerState *)state {
    return [state isMemberOfClass:[LXCurrentTimePlayerState class]] && (self.state == state.state) && self.currentTime == ((LXCurrentTimePlayerState*)state).currentTime;
}

- (BOOL)isApproximateEqualToState:(LXPlayerState *)state tolerate:(NSTimeInterval)tolerate {
    return [state isMemberOfClass:[LXCurrentTimePlayerState class]] && (self.state == state.state) && fabs(self.currentTime-((LXCurrentTimePlayerState*)state).currentTime) < tolerate;
}

@end
