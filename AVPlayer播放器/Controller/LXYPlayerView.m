//
//  LXYPlayerView.m
//  视频播放
//
//  Created by lixiya on 16/3/30.
//  Copyright © 2016年 lixiya. All rights reserved.
//

#define IphoneHeight  [[UIScreen mainScreen] bounds].size.height
#define IphoneWidth  [[UIScreen mainScreen] bounds].size.width
#define degreeTOradians(x) (M_PI * (x)/180)


#import "LXYPlayerView.h"
#import "LXYPlayerControlView.h"
#import <AVFoundation/AVFoundation.h>

// 枚举值 判断水平移动和垂直移动
typedef NS_ENUM(NSInteger, PanDirection){
    
    PanDirectionHorizontalMoved, //横向移动
    PanDirectionVerticalMoved    //纵向移动
    
};


@interface LXYPlayerView ()

/**
 *  播放器
 */
@property(nonatomic ,strong) AVPlayer * player;

/**
 *  播放对象
 */
@property(nonatomic ,strong) AVPlayerItem * playerItem;

/**
 *  播放层
 */
@property(nonatomic ,strong) AVPlayerLayer * playerLayer;

/**
 *  底部UIImageView
 */
@property(nonatomic ,strong) UIImageView * bottomImgV;

/**
 * 控制层View
 * 暂停/开始 进度条 时间显示 全屏切换按钮
 */
@property(nonatomic ,strong) LXYPlayerControlView * controlView;

@property(nonatomic ,strong) id playerTimeObserver; // 监听播放进度

@property(nonatomic ,strong) NSString * totalTimeString; // 播放总时间
@property(nonatomic ,assign) CGFloat  starPanTime; // 开始移动时当前播放时间进度（秒）
@property(nonatomic ,assign) BOOL isDragSlider; // 是否拖动进度条/pan手势移动
@property (nonatomic, assign) BOOL isFullScreen; // 是否为全屏
@property (nonatomic, assign) BOOL isPauseByUser; // 是否用户自己点击按钮暂停


/** 
 * 移动方向枚举值
 */
@property (nonatomic, assign) PanDirection  panDirection;

@end


@implementation LXYPlayerView

#pragma mark - 隐藏显示LXYPlayerControlView
/**
 *  隐藏显示LXYPlayerControlView
 */
-(void)doTapClick:(UITapGestureRecognizer*)tap{

    if (self.controlView.isMaskShowing) {
        [self hiddenControlView];
    }else{
        [self showControlView];
    }

}

/**
 *  取消延时隐藏LXYPlayerControlView
 */
-(void)canceldelayHiddenControlView{
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(hiddenControlView) object:nil];
}

/**
 *  延时隐藏LXYPlayerControlView
 */
-(void)delayHiddenControlView{

    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(hiddenControlView) object:nil];
    [self performSelector:@selector(hiddenControlView) withObject:nil afterDelay:5];
    
}

-(void)hiddenControlView{
    
    [UIView animateWithDuration:0.5 animations:^{
        [self.controlView hiddenControlView];
    } completion:^(BOOL finished) {
        self.controlView.isMaskShowing = NO;
    }];
}

-(void)showControlView{
    
    [UIView animateWithDuration:0.5 animations:^{
        [self.controlView showControlView];
        
    } completion:^(BOOL finished) {
        self.controlView.isMaskShowing = YES;
        
        // 工具条显示出来后默认延迟隐藏
        [self delayHiddenControlView];

    }];
    
    
}

#pragma mark - 开始暂停，重播，全屏切换方法
/**
 *  暂停、播放
 */
-(void)doPlayBtClick:(UIButton*)bt{
    bt.selected =! bt.selected;
    
    if (bt.selected) {
        // 开始播放
        self.isPauseByUser = NO;
        [self play];
    }else{
        // 暂停
        self.isPauseByUser = YES;
        [self pause];
    }
}

-(void)play{
    [self.player play];
    
    // 开始播放后延迟隐藏
    [self delayHiddenControlView];
}

