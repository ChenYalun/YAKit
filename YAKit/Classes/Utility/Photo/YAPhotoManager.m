//
//  YAPhotoManager.m
//  GPS
//
//  Created by Chen,Yalun on 2018/11/5.
//  Copyright © 2018 ChenYalun. All rights reserved.
//

#import "YAPhotoManager.h"
#import <CoreServices/CoreServices.h>

@interface YAPhotoManager()<UIImagePickerControllerDelegate, UINavigationControllerDelegate>
@end

@implementation YAPhotoManager
+ (void)requestReadAuthorizationWithDeniedBlock:(void (^)(void))deniedBlock
                                authorizedBlock:(void (^)(PHFetchResult<PHAsset *> *))authorizedBlock {
    PHAuthorizationStatus status = [PHPhotoLibrary authorizationStatus];
    if (status == PHAuthorizationStatusNotDetermined) {
        [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (status == PHAuthorizationStatusAuthorized) {
                    PHFetchResult<PHAsset *> *allPhotos = [PHAsset fetchAssetsWithOptions:[PHFetchOptions new]];
                    if (authorizedBlock) { authorizedBlock(allPhotos); }
                } else {
                    if (deniedBlock) { deniedBlock(); }
                    return;
                }
            });
        }];
    } else if (status == PHAuthorizationStatusDenied) {
        if (deniedBlock) { deniedBlock(); }
    } else if (status == PHAuthorizationStatusAuthorized) {
        PHFetchResult<PHAsset *> *allPhotos = [PHAsset fetchAssetsWithOptions:[PHFetchOptions new]];
        if (authorizedBlock) { authorizedBlock(allPhotos); }
    }
}

- (void)presentPickerControllerInViewController:(UIViewController *)controller
                                      mediaType:(YAPickMediaType)mediaType{
    UIImagePickerController *pickerController= [[UIImagePickerController alloc] init];
    pickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    pickerController.delegate = self;
    NSMutableArray *types = [NSMutableArray array];
    if ((mediaType & YAPickMediaTypeImage) == YAPickMediaTypeImage) {
        [types addObject:(NSString *)kUTTypeImage];
    }
    if ((mediaType & YAPickMediaTypeVideo) == YAPickMediaTypeVideo) {
        [types addObject:(NSString *)kUTTypeMovie];
    }
    pickerController.mediaTypes = types;
    [controller presentViewController:pickerController animated:YES completion:nil];
}

+ (PHFetchResult <PHAsset *> *)saveImageIntoDefaultAlbum:(UIImage *)image {
    if ([PHPhotoLibrary authorizationStatus] != PHAuthorizationStatusAuthorized) {
        return nil;
    }
    __block NSString *assetID = nil;
    NSError *error = nil;
    [[PHPhotoLibrary sharedPhotoLibrary] performChangesAndWait:^{
        assetID = [PHAssetChangeRequest             creationRequestForAssetFromImage:image].placeholderForCreatedAsset.localIdentifier;
    } error:&error];
    if (error || !assetID) return nil;
    PHFetchResult<PHAsset *> *assets = [PHAsset fetchAssetsWithLocalIdentifiers:@[assetID] options:nil];
    return assets;
}


+ (PHFetchResult <PHAsset *> *)saveImageIntoCustomAlbum:(UIImage *)image {
    if ([PHPhotoLibrary authorizationStatus] != PHAuthorizationStatusAuthorized) {
        return nil;
    }
    PHAssetCollection *customAlbum = nil;
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    NSString *appName = [infoDictionary objectForKey:@"CFBundleName"];
    PHFetchOptions *option = [[PHFetchOptions alloc] init];
    option.predicate = [NSPredicate predicateWithFormat:@"localizedTitle contains %@", appName];
    PHFetchResult<PHAssetCollection *> *collections = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeAlbum subtype:PHAssetCollectionSubtypeAlbumRegular options:option];
    customAlbum = collections.firstObject;
    // Can't find the custom album.
    if (!customAlbum) {
        NSError *error = nil;
        __block NSString *createID = nil;
        [[PHPhotoLibrary sharedPhotoLibrary] performChangesAndWait:^{
            PHAssetCollectionChangeRequest *request = [PHAssetCollectionChangeRequest creationRequestForAssetCollectionWithTitle:appName];
            createID = request.placeholderForCreatedAssetCollection.localIdentifier;
        } error:&error];
        if (!error) {
            customAlbum = [PHAssetCollection fetchAssetCollectionsWithLocalIdentifiers:@[createID] options:nil].firstObject;
        }
    }
    if (!customAlbum) return nil;
    
    PHFetchResult<PHAsset *> *assets = [self saveImageIntoDefaultAlbum:image];
    NSError *error = nil;
    [[PHPhotoLibrary sharedPhotoLibrary] performChangesAndWait:^{
        PHAssetCollectionChangeRequest *collectionChangeRequest = [PHAssetCollectionChangeRequest changeRequestForAssetCollection:customAlbum];
        [collectionChangeRequest insertAssets:assets atIndexes:[NSIndexSet indexSetWithIndex:0]];
    } error:&error];
    return assets;
}

