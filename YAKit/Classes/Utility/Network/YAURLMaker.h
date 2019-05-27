//
//  YAURLMaker.h
//  GPS
//
//  Created by Chen,Yalun on 2018/11/16.
//  Copyright © 2018 ChenYalun. All rights reserved.
//

#import <Foundation/Foundation.h>
typedef NSString *YAServerInterfaceName;

extern YAServerInterfaceName const kYAServerInterfaceFirstHost;

@interface YAURLMaker : NSObject
@property (class, readonly) NSString *serverHost;
+ (NSString *)URLWithInterfaceName:(YAServerInterfaceName)name;
@end
