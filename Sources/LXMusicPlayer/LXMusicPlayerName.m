//
//  LXMusicPlayerName.m
//  This file is part of LyricsX - https://github.com/ddddxxx/LyricsX
//
//  Copyright (C) 2017  Xander Deng
//  Licensed under GPL v3 - https://www.gnu.org/licenses/gpl-3.0.html
//

#if TARGET_OS_MAC

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
        return @[@"com.audirvana.Audirvana", @"com.audirvana.Audirvana-Plus"];
    } else if ([name isEqualToString:LXMusicPlayerNameSwinsian]) {
        return @[@"com.swinsian.Swinsian"];
    } else {
        return @[];
    }
}

#endif
