//
//  LXPlayerState.h
//  This file is part of LyricsX - https://github.com/ddddxxx/LyricsX
//
//  Copyright (C) 2017  Xander Deng
//  Licensed under GPL v3 - https://www.gnu.org/licenses/gpl-3.0.html
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, LXPlaybackState) {
    LXPlaybackStatePlaying,
    LXPlaybackStatePaused,
    LXPlaybackStateStopped,
    LXPlaybackStateFastForwarding,
    LXPlaybackStateRewinding,
};

@interface LXPlayerState : NSObject<NSCopying>

- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)stopped;
+ (instancetype)playingWithStartTime:(NSDate *)date;
+ (instancetype)state:(LXPlaybackState)state playbackTime:(NSTimeInterval)time;

- (LXPlaybackState)state;
- (NSTimeInterval)playbackTime;
- (nullable NSDate *)startTime;
- (BOOL)isPlaying;

- (BOOL)isEqualToState:(LXPlayerState *)state;
- (BOOL)isApproximateEqualToState:(LXPlayerState *)state tolerate:(NSTimeInterval)tolerate;

@end

NS_ASSUME_NONNULL_END