-(void)pause{
    [self.player pause];
}


/**
 *  全屏切换
 */
-(void)doFullScreenSwitchBtClick:(UIButton*)bt{
    if (!self.isFullScreen) { // 开启全屏

        [UIView animateWithDuration:0.3 animations:^{
            
            // 设置翻转
            self.transform = CGAffineTransformMakeRotation(degreeTOradians(90));
            
            // 设置全屏
            self.frame = CGRectMake(0, 0, IphoneWidth, IphoneHeight);
            
            // 设置其他view
            self.controlView.frame = CGRectMake(0, 0, IphoneHeight, IphoneWidth);
            self.bottomImgV.frame = CGRectMake(0, 0, IphoneHeight, IphoneWidth);
            self.playerLayer.frame =  CGRectMake(0, 0, IphoneHeight, IphoneWidth);
        } completion:^(BOOL finished) {
            
            self.isFullScreen = YES;
            
        }];
        
        [[UIApplication sharedApplication].keyWindow addSubview:self];

    }else{

        [UIView animateWithDuration:0.3 animations:^{
            // 设置翻转(还原)
            self.transform = CGAffineTransformIdentity;

            // 设置全屏
            self.frame = CGRectMake(0, 100, IphoneWidth, 240);
            
            // 设置其他view
            self.controlView.frame = self.bounds;
            self.bottomImgV.frame = self.bounds;
            self.playerLayer.frame = self.bounds;

        } completion:^(BOOL finished) {
            
            self.isFullScreen = NO;
            
        }];
        

    }

}


-(void)layoutSubviews{

    [super layoutSubviews];
   
}

#pragma mark - slider事件 快进后退
/**
 * slider开始滑动
 */
-(void)sliderTouchBegan:(UISlider*)slider{
    
    [self canceldelayHiddenControlView];
}

/**
 * slider滑动中
 */
-(void)sliderValueChanged:(UISlider*)slider{
    _isDragSlider = YES;
    
    // 拖动过程中更新时间进度
    CMTime time = CMTimeMakeWithSeconds(slider.value, 1);
    NSString * currentTimeString = [self convertTime:time.value/time.timescale];
    
    self.controlView.timeLabel.text = [NSString stringWithFormat:@"%@/%@",currentTimeString,_totalTimeString];

}

/**
 * slider滑动结束
 */
-(void)sliderTouchEnded:(UISlider*)slider{
    // 拖动结束，视频跳转到当前时间点
    CMTime time = CMTimeMakeWithSeconds(slider.value, 1);
    [self.player seekToTime:time completionHandler:^(BOOL finished) {
        _isDragSlider = NO;
    }];
}

#pragma mark - pan手势  快进后退
/**
 *  pan手势事件
 */
-(void)panDirection:(UIPanGestureRecognizer*)pan{

    // 移动速率的point
    CGPoint veloctyPoint = [pan velocityInView:pan.view];
    NSLog(@"移动速度的point______%@",NSStringFromCGPoint(veloctyPoint));
    
    switch (pan.state) {
            
        case UIGestureRecognizerStateBegan:{ // 开始移动
            // 使用绝对值来判断移动的方向
            CGFloat x = fabs(veloctyPoint.x);
            CGFloat y = fabs(veloctyPoint.y);
            if (x > y) { // 水平移动
                self.panDirection = PanDirectionHorizontalMoved;
                
                // 显示
                self.controlView.panProgressView.hidden = NO;

                // 当前所处播放时间
                _starPanTime = self.playerItem.currentTime.value/self.playerItem.currentTime.timescale;
                
                _isDragSlider = YES;
            }
            else if (x < y){ // 垂直移动
                self.panDirection = PanDirectionVerticalMoved;
                
                
                
                

            }

            break;
        }
        case UIGestureRecognizerStateChanged:{ // 移动过程中
            switch (self.panDirection) {
                case PanDirectionHorizontalMoved:{
                    [self horizontalMoved:veloctyPoint.x];
                    break;
                }
                case PanDirectionVerticalMoved:{
                    
                    break;
                }
                default:
                    break;
            }

            break;
        }
        case UIGestureRecognizerStateEnded:{ // 移动结束
            switch (self.panDirection) {
                case PanDirectionHorizontalMoved:{
                    
                    // 隐藏
                    self.controlView.panProgressView.hidden = YES;
                    
                    // 平移结束，视频跳转到当前时间点
                    CMTime time = CMTimeMakeWithSeconds(_starPanTime, 1);
                    [self.player seekToTime:time completionHandler:^(BOOL finished) {
                        // starPanTime置空
                        _starPanTime = 0;
                        _isDragSlider = NO;
                    }];
                    
                  
                    break;
                }
                case PanDirectionVerticalMoved:{
                    
                    break;
                }
                default:
                    break;
            }
            
            break;

        }
        default:
            break;
    }
}


