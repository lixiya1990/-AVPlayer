//
//  LXYPlayerFootView.h
//  视频播放
//
//  Created by lixiya on 16/3/30.
//  Copyright © 2016年 lixiya. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LXYPlayerFootView : UIView

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
 缓冲进度条
 */
@property (nonatomic, strong) UISlider *progressSlider;


/**
 * 时间label
 */
@property(nonatomic ,strong) UILabel  * timeLabel;

/**
 *  是否显示LXYPlayerFootView
 */
@property(nonatomic ,assign) BOOL isMaskShowing;

@end
