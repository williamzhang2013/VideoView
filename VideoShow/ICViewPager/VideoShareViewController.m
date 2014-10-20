//
//  VideoShareViewController.m
//  VideoShow
//
//  Created by Jerry Chen  on 14-8-21.
//  Copyright (c) 2014年 energy. All rights reserved.
//

#import "VideoShareViewController.h"
#import "qxTimeline.h"
#import "AppMacros.h"
#import "MobClick.h"
#import "qxTrack.h"
#import "UMSocial.h"
#import "AppEvent.h"
#import "Util.h"
#import "SVProgressHUD.h"
#import "VideoPlayerViewController.h"

@implementation VideoShareViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.navigationController.navigationBar setBackgroundImage:nil forBarMetrics:UIBarMetricsDefault];
    if([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0){
        self.edgesForExtendedLayout = UIRectEdgeNone;
        self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:40/255.0 green:35/255.0 blue:35/255.0 alpha:1.0];
    }else{
        self.navigationController.navigationBar.tintColor = [UIColor colorWithRed:40/255.0 green:35/255.0 blue:35/255.0 alpha:1.0];
    }
    self.navigationController.navigationBar.barStyle = UIBarStyleDefault;
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"black_bg.png"]];
    [self initView];
}

- (void)initView
{
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    float availabelHeight = screenRect.size.height - 64;
    float delta = 0;
    if([UIDevice currentDevice].systemVersion.floatValue < 7.0){
        delta = 44;
    }
    
    //title
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 80, 30)];
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.text = NSLocalizedString(@"Share", nil);
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.textColor = [UIColor whiteColor];
    titleLabel.font=[UIFont boldSystemFontOfSize:17];
    [titleLabel sizeToFit];
    self.navigationItem.titleView = titleLabel;
    
    //left bar button
    UIButton *leftBtnView = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 39, 39)];
    [leftBtnView setImage:[UIImage imageNamed:@"home.png"] forState:UIControlStateNormal];
    [leftBtnView setImageEdgeInsets:UIEdgeInsetsMake(8, 0, 8, 16)];
    [leftBtnView addTarget:self action:@selector(homeAction:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *leftBarButton = [[UIBarButtonItem alloc] initWithCustomView:leftBtnView];
    leftBarButton.style = UIBarButtonItemStylePlain;
    self.navigationItem.leftBarButtonItem = leftBarButton;
    
    //share modal
    float y = availabelHeight + 44 - 130;
    if([UIDevice currentDevice].systemVersion.floatValue >= 7.0){
        y = availabelHeight - 130;
    }
    UIView *shareView = [[UIView alloc] initWithFrame:CGRectMake(0, y, self.view.frame.size.width, 130)];
    shareView.backgroundColor = [UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:0.8];
    [self.view addSubview:shareView];
    
    //
    UILabel *shareTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, 80, 30)];
    shareTitleLabel.backgroundColor = [UIColor clearColor];
    shareTitleLabel.text = NSLocalizedString(@"Share To", nil);
    shareTitleLabel.textColor = [UIColor blackColor];
    [shareTitleLabel sizeToFit];
    [shareView addSubview:shareTitleLabel];
    
    //
    UIView *divider = [[UIView alloc] initWithFrame:CGRectMake(10, shareTitleLabel.frame.origin.y + shareTitleLabel.frame.size.height + 10, self.view.frame.size.width - 20, 0.5)];
    divider.backgroundColor = [UIColor colorWithRed:51.0/255.0 green:7.0/255.0 blue:7.0/255.0 alpha:1.0];
    [shareView addSubview:divider];
    
    //-----------------------social button -------------
    int shareBtnCount=2;
    int btnSize=50;
    CGFloat vDividerWidth = (shareView.frame.size.width - btnSize*shareBtnCount)/(shareBtnCount+1);
    //
    UIButton *facebookShare = [[UIButton alloc] initWithFrame:CGRectMake(vDividerWidth, divider.frame.origin.y + 0.5 + 20, btnSize,btnSize)];
    [facebookShare setImage:[UIImage imageNamed:@"facebook.png"] forState:UIControlStateNormal];
    [facebookShare addTarget:self action:@selector(facebookShareAction:) forControlEvents:UIControlEventTouchUpInside];
    [shareView addSubview:facebookShare];
    
    //
    UIButton *youtubeShare = [[UIButton alloc] initWithFrame:CGRectMake(facebookShare.frame.origin.x + facebookShare.frame.size.width + vDividerWidth, facebookShare.frame.origin.y, btnSize,btnSize)];
    youtubeShare.layer.cornerRadius = 25;
    [youtubeShare setImage:[UIImage imageNamed:@"youtube.png"] forState:UIControlStateNormal];
    [youtubeShare addTarget:self action:@selector(youtubeShareAction:) forControlEvents:UIControlEventTouchUpInside];
    [shareView addSubview:youtubeShare];
    //
