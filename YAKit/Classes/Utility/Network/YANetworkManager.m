//
//  YANetworkManager.m
//  GPS
//
//  Created by Chen,Yalun on 2018/11/15.
//  Copyright © 2018 ChenYalun. All rights reserved.
//

#import "YANetworkManager.h"
#import "AFNetworking.h"
@interface YANetworkManager()
@property (nonatomic, strong) AFHTTPSessionManager *sessionManager;
@end


@implementation YANetworkManager
#pragma mark - Life cycle
+ (instancetype)shareMananger {
    static YANetworkManager *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[[self class] alloc] init];
        manager.sessionManager = [AFHTTPSessionManager manager];
        manager.sessionManager.requestSerializer = [AFHTTPRequestSerializer serializer];
        manager.sessionManager.responseSerializer = [AFHTTPResponseSerializer serializer];
        manager.sessionManager.requestSerializer.timeoutInterval = 30.f;
    });
    return manager;
}

+ (YANetworkManager *)sharedManager {
    return [YANetworkManager sharedManager];
}

#pragma mark - Public methods
- (void)postFormWithURL:(NSString *)url
              parameter:(NSDictionary *)parameter
               fileName:(NSString *)fileName
               mimeType:(NSString *)mimeType
                   data:(NSData *)data
                success:(void (^)(NSURLSessionDataTask *, id))success
                failure:(void (^)(NSURLSessionDataTask *, NSError *))failure {
    [self.sessionManager POST:url parameters:parameter constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
        [formData appendPartWithFileData:data name:fileName fileName:fileName mimeType:mimeType];
    } progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if (success) success(task, responseObject);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if (failure) failure(task, error);
    }];
}

+ (void)resumeDownloadFileUrl:(NSString *)fileUrl
           destinationFileUrl:(NSString *)destFileUrl
                    otherInfo:(NSDictionary *)otherInfo
                     progress:(void (^)(NSProgress *progress))progressCallback
                     complete:(void (^)(NSURLResponse *response, NSURL *filePath, NSError *error))completion {
    
    NSURLSessionDownloadTask *task = [self downloadTaskWithUrl:fileUrl destination:destFileUrl progress:progressCallback completion:completion];
    if (task) [task resume];
}

- (void)getWithURL:(NSString *)url
         parameter:(NSDictionary *)parameter
           success:(void (^)(NSURLSessionDataTask *, id))success
           failure:(void (^)(NSURLSessionDataTask *, NSError *))failure {
    [self.sessionManager GET:url parameters:parameter progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if (responseObject && success) success(task, responseObject);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if (failure) failure(task, error);
    }];
}

- (void)postWithURL:(NSString *)url
          parameter:(NSDictionary *)parameter
            success:(void (^)(NSURLSessionDataTask *, id))success
            failure:(void (^)(NSURLSessionDataTask *, NSError *))failure {
    [self.sessionManager POST:url parameters:parameter progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if (success && responseObject) success(task, responseObject);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if (failure) failure(task, error);
    }];
}

#pragma mark - Private methods
+ (NSURLSessionDownloadTask *)downloadTaskWithUrl:(NSString*)fileUrl
                                      destination:(NSString *)destFileUrl
                                         progress:(void (^)(NSProgress *downloadProgress)) downloadProgressCallback
                                       completion:(void (^)(NSURLResponse *response, NSURL *filePath, NSError *error))completion {
    if (!fileUrl || [NSURL URLWithString:fileUrl]) return nil;
    NSURL *destUrl = [NSURL fileURLWithPath:destFileUrl];
    if (!destUrl) return nil;
    AFHTTPSessionManager *downloadManager = [AFHTTPSessionManager manager];
    NSURL *fileRequestUrl = [NSURL URLWithString:fileUrl];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:fileRequestUrl];

    // NSData
    NSString* destFileDir = nil;
    NSString* resumeDataFilePath = nil;
    destFileDir = [destFileUrl stringByDeletingLastPathComponent];
    resumeDataFilePath = [destFileUrl stringByDeletingPathExtension];
    resumeDataFilePath = [resumeDataFilePath stringByAppendingPathExtension:@"tmp"];
    [[NSFileManager defaultManager] createDirectoryAtPath:destFileDir withIntermediateDirectories:YES attributes:nil error:nil];
    
    // Completion
    void (^completionHandler)(NSURLResponse * _Nonnull response, NSURL * _Nullable filePath, NSError * _Nullable error)
    = ^(NSURLResponse * _Nonnull response, NSURL * _Nullable filePath, NSError * _Nullable error) {
        if (error) {
            NSData *resumeData = error.userInfo[@"NSURLSessionDownloadTaskResumeData"];
            if (resumeData.length > 0) {
                [resumeData writeToFile:resumeDataFilePath atomically:YES];
            }
        } else {
            [[NSFileManager defaultManager] removeItemAtPath:resumeDataFilePath error:nil];
        }
        if (completion) completion(response,filePath,error);
    };
    
    typedef NSURL * (^DestinationHandler)(NSURL *targetPath, NSURLResponse *response);
    DestinationHandler destinationHandler = ^(NSURL *targetPath, NSURLResponse *response) {
        if ([response isKindOfClass:[NSHTTPURLResponse class]] && ((NSHTTPURLResponse *)response).statusCode == 200) {
            [[NSFileManager defaultManager] removeItemAtPath:destFileUrl error:nil];
        }
        return destUrl;
    };
    
    
    // Download
    NSURLSessionDownloadTask *downloadTask = nil;
    NSData* resumeData = [NSData dataWithContentsOfFile:resumeDataFilePath];
    if (!(resumeData.length > 0)) {
        downloadTask = [downloadManager downloadTaskWithRequest:request progress:downloadProgressCallback destination:destinationHandler completionHandler:completionHandler];
    } else {
        downloadTask = [downloadManager downloadTaskWithResumeData:resumeData progress:downloadProgressCallback destination:destinationHandler completionHandler:completionHandler];
    }
    return downloadTask;
}
@end
