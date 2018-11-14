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
@end
