//
//  LXMusicTrack.h
//  LyricsX - https://github.com/ddddxxx/LyricsX
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

#import <Foundation/Foundation.h>
#import <ScriptingBridge/ScriptingBridge.h>

NS_ASSUME_NONNULL_BEGIN

@interface LXMusicTrack : NSObject<NSCopying>

@property (nonatomic, copy) NSString *persistentID;
@property (nonatomic, copy, nullable) NSString *title;
@property (nonatomic, copy, nullable) NSString *album;
@property (nonatomic, copy, nullable) NSString *artist;
@property (nonatomic, nullable) NSNumber *duration;
@property (nonatomic, nullable) NSURL *fileURL;
@property (nonatomic, nullable) NSImage *artwork;

@property (nonatomic, nullable) SBObject *originalTrack;

- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithPersistentID:(NSString *)persistentID NS_DESIGNATED_INITIALIZER;

@end

NS_ASSUME_NONNULL_END
