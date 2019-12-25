//
//  YACrashHandlerManager.m
//  Splash
//
//  Created by Chen,Yalun on 2019/12/9.
//  Copyright © 2019 Chen,Yalun. All rights reserved.
//

#import "YACrashHandlerManager.h"
#include <libkern/OSAtomic.h>
#include <execinfo.h>

static void handleException(NSException *exception);
static void signalHandler(int signal);
static void configCatchExceptionHandler(BOOL isNil);
static NSString * const kSignalExceptionName = @"kSignalExceptionName";
static NSString * const kSignalKey = @"kSignalKey";
static NSString * const kCaughtExceptionStackInfoKey = @"kCaughtExceptionStackInfoKey";


@interface YACrashHandlerManager ()
@property (nonatomic, assign) BOOL shouldIgnore;
@end

@implementation YACrashHandlerManager
+ (instancetype)sharedManager {
    static YACrashHandlerManager *manager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [YACrashHandlerManager new];
    });
    return manager;
}

- (instancetype)init {
    if (self = [super init]) {
        configCatchExceptionHandler(NO);
    }
    return self;
}

- (void)handleException:(NSException *)exception {
    NSString *message = [NSString stringWithFormat:@"崩溃原因如下:\n%@\n%@",
                         [exception reason],
                         [[exception userInfo]
                          objectForKey:kCaughtExceptionStackInfoKey]];
    NSLog(@"%@",message);
    // 弹出弹窗, 设置shouldIgnore的值
    // ....
    
    NSArray *allModes = CFBridgingRelease(CFRunLoopCopyAllModes(CFRunLoopGetCurrent()));
    while (!self.shouldIgnore) {
        for (NSString *mode in allModes) {
            CFRunLoopRunInMode((CFStringRef)mode, 0.001, false);
        }
    }
    configCatchExceptionHandler(YES);
    if ([[exception name] isEqual:kSignalExceptionName]) {
        kill(getpid(), [[[exception userInfo] objectForKey:kSignalKey] intValue]);
    } else {
        [exception raise];
    }
}
@end

static NSArray *getBacktrace() {
    void *callstack[128];
    int frames = backtrace(callstack, 128);
    char **strs = backtrace_symbols(callstack, frames);
    NSMutableArray *backtrace = [NSMutableArray arrayWithCapacity:frames];
    for (int i = 0; i < frames; i++) {
        [backtrace addObject:[NSString stringWithUTF8String:strs[i]]];
    }
    free(strs);
    return backtrace;
}

static void configCatchExceptionHandler(BOOL isNil) {
    void (*handler)(int) = SIG_DFL;
    NSUncaughtExceptionHandler *exc = NULL;
    if (!isNil) {
        handler = signalHandler;
        exc = &handleException;
    }
    NSSetUncaughtExceptionHandler(exc);
    signal(SIGABRT, handler);
    signal(SIGILL, handler);
    signal(SIGSEGV, handler);
    signal(SIGFPE, handler);
    signal(SIGBUS, handler);
    signal(SIGPIPE, handler);
}

static void handleException(NSException *exception) {
    NSException *customException = [NSException exceptionWithName:[exception name] reason:[exception reason] userInfo:@{kCaughtExceptionStackInfoKey: [exception callStackSymbols]}];
    [[YACrashHandlerManager sharedManager] performSelectorOnMainThread:@selector(handleException:) withObject:customException waitUntilDone:YES];
}

static void signalHandler(int signal) {
    NSString *stack = [NSString stringWithFormat:@"%@", getBacktrace()];
    NSException *customException = [NSException exceptionWithName:kSignalExceptionName
                                                           reason:[NSString stringWithFormat:NSLocalizedString(@"Signal %d was raised.", nil), signal]
                                                         userInfo:@{kSignalKey:[NSNumber numberWithInt:signal], kCaughtExceptionStackInfoKey: stack}];
    [[YACrashHandlerManager sharedManager] performSelectorOnMainThread:@selector(handleException:) withObject:customException waitUntilDone:YES];
}
