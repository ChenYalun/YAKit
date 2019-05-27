//
//  YALocationManager.h
//  YALocation
//
//  Created by Aaron on 2018/5/19.
//  Copyright © 2018年 ChenYalun. All rights reserved.
//
#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

typedef void (^YALocationRequestCompletion)(CLLocation *location, CLPlacemark *place, NSError *error);

@interface YALocationManager : NSObject

/**
 Returns the singleton instance of this class.

 @return  A manager.
 */
+ (instancetype)sharedManager;

/**
 Gets the user's current location.

 @param block A callback.
 */
- (void)requestLocationWithCompletion:(YALocationRequestCompletion)block;

/**
 Gets the location authorization.
 */
- (void)requestAuthorization;

// The constructor method is disabled.
- (instancetype) init __attribute__((unavailable("init not available, call sharedManager instead")));
+ (instancetype) new __attribute__((unavailable("new not available, call sharedManager instead")));
@end