/**
 *  pan 水平移动的方法
 */
- (void)horizontalMoved:(CGFloat)value
{
    // 快进快退图标
    UIImage *iconImg = nil;
    if (value < 0) {
        iconImg = [UIImage imageNamed:@"fast_back"];
    }
    else if (value > 0){
        iconImg = [UIImage imageNamed:@"fast_forward"];
    }
    self.controlView.panIconImgV.image = iconImg;
    
    // 每次滑动需要叠加时间
    _starPanTime += value / 200;
    
    // 范围限定
    CGFloat totalSecond = self.playerItem.duration.value/self.playerItem.duration.timescale;
    if (_starPanTime > totalSecond) {
        _starPanTime = totalSecond;
    }else if (_starPanTime < 0){
        _starPanTime = 0;
    }
    
    // 当前快进到达的时间
    NSString *nowTime = [self convertTime:_starPanTime];
    
    // 更新快进进度
    self.controlView.timeLabel.text = [NSString stringWithFormat:@"%@/%@",nowTime,_totalTimeString];
    self.controlView.panTimeLabel.text = [NSString stringWithFormat:@"%@/%@",nowTime,_totalTimeString];
    [self.controlView.playSlider setValue:_starPanTime animated:YES];
    [self.controlView.panProgressSlider setValue:_starPanTime animated:YES];

    NSLog(@"nowTime++++++++++%@/%@",nowTime,_totalTimeString);
    
    
    /*
    // 移动过程中，视频跳转到当前时间点
    CMTime time = CMTimeMakeWithSeconds(_starPanTime, 1);
    [self.player seekToTime:time completionHandler:^(BOOL finished) {
        
    }];
    */
    
}

#pragma mark - init 初始化方法
-(instancetype)initWithFrame:(CGRect)frame videoURL:(NSURL*)url{

    if (self = [super initWithFrame:frame]) {
        self.videoURL = url;
        
        // 播放器
        [self addSubview:self.bottomImgV];
        
        // 底部工具view
        [self addSubview:self.controlView];
    
        // 点击手势
        UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doTapClick:)];
        [self addGestureRecognizer:tap];
        
        [self.controlView.activity startAnimating];

    }
    return  self;
 
}


#pragma mark - 播放器相关
/**
 *  LXYPlayerControlView 控制操作view
 */
-(LXYPlayerControlView *)controlView{

    if (!_controlView) {
        _controlView = [[LXYPlayerControlView alloc] initWithFrame:CGRectMake(0, 0, IphoneWidth, self.frame.size.height)];
        
        // 开始默认滑竿不可用
        _controlView.playSlider.userInteractionEnabled = NO;
        _controlView.playBt.userInteractionEnabled = NO;
        
        // 绑定事件
        [_controlView.playBt addTarget:self action:@selector(doPlayBtClick:) forControlEvents:UIControlEventTouchUpInside];
        [_controlView.fullScreenSwitchBt addTarget:self action:@selector(doFullScreenSwitchBtClick:) forControlEvents:UIControlEventTouchUpInside];

        // slider开始滑动事件
        [_controlView.playSlider addTarget:self action:@selector(sliderTouchBegan:) forControlEvents:UIControlEventTouchDown];
        // slider滑动中事件
        [_controlView.playSlider addTarget:self action:@selector(sliderValueChanged:) forControlEvents:UIControlEventValueChanged];
        // slider结束滑动事件
        [_controlView.playSlider addTarget:self action:@selector(sliderTouchEnded:) forControlEvents:UIControlEventTouchUpInside | UIControlEventTouchCancel | UIControlEventTouchUpOutside];

    }
    return _controlView;
}


