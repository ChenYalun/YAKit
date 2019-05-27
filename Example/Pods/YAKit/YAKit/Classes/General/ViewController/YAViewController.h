//
//  YAViewController.h
//  GPS
//
//  Created by Chen,Yalun on 2018/11/15.
//  Copyright © 2018 ChenYalun. All rights reserved.
//

#import <UIKit/UIKit.h>

// 中间件映射, 用于解耦控制器获取
@interface YAMediator : NSObject
+ (UIViewController *)getMain_viewController:(NSString *)ID type:(NSInteger)type;
@end


@interface YAViewController : UIViewController
@property (nonatomic, assign) BOOL hiddenStatusBar; ///< Default NO.
- (void)pushInNavigationController:(UINavigationController *)navigationController
                          animated:(BOOL)animated
                        completion:(void (^)(void))completion;
- (void)pushInViewController:(UIViewController *)viewController
                    animated:(BOOL)animated
                  completion:(void (^)(void))completion;
- (void)presentInViewController:(UIViewController *)viewController
                       animated:(BOOL)animated
                     completion:(void (^)(void))completion;


- (void)popWithAnimated:(BOOL)animated
             completion:(void (^)(void))completion;
- (void)dismissWithAnimated:(BOOL)animated
                 completion:(void (^)(void))completion;



- (void)pushViewController:(UIViewController *)viewController
                  animated:(BOOL)animated
                completion:(void (^)(void))completion;
@end
