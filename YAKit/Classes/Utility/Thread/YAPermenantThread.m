//
//  YAPermenantThread.m
//  GPS
//
//  Created by Aaron on 2018/6/5.
//  Copyright © 2018年 chenyalun. All rights reserved.
//

#import "YAPermenantThread.h"

@interface YAPermenantThread()
@property (nonatomic, strong) NSThread *innerThread;
@end

@implementation YAPermenantThread
- (instancetype)init {
    if (self = [super init]) {
        _innerThread = [[NSThread alloc] initWithBlock:^{
            CFRunLoopSourceContext context = {0};
            CFRunLoopSourceRef source = CFRunLoopSourceCreate(kCFAllocatorDefault, 0, &context);
            CFRelease(source);
            // 第3个参数：returnAfterSourceHandled，设置为true，代表执行完source后就会退出当前loop
            CFRunLoopRunInMode(kCFRunLoopDefaultMode, 1.0e10, false);
        }];
        [_innerThread start];
    }
    return self;
}

- (void)dealloc {
    [self stop];
}

- (void)executeTask:(void (^)(void))task {
    if (!self.innerThread || !task) return;
    [self performSelector:@selector(executeInnerTask:) onThread:self.innerThread withObject:task waitUntilDone:NO];
}

- (void)stop {
    if (!self.innerThread) return;
    [self performSelector:@selector(stopThread) onThread:self.innerThread withObject:nil waitUntilDone:YES];
}

#pragma mark - private methods
- (void)stopThread {
    CFRunLoopStop(CFRunLoopGetCurrent());
    self.innerThread = nil;
}

- (void)executeInnerTask:(void (^)(void))task {
    if (task) task();
}
@end
