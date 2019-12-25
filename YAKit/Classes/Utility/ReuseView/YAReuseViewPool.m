//
//  YAReuseViewPool.m
//  Aaron
//
//  Created by Chen,Yalun on 2019/6/1.
//  Copyright © 2019 Chen,Yalun. All rights reserved.
//

#import "YAReuseViewPool.h"

@interface YAReuseViewPool ()
// 正在使用的视图集合
@property (nonatomic, strong) NSMutableSet *usedViewSet;
// 缓存池
@property (nonatomic, strong) NSMutableSet *reuseViewSet;
@end

@implementation YAReuseViewPool
+ (instancetype)sharedPool {
    static YAReuseViewPool *pool;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        pool = [YAReuseViewPool new];
    });
    return pool;
}

- (NSMutableSet *)usedViewSet {
    if (!_usedViewSet) {
        _usedViewSet = [NSMutableSet set];
    }
    return _usedViewSet;
}

- (NSMutableSet *)reuseViewSet {
    if (!_reuseViewSet) {
        _reuseViewSet = [NSMutableSet set];
    }
    return _reuseViewSet;
}

- (UIView *)reuseViewWithClass:(Class)cls {
    if (self.reuseViewSet.count > 0) {
        // 缓存池有可用视图
        UIView *view = self.reuseViewSet.anyObject;
        [self.reuseViewSet removeObject:view];
        [self.usedViewSet addObject:view];
        return view;
    } else {
        UIView *view = [cls new];
        [self.usedViewSet addObject:view];
        return view;
    }
}

- (void)invalidateView:(UIView *)view {
    if ([self.usedViewSet containsObject:view]) {
        [self.usedViewSet removeObject:view];
        [self.reuseViewSet addObject:view];
    }
}
@end