/**
 *  播放器视图，这里用UIImageView便于初始显现图片logo
 */
-(UIImageView *)bottomImgV{
    if (!_bottomImgV) {
        _bottomImgV = [[UIImageView alloc] initWithFrame:self.bounds];
        _bottomImgV.image = [UIImage imageNamed:@"bg_media_default@2x.jpg"];
        [_bottomImgV.layer addSublayer:self.playerLayer];
    }
    return _bottomImgV;
}

-(AVPlayerLayer *)playerLayer{
    if (!_playerLayer) {
        _playerLayer = [AVPlayerLayer playerLayerWithPlayer:self.player];
        _playerLayer.frame = self.bounds;
        _playerLayer.videoGravity = AVLayerVideoGravityResizeAspect;
        
        /*
         // transform 这块待研究
         CATransform3D transform = CATransform3DIdentity;
         transform.m34 = -1.0 / 500.0;
         transform = CATransform3DRotate(transform, M_PI_4, 1, 1, 0);
         _playerLayer.transform = transform;
         
         */
    }
    return _playerLayer;
}

-(AVPlayer *)player{
    if (!_player) {
        _player = [[AVPlayer alloc] initWithPlayerItem:self.playerItem];
    }
    return _player;
}

//http://v.jxvdy.com/sendfile/w5bgP3A8JgiQQo5l0hvoNGE2H16WbN09X-ONHPq3P3C1BISgf7C-qVs6_c8oaw3zKScO78I--b0BGFBRxlpw13sf2e54QA

-(AVPlayerItem *)playerItem{
    if (!_playerItem) {
        _playerItem = [[AVPlayerItem alloc] initWithURL:self.videoURL];
        [self addObserverToPlayerItem:_playerItem];
    }
    return _playerItem;
}


/**
 *  给AVPlayerItem添加监控
 *  @param playerItem AVPlayerItem对象
 */
-(void)addObserverToPlayerItem:(AVPlayerItem *)playerItem{
    //监控状态属性，注意AVPlayer也有一个status属性，通过监控它的status也可以获得播放状态
    [playerItem addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:nil];
    
    //loadedTimeRanges表示已经缓冲的进度
    [playerItem addObserver:self forKeyPath:@"loadedTimeRanges" options:NSKeyValueObservingOptionNew context:nil];
    
    // 缓冲区空了，需要等待数据
    [playerItem addObserver:self forKeyPath:@"playbackBufferEmpty" options:NSKeyValueObservingOptionNew context:nil];
    
    // 缓冲区有足够数据可以播放了
    [playerItem addObserver:self forKeyPath:@"playbackLikelyToKeepUp" options:NSKeyValueObservingOptionNew context:nil];

    //播放完成通知
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(moviePlayDidEnd:)name:AVPlayerItemDidPlayToEndTimeNotification object:playerItem];
}


#pragma mark - KVO

/**
 *通过KVO监控播放器状态
 *
 *  @param keyPath监控属性
 *  @param object监视器
 *  @param change状态改变
 *  @param context上下文
 
 *  status状态
 *  AVPlayerItemStatusUnknown,播放源未知
 *  AVPlayerItemStatusReadyToPlay,播放源已经准备好，代表视频已经可以播放了，我们就可以调用play方法播放了
 *  AVPlayerItemStatusFailed播放源失败
 
 */

