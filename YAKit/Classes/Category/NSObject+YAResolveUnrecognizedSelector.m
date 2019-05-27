
//  NSObject+YAResolveUnrecognizedSelector.m
//  GPS
//
//  Created by Aaron on 2018/8/29.
//  Copyright © 2018年 ChenYalun. All rights reserved.
//

#import "NSObject+YAResolveUnrecognizedSelector.h"
#import <objc/runtime.h>

@interface YAForwardingTarget : NSObject
@end
@implementation YAForwardingTarget
static void forwardingTargetDynamicMethod(id self, SEL _cmd) {}
+ (BOOL)resolveInstanceMethod:(SEL)sel {
    class_addMethod(self.class, sel, (IMP)forwardingTargetDynamicMethod, "v@:");
    [super resolveInstanceMethod:sel];
    NSLog(@"Unrecognized instance Method: %@", NSStringFromSelector(sel));
    return YES;
}

+ (BOOL)resolveClassMethod:(SEL)sel {
    class_addMethod(object_getClass(self), sel, (IMP)forwardingTargetDynamicMethod, "v@:");
    [class_getSuperclass(self) resolveClassMethod:sel];
    NSLog(@"Unrecognized class Method: %@", NSStringFromSelector(sel));
    return YES;
}
@end

@implementation NSObject (YAResolveUnrecognizedSelector)
+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        methodSwizzle(self.class, @selector(forwardingTargetForSelector:), @selector(swizzleForwardingTargetForSelector:), YES);
        methodSwizzle(object_getClass(self), @selector(forwardingTargetForSelector:), @selector(swizzleForwardingTargetForSelector:), NO);
    });
}

#define swizzleForwardingTargetForSelector(arg) \
arg (id)swizzleForwardingTargetForSelector:(SEL)aSelector { \
    id result = [self swizzleForwardingTargetForSelector:aSelector]; \
    if (result) return result; \
    NSString *classString = NSStringFromClass(object_getClass(self)); \
    if (classString) { \
        return [@#arg isEqualToString:@"-"] ? [YAForwardingTarget new] : YAForwardingTarget.class;/* Avoid the crash. */ \
    } else { \
        return nil; /* Raise an exception. */ \
    } \
} \

// Class method and instance method.
swizzleForwardingTargetForSelector(+)
swizzleForwardingTargetForSelector(-)

#pragma mark - private method
// Method swizzle.
static BOOL methodSwizzle(Class aClass, SEL originalSelector, SEL swizzleSelector, BOOL isInstanceMethod) {
    Method originalMethod = nil;
    Method swizzleMethod = nil;
    if (isInstanceMethod) {
        originalMethod = class_getInstanceMethod(aClass, originalSelector);
        swizzleMethod = class_getInstanceMethod(aClass, swizzleSelector);
    } else {
        originalMethod = class_getClassMethod(aClass, originalSelector);
        swizzleMethod = class_getClassMethod(aClass, swizzleSelector);
    }
    BOOL didAddMethod = class_addMethod(aClass,
                                        originalSelector,
                                        method_getImplementation(swizzleMethod),
                                        method_getTypeEncoding(swizzleMethod));
    if (didAddMethod) {
        class_replaceMethod(aClass,
                            swizzleSelector,
                            method_getImplementation(originalMethod),
                            method_getTypeEncoding(originalMethod));
    } else {
        method_exchangeImplementations(originalMethod, swizzleMethod);
    }
    return YES;
}
@end

