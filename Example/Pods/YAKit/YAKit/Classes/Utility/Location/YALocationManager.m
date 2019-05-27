//
//  YALocationManager.m
//  YALocation
//
//  Created by Aaron on 2018/5/19.
//  Copyright © 2018年 ChenYalun. All rights reserved.
//
#ifdef __OBJC__
#ifdef DEBUG
#   define YALog(fmt, ...) NSLog((@"%s [Line %d] " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__);
#else
#   define YALog(...)
#endif
#endif

#import "YALocationManager.h"
#import <UIKit/UIKit.h>

@interface YALocationManager() <CLLocationManagerDelegate>
@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, copy) YALocationRequestCompletion locationBlock;
@end
@implementation YALocationManager
#pragma mark - Life cycle
+ (instancetype)sharedManager {
    static YALocationManager *manager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [super new];
        manager.locationManager = [[CLLocationManager alloc] init];
        manager.locationManager.delegate = manager;
        manager.locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters;
        manager.locationManager.distanceFilter = kCLLocationAccuracyNearestTenMeters;
    });
    return manager;
}

- (void)requestAuthorization {
    if (![CLLocationManager locationServicesEnabled]) {
        YALog(@"定位服务没有打开")
        return;
    }
    if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusNotDetermined) {
        [self.locationManager requestWhenInUseAuthorization];
    }
}

- (void)requestLocationWithCompletion:(YALocationRequestCompletion)block {
    self.locationBlock = block;
    [self requestAuthorization];
    [self.locationManager startUpdatingLocation];
}

#pragma mark - location delegate
- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations {
    [manager stopUpdatingLocation];
    CLLocation *currentLocation = locations.firstObject;
    CLGeocoder *geocoder = [[CLGeocoder alloc] init];
    [geocoder reverseGeocodeLocation:currentLocation completionHandler:^(NSArray *placemarks, NSError *error) {
            if (self.locationBlock) {
                self.locationBlock(currentLocation, placemarks.lastObject, error);
            }
    }];
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    if (self.locationBlock) {self.locationBlock(nil, nil, error);}
}
@end
