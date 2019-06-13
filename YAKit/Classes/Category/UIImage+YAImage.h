//
//  UIImage+YAImage.h
//  GPS
//
//  Created by Aaron on 2018/8/2.
//  Copyright © 2018年 ChenYalun. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (YAImage)

/**
 高性能加载大型图片(速度是普通方式的几十倍)

 @param imagePath 图片路径
 @param imageView 图片所在视图
 */
+ (void)loadLargeImageWithContentsOfFile:(NSString *)imagePath
                            forImageView:(UIImageView *)imageView;


/**
 高性能加载大型图片并作缓存处理

 @param imagePath 图片路径
 @param imageView 图片所在视图
 @return 加载后的图片
 */
+ (UIImage *)loadCacheLargeImageWithContentsOfFile:(NSString *)imagePath
                                      forImageView:(UIImageView *)imageView;

/**
 优雅地旋转图片

 @param oldImage 原始图片
 @param orientation 旋转方向
 @return 旋转后的图片
 */
+ (UIImage *)rotateImage:(UIImage *)oldImage orientation:(UIImageOrientation)orientation;

/**
 获取镜像图片

 @param originImage 原始图片
 @return 镜像图片
 */
+ (UIImage *)mirroredImage:(UIImage *)originImage;

/**
 高性能获取缩略图

 @param size 目标尺寸
 @return 缩略图
 */
- (UIImage *)thumbnailImageForSize:(CGSize)size;
@end
