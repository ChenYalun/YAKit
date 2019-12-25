//
//  UIGestureRecognizer+YABlock.h
//  Aaron
//
//  Created by Chen,Yalun on 2019/1/21.
//  Copyright © 2019 Chen,Yalun. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIGestureRecognizer (YABlock)
- (instancetype)initWithActionBlock:(void (^)(id sender))block;
- (void)addActionBlock:(void (^)(id sender))block;
- (void)removeAllActionBlocks;
@end
