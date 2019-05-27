//
//  YACameraManager.m
//  GPS
//
//  Created by Chen,Yalun on 2018/11/6.
//  Copyright © 2018 ChenYalun. All rights reserved.
//


#import "YACameraManager.h"
#define kFocusViewWidthHeight 30 // 对焦视图宽高

@interface YACameraManager() <AVCaptureMetadataOutputObjectsDelegate, UIGestureRecognizerDelegate>
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
@property (nonatomic, strong) AVCaptureDevice *device;
@property (nonatomic, strong) AVCaptureDeviceInput *input;
@property (nonatomic, strong) AVCaptureMetadataOutput *output;
@property (nonatomic, strong) AVCaptureStillImageOutput *imageOutput;
@property (nonatomic, strong) AVCaptureSession *session;
@property (nonatomic, strong) UIButton *focusView;
@property (nonatomic, strong) AVCaptureVideoPreviewLayer *previewLayer;
// 开始的缩放比例
@property(nonatomic, assign) CGFloat beginGestureScale;
// 最后的缩放比例
@property(nonatomic, assign) CGFloat effectiveScale;

@property (nonatomic, strong) UITapGestureRecognizer *focusTap;
@property (nonatomic, strong) UIPinchGestureRecognizer *pinch;
@end

@implementation YACameraManager
#pragma mark - Life cycle
+ (instancetype)sharedManager {
    static YACameraManager *_manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _manager = [[[self class] alloc] init];
    });
    return _manager;
}

- (instancetype)init {
    if (self = [super init]) {
        // Device.
        _device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
        // Input.
        _input = [[AVCaptureDeviceInput alloc] initWithDevice:_device error:nil];
        // Session.
        _session = [[AVCaptureSession alloc] init];
        // Output.
        _output = [[AVCaptureMetadataOutput alloc] init];
        // Image output.
        _imageOutput = [[AVCaptureStillImageOutput alloc] init];
        if ([_session canSetSessionPreset:AVCaptureSessionPreset1280x720]) {
            _session.sessionPreset = AVCaptureSessionPreset1280x720;
        }
        if ([_session canAddInput:self.input]) [_session addInput:_input];
        if ([_session canAddOutput:_imageOutput]) [_session addOutput:_imageOutput];
        _previewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:_session];
        _previewLayer.frame = UIScreen.mainScreen.bounds;
        _previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
        
        if ([_device lockForConfiguration:nil]) {
            if ([_device isFlashModeSupported:AVCaptureFlashModeAuto]) {
                [_device setFlashMode:AVCaptureFlashModeAuto];
            }
            // White balance.
            if ([_device isWhiteBalanceModeSupported:AVCaptureWhiteBalanceModeAutoWhiteBalance]) {
                [_device setWhiteBalanceMode:AVCaptureWhiteBalanceModeAutoWhiteBalance];
            }
            [_device unlockForConfiguration];
        }
        
        // Preview view.
        _previewView = [[UIView alloc] initWithFrame:UIScreen.mainScreen.bounds];
        _previewView.backgroundColor = UIColor.clearColor;
        [_previewView.layer addSublayer:_previewLayer];
        
        // Focus.
        _focusView = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, kFocusViewWidthHeight, kFocusViewWidthHeight)];
        _focusView.backgroundColor = UIColor.orangeColor;
        _focusView.layer.cornerRadius = 0.5 * kFocusViewWidthHeight;
        _focusView.hidden = YES;
        [_previewView addSubview:_focusView];
    }
    return self;
}

#pragma mark - Public methods
- (void)requestAccessForVideoTypeWithDeniedBlock:(void (^)(void))deniedBlock
                                 authorizedBlock:(void (^)(void))authorizedBlock {
    if (self.hasCameraAccess) return ;
    [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
        typeof(self) weakSelf = self;
        if (granted) {
            weakSelf.hasCameraAccess = YES;
            if (authorizedBlock) authorizedBlock();
        } else{
            weakSelf.hasCameraAccess = NO;
            if (deniedBlock) deniedBlock();
        }
    }];
}

