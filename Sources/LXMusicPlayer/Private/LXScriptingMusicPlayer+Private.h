//
//  LXScriptingMusicPlayer+Private.h
//  LyricsX - https://github.com/ddddxxx/LyricsX
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

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