//    UIButton *instagramShare = [[UIButton alloc] initWithFrame:CGRectMake(youtubeShare.frame.origin.x + youtubeShare.frame.size.width + vDividerWidth, youtubeShare.frame.origin.y, 50, 50)];
//    instagramShare.layer.cornerRadius = 25;
//    [instagramShare setImage:[UIImage imageNamed:@"instagram.png"] forState:UIControlStateNormal];
//    [instagramShare addTarget:self action:@selector(instagramShareAction:) forControlEvents:UIControlEventTouchUpInside];
//    [shareView addSubview:instagramShare];
    //--------------------------------------------------
    
    //
    UIImageView *exportSuccessImage = [[UIImageView alloc] initWithFrame:CGRectMake(20, 10 + delta, 24, 24)];
    exportSuccessImage.image = [UIImage imageNamed:@"export_success.png"];
    [self.view addSubview:exportSuccessImage];
    //
    UILabel *exportSuccessLabel = [[UILabel alloc] initWithFrame:CGRectMake(exportSuccessImage.frame.origin.x + exportSuccessImage.frame.size.width + 5, exportSuccessImage.frame.origin.y, 80, 24)];
    exportSuccessLabel.backgroundColor = [UIColor clearColor];
    exportSuccessLabel.textColor = [UIColor whiteColor];
    exportSuccessLabel.font = [UIFont systemFontOfSize:17];
    exportSuccessLabel.text = NSLocalizedString(@"Saved to My Studio", nil);
    [exportSuccessLabel sizeToFit];
    [self.view addSubview:exportSuccessLabel];

    //preview
    CGFloat height = availabelHeight - 20 - 130 - 10 - 24;
    CGRect previewRect = CGRectMake(20, exportSuccessImage.frame.origin.y + exportSuccessImage.frame.size.height + 10, self.view.frame.size.width - 40, height);
    ALAssetRepresentation *representation = [self.asset defaultRepresentation];
    CGSize dimen = [representation dimensions];
    CGFloat width = dimen.width * height / dimen.height;
    if(width > screenRect.size.width - 40){
        width = screenRect.size.width - 40;
        height = width * dimen.height / dimen.width;
    }
    previewRect.size.height = height;
    previewRect.size.width = width;
    previewRect.origin.y = (exportSuccessImage.frame.origin.y + exportSuccessImage.frame.size.height) + ((shareView.frame.origin.y - (exportSuccessImage.frame.origin.y + exportSuccessImage.frame.size.height) - previewRect.size.height)/2);
    previewRect.origin.x = (screenRect.size.width - width)/2;
    //video image
    UIImageView *videoImageView = [[UIImageView alloc] initWithFrame:previewRect];
    videoImageView.image = [UIImage imageWithCGImage:representation.fullResolutionImage];
    [self.view addSubview:videoImageView];
    
    //
    UIButton *playBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 55, 55)];
    playBtn.center = CGPointMake(self.view.frame.size.width/2.0, videoImageView.frame.size.height/2.0 + videoImageView.frame.origin.y);
    [playBtn setBackgroundImage:[UIImage imageNamed:@"play_transparent.png"] forState:UIControlStateNormal];
    [playBtn addTarget:self action:@selector(playAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:playBtn];
}

