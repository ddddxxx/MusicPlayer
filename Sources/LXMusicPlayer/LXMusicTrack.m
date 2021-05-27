//
//  LXMusicTrack.m
//  LyricsX - https://github.com/ddddxxx/LyricsX
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

#import "LXMusicTrack+Private.h"

@implementation LXMusicTrack

- (nonnull id)copyWithZone:(nullable NSZone *)zone {
    LXMusicTrack *t = [[[self class] allocWithZone:zone] initWithPersistentID:_persistentID];
    t->_title = [_title copyWithZone:zone];
    t->_album = [_album copyWithZone:zone];
    t->_artist = [_artist copyWithZone:zone];
    t->_duration = [_duration copyWithZone:zone];
    t->_fileURL = [_fileURL copyWithZone:zone];
    t->_artwork = _artwork;
    t->_originalTrack = _originalTrack;
    return t;
}

- (instancetype)initWithPersistentID:(NSString *)persistentID {
    self = [super init];
    _persistentID = persistentID;
    return self;
}

@end

@implementation LXAppleMusicTrack

+ (NSString *)fileURLKey {
    return @"location";
}

- (NSImage *)artworkGetter {
    return ((MusicTrack *)self.originalTrack).artworks.firstObject.data;
}

@end

@implementation LXSpotifyTrack

+ (NSString *)persistentIDKey {
    return @"id";
}

@end

@implementation LXSwinsianTrack

+ (NSString *)persistentIDKey {
    return @"id";
}

+ (NSString *)artworkKey {
    return @"albumArt";
}

- (NSURL *)fileURLGetter {
    NSString *path = ((SwinsianTrack *)self.originalTrack).path;
    if (path) {
        return [NSURL fileURLWithPath:path];
    } else {
        return nil;
    }
}

@end

// MARK: -

@implementation LXScriptingTrack

+ (NSString *)persistentIDKey {
    return @"persistentID";
}

+ (NSString *)titleKey {
    return @"name";
}

+ (NSString *)albumKey {
    return @"album";
}

+ (NSString *)artistKey {
    return @"artist";
}

+ (NSString *)durationKey {
    return @"duration";
}

+ (NSString *)fileURLKey {
    return nil;
}

+ (NSString *)artworkKey {
    return nil;
}

+ (NSString *)persistentIDForTrack:(SBObject *)sbTrack {
    return nil;
}

- (instancetype)initWithSBTrack:(SBObject *)track {
    // The "real object" of Apple Music stream does not return anything 🤔
//    if ((track = [track get]) == nil) {
//        return nil;
//    }
    NSString *persistentID;
    NSString *key = self.class.persistentIDKey;
    if (key && [track respondsToSelector:NSSelectorFromString(key)]) {
        persistentID = [track valueForKey:key];
    } else {
        persistentID = [self.class persistentIDForTrack:track];
    }
    if (persistentID == nil) {
        return nil;
    }
    self = [super initWithPersistentID:persistentID];
    self.originalTrack = track;
    return self;
}

#define NSStringize_helper(x) #x
#define NSStringize(x) @NSStringize_helper(x)

#define GetAndCacheRefValue(NAME)\
    id v = super.NAME;\
    if (v == (id)NSNull.null) {\
        return nil;\
    } else if (v) {\
        return v;\
    }\
    id obj = self.originalTrack;\
    NSString *key = self.class.NAME##Key;\
    if (key && [obj respondsToSelector:NSSelectorFromString(key)]) {\
        v = [obj valueForKey:key];\
    } else if ([obj respondsToSelector:@selector(NAME##Getter)]) {\
        v = [obj valueForKey:NSStringize(NAME##Getter)];\
    }\
    super.NAME = v ?: (id)NSNull.null;\
    return v;

#define GenerateRefValueGetter(NAME) - (id)NAME { GetAndCacheRefValue(NAME) }

GenerateRefValueGetter(title)
GenerateRefValueGetter(album)
GenerateRefValueGetter(artist)
GenerateRefValueGetter(duration)
GenerateRefValueGetter(fileURL)
GenerateRefValueGetter(artwork)

@end
