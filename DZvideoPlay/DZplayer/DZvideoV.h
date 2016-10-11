//
//  DZvideoV.h
//  DZvideoPlay
//
//  Created by LIU on 16/10/10.
//  Copyright © 2016年 LZD. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import <MediaPlayer/MediaPlayer.h>
@interface DZvideoV : UIView
@property (nonatomic,strong)NSArray *videoUrlArray;
//视频播放器初始化
+ (instancetype)videoWithFrame:(CGRect)frame withUrl:(NSArray *)urlArray;


@end
