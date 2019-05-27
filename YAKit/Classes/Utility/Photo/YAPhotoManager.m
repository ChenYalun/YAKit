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
@end
