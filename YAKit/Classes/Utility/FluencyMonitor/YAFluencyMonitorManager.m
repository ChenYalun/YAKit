//
//  YAFluencyMonitorManager.m
//  Splash
//
//  Created by Chen,Yalun on 2019/12/7.
//  Copyright © 2019 Chen,Yalun. All rights reserved.
//

#import "YAFluencyMonitorManager.h"
#import <CrashReporter/CrashReporter.h>

/*
@interface YAFluencyMonitorManager ()
@property (nonatomic, strong) NSThread *monitorThread;
@property (nonatomic, strong) NSDate *startDate;
@property (nonatomic, assign) CFRunLoopObserverRef observer;
@property (nonatomic, assign) CFRunLoopTimerRef threadTimer;
@property (nonatomic, assign) BOOL excuting;
@property (nonatomic, assign) NSTimeInterval interval;
@property (nonatomic, assign) NSTimeInterval fault;
@end

@implementation YAFluencyMonitorManager
#pragma mark - Life cycle
// 单例管理器
+ (instancetype)shareManager {
    static dispatch_once_t onceToken;
    static YAFluencyMonitorManager *manager = nil;
    dispatch_once(&onceToken, ^{
        manager = [[[self class] alloc] init];
        manager.monitorThread = [[NSThread alloc] initWithBlock:^{
            [NSRunLoop.currentRunLoop addPort:[NSMachPort port] forMode:NSDefaultRunLoopMode];
            [NSRunLoop.currentRunLoop run];
        }];
        [manager.monitorThread start];
    });
    return manager;
}

// Runloop回调
static void RunLoopObserverCallBack(CFRunLoopObserverRef observer, CFRunLoopActivity activity, void *info){
    YAFluencyMonitorManager *manager = YAFluencyMonitorManager.shareManager;
    switch (activity) {
        case kCFRunLoopEntry: break;
        case kCFRunLoopBeforeTimers: break;
        case kCFRunLoopBeforeSources:
            manager.startDate = [NSDate date];
            manager.excuting = YES;
            break;
        case kCFRunLoopBeforeWaiting:
            manager.excuting = NO;
            break;
        case kCFRunLoopAfterWaiting: break;
        case kCFRunLoopExit: break;
        default: break;
    }
}

- (void)handleStackInfo {
    NSData *lagData = [[[PLCrashReporter alloc]
                        initWithConfiguration:[[PLCrashReporterConfig alloc] initWithSignalHandlerType:PLCrashReporterSignalHandlerTypeBSD symbolicationStrategy:PLCrashReporterSymbolicationStrategyAll]] generateLiveReport];
    PLCrashReport *lagReport = [[PLCrashReport alloc] initWithData:lagData error:NULL];
    NSString *lagReportString = [PLCrashReportTextFormatter stringValueForCrashReport:lagReport withTextFormat:PLCrashReportTextFormatiOS];
    NSLog(@"lag happen, detail below: \n %@",lagReportString);
}

#pragma mark - ThreadTimer
static void RunLoopTimerCallBack(CFRunLoopTimerRef timer, void *info) {
     YAFluencyMonitorManager *manager = (__bridge YAFluencyMonitorManager *)info;
     if (!manager.excuting) return;
     NSTimeInterval excuteTime = [NSDate.date timeIntervalSinceDate:manager.startDate];
     if (excuteTime >= manager.fault) {
         NSLog(@"线程卡顿了%f秒", excuteTime);
         [manager handleStackInfo];
     }
 }

- (CFRunLoopTimerRef)threadTimer {
    if (!_threadTimer) {
        CFRunLoopTimerContext context = {0, (__bridge void *)self, NULL, NULL, NULL};
        _threadTimer = CFRunLoopTimerCreate(kCFAllocatorDefault,
                                            0.1,
                                            _interval,
                                            0,
                                            0,
                                            &RunLoopTimerCallBack,
                                            &context);
        // 添加到子线程的RunLoop中
        CFRunLoopAddTimer(CFRunLoopGetCurrent(), _threadTimer, kCFRunLoopCommonModes);
    }
    return _threadTimer;
}

- (void)removeTimer {
    if (_threadTimer) {
        CFRunLoopRemoveTimer(CFRunLoopGetCurrent(), _threadTimer, kCFRunLoopCommonModes);
        CFRelease(_threadTimer);
        _threadTimer = NULL;
    }
}

#pragma mark - Public methods
+ (void)startWithTimeInterval:(NSTimeInterval)interval fault:(NSTimeInterval)fault {
    YAFluencyMonitorManager *manager = YAFluencyMonitorManager.shareManager;
    manager.interval = interval;
    manager.fault = fault;
    if (manager.observer) return;
    
    // 配置主线程Runloop的回调
    CFRunLoopObserverContext context = {0, (__bridge void *)self, NULL, NULL, NULL};
    manager.observer = CFRunLoopObserverCreate(kCFAllocatorDefault,
                                        kCFRunLoopAllActivities,
                                        YES,
                                        0,
                                        &RunLoopObserverCallBack,
                                        &context);
    CFRunLoopAddObserver(CFRunLoopGetMain(), manager.observer, kCFRunLoopCommonModes);
    // 设置Timer
    [manager performSelector:@selector(threadTimer) onThread:manager.monitorThread withObject:nil waitUntilDone:NO modes:@[NSRunLoopCommonModes]];
}

+ (void)stop {
    YAFluencyMonitorManager *manager = YAFluencyMonitorManager.shareManager;
    if (manager.observer) {
        CFRunLoopRemoveObserver(CFRunLoopGetMain(), manager.observer, kCFRunLoopCommonModes);
        CFRelease(manager.observer);
        manager.observer = NULL;
    }
    [manager performSelector:@selector(removeTimer) onThread:manager.monitorThread withObject:nil waitUntilDone:NO modes:@[NSRunLoopCommonModes]];
}
@end
*/

