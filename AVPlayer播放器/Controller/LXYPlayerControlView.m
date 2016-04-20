//
//  LXYPlayerControlView.m
//  视频播放
//
//  Created by lixiya on 16/4/6.
//  Copyright © 2016年 lixiya. All rights reserved.
//

#define   KFooterViewHeight    40  // 下面工具栏高度
#define   KHeaderViewHeight    40  // 上面工具栏高度

#import "LXYPlayerControlView.h"
#import "UIView+SDAutoLayout.h"

@implementation LXYPlayerControlView


-(instancetype)initWithFrame:(CGRect)frame{

    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor clearColor];
        
        [self addSubview:self.headerView];
        [self addSubview:self.footerView];
        [self addSubview:self.panProgressView];
        [self addSubview:self.activity];

        [self.headerView addSubview:self.backBt];
        [self.headerView addSubview:self.titleLabel];
        
        
        [self.footerView addSubview:self.playBt];
        [self.footerView addSubview:self.fullScreenSwitchBt];
        [self.footerView addSubview:self.timeLabel];
        [self.footerView addSubview:self.progressSlider];
        [self.footerView addSubview:self.playSlider];
        
        [self.panProgressView addSubview:self.panIconImgV];
        [self.panProgressView addSubview:self.panTimeLabel];
        [self.panProgressView addSubview:self.panProgressSlider];

        // 添加约束
        self.headerView.sd_layout
        .leftSpaceToView(self,0)
        .rightSpaceToView(self,0)
        .topSpaceToView(self,0)
        .heightIs(KHeaderViewHeight);
        
        self.backBt.sd_layout
        .leftSpaceToView(self.headerView,10)
        .topSpaceToView(self.headerView,(KHeaderViewHeight-30)/2)
        .heightIs(30)
        .widthIs(30);
        
        self.titleLabel.sd_layout
        .leftSpaceToView(self.backBt,10)
        .rightSpaceToView(self.headerView,10)
        .topEqualToView(self.backBt)
        .heightIs(30);
        
        // 底部
        self.footerView.sd_layout
        .leftSpaceToView(self,0)
        .rightSpaceToView(self,0)
        .bottomSpaceToView(self,0)
        .heightIs(KFooterViewHeight);
        
        self.playBt.sd_layout
        .leftSpaceToView(self.footerView,10)
        .topSpaceToView(self.footerView,(KFooterViewHeight-30)/2)
        .heightIs(30)
        .widthIs(30);

        self.fullScreenSwitchBt.sd_layout
        .rightSpaceToView(self.footerView,10)
        .topEqualToView(self.playBt)
        .heightIs(30)
        .widthIs(30);

        self.timeLabel.sd_layout
        .rightSpaceToView(self.fullScreenSwitchBt,10)
        .topEqualToView(self.playBt)
        .heightIs(30)
        .widthIs(80);
        
        self.playSlider.sd_layout
        .leftSpaceToView(self.playBt,10)
        .rightSpaceToView(self.timeLabel,10)
        .heightIs(10)
        .topSpaceToView(self.footerView,(KFooterViewHeight-10)/2);
        
        self.progressSlider.sd_layout
        .leftSpaceToView(self.playBt,10)
        .rightSpaceToView(self.timeLabel,10)
        .heightIs(10)
        .topSpaceToView(self.footerView,(KFooterViewHeight-10)/2);
        
        // 快进后退进度提示view
        self.panProgressView.sd_layout.centerXEqualToView(self).centerYEqualToView(self).heightIs(80).widthIs(120);
        self.panIconImgV.sd_layout.topSpaceToView(self.panProgressView,5).centerXEqualToView(self.panProgressView).heightIs(30).widthIs(30);
        self.panTimeLabel.sd_layout.centerXEqualToView(self.panProgressView).topSpaceToView(self.panIconImgV,5).widthRatioToView(self.panProgressView,1).heightIs(20);
        self.panProgressSlider.sd_layout.leftSpaceToView(self.panProgressView,10).rightSpaceToView(self.panProgressView,10).topSpaceToView(self.panTimeLabel,0).heightIs(10);
        
        // 菊花
        self.activity.sd_layout.centerXEqualToView(self).centerYEqualToView(self);
        
        
        // 默认显示工具条
        self.isMaskShowing = YES;

    }
    return self;
}

#pragma mark - methods

-(void)showControlView{
    self.headerView.alpha = 1;
    self.footerView.alpha = 1;

}

-(void)hiddenControlView{
    self.headerView.alpha = 0;
    self.footerView.alpha = 0;
  
}


-(void)playDidEnd{

    self.playBt.selected = NO;
    self.isMaskShowing = YES;
    [self showControlView];
    
}

#pragma mark - geeter

