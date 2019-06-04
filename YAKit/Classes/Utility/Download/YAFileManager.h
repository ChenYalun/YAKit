//
//  YAFileManager.h
//  Aaron
//
//  Created by Chen,Yalun on 2019/6/3.
//  Copyright © 2019 Chen,Yalun. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface YAFileManager : NSObject
+ (BOOL)moveItemAtPath:(NSString *)srcPath
                toPath:(NSString *)dstPath
                 error:(NSError **)error;
+ (BOOL)removeItemAtPath:(NSString *)path error:(NSError **)error;
+ (BOOL)fileExistsAtPath:(NSString *)path;
+ (long long)fileSize:(NSString *)path;
+ (NSString *)contentTypeWithURL:(NSURL *)url;
+ (NSString *)cachePathWithURL:(NSURL *)url;
+ (NSString *)tempPathWithURL:(NSURL *)url;
+ (BOOL)isCacheFileExists:(NSURL *)url;
+ (BOOL)isTempFileExists:(NSURL *)url;
@end
