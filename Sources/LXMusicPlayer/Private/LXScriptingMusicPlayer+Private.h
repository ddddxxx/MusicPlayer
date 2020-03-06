//
//  LXScriptingMusicPlayer+Private.h
//
//  This file is part of LyricsX - https://github.com/ddddxxx/LyricsX
//  Copyright (C) 2019  Xander Deng. Licensed under LGPLv3.
//

#if OS_MACOS || (TARGET_OS_MAC && !TARGET_OS_IPHONE)

#import "LXScriptingMusicPlayer.h"

NS_ASSUME_NONNULL_BEGIN

@interface LXScriptingMusicPlayer()

@property (nonatomic, class, readonly) LXMusicPlayerName playerName;

@property (nonatomic, readwrite, nullable) LXMusicTrack *currentTrack;
@property (nonatomic, readwrite) LXPlayerState *playerState;
@property (nonatomic, readwrite, getter=isRunning) BOOL running;

@property (nonatomic) NSTimer *nextTrackUpdatingTimer;

- (nullable instancetype)init NS_DESIGNATED_INITIALIZER;

- (void)setPlayerState:(LXPlayerState *)playerState tolerate:(NSTimeInterval)tolerate;

@end

@interface LXPlayerAppleMusic : LXScriptingMusicPlayer
@end

@interface LXPlayerSpotify : LXScriptingMusicPlayer
@end

@interface LXPlayerVox : LXScriptingMusicPlayer
@end

@interface LXPlayerAudirvana : LXScriptingMusicPlayer
@end

@interface LXPlayerSwinsian : LXScriptingMusicPlayer
@end

NS_ASSUME_NONNULL_END

#endif
