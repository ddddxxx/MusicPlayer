//
//  LXMusicTrack+Private.h
//  This file is part of LyricsX - https://github.com/ddddxxx/LyricsX
//
//  Copyright (C) 2017  Xander Deng
//  Licensed under GPL v3 - https://www.gnu.org/licenses/gpl-3.0.html
//

#if TARGET_OS_MAC

#import "LXMusicTrack.h"
#import "Music.h"
#import "Spotify.h"
#import "Swinsian.h"

NS_ASSUME_NONNULL_BEGIN

//@interface LXMusicTrack()
//
//- (nullable instancetype)initWithMusicTrack:(MusicTrack *)track;
//- (nullable instancetype)initWithSpotifyTrack:(SpotifyTrack *)track;
//- (nullable instancetype)initWithSwinsianTrack:(SwinsianTrack *)track;
//
//@end

@interface LXScriptingTrack : LXMusicTrack

+ (nullable NSString *)persistentIDKey;
+ (nullable NSString *)titleKey;
+ (nullable NSString *)albumKey;
+ (nullable NSString *)artistKey;
+ (nullable NSString *)durationKey;
+ (nullable NSString *)fileURLKey;
+ (nullable NSString *)artworkKey;

- (instancetype)initWithPersistentID:(NSString *)persistentID NS_UNAVAILABLE;
- (nullable instancetype)initWithSBTrack:(SBObject *)track NS_DESIGNATED_INITIALIZER;

@end

@interface LXAppleMusicTrack : LXScriptingTrack
@end

@interface LXSpotifyTrack : LXScriptingTrack
@end

@interface LXSwinsianTrack : LXScriptingTrack
@end

NS_ASSUME_NONNULL_END

#endif
