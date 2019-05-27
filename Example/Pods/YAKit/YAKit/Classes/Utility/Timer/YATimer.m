//
//  YATimer.m
//  GPS
//
//  Created by Chen,Yalun on 2018/11/16.
//  Copyright © 2018 ChenYalun. All rights reserved.
//

#import "YATimer.h"

@implementation YATimer

static NSMutableDictionary *timerDictionary = nil;
dispatch_semaphore_t semaphore = nil;

+ (void)initialize {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        timerDictionary = [NSMutableDictionary dictionary];
        semaphore = dispatch_semaphore_create(1);
    });
}

+ (YATaskName)executeTask:(void (^)(void))task
                    start:(NSTimeInterval)start
                 interval:(NSTimeInterval)interval
                  repeats:(BOOL)repeats
                    async:(BOOL)async {
    if (!task || start < 0 || (interval <= 0 && repeats)) return nil;
    dispatch_queue_t queue = async ? dispatch_get_global_queue(0, 0) : dispatch_get_main_queue();
    dispatch_source_t timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue);
    dispatch_source_set_timer(timer,
                              dispatch_time(DISPATCH_TIME_NOW, start * NSEC_PER_SEC),
                              interval * NSEC_PER_SEC, 0);
    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
    NSString *taskIdentifier = [NSString stringWithFormat:@"%zd", timerDictionary.count];
    timerDictionary[taskIdentifier] = timer;
    dispatch_semaphore_signal(semaphore);
    dispatch_source_set_event_handler(timer, ^{
        task();
        if (!repeats) [self cancelTask:taskIdentifier];
    });
    dispatch_resume(timer);
    return taskIdentifier;
}

+ (YATaskName)executeTask:(id)target
                 selector:(SEL)selector
                    start:(NSTimeInterval)start
                 interval:(NSTimeInterval)interval
                  repeats:(BOOL)repeats
                    async:(BOOL)async {
    if (!target || !selector) return nil;
    return [self executeTask:^{
        if ([target respondsToSelector:selector]) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
            [target performSelector:selector];
#pragma clang diagnostic pop
        }
    } start:start interval:interval repeats:repeats async:async];
}

+ (void)cancelTask:(NSString *)taskIdentifier {
    if (taskIdentifier.length == 0) return;
    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
    dispatch_source_t timer = timerDictionary[taskIdentifier];
    if (timer) {
        dispatch_source_cancel(timer);
        [timerDictionary removeObjectForKey:taskIdentifier];
    }
    dispatch_semaphore_signal(semaphore);
}

@end
