//
//  YACameraManager.h
//  GPS
//
//  Created by Chen,Yalun on 2018/11/6.
//  Copyright © 2018 ChenYalun. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

@interface YACameraManager : NSObject
// 是否有相机权限
@property (nonatomic, assign) BOOL hasCameraAccess;
// 是否打开闪光灯, 默认NO
@property (nonatomic, assign, readonly) BOOL isFlashOn;
// 是否在使用前摄像头, 默认NO
@property (nonatomic, assign, readonly) BOOL isFrontCamera;
// 画面展示view
@property (nonatomic, strong) UIView *previewView;

+ (instancetype)sharedManager;
- (void)requestAccessForVideoTypeWithDeniedBlock:(void (^)(void))deniedBlock
                                 authorizedBlock:(void (^)(void))authorizedBlock;
// 设置前摄像头
- (BOOL)setFrontCameraPosition;
// 设置后摄像头
- (BOOL)setBackCameraPosition;
// 拍照
- (void)takePhotoWithCompletion:(void (^)(UIImage *image))completion;
// 开始捕捉画面
- (void)startCapture;
// 停止捕捉画面
- (void)stopCapture;
// 打开闪光灯
- (void)turnOnFlash;
// 关闭闪光灯
- (void)turnOffFlash;

// 对焦功能,默认NO
- (void)setFocusEnable:(BOOL)enable;
// 缩放功能,默认NO
- (void)setScaleEnable:(BOOL)enable;
@end
