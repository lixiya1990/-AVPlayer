//
//  LXYPlayerControlView.h
//  视频播放
//
//  Created by lixiya on 16/4/6.
//  Copyright © 2016年 lixiya. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LXYPlayerControlView : UIView

/**********  底部工具条View  *********/
@property (nonatomic ,strong) UIView * footerView;

/**
 * 开始、暂停
 */
@property(nonatomic ,strong) UIButton * playBt;


/**
 * 全屏切换按钮
 */
@property(nonatomic ,strong) UIButton * fullScreenSwitchBt;


/**
 *  播放进度条
 */
@property(nonatomic ,strong) UISlider * playSlider;


/**
 * 缓冲进度条
 */
@property (nonatomic, strong) UISlider *progressSlider;


/**
 * 时间label
 */
@property(nonatomic ,strong) UILabel  * timeLabel;



/**********  顶部View  *********/
@property(nonatomic ,strong)  UIView * headerView;
/**
 *  返回按钮
 */
@property(nonatomic ,strong) UIButton * backBt;

/**
 *  标题
 */
@property(nonatomic ,strong) UILabel * titleLabel;


/**********  pan手势快进后退时显示进度View   *********/
@property(nonatomic ,strong) UIView * panProgressView;

/**
 *  快进后退图标
 */
@property(nonatomic ,strong) UIImageView * panIconImgV;

/**
 *  时间进度
 */
@property(nonatomic ,strong) UILabel * panTimeLabel;

/**
 *  平移进度
 */
@property(nonatomic ,strong) UISlider * panProgressSlider;

/**
 *  是否显示
 */
@property(nonatomic ,assign) BOOL isMaskShowing;

/*
 * 系统菊花
 */
@property (nonatomic, strong) UIActivityIndicatorView *activity;

-(void)showControlView;

-(void)hiddenControlView;

-(void)playDidEnd;

@end
