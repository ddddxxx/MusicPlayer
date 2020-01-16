//
//  MediaRemotePrivate.h
//
//  This file is part of LyricsX - https://github.com/ddddxxx/LyricsX
//  Copyright (C) 2019  Xander Deng. Licensed under GPLv3.
//

#if OS_MACOS || (TARGET_OS_MAC && !TARGET_OS_IPHONE)

#import <Foundation/Foundation.h>
#import "SymbolLoader.h"

NS_ASSUME_NONNULL_BEGIN

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
