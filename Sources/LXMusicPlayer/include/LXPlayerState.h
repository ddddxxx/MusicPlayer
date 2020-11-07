//
//  LXPlayerState.h
//  LyricsX - https://github.com/ddddxxx/LyricsX
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at https://mozilla.org/MPL/2.0/.
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
