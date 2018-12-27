//
//  YAWeakProxy.h
//  Aaron
//
//  Created by Chen,Yalun on 2018/12/27.
//  Copyright © 2018 Chen,Yalun. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

// 主要利用NSProxy消息转发的优势, 弱引用 target 是通过 weak 修饰实现的.
@interface YAWeakProxy : NSProxy
@property (nonatomic, weak, readonly) id target; // 关键这里是 weak, 改为 strong 后失去效果
- (instancetype)initWithTarget:(id)target;
+ (instancetype)proxyWithTarget:(id)target;
@end

NS_ASSUME_NONNULL_END

/*
YAWeakProxy *proxy = [YAWeakProxy proxyWithTarget:self];
self.timer = [NSTimer timerWithTimeInterval:1 target:proxy selector:@selector(print) userInfo:nil repeats:YES];
[NSRunLoop.mainRunLoop addTimer:self.timer forMode:NSRunLoopCommonModes];
*/
