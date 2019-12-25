//
//  YAReuseViewPool.h
//  Aaron
//
//  Created by Chen,Yalun on 2019/6/1.
//  Copyright © 2019 Chen,Yalun. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface YAReuseViewPool : NSObject
+ (instancetype)sharedPool;
- (UIView *)reuseViewWithClass:(Class)cls;
- (void)invalidateView:(UIView *)view;
@end
