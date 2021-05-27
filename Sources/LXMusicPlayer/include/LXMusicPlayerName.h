//
//  LXMusicPlayerName.h
//  LyricsX - https://github.com/ddddxxx/LyricsX
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

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
