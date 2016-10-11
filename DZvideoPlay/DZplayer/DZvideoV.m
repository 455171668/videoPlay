//
//  DZvideoV.m
//  DZvideoPlay
//
//  Created by LIU on 16/10/10.
//  Copyright © 2016年 LZD. All rights reserved.
//

#import "DZvideoV.h"
@interface DZvideoV()
{

    CGFloat playTotalTime;
    BOOL isChangeSlider;
    CGRect myFrame;
    NSArray *dzUrlArray;
}
//播放器
@property (nonatomic,strong)AVPlayer *dzPlayer;
@property (nonatomic,strong)AVPlayerLayer *dzPlayerLayer;
@property (nonatomic,strong)AVPlayerItem *dzPlayerItem;
//视频控制器相关
@property (nonatomic,strong)UIView *bottomV;
//播放／暂停按钮
@property (nonatomic,strong)UIButton *playBtn;
//播放时间
@property (nonatomic,strong)UILabel *playTime;
//播放总时间
@property (nonatomic,strong)UILabel *playAllTime;
//缓冲进度条
@property (nonatomic,strong)UIProgressView *playPro;
//播放进度条滑块
@property (nonatomic,strong)UISlider *videoSlider;
//播放清晰度
@property (nonatomic,strong)UIButton *playSwitchBtn;
//播放清晰度切换菜单
@property (nonatomic,strong)UIButton *playSwitchMenu;
//播放下载
@property (nonatomic,strong)UIButton *playDownBtn;
//播放全屏
@property (nonatomic,strong)UIButton *playFillDownBtn;
//关闭视频
@property (nonatomic,strong)UIButton *playCloseBtn;

@end

@implementation DZvideoV

+ (instancetype)videoWithFrame:(CGRect)frame withUrl:(NSArray *)urlArray
{
    
    DZvideoV *vedioV = [[DZvideoV alloc]initWithFrame:frame url:urlArray];
    return vedioV;
}
- (instancetype)initWithFrame:(CGRect)frame url:(NSArray *)urlArray
{
    dzUrlArray = urlArray;
    self = [super initWithFrame:frame];
    myFrame = frame;
    if (self) {
        //初始化播放器
        [self setPlayer];
        //初始化控制器
        [self setBottomUI];
        
        //添加通知
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(screenChange:) name:UIApplicationDidChangeStatusBarOrientationNotification object:nil];
        //播放完成
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(moviePlayDidEnd:) name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
        
    }
    return self;
}
#pragma mark - 视频播放器初始化
#pragma mark 初始化播放器
- (void)setPlayer
{
    NSDictionary *dic = dzUrlArray[0];
    _dzPlayerItem = [[AVPlayerItem alloc]initWithURL:[NSURL URLWithString:dic[@"url"]]];
    [_dzPlayerItem addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:nil];
    __weak typeof(self)weakSelf = self;
    _dzPlayer = [[AVPlayer alloc]initWithPlayerItem:_dzPlayerItem];
    [_dzPlayer addPeriodicTimeObserverForInterval:CMTimeMake(1, 1) queue:nil usingBlock:^(CMTime time) {
        long long currentSecond = weakSelf.dzPlayer.currentItem.currentTime.value/weakSelf.dzPlayer.currentItem.currentTime.timescale;
        if (!isChangeSlider) {
            self.videoSlider.value = currentSecond;
        }
        
        NSString * tempTime = [self goToTime:currentSecond];
        if (tempTime.length > 5) {
            weakSelf.playTime.text = [NSString stringWithFormat:@"00:%@", tempTime];
        }else{
            weakSelf.playTime.text = tempTime;
        }
    }];
    _dzPlayerLayer = [AVPlayerLayer playerLayerWithPlayer:_dzPlayer];
    _dzPlayerLayer.frame = self.bounds;
    _dzPlayerLayer.backgroundColor = [[UIColor blueColor]CGColor];
    _dzPlayerLayer.videoGravity = AVLayerVideoGravityResize;
    [self.layer addSublayer:_dzPlayerLayer];
}
#pragma mark 初始化播放控制器
- (void)setBottomUI
{
    NSDictionary *dic = dzUrlArray[0];
    _bottomV = [[UIView alloc]initWithFrame:CGRectMake(0, self.frame.size.height-64, self.frame.size.width, 64)];
    _bottomV.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.4];
    [self addSubview:_bottomV];
    
    //播放 暂停
    _playBtn = [[UIButton alloc]initWithFrame:CGRectMake(10, 10, 44, 44)];
    [_playBtn setImage:[UIImage imageNamed:@"ad_play_f_p"] forState:UIControlStateNormal];
    [_playBtn setImage:[UIImage imageNamed:@"ad_pause_f_p"] forState:UIControlStateSelected];
    _playBtn.backgroundColor = [UIColor redColor];
    [_playBtn addTarget:self action:@selector(playBtnClike:) forControlEvents:UIControlEventTouchUpInside];
    [self.bottomV addSubview:_playBtn];
    
    //已播放时间
    _playTime = [[UILabel alloc]init];
    _playTime.textColor = [UIColor whiteColor];
    _playTime.text = @"00:00:00";
    [_playTime sizeToFit];
    _playTime.frame = CGRectMake(CGRectGetMaxX(_playBtn.frame)+5, 60-_playTime.frame.size.height, _playTime.frame.size.width, _playTime.frame.size.height);
    [self.bottomV addSubview:_playTime];
    
    //播放进度
    _videoSlider = [[UISlider alloc]initWithFrame:CGRectMake(CGRectGetMaxX(_playBtn.frame)+5, 20, self.frame.size.width*0.6, 5)];
    [_videoSlider setThumbImage:[UIImage imageNamed:@"movieTicketsPayType_select"] forState:UIControlStateNormal];
    [_videoSlider setThumbImage:[UIImage imageNamed:@"movieTicketsPayType_select"] forState:UIControlStateHighlighted];
