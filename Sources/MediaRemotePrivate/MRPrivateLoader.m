//
//  MRPrivateLoader.h
//  LyricsX - https://github.com/ddddxxx/LyricsX
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

#if OS_DARWIN || TARGET_OS_MAC

#import <Foundation/Foundation.h>
#import <dlfcn.h>
#import "MediaRemotePrivate.h"
#import "SymbolLoader.h"

#define kMediaRemotePath "/System/Library/PrivateFrameworks/MediaRemote.framework/MediaRemote"

bool MRIsMediaRemoteLoaded = false;

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
    
    MRIsMediaRemoteLoaded = true;
    
    SLLoad(handle, MRMediaRemoteSendCommand);
    SLLoad(handle, MRMediaRemoteSetElapsedTime);
    
    SLLoad(handle, MRMediaRemoteGetNowPlayingInfo);
    SLLoad(handle, MRMediaRemoteGetNowPlayingApplicationIsPlaying);
    
    SLLoad(handle, MRMediaRemoteRegisterForNowPlayingNotifications);
    SLLoad(handle, MRMediaRemoteUnregisterForNowPlayingNotifications);
    
    dlclose(handle);
}

#endif
