//
//  FeaturedViewController.m
//  VideoShow
//
//  Created by Jerry Chen  on 14-7-15.
//  Copyright (c) 2014年 energy. All rights reserved.
//

#import "FeaturedViewController.h"
#import "VideoPlayerViewController.h"
#import "UMSocial.h"
#import "MobClick.h"
#import "Prefs.h"
#import "InstagramAuthController.h"
#import "NSString+Util.h"

#import "NetService.h"

@interface FeaturedViewController()<SharedListViewControllerDataSource,SharedListViewControllerDelegate>


@end

@implementation FeaturedViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.datasource = self;
    self.delegate = self;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [MobClick beginLogPageView:@"FeaturedViewController"];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [MobClick endLogPageView:@"FeaturedViewController"];
}

- (BOOL)shouldAutorotate
{
    return NO;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
    return UIInterfaceOrientationPortrait;
}

#pragma mark - SharedListViewControllerDataSource
- (NSString *)requestUrl
{
    return @"http://api.videoshowapp.com:8087/api/v2/medium/featured.json";
}

- (BOOL)orderResult
{
    return NO;
}

#pragma mark - SharedListViewControllerDelegate
-(void)playUrl:(NSURL *)url
{
    VideoPlayerViewController *videoPlayerViewController = [[VideoPlayerViewController alloc] initWithContentURL:url];
    videoPlayerViewController.moviePlayer.shouldAutoplay = YES;
    videoPlayerViewController.moviePlayer.controlStyle = MPMovieControlStyleFullscreen;
    [videoPlayerViewController.moviePlayer prepareToPlay];
    [self.pageControler presentViewController:videoPlayerViewController animated:YES completion:nil];
}

- (void)shareItem:(NSString *)url
{
    [[UMSocialData defaultData].urlResource setResourceType:UMSocialUrlResourceTypeVideo url:url];
    [UMSocialSnsService presentSnsIconSheetView:self.pageControler
                            appKey:@"53cf1d2856240bfc7e0936d8"
                            shareText:[NSString stringWithFormat:@"%@ %@",@"分享测试",url]
                            shareImage:[UIImage imageNamed:@"Icon.png"]
                            shareToSnsNames:[NSArray arrayWithObjects:UMShareToFacebook,UMShareToTwitter,UMShareToSina,UMShareToWechatTimeline,nil]
                            delegate:nil];
}

//请求令牌
- (void)requestInstagramAccessToken
{
    InstagramAuthController * act=[[InstagramAuthController alloc] init];
    act.authDelegate=self;
    [self.pageControler presentViewController:act animated:YES completion:nil];
}


@end
