//
//  LXWeakProxy.m
//  LyricsX - https://github.com/ddddxxx/LyricsX
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

#import "LXWeakProxy.h"

@interface LXWeakProxy ()

@property (nonatomic, weak) id target;

@end

@implementation LXWeakProxy

- (instancetype)initWithObject:(id)object {
    self.target = object;
    return self;
}

- (id)forwardingTargetForSelector:(SEL)aSelector {
    return self.target;
}

- (NSMethodSignature *)methodSignatureForSelector:(SEL)aSelector {
    id target = self.target;
    if (target) {
        return [target methodSignatureForSelector:aSelector];
    } else {
        return [NSMethodSignature signatureWithObjCTypes:"@:"];
    }
}

- (void)forwardInvocation:(NSInvocation *)anInvocation {
    [anInvocation invokeWithTarget:self.target];
}

@end
