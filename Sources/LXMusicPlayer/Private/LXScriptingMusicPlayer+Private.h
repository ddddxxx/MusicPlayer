//
//  LXScriptingMusicPlayer+Private.h
//  This file is part of LyricsX - https://github.com/ddddxxx/LyricsX
//
//  Copyright (C) 2017  Xander Deng
//  Licensed under GPL v3 - https://www.gnu.org/licenses/gpl-3.0.html
//

#if TARGET_OS_MAC

#import "LXScriptingMusicPlayer.h"

NS_ASSUME_NONNULL_BEGIN

@interface LXScriptingMusicPlayer()

@property (nonatomic, class, readonly) LXMusicPlayerName playerName;

@property (nonatomic, readwrite, nullable) LXMusicTrack *currentTrack;
@property (nonatomic, readwrite) LXPlayerState *playerState;

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
