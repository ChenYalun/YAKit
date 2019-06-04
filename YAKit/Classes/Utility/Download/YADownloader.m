//
//  YADownloader.m
//  Aaron
//
//  Created by Chen,Yalun on 2019/6/1.
//  Copyright © 2019 Chen,Yalun. All rights reserved.
//

#import "YADownloader.h"
#import "YAFileManager.h"

#define kTempPath NSTemporaryDirectory()
#define kCachePath NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES).firstObject

@interface YADownloader() <NSURLSessionTaskDelegate>
@property (nonatomic, strong) NSURLSession *session;
@property (nonatomic, copy) NSString *filePath;
@property (nonatomic, copy) NSString *downloadingPath;
@property (nonatomic, strong) NSOutputStream *outputStream;
@property (nonatomic, weak) NSURLSessionDataTask *dataTask;
@end

@implementation YADownloader
- (void)startDownloadTaskWithURL:(NSURL *)url {
    // 暂停下载后继续下载
    if ([url isEqual:self.dataTask.originalRequest.URL]) {
        [self resumeTask];
        return;
    }
    // 取消下载后重新下载
    NSString *fileName = url.lastPathComponent;
    self.downloadingPath = [kTempPath stringByAppendingPathComponent:fileName];
    self.filePath = [kCachePath stringByAppendingPathComponent:fileName];
    if (![YAFileManager fileExistsAtPath:self.downloadingPath]) {
        [self startDownloadTaskWithURL:url offset:0];
        return ;
    }
    // 取消下载后继续下载
    _tempSize = [YAFileManager fileSize:self.downloadingPath];
    [self startDownloadTaskWithURL:url offset:_tempSize];
}

- (void)resumeTask {
    if (self.dataTask && self.state == YADownloaderStatePause) {
        self.state = YADownloaderStateDownloading;
        [self.dataTask resume];
    }
}

- (void)pauseTask {
    if (self.state == YADownloaderStateDownloading) {
        self.state = YADownloaderStatePause;
        [self.dataTask suspend];
    }
}

- (void)cancelTask {
    self.state = YADownloaderStatePause;
    [self.session invalidateAndCancel];
    _session = nil;
    _filePath = nil;
    _downloadingPath = nil;
    _progressHandler = nil;
    _sueecssHandler = nil;
    _failureHandler = nil;
    _tempSize = 0;
    _totalSize = 0;
    _outputStream = nil;
    _dataTask = nil;
}

- (void)cancelAndClean {
    [self cancelTask];
    [YAFileManager removeItemAtPath:self.downloadingPath error:nil];
}

- (void)startDownloadTaskWithURL:(NSURL *)url offset:(long long)offset {
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:0];
    [request setValue:[NSString stringWithFormat:@"bytes=%lld-", offset] forHTTPHeaderField:@"Range"];
    self.dataTask = [self.session dataTaskWithRequest:request];
    [self resumeTask];
}

#pragma mark - Getter and setter
- (NSURLSession *)session {
    if (!_session) {
        _session = [NSURLSession sessionWithConfiguration:NSURLSessionConfiguration.defaultSessionConfiguration delegate:self delegateQueue:NSOperationQueue.mainQueue];
    }
    return _session;
}

- (void)setState:(YADownloaderState)state {
    _state = state;
    if (self.sueecssHandler && state == YADownloaderStateSuccess) {
        self.sueecssHandler(self.filePath);
    } else if (self.failureHandler && state == YADownloaderStateFailure) {
        self.failureHandler();
    }
}

#pragma mark - Session task delegate
- (void)URLSession:(NSURLSession *)session dataTask:(nonnull NSURLSessionDataTask *)dataTask didReceiveResponse:(nonnull NSHTTPURLResponse *)response completionHandler:(nonnull void (^)(NSURLSessionResponseDisposition))completionHandler {
    _totalSize = [response.allHeaderFields[@"Content-Length"] longLongValue];
    NSString *contentRange = response.allHeaderFields[@"Content-Range"];
    if (contentRange.length) {
        _totalSize = [[contentRange componentsSeparatedByString:@"/"].lastObject longLongValue];
    }
    
    // 下载完成
    if (_totalSize == _tempSize) {
        [YAFileManager moveItemAtPath:self.downloadingPath toPath:self.filePath error:nil];
        completionHandler(NSURLSessionResponseCancel);
        self.state = YADownloaderStateSuccess;
        return;
    }
    
    // 文件错误
    if (_tempSize > _totalSize) {
        [YAFileManager removeItemAtPath:self.downloadingPath error:nil];
        completionHandler(NSURLSessionResponseCancel);
        [self startDownloadTaskWithURL:response.URL];
        return;
    }
    
    // 下载中
    self.state = YADownloaderStateDownloading;
    self.outputStream = [NSOutputStream outputStreamToFileAtPath:self.downloadingPath append:YES];
    [self.outputStream open];
    completionHandler(NSURLSessionResponseAllow);
}

- (void)URLSession:(NSURLSession *)session dataTask:(nonnull NSURLSessionDataTask *)dataTask didReceiveData:(nonnull NSData *)data {
    _tempSize += data.length;
    if (self.progressHandler) self.progressHandler(1.0 * _tempSize / _totalSize);
    [self.outputStream write:data.bytes maxLength:data.length];
}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(nullable NSError *)error {
    if (error) {
        if (error.code == -999) {
            self.state = YADownloaderStatePause;
        } else {
            self.state = YADownloaderStateFailure;
        }
    } else {
        self.state = YADownloaderStateSuccess;
        [YAFileManager moveItemAtPath:self.downloadingPath toPath:self.filePath error:nil];
    }
    [self.outputStream close];
}
@end
