//
//  UIImage+YAImage.m
//  GPS
//
//  Created by Aaron on 2018/8/2.
//  Copyright © 2018年 ChenYalun. All rights reserved.
//

#import "UIImage+YAImage.h"

@implementation UIImage (YAImage)

+ (void)loadLargeImageWithContentsOfFile:(NSString *)imagePath forImageView:(UIImageView *)imageView {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        UIImage *image = [UIImage imageWithContentsOfFile:imagePath];
        // redraw image using device context
        UIGraphicsBeginImageContextWithOptions(imageView.bounds.size, YES, 0);
        [image drawInRect:imageView.bounds];
        image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        // set image on main thread, but only if index still matches up
        dispatch_async(dispatch_get_main_queue(), ^{
            imageView.image = image;
        });
    });
}

+ (UIImage *)loadCacheLargeImageWithContentsOfFile:(NSString *)imagePath forImageView:(UIImageView *)imageView {
    // set up cache
    static NSCache *cache = nil;
    if (!cache) {
        cache = [[NSCache alloc] init];
    }
    // if already cached, return immediately
    UIImage *image = [cache objectForKey:imagePath];
    if (image) {
        return [image isKindOfClass:[NSNull class]]? nil: image;
    }
    // set placeholder to avoid reloading image multiple times
    [cache setObject:[NSNull null] forKey:imagePath];
    // switch to background thread
    dispatch_async( dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        // load image
        UIImage *image = [UIImage imageWithContentsOfFile:imagePath];
        // redraw image using device context
        UIGraphicsBeginImageContextWithOptions(image.size, YES, 0);
        [image drawAtPoint:CGPointZero];
        image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        // set image for correct image view
        dispatch_async(dispatch_get_main_queue(), ^{ //cache the image
            [cache setObject:image forKey:imagePath];
            imageView.image = image;
        });
    });
    // not loaded yet
    return nil;
}

@end
