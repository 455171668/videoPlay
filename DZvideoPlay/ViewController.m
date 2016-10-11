//
//  ViewController.m
//  DZvideoPlay
//
//  Created by LIU on 16/10/10.
//  Copyright © 2016年 LZD. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()
{
    DZvideoV *video;
}
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    NSArray *array = @[@{@"title":@"标清",@"url":@"http://200036408.vod.myqcloud.com/200036408_d4615a088eaf11e6b735d7922caca09c.f20.mp4"},@{@"title":@"高清",@"url":@"http://200036408.vod.myqcloud.com/200036408_7d10ce3a8d3a11e6b38f27eb658ee9e8.f20.mp4"}];

    video = [DZvideoV videoWithFrame:CGRectMake(0, 64, self.view.frame.size.width, 200) withUrl:array];
    video.backgroundColor = [UIColor redColor];
    [self.view addSubview:video];
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
