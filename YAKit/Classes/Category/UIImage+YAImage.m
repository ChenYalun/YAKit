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

+ (UIImage *)rotateImage:(UIImage *)oldImage orientation:(UIImageOrientation)orientation {
    UIImage *newImage = [UIImage imageWithCGImage:oldImage.CGImage scale:oldImage.scale orientation:orientation];
    //fix original Image with gived orientation.
    UIImage *fixedRotationImage = [newImage fixedRotation];
    return fixedRotationImage;
}

- (UIImage *)fixedRotation {
    if (self.imageOrientation == UIImageOrientationUp) return self;
    CGAffineTransform transform = CGAffineTransformIdentity;
    switch (self.imageOrientation) {
        case UIImageOrientationDown:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, self.size.width, self.size.height);
            transform = CGAffineTransformRotate(transform, M_PI);
            break;
            
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
            transform = CGAffineTransformTranslate(transform, self.size.width, 0);
            transform = CGAffineTransformRotate(transform, M_PI_2);
            break;
            
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, 0, self.size.height);
            transform = CGAffineTransformRotate(transform, -M_PI_2);
            break;
        case UIImageOrientationUp:
        case UIImageOrientationUpMirrored:
            break;
    }
    
    switch (self.imageOrientation) {
        case UIImageOrientationUpMirrored:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, self.size.width, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
            
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, self.size.height, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
        case UIImageOrientationUp:
        case UIImageOrientationDown:
        case UIImageOrientationLeft:
        case UIImageOrientationRight:
            break;
    }
    
    // Now we draw the underlying CGImage into a new context, applying the transform
    // calculated above.
    CGContextRef ctx = CGBitmapContextCreate(NULL, self.size.width, self.size.height,
                                             CGImageGetBitsPerComponent(self.CGImage), 0,
                                             CGImageGetColorSpace(self.CGImage),
                                             CGImageGetBitmapInfo(self.CGImage));
    CGContextConcatCTM(ctx, transform);
    switch (self.imageOrientation) {
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            // Grr...
            CGContextDrawImage(ctx, CGRectMake(0,0,self.size.height,self.size.width), self.CGImage);
            break;
            
        default:
            CGContextDrawImage(ctx, CGRectMake(0,0,self.size.width,self.size.height), self.CGImage);
            break;
    }
    
    // And now we just create a new UIImage from the drawing context
    CGImageRef cgimg = CGBitmapContextCreateImage(ctx);
    UIImage *img = [UIImage imageWithCGImage:cgimg];
    CGContextRelease(ctx);
    CGImageRelease(cgimg);
    return img;
}

+ (UIImage *)mirroredImage:(UIImage *)originImage {
    UIImage *newImage = [UIImage imageWithCGImage:originImage.CGImage scale:originImage.scale orientation:UIImageOrientationUpMirrored];
    return [newImage fixedRotation];
}
@end
