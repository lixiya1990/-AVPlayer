//
//  PVMyVideoViewController.m
//  视频播放
//
//  Created by lixiya on 16/3/23.
//  Copyright © 2016年 lixiya. All rights reserved.
//
#define IphoneHeight  [[UIScreen mainScreen] bounds].size.height
#define IphoneWidth  [[UIScreen mainScreen] bounds].size.width

#import "PVMyVideoViewController.h"
#import "LXYPlayerView.h"

@interface PVMyVideoViewController ()
@property(nonatomic ,strong) LXYPlayerView * playerView;

@end

@implementation PVMyVideoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"视频播放器";
    
    [self.view addSubview:self.playerView];
    
    
}

-(LXYPlayerView *)playerView{

    if (!_playerView) {
       // _playerView = [[LXYPlayerView alloc] initWithFrame:CGRectMake(0, 100, IphoneWidth, 240) videoURL:[[NSBundle mainBundle] URLForResource:@"150511_JiveBike" withExtension:@"mov"]];
        _playerView = [[LXYPlayerView alloc] initWithFrame:CGRectMake(0, 100, IphoneWidth, 240) videoURL:[NSURL URLWithString:@"http://v.jxvdy.com/sendfile/w5bgP3A8JgiQQo5l0hvoNGE2H16WbN09X-ONHPq3P3C1BISgf7C-qVs6_c8oaw3zKScO78I--b0BGFBRxlpw13sf2e54QA"]];
       
//http://v.jxvdy.com/sendfile/w5bgP3A8JgiQQo5l0hvoNGE2H16WbN09X-ONHPq3P3C1BISgf7C-qVs6_c8oaw3zKScO78I--b0BGFBRxlpw13sf2e54QA
        
    }
    return _playerView;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
