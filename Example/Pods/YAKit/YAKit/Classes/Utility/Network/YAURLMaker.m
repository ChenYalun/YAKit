//
//  YAURLMaker.m
//  GPS
//
//  Created by Chen,Yalun on 2018/11/16.
//  Copyright © 2018 ChenYalun. All rights reserved.
//

#import "YAURLMaker.h"

YAServerInterfaceName const kYAServerInterfaceFirstHost = @"kYAServerInterfaceFirstHost";
static NSDictionary <NSString *, NSString *> *interfaceMap = nil;

@implementation YAURLMaker
+ (NSString *)serverHost {
    return @"https://api.chenyalun.com";
}

+ (NSString *)URLWithInterfaceName:(YAServerInterfaceName)name {
    if (!interfaceMap) {
        NSString *first = [NSString stringWithFormat:@"%@/%@", [self serverHost],@"first"];
        interfaceMap = @{kYAServerInterfaceFirstHost: first};
    }
    return interfaceMap[name];
}
@end
