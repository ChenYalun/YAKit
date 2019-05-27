//
//  YAViewController.m
//  GPS
//
//  Created by Chen,Yalun on 2018/11/15.
//  Copyright © 2018 ChenYalun. All rights reserved.
//

#import "YAViewController.h"

#define SuppressPerformSelectorLeakWarning(Stuff) \
do { \
_Pragma("clang diagnostic push") \
_Pragma("clang diagnostic ignored \"-Warc-performSelector-leaks\"") \
Stuff; \
_Pragma("clang diagnostic pop") \
} while (0)

// 控制器跳转中转
@implementation YAMediator
+ (UIViewController *)getMain_viewController:(NSString *)ID type:(NSInteger)type {
    Class cls = NSClassFromString(@"ViewController");
    id argue = @{@"id":ID, @"type": @(type)};
    SEL sel = NSSelectorFromString(@"controllerWithID:type:");
    SuppressPerformSelectorLeakWarning(
        return [[[cls alloc] init] performSelector:sel withObject:argue];
    );
}
@end



@interface YAViewController ()

@end

@implementation YAViewController
#pragma mark - Life cycle
- (instancetype)init {
    if (self = [super init]) {
        _hiddenStatusBar = NO;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = UIColor.whiteColor;
}

#pragma mark - Private methods
- (BOOL)prefersStatusBarHidden {
    return self.hiddenStatusBar;
}

#pragma mark - Public methods
- (void)pushInNavigationController:(UINavigationController *)navigationController
                          animated:(BOOL)animated
                        completion:(void (^)(void))completion {
    if (!navigationController) return ;
    [navigationController pushViewController:self animated:animated];
    if (completion) completion();
}

- (void)pushInViewController:(UIViewController *)viewController
                    animated:(BOOL)animated
                  completion:(void (^)(void))completion {
    if (!viewController) return ;
    UINavigationController *navigationController = nil;
    do {
        navigationController = viewController.navigationController;
    } while (!navigationController);
    [self pushInNavigationController:navigationController animated:animated completion:completion];
}

- (void)presentInViewController:(UIViewController *)viewController
                       animated:(BOOL)animated
                     completion:(void (^)(void))completion {
    if (!viewController) return ;
    [viewController presentViewController:self animated:animated completion:completion];
}

- (void)popWithAnimated:(BOOL)animated
             completion:(void (^)(void))completion {
    [self.navigationController popViewControllerAnimated:NO];
    if (completion) completion();
}

- (void)dismissWithAnimated:(BOOL)animated completion:(void (^)(void))completion {
    [self dismissViewControllerAnimated:animated completion:completion];
}

- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated completion:(void (^)(void))completion {
    [self.navigationController pushViewController:viewController animated:animated];
    if (completion) completion();
}
@end


