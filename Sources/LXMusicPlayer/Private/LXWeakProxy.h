//
//  LXWeakProxy.h
//  LyricsX - https://github.com/ddddxxx/LyricsX
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

#if OS_MACOS || (TARGET_OS_MAC && !TARGET_OS_IPHONE)

#import <Foundation/Foundation.h>

@interface LXWeakProxy : NSProxy

- (instancetype)initWithObject:(id)object;

@end

#endif
