//
//  YATimer.h
//  GPS
//
//  Created by Chen,Yalun on 2018/11/16.
//  Copyright © 2018 ChenYalun. All rights reserved.
//

#import <Foundation/Foundation.h>
typedef NSString *YATaskName;

@interface YATimer : NSObject

+ (YATaskName)executeTask:(void (^)(void))task
                    start:(NSTimeInterval)start
                 interval:(NSTimeInterval)interval
                  repeats:(BOOL)repeats
                    async:(BOOL)async ;

+ (YATaskName)executeTask:(id)target
                 selector:(SEL)selector
                    start:(NSTimeInterval)start
                 interval:(NSTimeInterval)interval
                  repeats:(BOOL)repeats
                    async:(BOOL)async;

+ (void)cancelTask:(NSString *)name;
@end
