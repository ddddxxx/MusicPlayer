//
//  MRPrivateLoader.h
//
//  This file is part of LyricsX - https://github.com/ddddxxx/LyricsX
//  Copyright (C) 2019  Xander Deng. Licensed under GPLv3.
//

#if OS_MACOS || (TARGET_OS_MAC && !TARGET_OS_IPHONE)

#import <Foundation/Foundation.h>
#import <dlfcn.h>
#import "MediaRemotePrivate.h"
#import "SymbolLoader.h"

#define kMediaRemotePath "/System/Library/PrivateFrameworks/MediaRemote.framework/MediaRemote"

SLDefineFunction(MRMediaRemoteSendCommand, Boolean, MRCommand, _Nullable id);
SLDefineFunction(MRMediaRemoteSetElapsedTime, void, double);

SLDefineFunction(MRMediaRemoteGetNowPlayingInfo, void, dispatch_queue_t, void(^)(_Nullable CFDictionaryRef));
SLDefineFunction(MRMediaRemoteGetNowPlayingApplicationIsPlaying, void, dispatch_queue_t, void(^)(Boolean));

SLDefineFunction(MRMediaRemoteRegisterForNowPlayingNotifications, void, dispatch_queue_t);
SLDefineFunction(MRMediaRemoteUnregisterForNowPlayingNotifications, void);

__attribute__((constructor)) static void loadMediaRemote() {
    void *handle = dlopen(kMediaRemotePath, RTLD_LAZY);
    if (handle == NULL) {
        return;
    }
    
    SLLoad(handle, MRMediaRemoteSendCommand);
    SLLoad(handle, MRMediaRemoteSetElapsedTime);
    
    SLLoad(handle, MRMediaRemoteGetNowPlayingInfo);
    SLLoad(handle, MRMediaRemoteGetNowPlayingApplicationIsPlaying);
    
    SLLoad(handle, MRMediaRemoteRegisterForNowPlayingNotifications);
    SLLoad(handle, MRMediaRemoteUnregisterForNowPlayingNotifications);
    
    dlclose(handle);
}

#endif
