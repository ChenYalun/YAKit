//
//  YANetworkManager.h
//  GPS
//
//  Created by Chen,Yalun on 2018/11/15.
//  Copyright © 2018 ChenYalun. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface YANetworkManager : NSObject
@property (class, readonly) YANetworkManager *sharedManager;
- (void)getWithURL:(NSString *)url
         parameter:(NSDictionary *)parameter
           success:(void (^)(NSURLSessionDataTask *, id))success
           failure:(void (^)(NSURLSessionDataTask *, NSError *))failure;

- (void)postWithURL:(NSString *)url
          parameter:(NSDictionary *)parameter
            success:(void (^)(NSURLSessionDataTask *, id))success
            failure:(void (^)(NSURLSessionDataTask *, NSError *))failure;

- (void)postFormWithURL:(NSString *)url
              parameter:(NSDictionary *)parameter
               fileName:(NSString *)fileName
               mimeType:(NSString *)mimeType
                   data:(NSData *)data
                success:(void (^)(NSURLSessionDataTask *task, id responseObject))success
                failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure;

+ (void)resumeDownloadFileUrl:(NSString *)fileUrl
           destinationFileUrl:(NSString *)destFileUrl
                    otherInfo:(NSDictionary *)otherInfo
                     progress:(void (^)(NSProgress *progress))progressCallback
                     complete:(void (^)(NSURLResponse *response, NSURL *filePath, NSError *error))completion;

+ (instancetype)new NS_UNAVAILABLE;
- (instancetype)init NS_UNAVAILABLE;
@end
