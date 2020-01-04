//
//  LXScriptingMusicPlayer.h
//  This file is part of LyricsX - https://github.com/ddddxxx/LyricsX
//
//  Copyright (C) 2017  Xander Deng
//  Licensed under GPL v3 - https://www.gnu.org/licenses/gpl-3.0.html
//

#if OS_MACOS

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

#endif