//    _videoSlider.maximumTrackTintColor = [UIColor clearColor];
    [_videoSlider addTarget:self action:@selector(videoSlidertouch:) forControlEvents:UIControlEventValueChanged];
    [_videoSlider addTarget:self action:@selector(videoSliderChange:) forControlEvents:UIControlEventTouchUpInside];
    _videoSlider.userInteractionEnabled = YES;
    [self.bottomV addSubview:_videoSlider];
    
    //播放总时间
    _playAllTime = [[UILabel alloc]init];
    _playAllTime.textColor = [UIColor whiteColor];
    _playAllTime.text = @"00:00:00";
    [_playAllTime sizeToFit];
    _playAllTime.frame = CGRectMake(CGRectGetMaxX(_videoSlider.frame)-_playAllTime.frame.size.width, 60-_playAllTime.frame.size.height, _playAllTime.frame.size.width, _playAllTime.frame.size.height);
    [self.bottomV addSubview:_playAllTime];
    
    //播放清晰度
    _playSwitchBtn = [[UIButton alloc]initWithFrame:CGRectMake(CGRectGetMaxX(_videoSlider.frame)+5, 10, 44, 44)];
    [_playSwitchBtn setTitle:dic[@"title"] forState:UIControlStateNormal];
    [_playSwitchBtn addTarget:self action:@selector(playSwitchBtnClike) forControlEvents:UIControlEventTouchUpInside];
    [self.bottomV addSubview:_playSwitchBtn];
    //播放下载
    _playDownBtn = [[UIButton alloc]initWithFrame:CGRectMake(CGRectGetMaxX(_videoSlider.frame)+5, 10, 44, 44)];
    [_playDownBtn setImage:[UIImage imageNamed:@"icon_caidan_download_normal"] forState:UIControlStateNormal];
    [_playDownBtn addTarget:self action:@selector(playDownbtnClike) forControlEvents:UIControlEventTouchUpInside];
