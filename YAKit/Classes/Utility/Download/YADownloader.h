//
//  YADownloader.h
//  Aaron
//
//  Created by Chen,Yalun on 2019/6/1.
//  Copyright © 2019 Chen,Yalun. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, YADownloaderState) {
    YADownloaderStatePause,
    YADownloaderStateDownloading,
    YADownloaderStateSuccess,
    YADownloaderStateFailure
};

typedef void(^YADownloaderProgressHandler)(CGFloat progress);
typedef void(^YADownloaderSueecssHandler)(NSString *filePath);
typedef void(^YADownloaderFailureHandler)(void);

@interface YADownloader : NSObject
@property (nonatomic, assign, readonly) YADownloaderState state;
@property (nonatomic, assign, readonly) long long tempSize;
@property (nonatomic, assign, readonly) long long totalSize;

@property (nonatomic, copy) YADownloaderProgressHandler progressHandler;
@property (nonatomic, copy) YADownloaderSueecssHandler sueecssHandler;
@property (nonatomic, copy) YADownloaderFailureHandler failureHandler;

// 默认支持断点下载
- (void)startDownloadTaskWithURL:(NSURL *)url;
- (void)pauseTask;
- (void)cancelTask;
- (void)cancelAndClean;
@end