- (BOOL)setFrontCameraPosition {
    if (self.isFrontCamera) return NO;
    return [self changeCameraPosition];
}

- (BOOL)setBackCameraPosition {
    if (!self.isFrontCamera) return NO;
    return [self changeCameraPosition];
}

- (BOOL)isFrontCamera {
    return self.input.device.position == AVCaptureDevicePositionFront;
}

- (void)startCapture {
    [self.session startRunning];
}

- (void)stopCapture {
    [self.session stopRunning];
}

- (void)takePhotoWithCompletion:(void (^)(UIImage *))completion {
    AVCaptureConnection *videoConnection = [self.imageOutput connectionWithMediaType:AVMediaTypeVideo];
    if (!videoConnection) return;
    [self.imageOutput captureStillImageAsynchronouslyFromConnection:videoConnection completionHandler:^(CMSampleBufferRef imageDataSampleBuffer, NSError *error) {
        if (imageDataSampleBuffer == NULL) return;
        [self stopCapture];
        NSData *imageData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageDataSampleBuffer];
        UIImage *image = [UIImage imageWithData:imageData];
        if (completion) completion(image);
    }];
}

- (void)turnOnFlash {
    if ([self.device lockForConfiguration:nil] && [self.device hasTorch] ) {
        if (!self.isFlashOn) {
            [self.device setTorchMode:AVCaptureTorchModeOn];
            _isFlashOn = YES;
        }
        [self.device unlockForConfiguration];
    }
}

- (void)turnOffFlash {
    if ([self.device lockForConfiguration:nil] && [self.device hasTorch]) {
        if (self.isFlashOn) {
            [self.device setTorchMode:AVCaptureTorchModeOff];
            _isFlashOn = NO;
        }
        [self.device unlockForConfiguration];
    }
}

- (void)setFocusEnable:(BOOL)enable {
    if (enable) {
        [self.previewView addGestureRecognizer:self.focusTap];
    } else {
        [self.previewView removeGestureRecognizer:self.focusTap];
    }
}

- (void)setScaleEnable:(BOOL)enable {
    if (enable) {
        [self.previewView addGestureRecognizer:self.pinch];
    } else {
        [self.previewView removeGestureRecognizer:self.pinch];
    }
}

#pragma mark - Delegate
- (void)captureOutput:(AVCaptureOutput *)output didOutputMetadataObjects:(NSArray<__kindof AVMetadataObject *> *)metadataObjects fromConnection:(AVCaptureConnection *)connection {
    
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    if ([gestureRecognizer isKindOfClass:[UIPinchGestureRecognizer class]] ) {
        self.beginGestureScale = self.effectiveScale;
    }
    return YES;
}

#pragma mark - Getter and setter
- (UIPinchGestureRecognizer *)pinch {
    if (!_pinch) {
        // Scale.
        _pinch = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(handlePinchGesture:)];
        _pinch.delegate = self;
        [self.previewView addGestureRecognizer:_pinch];
    }
    return _pinch;
}

- (UITapGestureRecognizer *)focusTap {
    if (!_focusTap) {
        _focusTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(focusGesture:)];
        [self.previewView addGestureRecognizer:_focusTap];
    }
    return _focusTap;
}

