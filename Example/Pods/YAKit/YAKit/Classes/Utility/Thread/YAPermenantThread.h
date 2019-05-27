//
//  YAPermenantThread.h
//  GPS
//
//  Created by Aaron on 2018/6/5.
//  Copyright © 2018年 Chenyalun. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^YAPermenantThreadTask)(void);

@interface YAPermenantThread : NSObject

/**
 Execute a task.
 */
- (void)executeTask:(void (^)(void))task;

/**
 Stop a task.
 */
- (void)stop;

@end
