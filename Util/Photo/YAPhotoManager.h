//
//  YAPhotoManager.h
//  GPS
//
//  Created by Chen,Yalun on 2018/11/5.
//  Copyright © 2018 ChenYalun. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Photos/Photos.h>
typedef NS_OPTIONS(NSUInteger, YAPickMediaType) {
    YAPickMediaTypeImage    = 1 << 0, // 照片
    YAPickMediaTypeVideo    = 1 << 1, // 视频
};

@interface YAPhotoManager: NSObject
// 弹出相册照片选择控制器且用户选中图片后, 该回调将被调用
@property (nonatomic, copy) void (^pickImageCompletion) (UIImage *image, NSURL *videoURL);

/**
 请求相册访问权限并读取相册图片

 @param deniedBlock 拒绝读取权限
 @param authorizedBlock 允许读取权限
 */
+ (void)requestReadAuthorizationWithDeniedBlock:(void (^)(void))deniedBlock
                                authorizedBlock:(void (^)(PHFetchResult <PHAsset *> *allPhotos))authorizedBlock;

/**
 弹出相册选择控制器

 @param controller 当前控制器
 @param mediaType 媒体类型
 */
- (void)presentPickerControllerInViewController:(UIViewController *)controller
                                      mediaType:(YAPickMediaType)mediaType;

/**
 保存图片到相机胶卷

 @param image 图片
 @return Asset对象集合
 */
+ (PHFetchResult <PHAsset *> *)saveImageIntoDefaultAlbum:(UIImage *)image;

/**
 保存图片到以App name为名称的相册

 @param image 图片
 @return Asset对象集合
 */
+ (PHFetchResult <PHAsset *> *)saveImageIntoCustomAlbum:(UIImage *)image;

/**
 获取相机胶卷中最近的几张照片

 @param count 照片数量
 @param completion 图片集合回调
 */
+ (void)pickRecentImageListFromAlbumWithCount:(NSUInteger)count
                                   completion:(void (^)(NSArray <UIImage *> *imageList))completion;
@end
