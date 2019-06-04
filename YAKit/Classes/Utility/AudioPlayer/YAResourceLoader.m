//
//  YAResourceLoader.m
//  Aaron
//
//  Created by Chen,Yalun on 2019/6/3.
//  Copyright © 2019 Chen,Yalun. All rights reserved.
//

#import "YAResourceLoader.h"
#import "YAFileManager.h"
#import <AVFoundation/AVFoundation.h>


@interface NSURL (HTTP)
@end
@implementation NSURL (HTTP)
- (NSURL *)httpURL {
    NSURLComponents *components = [NSURLComponents componentsWithString:self.absoluteString];
    components.scheme = @"http";
    return components.URL;
}
@end



@interface YAResourceLoader() <AVAssetResourceLoaderDelegate>
@property (nonatomic, strong) NSMutableArray<AVAssetResourceLoadingRequest *> *loadingRequests;
@end
@implementation YAResourceLoader
- (BOOL)resourceLoader:(AVAssetResourceLoader *)resourceLoader shouldWaitForLoadingOfRequestedResource:(AVAssetResourceLoadingRequest *)loadingRequest {
    NSURL *url = [loadingRequest.request.URL httpURL];
    if ([YAFileManager isCacheFileExists:url]) {
        // 文件已经下载完成, 直接请求本地
        loadingRequest.contentInformationRequest.contentType = [YAFileManager contentTypeWithURL:url];
        loadingRequest.contentInformationRequest.contentLength = [YAFileManager fileSize:[YAFileManager cachePathWithURL:url]];
        loadingRequest.contentInformationRequest.byteRangeAccessSupported = YES;
        NSData *data = [NSData dataWithContentsOfFile:[YAFileManager cachePathWithURL:url] options:NSDataReadingMappedIfSafe error:nil];
        long long requestOffset = loadingRequest.dataRequest.requestedOffset;
        long long requestLen = loadingRequest.dataRequest.requestedLength;
        NSData *subData = [data subdataWithRange:NSMakeRange(requestOffset, requestLen)];
        [loadingRequest.dataRequest respondWithData:subData];
        [loadingRequest finishLoading];
        return YES;
    } else {
        // 待完善
    }
    return YES;
}
@end
