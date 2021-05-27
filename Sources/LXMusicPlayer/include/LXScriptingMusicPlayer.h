//
//  LXScriptingMusicPlayer.h
//  LyricsX - https://github.com/ddddxxx/LyricsX
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

#import <Foundation/Foundation.h>
#import <ScriptingBridge/ScriptingBridge.h>

#import "LXMusicPlayerName.h"
#import "LXMusicTrack.h"
#import "LXPlayerState.h"

NS_ASSUME_NONNULL_BEGIN

@protocol LXMusicPlayerPlaybackControl

@optional

- (void)resume;
- (void)pause;
- (void)playPause;
- (void)skipToNextItem;
- (void)skipToPreviousItem;

@end

@interface LXScriptingMusicPlayer : NSObject<LXMusicPlayerPlaybackControl>

@property (nonatomic, readonly) LXMusicPlayerName playerName;
@property (nonatomic, readonly) NSString *playerBundleID;
@property (nonatomic, readonly) SBApplication *originalPlayer;
@property (nonatomic, readonly, getter=isRunning) BOOL running;

@property (nonatomic, readonly, nullable) LXMusicTrack *currentTrack;
@property (nonatomic, readonly) LXPlayerState *playerState;
@property (nonatomic) NSTimeInterval playbackTime;

- (instancetype)init NS_UNAVAILABLE;
+ (nullable instancetype)playerWithName:(LXMusicPlayerName)name;

- (void)updatePlayerState;

@end

NS_ASSUME_NONNULL_END