//    [self.bottomV addSubview:_playDownBtn];
    
    //播放全屏
     _playFillDownBtn= [[UIButton alloc]initWithFrame:CGRectMake(CGRectGetMaxX(_playDownBtn.frame)+5, 10, 44, 44)];
    [_playFillDownBtn setImage:[UIImage imageNamed:@"play_mini_f_p"] forState:UIControlStateNormal];
    [_playFillDownBtn setImage:[UIImage imageNamed:@"play_full_f_p"] forState:UIControlStateSelected];
    [_playFillDownBtn addTarget:self action:@selector(playFillDownBtnClike) forControlEvents:UIControlEventTouchUpInside];
    [self.bottomV addSubview:_playFillDownBtn];
    
    //关闭按钮
    _playCloseBtn = [[UIButton alloc]initWithFrame:CGRectMake(self.frame.size.width-40, 10, 40, 40)];
    _playCloseBtn.backgroundColor = [UIColor redColor];
    [_playCloseBtn addTarget:self action:@selector(playCloseBtnClike) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_playCloseBtn];
}
#pragma mark - 视频播放器控制相关
#pragma mark 播放 暂停视频
- (void)playBtnClike:(UIButton *)sender
{
    if (sender.selected) {
        [self.dzPlayer pause];
        sender.selected = NO;
    }else{
        
        [self.dzPlayer play];
        sender.selected = YES;
    }
}
#pragma mark 滑块滑动
- (void)videoSlidertouch:(id) sender
{
    isChangeSlider = YES;
}
#pragma mark 滑块滑动结束
- (void)videoSliderChange:(id) sender
{
    [self.dzPlayer pause];
    __weak typeof(self)weakSelf = self;
    [self.dzPlayer seekToTime:CMTimeMake(self.videoSlider.value, 1) completionHandler:^(BOOL finished) {
        if (weakSelf.dzPlayer) {
            if (self.playBtn.selected) {
                [weakSelf.dzPlayer play];
            }
        }
        isChangeSlider = NO;
    }];
}
#pragma mark 全屏切换
- (void)playFillDownBtnClike
{
    if (self.playFillDownBtn.selected) {
        [self screenChangeToOrientation:UIInterfaceOrientationPortrait];
        self.playFillDownBtn.selected= NO;
    }else{
        [self screenChangeToOrientation:UIInterfaceOrientationLandscapeRight];
        self.playFillDownBtn.selected= YES;
    }
//    self.playFillDownBtn.selected = !self.playFillDownBtn.selected;
}
#pragma mark 屏幕旋转相关
- (void)screenChangeToOrientation:(UIInterfaceOrientation )orientation
{

    if ([[UIDevice currentDevice] respondsToSelector:@selector(setOrientation:)])
    {
        if (self.playFillDownBtn.selected) {
            SEL selector = NSSelectorFromString(@"setOrientation:");
            NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:[UIDevice instanceMethodSignatureForSelector:selector]];
            [invocation setSelector:selector];
            [invocation setTarget:[UIDevice currentDevice]];
            int val = orientation;
            [invocation setArgument:&val atIndex:2];
            [invocation invoke];
            self.playFillDownBtn.selected = NO;
        }else{
            SEL selector = NSSelectorFromString(@"setOrientation:");
            NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:[UIDevice instanceMethodSignatureForSelector:selector]];
            [invocation setSelector:selector];
            [invocation setTarget:[UIDevice currentDevice]];
            int val = orientation;
            [invocation setArgument:&val atIndex:2];
            [invocation invoke];
            self.playFillDownBtn.selected = YES;
        }
        
    }
