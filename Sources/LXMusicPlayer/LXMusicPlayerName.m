//
//  LXMusicPlayerName.m
//  LyricsX - https://github.com/ddddxxx/LyricsX
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

#import "LXMusicPlayerName.h"

const LXMusicPlayerName LXMusicPlayerNameAppleMusic = @"Music";
const LXMusicPlayerName LXMusicPlayerNameSpotify = @"Spotify";
const LXMusicPlayerName LXMusicPlayerNameVox = @"Vox";
const LXMusicPlayerName LXMusicPlayerNameAudirvana = @"Audirvana";
const LXMusicPlayerName LXMusicPlayerNameSwinsian = @"Swinsian";

NSArray<NSString *> *LXMusicPlayerNameGetCandidateBundleID(LXMusicPlayerName name) {
    if ([name isEqualToString:LXMusicPlayerNameAppleMusic]) {
        return @[@"com.apple.Music", @"com.apple.iTunes"];
    } else if ([name isEqualToString:LXMusicPlayerNameSpotify]) {
        return @[@"com.spotify.client"];
    } else if ([name isEqualToString:LXMusicPlayerNameVox]) {
        return @[@"com.coppertino.Vox"];
    } else if ([name isEqualToString:LXMusicPlayerNameAudirvana]) {
        return @[@"com.audirvana.Audirvana-Studio", @"com.audirvana.Audirvana", @"com.audirvana.Audirvana-Plus"];
    } else if ([name isEqualToString:LXMusicPlayerNameSwinsian]) {
        return @[@"com.swinsian.Swinsian"];
    } else {
        return @[];
    }
}
