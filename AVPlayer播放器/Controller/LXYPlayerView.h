//
//  LXYPlayerView.h
//  视频播放
//
//  Created by lixiya on 16/3/30.
//  Copyright © 2016年 lixiya. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LXYPlayerView : UIView

/** 
 视频URL
 */
@property (nonatomic, strong) NSURL * videoURL;

-(instancetype)initWithFrame:(CGRect)frame videoURL:(NSURL*)url;

@end