- (void)homeAction:(id)sender
{
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

- (void)playAction:(id)sender
{
    NSURL *url = [self.asset valueForProperty:ALAssetPropertyAssetURL];
    VideoPlayerViewController *videoPlayerViewController = [[VideoPlayerViewController alloc] initWithContentURL:url];
    videoPlayerViewController.moviePlayer.shouldAutoplay = YES;
    videoPlayerViewController.moviePlayer.controlStyle = MPMovieControlStyleFullscreen;
    [videoPlayerViewController.moviePlayer prepareToPlay];
    [self presentViewController:videoPlayerViewController animated:YES completion:nil];
}

#pragma mark - Instagram share
//分享到instagram
- (void)instagramShareAction:(id)sender
{
    
    
}

//分享到facebook
- (void)facebookShareAction:(id)sender
{
    [MobClick event: SHARE_VIA_FB];
    [Util uploadVideoALAssetToFacebook:self.asset];
}

//分享视频到YouTube
- (void)youtubeShareAction:(id)sender
{
    [MobClick event: SHARE_VIA_YOUTUBE];
    if(!ytbHelper){
        ytbHelper = [[YouTubeHelper alloc] initWithDelegate:self];
    }
    [ytbHelper storedAuth];
    if([ytbHelper isAuthValid]){
        NSURL *url = [self.asset valueForProperty:ALAssetPropertyAssetURL];
        [self uploadVideoToYTB:url.absoluteString];
    }else{
        [ytbHelper authenticate];
    }
}

#pragma mark - YouTubeHelperDelegate
- (NSString *)youtubeAPIClientID
{
    return youtube_key;
}

- (NSString *)youtubeAPIClientSecret
{
    return youtube_secret;
}

- (void)showAuthenticationViewController:(UIViewController *)authView
{
    [self presentViewController:authView animated:YES completion:nil];
}

- (void)authenticationEndedWithError:(NSError *)error
{
    [self dismissViewControllerAnimated:YES completion:nil];
    if(error){
        [Util showErrorAlertWithMessage:NSLocalizedString(@"Authorization Failure", nil)];
    }else{
        NSURL *url = [self.asset valueForProperty:ALAssetPropertyAssetURL];
        [self uploadVideoToYTB:url.absoluteString];
    }
}

- (void)uploadProgressPercentage:(int)percentage
{
    if(percentage >= 100){
        [SVProgressHUD dismiss];
        [SVProgressHUD showSuccessWithStatus:NSLocalizedString(@"Upload Success", nil) duration:2.0];
    }
}

- (void)uploadVideoDoneWithError:(NSError *)error
{   
    [SVProgressHUD dismiss];
    if(error){
        [SVProgressHUD showSuccessWithStatus:NSLocalizedString(@"Upload Failed", nil) duration:2.0];
    }
}

//上传到YouTube
- (void)uploadVideoToYTB:(NSString*)videoPath
{
    if(!ytbHelper){
        ytbHelper = [[YouTubeHelper alloc] initWithDelegate:self];
    }
    [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeClear];
    NSString *file = [Util generateTempFileFromALAsset:self.asset];
    if(file){
        [ytbHelper uploadPrivateVideoWithTitle:@"VideoShow" description:nil commaSeperatedTags:@"VideoShow" andPath:file];
    }else{
        [SVProgressHUD dismiss];
        [SVProgressHUD showSuccessWithStatus:NSLocalizedString(@"Upload Failed", nil) duration:2.0];
    }
}

@end