/**
 * 知识点扩充
 * 1.CMTime可是专门用來表示影片时间的类别,他的用法: CMTimeMake(time, timeScale)
 time当前第几帧, timeScale每秒钟多少帧.当前播放时间time/timeScale
 */

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context{
    AVPlayerItem * playerItem = object;
    
    if ([keyPath isEqualToString:@"status"]) {
        
        if ([playerItem status] == AVPlayerStatusReadyToPlay) {
            NSLog(@"开始播放");
            // 开始播放
            [self.controlView.activity stopAnimating];
            self.controlView.playBt.selected = YES;
            [self play];

            // 开始播放时才可以开启playSlider可用
            self.controlView.playSlider.userInteractionEnabled = YES;
            _controlView.playBt.userInteractionEnabled = YES;

            // 添加平移手势，用来控制音量、亮度、快进快退
            UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(panDirection:)];
            [self addGestureRecognizer:pan];
            
            // 获取视频总长度
            CMTime duration = playerItem.duration;
            // 转换成秒
            CGFloat totalDuration = duration.value/duration.timescale;
            // 转换成播放时间
            _totalTimeString = [self convertTime:totalDuration];
            
            // 设置播放时间
            self.controlView.timeLabel.text = [NSString stringWithFormat:@"00:00/%@",_totalTimeString];
            self.controlView.panTimeLabel.text = [NSString stringWithFormat:@"00:00/%@",_totalTimeString];

            // 设置总的缓冲量
            self.controlView.progressSlider.maximumValue = CMTimeGetSeconds(duration);
            self.controlView.playSlider.maximumValue = CMTimeGetSeconds(duration);
            self.controlView.panProgressSlider.maximumValue = CMTimeGetSeconds(duration);
            
            // 监听播放状态,更新播放进度
            [self addPlayerTimeObserver];
            
            
        } else if ([playerItem status] == AVPlayerStatusFailed) {
            
            NSLog(@"播放失败");
            
        }else if ([playerItem status] == AVPlayerItemStatusUnknown) {
            
            NSLog(@"播放源未知");
            
        }
    } else if ([keyPath isEqualToString:@"loadedTimeRanges"]) {
        
        // 第一次开始播放会出现高亮颜色线？、、？？（原因是先执行loadedTimeRanges这个然后才执行的status，此时progressSlider最大值为空，所以在此判断下）
        if (self.controlView.progressSlider.maximumValue == 1) {
            self.controlView.progressSlider.maximumValue = CMTimeGetSeconds(self.playerItem.duration);
        }
        
        // 计算缓冲进度
        NSTimeInterval currentBuffer = [self availableDuration];
        // 缓冲进度更新
        [self.controlView.progressSlider setValue:currentBuffer animated:YES];
        
    }else if([keyPath isEqualToString:@"playbackBufferEmpty"]){
        if (self.playerItem.playbackBufferEmpty) {
            NSLog(@"缓冲区空了，需要等待数据");
            [self bufferingSomeSecond];
        }
    }else if([keyPath isEqualToString:@"playbackLikelyToKeepUp"]){
        if (self.playerItem.playbackLikelyToKeepUp) {
            NSLog(@"缓冲区有足够数据可以播放了");
            [self.controlView.activity stopAnimating];
        }
    }
}


#pragma mark - 缓冲较差时候
/**
 *  缓冲较差时候回调这里
 *  不知道是否有更好的办法,参考他人的写法
 *  self.maskView.progressView.progress - self.maskView.videoSlider.value) > 0.01这样判断好像比系统的更好点
 */

