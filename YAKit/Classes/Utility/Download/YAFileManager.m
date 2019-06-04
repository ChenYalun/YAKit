//
//  YAFileManager.m
//  Aaron
//
//  Created by Chen,Yalun on 2019/6/3.
//  Copyright © 2019 Chen,Yalun. All rights reserved.
//

#import "YAFileManager.h"

#define kTempPath NSTemporaryDirectory()
#define kCachePath NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES).firstObject

@interface YAFileManager()
@property (nonatomic, strong) NSFileManager *fileManager;
@end
@implementation YAFileManager
+ (BOOL)moveItemAtPath:(NSString *)srcPath toPath:(NSString *)dstPath error:(NSError **)error {
    return [NSFileManager.defaultManager moveItemAtPath:srcPath toPath:dstPath error:error];
}

+ (BOOL)fileExistsAtPath:(NSString *)path {
    return [NSFileManager.defaultManager fileExistsAtPath:path];
}

+ (long long)fileSize:(NSString *)path {
    if (![self fileExistsAtPath:path]) return 0;
    NSDictionary *fileInfo = [NSFileManager.defaultManager attributesOfItemAtPath:path error:nil];
    return [fileInfo[NSFileSize] longLongValue];
}

+ (BOOL)removeItemAtPath:(NSString *)path error:(NSError **)error {
    return [NSFileManager.defaultManager removeItemAtPath:path error:error];
}

+ (NSString *)contentTypeWithURL:(NSURL *)url {
    NSString *fileExtension = url.absoluteString.pathExtension;
    CFStringRef contentTypeCF = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, (__bridge CFStringRef _Nonnull)(fileExtension), NULL);
    NSString *contentType = CFBridgingRelease(contentTypeCF);
    return contentType;
}

+ (NSString *)cachePathWithURL:(NSURL *)url {
    return [kCachePath stringByAppendingPathComponent:url.lastPathComponent];
}

+ (NSString *)tempPathWithURL:(NSURL *)url {
    return [kTempPath stringByAppendingPathComponent:url.lastPathComponent];
}

+ (BOOL)isCacheFileExists:(NSURL *)url {
    return [[NSFileManager defaultManager] fileExistsAtPath:[self cachePathWithURL:url]];
}

+ (BOOL)isTempFileExists:(NSURL *)url {
    return [[NSFileManager defaultManager] fileExistsAtPath:[self tempPathWithURL:url]];
}
@end
