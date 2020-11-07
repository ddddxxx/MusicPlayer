//
//  LXPlayerState+Private.h
//  LyricsX - https://github.com/ddddxxx/LyricsX
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

#import "LXPlayerState.h"

NS_ASSUME_NONNULL_BEGIN

@interface LXPlayerState()

- (instancetype)initInternal;

+ (instancetype)stopped;

@end

@interface LXStoppedPlayerState : LXPlayerState

@end

@interface LXStartTimePlayerState : LXPlayerState

@property (nonatomic) NSDate *startTime;

- (instancetype)initWithStartTime:(NSDate *)date;

@end

@interface LXCurrentTimePlayerState : LXPlayerState

@property (nonatomic) LXPlaybackState state;
@property (nonatomic) NSTimeInterval currentTime;

- (instancetype)initWithState:(LXPlaybackState)state playbackTime:(NSTimeInterval)time;

@end

NS_ASSUME_NONNULL_END
