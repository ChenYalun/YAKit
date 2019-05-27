//
//  YAWeakProxy.m
//  Aaron
//
//  Created by Chen,Yalun on 2018/12/27.
//  Copyright © 2018 Chen,Yalun. All rights reserved.
//

#import "YAWeakProxy.h"

@implementation YAWeakProxy
- (instancetype)initWithTarget:(id)target {
    _target = target;
    return self;
}

+ (instancetype)proxyWithTarget:(id)target {
    return [[self alloc] initWithTarget:target];
}

- (void)forwardInvocation:(NSInvocation *)invocation{
    if ([self.target respondsToSelector:invocation.selector]) {
        [invocation invokeWithTarget:self.target];
    }
}

- (NSMethodSignature *)methodSignatureForSelector:(SEL)aSelector{
    return [self.target methodSignatureForSelector:aSelector];
}
@end
