//
//  NSObject+YAModel.h
//  Aaron
//
//  Created by Chen,Yalun on 2018/12/20.
//  Copyright © 2018 Chen,Yalun. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol YAModelProtocol <NSObject>
@optional;
+ (NSDictionary <NSString *, NSString *> *)customPropertyKey;
+ (NSDictionary <NSString *, Class>*)classInArray;
@end


@interface NSObject (YAModel)
+ (instancetype)ya_modelWithDictionary:(NSDictionary *)dict;
+ (instancetype)ya_modelWithJSON:(NSData *)data;
+ (NSArray *)ya_modelArrayWithKeyValuesArray:(NSArray <NSDictionary *>*)dictArray;
@end


/*
typedef NS_ENUM(NSUInteger, YASexType) {
    YASexTypeMale,
    YASexTypeFemale,
    YASexTypeOther,
};

@interface YAOne : NSObject
@property YASexType sex;
@property NSNumber *xNSNumber;
@property NSDecimalNumber *xDecimalNumber;
@property BOOL xBOOL;
@property NSInteger xNSInteger;
@property NSUInteger xNSUInteger;
@property CGFloat xCGFloat;
@property NSObject *xNSObject;
@property NSArray *xNSArray;
@property NSMutableArray *xNSMutableArray;
@property NSDictionary *xNSDictionary;
@property NSMutableDictionary *xNSMutableDictionary;
@property NSSet *xNSSet;
@property NSMutableSet *xNSMutableSet;
@property NSString *xNSString;
@property NSMutableString *xNSMutableString;
@property NSData *xNSData;
@property NSDate *xNSDate;
@property Class xClass;
@property SEL xSEL;
@property NSArray <YAOne *> *models;
@property YAOne *one;
@end

@implementation YAOne
+ (NSDictionary *)customPropertyKey {
    return @{@"xNSString": @"xNSStringxNSString"};
}

+ (NSDictionary *)classInArray {
    return @{@"models": [YAOne class]};
}
@end
*/