+ (void)pickRecentImageListFromAlbumWithCount:(NSUInteger)count completion:(void (^)(NSArray<UIImage *> *imageList))completion {
    PHFetchOptions *option = [[PHFetchOptions alloc] init];
    option.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:NO]];
    option.fetchLimit = count;
    PHFetchResult<PHAsset *> *allPhotos = [PHAsset fetchAssetsWithOptions:option];
    NSMutableArray <UIImage *> *imageList = [NSMutableArray arrayWithCapacity:count];
    PHImageManager *manager = [PHImageManager defaultManager];
    [allPhotos enumerateObjectsUsingBlock:^(PHAsset * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        PHImageRequestOptions *requestOption = [[PHImageRequestOptions alloc] init];
        requestOption.synchronous = YES;
        [manager requestImageForAsset:obj targetSize:PHImageManagerMaximumSize contentMode:PHImageContentModeDefault options:requestOption resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
            if (result) [imageList addObject:result];
            if (idx == allPhotos.count - 1 && completion) {
                completion(imageList);
            }
        }];
    }];
}

+ (void)asyncSaveImage:(UIImage *)image
               toAlbum:(NSString *)albumName
            completion:(void (^)(BOOL))completion {
    // 最终的方法回调
    void (^finishCallBack)(BOOL) = ^(BOOL success) {
        // 在主线程回调
        dispatch_async(dispatch_get_main_queue(), ^{
            if (completion) completion(success);
        });
    };
    
    void (^block)(void) = ^() {
        [self asyncSaveImageIntoDefaultAlbum:image completion:^(PHFetchResult<PHAsset *> *assets) {
            [self asyncGetCustomAlbumWithName:albumName completion:^(PHAssetCollection *customAlbum) {
                if (!assets || !customAlbum) { // 不存在不保存
                    finishCallBack(NO);
                    return ;
                }
                // 将默认相册中的assets添加到自定义相册
                [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
                    PHAssetCollectionChangeRequest *collectionChangeRequest = [PHAssetCollectionChangeRequest changeRequestForAssetCollection:customAlbum];
                    [collectionChangeRequest addAssets:assets];
                } completionHandler:^(BOOL success, NSError * _Nullable error) {
                    finishCallBack(success);
                }];
            }];
        }];
    };
    
    // 鉴权
    switch (PHPhotoLibrary.authorizationStatus) {
        case PHAuthorizationStatusNotDetermined: {
            // 无权限则请求权限
            [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
                if (status == PHAuthorizationStatusAuthorized) block();
                else if (completion) completion(NO);
            }];
        } break;
        case PHAuthorizationStatusAuthorized: {
            block();
        } break;
        default: {
            if (completion) completion(NO);
        } break;
    }
}

#pragma mark - Private methods
// 保存照片到默认相册(未做权限判断, 不可暴露; 回调在子线程)
+ (void)asyncSaveImageIntoDefaultAlbum:(UIImage *)image
                            completion:(void (^)(PHFetchResult<PHAsset *> *))completion {
    __block NSString *assetID = nil;
    [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
        assetID = [PHAssetChangeRequest             creationRequestForAssetFromImage:image].placeholderForCreatedAsset.localIdentifier;
    } completionHandler:^(BOOL success, NSError * _Nullable error) {
        if (assetID && success && completion) {
            completion([PHAsset fetchAssetsWithLocalIdentifiers:@[assetID] options:nil]);
        } else if (completion) {
            completion(nil);
        }
    }];
}

// 获取自定义相册(未做权限判断, 不可暴露; 回调在子线程)
+ (void)asyncGetCustomAlbumWithName:(NSString *)albumName
                         completion:(void (^)(PHAssetCollection *))completion {
    if (!completion) return; // 没有回调直接返回
    // 自定义相册
    PHFetchOptions *option = [[PHFetchOptions alloc] init];
    option.predicate = [NSPredicate predicateWithFormat:@"localizedTitle contains %@", albumName];
    PHAssetCollection *customAlbum = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeAlbum subtype:PHAssetCollectionSubtypeAlbumRegular options:option].firstObject;
    if (customAlbum) {  // 相册已经存在直接返回
        completion(customAlbum);
        return;
    }
    
    // 没有找到则创建
    __block NSString *createID = nil;
    [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
        PHAssetCollectionChangeRequest *request = [PHAssetCollectionChangeRequest creationRequestForAssetCollectionWithTitle:albumName];
        createID = request.placeholderForCreatedAssetCollection.localIdentifier;
    } completionHandler:^(BOOL success, NSError * _Nullable error) {
        PHAssetCollection *customAlbum = nil;
        if (success && createID) {
            customAlbum = [PHAssetCollection fetchAssetCollectionsWithLocalIdentifiers:@[createID] options:nil].firstObject;
        }
        completion(customAlbum);
    }];
}

