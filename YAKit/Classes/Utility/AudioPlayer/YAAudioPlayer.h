//
//  YAAudioPlayer.h
//  Aaron
//
//  Created by Chen,Yalun on 2019/6/1.
//  Copyright © 2019 Chen,Yalun. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol AVAssetResourceLoaderDelegate;
typedef NS_ENUM(NSUInteger, YAAudioPlayerState) {
    YAAudioPlayerStateDefault, // 未加载
    YAAudioPlayerStateLoading, // 加载中
    YAAudioPlayerStatePlaying, // 播放中
    YAAudioPlayerStatePause,   // 暂停
    YAAudioPlayerStateStop,    // 停止, 加载成功, 加载失败
};

@interface YAAudioPlayer : NSObject

@property (nonatomic, assign, readonly) NSTimeInterval totalTime;
@property (nonatomic, assign, readonly) NSTimeInterval currentTime;
@property (nonatomic, assign, readonly) CGFloat progress;
@property (nonatomic, assign, readonly) CGFloat loadingProgress;
@property (nonatomic, assign, readonly) YAAudioPlayerState state;
@property (nonatomic, strong, readonly) NSURL *url;
// 配置资源加载器
@property (nonatomic, weak) id <AVAssetResourceLoaderDelegate> resourceLoader;

- (void)playWithURL:(NSURL *)url shouldCache:(BOOL)cache;
- (void)play;
- (void)pause;
- (void)stop;
// 设置进度(0~1)
- (void)seekToProgress:(CGFloat)progress;
// 设置时间偏移
- (void)seekOffsetTimeDiffer:(NSTimeInterval)time;
// 倍速
- (void)setRate:(float)rate;
// 静音
- (void)setMuted:(BOOL)muted;
// 音量
- (void)setVolume:(float)volume;
@end

