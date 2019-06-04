//
//  YAAudioPlayer.m
//  Aaron
//
//  Created by Chen,Yalun on 2019/6/1.
//  Copyright © 2019 Chen,Yalun. All rights reserved.
//

#import "YAAudioPlayer.h"
#import <AVFoundation/AVFoundation.h>

@interface NSURL (Sreaming)
@end
@implementation NSURL (Sreaming)
- (NSURL *)sreamingURL {
    NSURLComponents *components = [NSURLComponents componentsWithString:self.absoluteString];
    components.scheme = @"sreaming";
    return components.URL;
}
@end



@interface YAAudioPlayer() 
@property (nonatomic, strong) AVPlayer *player;
@end
@implementation YAAudioPlayer
- (void)playWithURL:(NSURL *)url shouldCache:(BOOL)cache {
    if ([url isEqual:self.url] || [url.sreamingURL isEqual:self.url]) {
        [self play];
        return;
    }
    
    // 移除之前的监听者
    if (self.player.currentItem) [self removeObserver];
    if (cache) url = url.sreamingURL;
    AVURLAsset *asset = [AVURLAsset assetWithURL:url];
    [asset.resourceLoader setDelegate:self.resourceLoader queue:dispatch_get_main_queue()];
    AVPlayerItem *item = [AVPlayerItem playerItemWithAsset:asset];
    [item addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:NULL];
    [item addObserver:self forKeyPath:@"playbackLikelyToKeepUp" options:NSKeyValueObservingOptionNew context:NULL];
    self.player = [AVPlayer playerWithPlayerItem:item];
}

- (void)play {
    [self.player play];
    if (self.player.currentItem.playbackLikelyToKeepUp) {
        _state = YAAudioPlayerStatePlaying;
    }
}

- (void)pause {
    [self.player pause];
    if (self.player.currentItem.playbackLikelyToKeepUp) {
        _state = YAAudioPlayerStatePause;
    }
}

- (void)stop {
    [self.player pause];
    self.player = nil;
    _state = YAAudioPlayerStateStop;
}

- (void)seekToProgress:(CGFloat)progress {
    if (progress < 0 || progress > 1) return;
    NSTimeInterval totolTime = self.totalTime;
    CMTime seekTime = CMTimeMake(progress * totolTime, 1);
    [self.player seekToTime:seekTime completionHandler:nil];
}

- (void)seekOffsetTimeDiffer:(NSTimeInterval)time {
    NSTimeInterval totolTime = self.totalTime;
    NSTimeInterval currentTime = self.currentTime;
    currentTime += time;
    [self seekToProgress:currentTime / totolTime];
}

- (void)setRate:(float)rate {
    self.player.rate = rate;
}

- (void)setMuted:(BOOL)muted {
    self.player.muted = muted;
}

- (void)setVolume:(float)volume {
    if (volume < 0 || volume > 1) return;
    if (volume > 0) [self setMuted:NO]; // 音量大于0, 取消静音
    self.player.volume = volume;
}

- (NSTimeInterval)totalTime {
    NSTimeInterval totalTime = CMTimeGetSeconds(self.player.currentItem.duration);
    return isnan(totalTime) ? 0 : totalTime;
}

- (NSTimeInterval)currentTime {
    NSTimeInterval currentTime = CMTimeGetSeconds(self.player.currentItem.currentTime);
    return isnan(currentTime) ? 0 : currentTime;
}

- (CGFloat)progress {
    if (self.totalTime == 0) return 0;
    return self.currentTime / self.totalTime;
}

- (NSURL *)url {
    return [(AVURLAsset *)self.player.currentItem.asset URL];
}

- (CGFloat)loadingProgress {
    CMTimeRange timeRange = [[self.player.currentItem loadedTimeRanges].lastObject CMTimeRangeValue];
    NSTimeInterval loadingTime = CMTimeGetSeconds(CMTimeAdd(timeRange.start, timeRange.duration));
    return loadingTime / self.totalTime;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    if ([keyPath isEqualToString:@"status"]) {
        AVPlayerItemStatus status = [change[NSKeyValueChangeNewKey] integerValue];
        if (status == AVPlayerItemStatusReadyToPlay) {
            [self play];
        }
    } else if ([keyPath isEqualToString:@"playbackLikelyToKeepUp"]) {
        BOOL playback = [change[NSKeyValueChangeNewKey] boolValue];
        if (playback) {
            // 准备播放 用户没有操作
            // [self play];
        } else {
            // 正在加载
            _state = YAAudioPlayerStateLoading;
        }
    }
}

- (void)removeObserver {
    [self.player removeObserver:self forKeyPath:@"status"];
    [self.player removeObserver:self forKeyPath:@"playbackLikelyToKeepUp"];
}
@end