#pragma mark - Private methods
- (void)focusGesture:(UITapGestureRecognizer*)gesture{
    CGPoint point = [gesture locationInView:gesture.view];
    CGSize size = UIScreen.mainScreen.bounds.size;
    CGPoint focusPoint = CGPointMake(point.y / size.height, 1 - point.x / size.width);
    NSError *error;
    if ([self.device lockForConfiguration:&error]) {
        // 对焦模式和对焦点
        if ([self.device isFocusModeSupported:AVCaptureFocusModeAutoFocus]) {
            [self.device setFocusPointOfInterest:focusPoint];
            [self.device setFocusMode:AVCaptureFocusModeAutoFocus];
        }
        // 曝光模式和曝光点
        if ([self.device isExposureModeSupported:AVCaptureExposureModeAutoExpose ]) {
            [self.device setExposurePointOfInterest:focusPoint];
            [self.device setExposureMode:AVCaptureExposureModeAutoExpose];
        }
        
        [self.device unlockForConfiguration];
        //设置对焦动画
        _focusView.center = point;
        _focusView.hidden = NO;
        [UIView animateWithDuration:0.3 animations:^{
            self.focusView.transform = CGAffineTransformMakeScale(1.25, 1.25);
        }completion:^(BOOL finished) {
            [UIView animateWithDuration:0.5 animations:^{
                self.focusView.transform = CGAffineTransformIdentity;
            } completion:^(BOOL finished) {
                self.focusView.hidden = YES;
            }];
        }];
    }
}

- (void)handlePinchGesture:(UIPinchGestureRecognizer *)recognizer{
    BOOL allTouchesAreOnThePreviewLayer = YES;
    for (int i = 0; i < recognizer.numberOfTouches; i++) {
        CGPoint location = [recognizer locationOfTouch:i inView:self.previewView];
        CGPoint convertedLocation = [self.previewLayer convertPoint:location fromLayer:self.previewLayer.superlayer];
        if (![self.previewLayer containsPoint:convertedLocation]) {
            allTouchesAreOnThePreviewLayer = NO;
            break;
        }
    }
    
    if (!allTouchesAreOnThePreviewLayer) return ;
    self.effectiveScale = self.beginGestureScale * recognizer.scale;
    if (self.effectiveScale < 1.0) self.effectiveScale = 1.0;
    if (self.effectiveScale > 2.0) self.effectiveScale = 2.0;
    CGFloat maxFactor = [[self.imageOutput connectionWithMediaType:AVMediaTypeVideo] videoMaxScaleAndCropFactor];
    if (self.effectiveScale > maxFactor) self.effectiveScale = maxFactor;
    
    [CATransaction begin];
    [CATransaction setAnimationDuration:.025];
    [self.previewLayer setAffineTransform:CGAffineTransformMakeScale(self.effectiveScale, self.effectiveScale)];
    NSError *error = nil;
    if ([self.device lockForConfiguration:&error]) {
        self.device.videoZoomFactor = self.effectiveScale;
    }
    [self.device unlockForConfiguration];
    [CATransaction commit];
}

- (AVCaptureDevice *)cameraWithPosition:(AVCaptureDevicePosition)position{
    NSArray *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    for (AVCaptureDevice *device in devices) {
        if (device.position == position) {
            return device;
        }
    }
    return nil;
}

- (BOOL)changeCameraPosition {
    if ([AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo].count <= 1) return NO;
    // Animation.
    CATransition *animation = [CATransition animation];
    animation.duration = 0.7f;
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    animation.type = @"oglFlip";
    
    // Device and input.
    AVCaptureDevice *newCamera = nil;
    AVCaptureDeviceInput *newInput = nil;
    if (self.isFrontCamera){
        newCamera = [self cameraWithPosition:AVCaptureDevicePositionBack];
        animation.subtype = kCATransitionFromLeft;
    } else {
        newCamera = [self cameraWithPosition:AVCaptureDevicePositionFront];
        animation.subtype = kCATransitionFromRight;
    }
    [self.previewLayer addAnimation:animation forKey:@"animation"];
    
    newInput = [AVCaptureDeviceInput deviceInputWithDevice:newCamera error:nil];
    if (!newInput) return NO;
    
    // Commit onfiguration.
    [self.session beginConfiguration];
    [self.session removeInput:self.input];
    if ([self.session canAddInput:newInput]) {
        [self.session addInput:newInput];
        self.input = newInput;
    } else {
        [self.session addInput:self.input];
    }
    [self.session commitConfiguration];
    return YES;
}
@end

#pragma clang diagnostic pop