#import <execinfo.h>

// minimum
static const NSInteger MXRMonitorRunloopMinOneStandstillMillisecond = 20;
static const NSInteger MXRMonitorRunloopMinStandstillCount = 1;

// default
// 超过多少毫秒为一次卡顿
static const NSInteger MXRMonitorRunloopOneStandstillMillisecond = 400;
// 多少次卡顿纪录为一次有效卡顿
static const NSInteger MXRMonitorRunloopStandstillCount = 5;

@interface YAFluencyMonitorManager (){
    CFRunLoopObserverRef _observer;  // 观察者
    dispatch_semaphore_t _semaphore; // 信号量
    CFRunLoopActivity _activity;     // 状态
}
@property (nonatomic, assign) BOOL isCancel;
@property (nonatomic, assign) NSInteger countTime; // 耗时次数
@end

@implementation YAFluencyMonitorManager

+ (instancetype)sharedInstance
{
    static dispatch_once_t once;
    static YAFluencyMonitorManager *sharedInstance;
    dispatch_once(&once, ^{
        sharedInstance = [[self alloc] init];
        sharedInstance.limitMillisecond = MXRMonitorRunloopOneStandstillMillisecond;
        sharedInstance.standstillCount  = MXRMonitorRunloopStandstillCount;
    });
    return sharedInstance;
}

- (void)setLimitMillisecond:(int)limitMillisecond
{
    [self willChangeValueForKey:@"limitMillisecond"];
    _limitMillisecond = limitMillisecond >= MXRMonitorRunloopMinOneStandstillMillisecond ? limitMillisecond : MXRMonitorRunloopMinOneStandstillMillisecond;
    [self didChangeValueForKey:@"limitMillisecond"];
}

- (void)setStandstillCount:(int)standstillCount
{
    [self willChangeValueForKey:@"standstillCount"];
    _standstillCount = standstillCount >= MXRMonitorRunloopMinStandstillCount ? standstillCount : MXRMonitorRunloopMinStandstillCount;
    [self didChangeValueForKey:@"standstillCount"];
}

- (void)startMonitor
{
    self.isCancel = NO;
    [self registerObserver];
}

- (void) endMonitor
{
    self.isCancel = YES;
    if(!_observer) return;
    CFRunLoopRemoveObserver(CFRunLoopGetMain(), _observer, kCFRunLoopCommonModes);
    CFRelease(_observer);
    _observer = NULL;
}

static void runLoopObserverCallBack(CFRunLoopObserverRef observer, CFRunLoopActivity activity, void *info)
{
    YAFluencyMonitorManager *instance = [YAFluencyMonitorManager sharedInstance];
    // 记录状态值
    instance->_activity = activity;
    // 发送信号
    dispatch_semaphore_t semaphore = instance->_semaphore;
    dispatch_semaphore_signal(semaphore);
}

// 注册一个Observer来监测Loop的状态,回调函数是runLoopObserverCallBack
- (void)registerObserver
{
    // 设置Runloop observer的运行环境
    CFRunLoopObserverContext context = {0, (__bridge void *)self, NULL, NULL};
    // 创建Runloop observer对象
    _observer = CFRunLoopObserverCreate(kCFAllocatorDefault,
                                        kCFRunLoopAllActivities,
                                        YES,
                                        0,
                                        &runLoopObserverCallBack,
                                        &context);
    // 将新建的observer加入到当前thread的runloop
    CFRunLoopAddObserver(CFRunLoopGetMain(), _observer, kCFRunLoopCommonModes);
    // 创建信号
    _semaphore = dispatch_semaphore_create(0);
    
    __weak __typeof(self) weakSelf = self;
    // 在子线程监控时长
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        __strong __typeof(weakSelf) strongSelf = weakSelf;
        if (!strongSelf) {
            return;
        }
        while (YES) {
            if (strongSelf.isCancel) {
                return;
            }
            // N次卡顿超过阈值T记录为一次卡顿
            long dsw = dispatch_semaphore_wait(self->_semaphore, dispatch_time(DISPATCH_TIME_NOW, strongSelf.limitMillisecond * NSEC_PER_MSEC));
            if (dsw != 0) {
                if (self->_activity == kCFRunLoopBeforeSources || self->_activity == kCFRunLoopAfterWaiting) {
                    if (++strongSelf.countTime < strongSelf.standstillCount){
                        NSLog(@"%ld",strongSelf.countTime);
                        continue;
                    }
                    [self handleStackInfo];
                    if (strongSelf.callbackWhenStandStill) {
                        strongSelf.callbackWhenStandStill();
                    }
                }
            }
            strongSelf.countTime = 0;
        }
    });
}

- (void)handleStackInfo {
    NSData *lagData = [[[PLCrashReporter alloc]
                        initWithConfiguration:[[PLCrashReporterConfig alloc] initWithSignalHandlerType:PLCrashReporterSignalHandlerTypeBSD symbolicationStrategy:PLCrashReporterSymbolicationStrategyAll]] generateLiveReport];
    PLCrashReport *lagReport = [[PLCrashReport alloc] initWithData:lagData error:NULL];
    NSString *lagReportString = [PLCrashReportTextFormatter stringValueForCrashReport:lagReport withTextFormat:PLCrashReportTextFormatiOS];
    NSLog(@"lag happen, detail below: \n %@",lagReportString);
}
@end
