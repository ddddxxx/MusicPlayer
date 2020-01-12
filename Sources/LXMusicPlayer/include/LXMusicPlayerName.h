//
//  LXMusicPlayerName.h
//
//  This file is part of LyricsX - https://github.com/ddddxxx/LyricsX
//  Copyright (C) 2019  Xander Deng. Licensed under LGPLv3.
//

#if OS_MACOS || (TARGET_OS_MAC && !TARGET_OS_IPHONE)

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NSString *LXMusicPlayerName NS_STRING_ENUM NS_SWIFT_NAME(LXScriptingMusicPlayer.Name);

extern const LXMusicPlayerName LXMusicPlayerNameAppleMusic;
extern const LXMusicPlayerName LXMusicPlayerNameSpotify;
extern const LXMusicPlayerName LXMusicPlayerNameVox;
extern const LXMusicPlayerName LXMusicPlayerNameAudirvana;
extern const LXMusicPlayerName LXMusicPlayerNameSwinsian;

NSArray<NSString *> *LXMusicPlayerNameGetCandidateBundleID(LXMusicPlayerName name) NS_SWIFT_NAME(LXMusicPlayerName.candidateBundleID(self:));

NS_ASSUME_NONNULL_END

#endif