#pragma mark - Image Picker Controller Delegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary <NSString *,id> *)info {
    [picker dismissViewControllerAnimated:YES completion:nil];
    UIImage *pickImage = nil;
    NSURL *videoURL = nil;
    NSString *mediaType = [info objectForKey:UIImagePickerControllerMediaType];
    if ([mediaType isEqualToString:@"public.image"]) {
        pickImage = info[UIImagePickerControllerOriginalImage];
    }
    if ([mediaType isEqualToString:@"public.movie"]) {
        videoURL = info[UIImagePickerControllerMediaURL];
    }
    if (self.pickImageCompletion) self.pickImageCompletion(pickImage, videoURL);
}

+ (void)mis_saveImage:(UIImage *)image
              toAlbum:(NSString *)albumName
           completion:(void (^)(BOOL))completion {
    // 最终的方法回调
    void (^finishCallBack)(BOOL) = ^(BOOL success) {
        // 在主线程回调
        dispatch_async(dispatch_get_main_queue(), ^{
            if (completion) completion(success);
        });
    };
    
    void (^block)(void) = ^() {
        [self mis_saveImageIntoDefaultAlbum:image completion:^(PHFetchResult<PHAsset *> *assets) {
            [self mis_getCustomAlbumWithName:albumName completion:^(PHAssetCollection *customAlbum) {
                if (!assets || !customAlbum) { // 不存在不保存
                    finishCallBack(NO);
                    return ;
                }
                // 将默认相册中的assets添加到自定义相册
                [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
                    PHAssetCollectionChangeRequest *collectionChangeRequest = [PHAssetCollectionChangeRequest changeRequestForAssetCollection:customAlbum];
                    [collectionChangeRequest addAssets:assets];
                } completionHandler:^(BOOL success, NSError * _Nullable error) {
                    finishCallBack(success);
                }];
            }];
        }];
    };
    
    // 鉴权
    switch (PHPhotoLibrary.authorizationStatus) {
        case PHAuthorizationStatusNotDetermined: {
            // 无权限则请求权限
            [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
                if (status == PHAuthorizationStatusAuthorized) block();
                else if (completion) completion(NO);
            }];
        } break;
        case PHAuthorizationStatusAuthorized: {
            block();
        } break;
        default: {
            if (completion) completion(NO);
        } break;
    }
}

#pragma mark - Private methods
// 保存照片到默认相册(未做权限判断, 不可暴露; 回调在子线程)
+ (void)mis_saveImageIntoDefaultAlbum:(UIImage *)image
                           completion:(void (^)(PHFetchResult<PHAsset *> *))completion {
    __block NSString *assetID = nil;
    [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
        assetID = [PHAssetChangeRequest             creationRequestForAssetFromImage:image].placeholderForCreatedAsset.localIdentifier;
    } completionHandler:^(BOOL success, NSError * _Nullable error) {
        if (assetID && success && completion) {
            completion([PHAsset fetchAssetsWithLocalIdentifiers:@[assetID] options:nil]);
        } else if (completion) {
            completion(nil);
        }
    }];
}

// 获取自定义相册(未做权限判断, 不可暴露; 回调在子线程)
+ (void)mis_getCustomAlbumWithName:(NSString *)albumName
                        completion:(void (^)(PHAssetCollection *))completion {
    if (!completion) return; // 没有回调直接返回
    // 自定义相册
    PHFetchOptions *option = [[PHFetchOptions alloc] init];
    option.predicate = [NSPredicate predicateWithFormat:@"localizedTitle contains %@", albumName];
    PHAssetCollection *customAlbum = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeAlbum subtype:PHAssetCollectionSubtypeAlbumRegular options:option].firstObject;
    if (customAlbum) {  // 相册已经存在直接返回
        completion(customAlbum);
        return;
    }
    
    // 没有找到则创建
    __block NSString *createID = nil;
    [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
        PHAssetCollectionChangeRequest *request = [PHAssetCollectionChangeRequest creationRequestForAssetCollectionWithTitle:albumName];
        createID = request.placeholderForCreatedAssetCollection.localIdentifier;
    } completionHandler:^(BOOL success, NSError * _Nullable error) {
        PHAssetCollection *customAlbum = nil;
        if (success && createID) {
            customAlbum = [PHAssetCollection fetchAssetCollectionsWithLocalIdentifiers:@[createID] options:nil].firstObject;
        }
        completion(customAlbum);
    }];
}
@end
