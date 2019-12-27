//
//  LXMusicTrack.h
//  This file is part of LyricsX - https://github.com/ddddxxx/LyricsX
//
//  Copyright (C) 2017  Xander Deng
//  Licensed under GPL v3 - https://www.gnu.org/licenses/gpl-3.0.html
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
