//
//  LXYPlayerFootView.m
//  视频播放
//
//  Created by lixiya on 16/3/30.
//  Copyright © 2016年 lixiya. All rights reserved.
//


#define   KFootViewHeight    40  // 下面工具栏高度

#import "LXYPlayerFootView.h"

@implementation LXYPlayerFootView

-(instancetype)initWithFrame:(CGRect)frame{

    if (self = [super initWithFrame:frame]) {
        // View透明度
        self.backgroundColor = [UIColor colorWithRed:0.0f green:0.0f blue:0.0f alpha:0.4f];
        
        // 开始默认显示
        self.isMaskShowing = YES;
        
        [self setUpChildView];
    }
    return self;
}

#pragma mark - 播放选项设置
-(void)setUpChildView{
   
    // 开始、暂停
    _playBt = [UIButton buttonWithType:UIButtonTypeCustom];
    _playBt.frame = CGRectMake(10, (KFootViewHeight-30)/2, 30, 30);
    [_playBt setImage:[UIImage imageNamed:@"CDPPlay"] forState:UIControlStateNormal];
    [_playBt setImage:[UIImage imageNamed:@"CDPPause"] forState:UIControlStateSelected];
    [self addSubview:_playBt];
    
    // 全屏切换按钮
    _fullScreenSwitchBt = [UIButton buttonWithType:UIButtonTypeCustom];
    _fullScreenSwitchBt.frame = CGRectMake(self.frame.size.width-30-10, (KFootViewHeight-30)/2, 30, 30);
    [_fullScreenSwitchBt setImage:[UIImage imageNamed:@"CDPZoomIn"] forState:UIControlStateNormal];
    [_fullScreenSwitchBt setImage:[UIImage imageNamed:@"CDPZoomOut"] forState:UIControlStateSelected];
    [self addSubview:_fullScreenSwitchBt];
    
    // 时间
    _timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMinX(_fullScreenSwitchBt.frame)-80,(KFootViewHeight-30)/2,80,30)];
    _timeLabel.textAlignment = NSTextAlignmentCenter;
    _timeLabel.text = @"00:00/00:00";
    _timeLabel.font = [UIFont systemFontOfSize:10];
    _timeLabel.numberOfLines = 0;
    _timeLabel.textColor = [UIColor whiteColor];
    [self addSubview:_timeLabel];
    
    // 缓冲进度条
    _progressSlider = [[UISlider alloc] initWithFrame:CGRectMake(CGRectGetMaxX(_playBt.frame), (KFootViewHeight-10)/2,CGRectGetMinX(_timeLabel.frame)-CGRectGetMaxX(_playBt.frame), 10)];
    _progressSlider.userInteractionEnabled = NO;
    [_progressSlider setThumbImage:[[UIImage alloc]init] forState:UIControlStateNormal];
    _progressSlider.minimumTrackTintColor = [UIColor greenColor];
    _progressSlider.maximumTrackTintColor = [UIColor grayColor];
    [self addSubview:_progressSlider];

    
    // 进度条
    _playSlider = [[UISlider alloc] initWithFrame:CGRectMake(CGRectGetMaxX(_playBt.frame), (KFootViewHeight-10)/2,CGRectGetMinX(_timeLabel.frame)-CGRectGetMaxX(_playBt.frame), 10)];
    [_playSlider setThumbImage:[UIImage imageNamed:@"CDPSlider"] forState:UIControlStateNormal];
    _playSlider.minimumTrackTintColor=[UIColor whiteColor];
    _playSlider.maximumTrackTintColor=[UIColor clearColor];
    [self addSubview:_playSlider];
    

}

@end
