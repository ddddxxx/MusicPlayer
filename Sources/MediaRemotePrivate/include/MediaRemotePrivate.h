//
//  MediaRemotePrivate.h
//  LyricsX - https://github.com/ddddxxx/LyricsX
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

#if TARGET_OS_MAC

#import <Foundation/Foundation.h>
#import "SymbolLoader.h"

NS_ASSUME_NONNULL_BEGIN

extern bool MRIsMediaRemoteLoaded;

typedef NS_ENUM(NSInteger, MRCommand) {
    /*
     * Use nil for userInfo.
     */
    MRCommandPlay = 0,
    MRCommandPause = 1,
    MRCommandTogglePlayPause = 2,
    MRCommandStop = 3,
    MRCommandNextTrack = 4,
    MRCommandPreviousTrack = 5,
    MRCommandToggleShuffle = 6,
    MRCommandToggleRepeat = 7,
    MRCommandStartForwardSeek = 8,
    MRCommandEndForwardSeek = 9,
    MRCommandStartBackwardSeek = 10,
    MRCommandEndBackwardSeek = 11,
    MRCommandGoBackFifteenSeconds = 12,
    MRCommandSkipFifteenSeconds = 13,

    /*
     * Use a NSDictionary for userInfo, which contains three keys:
     * kMRMediaRemoteOptionTrackID
     * kMRMediaRemoteOptionStationID
     * kMRMediaRemoteOptionStationHash
     */
    MRCommandLikeTrack = 0x6A,
    MRCommandBanTrack = 0x6B,
    MRCommandAddTrackToWishList = 0x6C,
    MRCommandRemoveTrackFromWishList = 0x6D
};

SLDeclareFunction(MRMediaRemoteSendCommand, Boolean, MRCommand, _Nullable id);
SLDeclareFunction(MRMediaRemoteSetElapsedTime, void, double);

SLDeclareFunction(MRMediaRemoteGetNowPlayingInfo, void, dispatch_queue_t, void(^)(_Nullable CFDictionaryRef));
SLDeclareFunction(MRMediaRemoteGetNowPlayingApplicationIsPlaying, void, dispatch_queue_t, void(^)(Boolean));

SLDeclareFunction(MRMediaRemoteRegisterForNowPlayingNotifications, void, dispatch_queue_t);
SLDeclareFunction(MRMediaRemoteUnregisterForNowPlayingNotifications, void);

NS_ASSUME_NONNULL_END

#endif