- (void)bufferingSomeSecond
{
    [self.controlView.activity startAnimating];
    
    // playbackBufferEmpty会反复进入，因此在bufferingOneSecond延时播放执行完之前再调用bufferingSomeSecond都忽略
    __block BOOL isBuffering = NO;
    if (isBuffering) {
        return;
    }
    isBuffering = YES;
    
    // 需要先暂停一小会之后再播放，否则网络状况不好的时候时间在走，声音播放不出来
    [self pause];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        // 如果此时用户已经暂停了，则不再需要开启播放了
        if (self.isPauseByUser) {
            isBuffering = NO;
            return;
        }
        
        // 如果执行了play还是没有播放则说明还没有缓存好，则再次缓存一段时间
        /** 是否缓冲好的标准 （系统默认是1分钟。不建议用 ）*/
        // self.playerItme.isPlaybackLikelyToKeepUp
        // 下面这种方式更好
        if ((self.controlView.progressSlider.value - self.controlView.playSlider.value) > 0.01) {
            [self.controlView.activity stopAnimating];
            [self play];
        }
        else
        {
            [self bufferingSomeSecond];
        }
        
        isBuffering = NO;
        
    });
}



#pragma mark - 播放过程监控
/**
 *  给播放器添加进度更新（播放过程）
 */
-(void)addPlayerTimeObserver{
    
    __weak typeof(self) weakSelf = self;
    self.playerTimeObserver = [self.player addPeriodicTimeObserverForInterval:CMTimeMake(1, 1) queue:NULL usingBlock:^(CMTime time) {
        //NSLog(@"+++++++播放进度监听方法++++++");
        if (weakSelf.isDragSlider) {
            return;
        }
        //CGFloat currentSecond = weakSelf.playerItem.currentTime.value/weakSelf.playerItem.currentTime.timescale;// 计算当前在第几秒
        CGFloat currentSecond = CMTimeGetSeconds(time); // 计算当前在第几秒
        
        NSLog(@"_____当前播放进度_____%f",currentSecond);
        
        // 更新播放进度条
        [weakSelf.controlView.playSlider setValue:currentSecond animated:YES];
        [weakSelf.controlView.panProgressSlider setValue:currentSecond animated:YES];

        // 更新播放时间进度
        NSString *currentTimeString = [weakSelf convertTime:currentSecond];
        weakSelf.controlView.timeLabel.text = [NSString stringWithFormat:@"%@/%@",currentTimeString,weakSelf.totalTimeString];
        weakSelf.controlView.panTimeLabel.text = [NSString stringWithFormat:@"%@/%@",currentTimeString,weakSelf.totalTimeString];

    }];

}


// 计算缓冲
- (NSTimeInterval)availableDuration{
    NSArray *loadedTimeRanges = [self.playerItem loadedTimeRanges];
    CMTimeRange timeRange = [loadedTimeRanges.firstObject CMTimeRangeValue];//本次缓冲时间范围
    
    float startSeconds = CMTimeGetSeconds(timeRange.start);
    float durationSeconds = CMTimeGetSeconds(timeRange.duration);
    NSTimeInterval totalBuffer = startSeconds + durationSeconds;//缓冲总长度
    NSLog(@"_____缓冲进度_____%f",totalBuffer);
    return totalBuffer;
}

// 秒转换成时间格式
- (NSString *)convertTime:(CGFloat)second{
    NSDate *d = [NSDate dateWithTimeIntervalSince1970:second];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    if (second/3600 >= 1) {
        [formatter setDateFormat:@"HH:mm:ss"];
    } else {
        [formatter setDateFormat:@"mm:ss"];
    }
    NSString *totalTime = [formatter stringFromDate:d];
    return totalTime;
}

#pragma mark - 播放完成
-(void)moviePlayDidEnd:(AVPlayerItem*)playerItem{
    NSLog(@"--播放完成--");
    __weak typeof(self) weakSelf = self;
    [self.player seekToTime:kCMTimeZero completionHandler:^(BOOL finished) {
        [weakSelf.controlView playDidEnd];
                
        // 平移快进时视频播放完了，此时隐藏平移快进进度View
        self.controlView.panProgressView.hidden = YES;
    }];
    
}


-(void)dealloc{

    [self.playerItem removeObserver:self forKeyPath:@"status" context:nil];
    [self.playerItem removeObserver:self forKeyPath:@"loadedTimeRanges" context:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:AVPlayerItemDidPlayToEndTimeNotification object:self.playerItem];
    
    [self.player removeTimeObserver:self.playerTimeObserver];

}
@end