//    [[UIApplication sharedApplication] setStatusBarOrientation:UIInterfaceOrientationLandscapeRight animated:YES];
}
#pragma mark 屏幕旋转监听
- (void)screenChange:(NSNotification *)not
{
    UIDeviceOrientation orientation = [[UIDevice currentDevice] orientation];
    switch (orientation) {
        case UIDeviceOrientationPortrait:
            self.frame = myFrame;
            _dzPlayerLayer.frame = self.bounds;
            _bottomV.frame = CGRectMake(0, self.frame.size.height-64, self.frame.size.width, 64);
            _playCloseBtn.frame = CGRectMake(self.frame.size.width-40, 10, 40, 40);
            break;
        case UIDeviceOrientationLandscapeRight:
            self.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height);
            break;
        case UIDeviceOrientationLandscapeLeft:
            self.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height);
            _dzPlayerLayer.frame = self.bounds;
            _bottomV.frame = CGRectMake(0, self.frame.size.height-64, self.frame.size.width, 64);
            _playCloseBtn.frame = CGRectMake(self.frame.size.width-40, 10, 40, 40);
            break;
        default:
            break;
    }
}
#pragma mark 关闭视频
- (void)playCloseBtnClike
{
    [self removeFromSuperview];
}
#pragma mark 视频清晰度切换
- (void)playSwitchBtnClike
{
    CGFloat menuHeight = 33*2;
    _playSwitchMenu = [[UIView alloc]initWithFrame:CGRectMake(CGRectGetMaxX(_videoSlider.frame)+5, self.frame.size.height-64-menuHeight, 44, menuHeight)];
    _playSwitchMenu.backgroundColor = [UIColor blackColor];
    for (int a = 0; a<dzUrlArray.count; a++) {
        NSDictionary *dic = dzUrlArray[a];
        UIButton *btn = [[UIButton alloc]initWithFrame:CGRectMake(0, a*33, 44, 33)];
        [btn setTitle:dic[@"title"] forState:UIControlStateNormal];
        [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        btn.tag = a;
        [btn addTarget:self action:@selector(menuBtnClike:) forControlEvents:UIControlEventTouchUpInside];
        [_playSwitchMenu addSubview:btn];
    }
    [self addSubview:_playSwitchMenu];
}
#pragma mark 视频清晰度切换
- (void)menuBtnClike:(UIButton *)sender
{
    [self.playSwitchMenu removeFromSuperview];
    if ([sender.titleLabel.text isEqualToString:_playSwitchBtn.titleLabel.text]) {
        return ;
    }
    [_playSwitchBtn setTitle:sender.titleLabel.text forState:UIControlStateNormal];
    [_dzPlayer pause];
    NSDictionary *dic = dzUrlArray[sender.tag];
    [self.dzPlayer.currentItem removeObserver:self forKeyPath:@"status"];
       _dzPlayerItem = [[AVPlayerItem alloc]initWithURL:[NSURL URLWithString:dic[@"url"]]];
        [_dzPlayerItem addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:nil];
        [_dzPlayer replaceCurrentItemWithPlayerItem:_dzPlayerItem];
        __weak typeof(self)weakSelf = self;
        [self.dzPlayer seekToTime:CMTimeMake(self.videoSlider.value, 1) completionHandler:^(BOOL finished) {
            if (weakSelf.dzPlayer) {
                if (self.playBtn.selected) {
                    [weakSelf.dzPlayer play];
                }
                
            }
            isChangeSlider = NO;
        }];

}
#pragma mark 视频播放完成
- (void)moviePlayDidEnd:(NSNotification *)not
{
    self.playBtn.selected = NO;
    self.videoSlider.value = 0;
    [self.dzPlayer seekToTime:CMTimeMake(0, 1)];
}
#pragma mark 视频播放监听
-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context{
    if ([keyPath isEqualToString:@"status"]) {
        //获取总的播放时长
       playTotalTime = self.dzPlayer.currentItem.duration.value/self.dzPlayer.currentItem.duration.timescale;
        self.videoSlider.maximumValue = playTotalTime;
        NSString * tempTime = [self goToTime:playTotalTime];
        if (tempTime.length > 5) {
            self.playAllTime.text = [NSString stringWithFormat:@"00:%@", tempTime];
        }else{
            self.playAllTime.text = tempTime;
        }
        [self.playAllTime sizeToFit];
    }else{
        
    }
}
#pragma mark - 公共方法
#pragma mark 秒转时间
- (NSString *)goToTime :(long long )timeSecond{
        NSString * theLastTime = nil;
        if (timeSecond < 60) {
            theLastTime = [NSString stringWithFormat:@"00:%.2lld", timeSecond];
        }else if(timeSecond >= 60 && timeSecond < 3600){
            theLastTime = [NSString stringWithFormat:@"%.2lld:%.2lld", timeSecond/60, timeSecond%60];
        }else if(timeSecond >= 3600){
            theLastTime = [NSString stringWithFormat:@"%.2lld:%.2lld:%.2lld", timeSecond/3600, timeSecond%3600/60, timeSecond%60];
        }
        return theLastTime;
}

@end