-(UIView *)headerView{
    if (!_headerView) {
        _headerView = [[UIView alloc] init];
        _headerView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.4];
    }
    return _headerView;
}

-(UIButton *)backBt{
    
    if (!_backBt) {
        _backBt = [UIButton buttonWithType:UIButtonTypeCustom];
        [_backBt setImage:[UIImage imageNamed:@"play_back_full"] forState:UIControlStateNormal];
    }
    return _backBt;
}

-(UILabel *)titleLabel{

    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.text = @"这里是标题";
        _titleLabel.textColor = [UIColor whiteColor];
        _titleLabel.font = [UIFont systemFontOfSize:13];
    
    }
    return _titleLabel;
}


-(UIView *)footerView{

    if (!_footerView) {
        _footerView = [[UIView alloc] init];
        _footerView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.4];
    }
    return _footerView;
}

-(UIButton *)playBt{

    if (!_playBt) {
        _playBt = [UIButton buttonWithType:UIButtonTypeCustom];
        [_playBt setImage:[UIImage imageNamed:@"CDPPlay"] forState:UIControlStateNormal];
        [_playBt setImage:[UIImage imageNamed:@"CDPPause"] forState:UIControlStateSelected];
    }
    return _playBt;
}

-(UIButton *)fullScreenSwitchBt{

    if (!_fullScreenSwitchBt) {
        _fullScreenSwitchBt = [UIButton buttonWithType:UIButtonTypeCustom];
        [_fullScreenSwitchBt setImage:[UIImage imageNamed:@"CDPZoomIn"] forState:UIControlStateNormal];
        [_fullScreenSwitchBt setImage:[UIImage imageNamed:@"CDPZoomOut"] forState:UIControlStateSelected];

    }
    return _fullScreenSwitchBt;
    
}

-(UILabel *)timeLabel{


    if (!_timeLabel) {
        _timeLabel = [[UILabel alloc] init];
        _timeLabel.textAlignment = NSTextAlignmentCenter;
        _timeLabel.text = @"00:00/00:00";
        _timeLabel.font = [UIFont systemFontOfSize:10];
        _timeLabel.numberOfLines = 0;
        _timeLabel.textColor = [UIColor whiteColor];

    }
    return _timeLabel;
}

-(UISlider *)progressSlider{

    if (!_progressSlider) {
        _progressSlider = [[UISlider alloc] init];
        _progressSlider.userInteractionEnabled = NO;
        [_progressSlider setThumbImage:[[UIImage alloc]init] forState:UIControlStateNormal];
        _progressSlider.minimumTrackTintColor = [UIColor redColor];
        _progressSlider.maximumTrackTintColor = [UIColor grayColor];
    }
    return _progressSlider;
}

-(UISlider *)playSlider{
    
    if (!_playSlider) {
        _playSlider = [[UISlider alloc] init];
        [_playSlider setThumbImage:[UIImage imageNamed:@"CDPSlider"] forState:UIControlStateNormal];
        _playSlider.minimumTrackTintColor=[UIColor whiteColor];
        _playSlider.maximumTrackTintColor=[UIColor clearColor];
    }
    return _playSlider;
}


-(UIView *)panProgressView{

    if (!_panProgressView) {
        _panProgressView = [[UIView alloc] init];
        _panProgressView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.8];
        _panProgressView.hidden = YES;
    }
    return _panProgressView;
}

-(UIImageView *)panIconImgV{

    if (!_panIconImgV) {
        _panIconImgV = [[UIImageView alloc] init];
        _panIconImgV.image = [UIImage imageNamed:@"fast_back"];
    }
    return _panIconImgV;
}

-(UILabel *)panTimeLabel{

    if (!_panTimeLabel) {
        _panTimeLabel = [[UILabel alloc] init];
        _panTimeLabel.textAlignment = NSTextAlignmentCenter;
        _panTimeLabel.text = @"00:00/00:00";
        _panTimeLabel.font = [UIFont systemFontOfSize:10];
        _panTimeLabel.numberOfLines = 0;
        _panTimeLabel.textColor = [UIColor whiteColor];
        
        
    }
    return _panTimeLabel;
}

-(UISlider *)panProgressSlider{

    if (!_panProgressSlider) {
        _panProgressSlider = [[UISlider alloc] init];
        _panProgressSlider.userInteractionEnabled = NO;
        [_panProgressSlider setThumbImage:[[UIImage alloc]init] forState:UIControlStateNormal];
        _panProgressSlider.minimumTrackTintColor = [UIColor redColor];
        _panProgressSlider.maximumTrackTintColor = [UIColor whiteColor];

    }
    return _panProgressSlider;
}

- (UIActivityIndicatorView *)activity
{
    if (!_activity) {
        _activity = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    }
    return _activity;
}

@end
