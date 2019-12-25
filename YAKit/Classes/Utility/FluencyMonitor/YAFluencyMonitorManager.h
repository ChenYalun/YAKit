//
//  YAFluencyMonitorManager.h
//  Splash
//
//  Created by Chen,Yalun on 2019/12/7.
//  Copyright © 2019 Chen,Yalun. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface YAFluencyMonitorManager : NSObject
+ (instancetype)sharedInstance;

/// 超过多少毫秒为一次卡顿 400毫秒
@property (nonatomic, assign) int limitMillisecond;

/// 多少次卡顿纪录为一次有效，默认为5次
@property (nonatomic, assign) int standstillCount;

/// 发生一次有效的卡顿回调函数
@property (nonatomic, copy) void (^callbackWhenStandStill)(void);

/**
 开始监听卡顿
 */
- (void)startMonitor;

/**
 结束监听卡顿
 */
- (void)endMonitor;

//+ (void)startWithTimeInterval:(NSTimeInterval)interval fault:(NSTimeInterval)fault;
//+ (void)stop;
@end

