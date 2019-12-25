//
//  UIGestureRecognizer+YABlock.m
//  Aaron
//
//  Created by Chen,Yalun on 2019/1/21.
//  Copyright © 2019 Chen,Yalun. All rights reserved.
//

#import "UIGestureRecognizer+YABlock.h"
#import <objc/runtime.h>

@interface YAGestureRecognizerTarget : NSObject
@property (nonatomic, copy) void (^block)(id sender);
@end

@implementation YAGestureRecognizerTarget
- (instancetype)initWithBlock:(void (^)(id sender))block {
    if (self = [super init]) {
        _block = [block copy];
    }
    return self;
}

- (void)invoke:(id)sender; {
    if (_block) _block(sender);
}
@end

@implementation UIGestureRecognizer (YABlock)
- (instancetype)initWithActionBlock:(void (^)(id))block{
    self = [self init];
    [self addActionBlock:block];
    return self;
}

- (void)addActionBlock:(void (^)(id sender))block {
    YAGestureRecognizerTarget *target = [[YAGestureRecognizerTarget alloc] initWithBlock:block];
    [self addTarget:target action:@selector(invoke:)];
    [[self blockTargets] addObject:target];
}

- (void)removeAllActionBlocks {
    NSMutableArray *targets = [self blockTargets];
    [targets enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [self removeTarget:obj action:@selector(invoke:)];
    }];
    [targets removeAllObjects];
}

- (NSMutableArray *)blockTargets {
    NSMutableArray *targets = objc_getAssociatedObject(self, @selector(blockTargets));
    if (!targets) {
        targets = [NSMutableArray array];
        objc_setAssociatedObject(self, @selector(blockTargets), targets, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return targets;
}
@end
