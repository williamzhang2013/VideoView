//
//  PlayerViewController.m
//  VideoShow
//
//  Created by Jerry Chen  on 14-7-24.
//  Copyright (c) 2014年 energy. All rights reserved.
//

#import "PlayerViewController.h"
#import "NMRangeSlider.h"
#import "SVProgressHUD.h"
#import "Util.h"
#import "MyLabel.h"
#import "VideoShareViewController.h"
#import "PortraitNavigationController.h"
#import "VideoDraft.h"
#import "AGIPCAlbumsController.h"
#import "Toast+UIView.h"
#import "MobClick.h"
#import "AppEvent.h"
#import <sys/param.h>
#import <sys/mount.h>

//连按2秒停止导出
#define STOP_INTERVAL 2

@interface PlayerViewController()

@property (nonatomic,assign) BOOL isStopExport;//是否点击了停止按钮
@property (nonatomic,retain) NSTimer * stopExportTimer;//停止导出计时器

@property (nonatomic,retain) UILabel * videoPrecent;
@property (nonatomic,retain) UILabel * musicPrecent;

@end

@implementation PlayerViewController

@synthesize isStopExport;
@synthesize stopExportTimer;
@synthesize videoPrecent;
@synthesize musicPrecent;

- (void)viewDidLoad
{
    [super viewDidLoad];
    screenRect = [UIScreen mainScreen].bounds;
    
    //navigation bar
    UIImage *previewNavBgImage = [UIImage imageNamed:@"preview_nav_bg.png"];
    if([[[UIDevice currentDevice] systemVersion] floatValue] < 7.0){
        previewNavBgImage = [UIImage imageNamed:@"preview_nav_bg_h44.png"];
    }

    [self.navigationController.navigationBar setBackgroundImage:previewNavBgImage forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.barStyle = UIBarStyleBlackTranslucent;
    
    //title
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 80, 30)];
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.font=[UIFont boldSystemFontOfSize:18];
    titleLabel.text = NSLocalizedString(@"Video Edit", nil);
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.textColor = [UIColor whiteColor];
    [titleLabel sizeToFit];
    self.navigationItem.titleView = titleLabel;
    
    //left bar button
    leftBtnView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 50, 44)];
    leftBtnView.userInteractionEnabled = YES;
    UITapGestureRecognizer *backBtnTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(backViewTap:)];
    [leftBtnView addGestureRecognizer:backBtnTapGesture];
    UIImageView *leftArrow = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"back.png"]];
    leftArrow.frame = CGRectMake(0, 0, 11, 19);
    [leftBtnView addSubview:leftArrow];
    UILabel *leftLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 0, 45, 44)];
    leftLabel.backgroundColor = [UIColor clearColor];
    leftLabel.text = NSLocalizedString(@"Back", nil);
    leftLabel.font = [UIFont boldSystemFontOfSize:17];
    leftLabel.textColor = [UIColor colorWithRed:221/255.0 green:107/255.0 blue:111/255.0 alpha:1.0];
    [leftBtnView addSubview:leftLabel];
    UIBarButtonItem *leftBarButton = [[UIBarButtonItem alloc] initWithCustomView:leftBtnView];
    leftBarButton.style = UIBarButtonItemStylePlain;
    leftArrow.center = CGPointMake(5.5, leftLabel.center.y);
    self.navigationItem.leftBarButtonItem = leftBarButton;
    
    //right bar button
    UIImage * rightImage=[UIImage imageNamed:@"export.png"];
    exportBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 28,28)];
    [exportBtn setImage:rightImage forState:UIControlStateNormal];
    //[exportBtn setImageEdgeInsets:UIEdgeInsetsMake(0, 28, 0, 0)];
    exportBtn.imageView.contentMode=UIViewContentModeScaleAspectFit;
    [exportBtn addTarget:self action:@selector(exportAction:) forControlEvents:UIControlEventTouchUpInside];
    //
    UIBarButtonItem *rightBarButton = [[UIBarButtonItem alloc] initWithCustomView:exportBtn];
    rightBarButton.tintColor = [UIColor blueColor];
    self.navigationItem.rightBarButtonItem = rightBarButton;
    
    //----------------------------------------------
    
    //playback view
    videoView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    videoView.backgroundColor = [UIColor blackColor];
    videoView.userInteractionEnabled = YES;
    UITapGestureRecognizer *playbackViewTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(playbackViewTap:)];
    [videoView addGestureRecognizer:playbackViewTapGesture];
    
    //bg
    UIView *bgView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    UIImage *bgImg = [UIImage imageNamed:@"bg_video_view.png"];
    bgView.backgroundColor = [UIColor colorWithPatternImage:bgImg];
    [bgView addSubview:videoView];
    [self.view addSubview:bgView];
    
    //bottom toolbar
    bottomToolBar = [[UIView alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height - 95, self.view.frame.size.width, 95)];
    bottomToolBar.backgroundColor = [UIColor clearColor];
    
    int timeSize=13;
    //current time label
    currentProgressLabel = [[MyLabel alloc] initWithFrame:CGRectMake(3, 0, 90, timeSize)];
    currentProgressLabel.font = [UIFont systemFontOfSize:timeSize];
    currentProgressLabel.textAlignment = NSTextAlignmentLeft;
    currentProgressLabel.drawOutline = YES;
    currentProgressLabel.outlineColor = [UIColor blackColor];
    currentProgressLabel.textColor = [UIColor whiteColor];
    [bottomToolBar addSubview:currentProgressLabel];
    
    //total time label
    totalProgressLabel = [[MyLabel alloc] initWithFrame:CGRectMake(bottomToolBar.frame.size.width - 93, 0, 90, timeSize)];
    totalProgressLabel.font = [UIFont systemFontOfSize:timeSize];
    totalProgressLabel.textAlignment = NSTextAlignmentRight;
    totalProgressLabel.drawOutline = YES;
    totalProgressLabel.outlineColor = [UIColor blackColor];
    totalProgressLabel.textColor = [UIColor whiteColor];
    [bottomToolBar addSubview:totalProgressLabel];
    
    UIView *bottomToolBarControlView = [[UIView alloc] initWithFrame:CGRectMake(0, bottomToolBar.frame.size.height - 75, bottomToolBar.frame.size.width, 75)];
    bottomToolBarControlView.backgroundColor = [UIColor colorWithRed:40/255.0 green:35/255.0 blue:35/255.0 alpha:1.0];
    
    //add media btn
    addMediaBtn = [[UIButton alloc] initWithFrame:CGRectMake(20, 30, 35, 35)];
    [addMediaBtn setImage:[UIImage imageNamed:@"add_media_btn.png"] forState:UIControlStateNormal];
    [addMediaBtn addTarget:self action:@selector(addMediaAction:) forControlEvents:UIControlEventTouchUpInside];
    [bottomToolBarControlView addSubview:addMediaBtn];
    //horizontal margin
    CGFloat margin = (screenRect.size.width - 40 - 35 * 5)/4.0;
    //set media duration btn
    setMediaDurationBtn = [[UIButton alloc] initWithFrame:CGRectMake(addMediaBtn.frame.origin.x + 35 + margin, 30, 35, 35)];
    [setMediaDurationBtn setImage:[UIImage imageNamed:@"set_media_duration_btn.png"] forState:UIControlStateNormal];
    [setMediaDurationBtn addTarget:self action:@selector(setMediaDurationAction:) forControlEvents:UIControlEventTouchUpInside];
    [bottomToolBarControlView addSubview:setMediaDurationBtn];
    //add subtitle btn
    addSubtitleBtn = [[UIButton alloc] initWithFrame:CGRectMake(setMediaDurationBtn.frame.origin.x + 35 + margin, 30, 35, 35)];
    [addSubtitleBtn setImage:[UIImage imageNamed:@"add_subtitle_btn.png"] forState:UIControlStateNormal];
    [addSubtitleBtn addTarget:self action:@selector(addSubtitleAction:) forControlEvents:UIControlEventTouchUpInside];
    [bottomToolBarControlView addSubview:addSubtitleBtn];
    //add music btn
    addMusicBtn = [[UIButton alloc] initWithFrame:CGRectMake(addSubtitleBtn.frame.origin.x + 35 + margin, 30, 35, 35)];
    [addMusicBtn setImage:[UIImage imageNamed:@"add_music_btn.png"] forState:UIControlStateNormal];
    [addMusicBtn addTarget:self action:@selector(addMusicAction:) forControlEvents:UIControlEventTouchUpInside];
    [bottomToolBarControlView addSubview:addMusicBtn];
    //record audio btn
    recordAudioBtn = [[UIButton alloc] initWithFrame:CGRectMake(addMusicBtn.frame.origin.x + 35 + margin, 30, 35, 35)];
    [recordAudioBtn setImage:[UIImage imageNamed:@"record_audio_btn.png"] forState:UIControlStateNormal];
    [recordAudioBtn addTarget:self action:@selector(recordAudioAction:) forControlEvents:UIControlEventTouchUpInside];
    [bottomToolBarControlView addSubview:recordAudioBtn];
    //slider
    previewSlider = [[NMRangeSlider alloc] initWithFrame:CGRectMake(0, 0, bottomToolBarControlView.frame.size.width, 15)];
    [previewSlider addTarget:self action:@selector(sliderValueChanged:) forControlEvents:UIControlEventValueChanged];
    [previewSlider addTarget:self action:@selector(sliderTouchUpInside:) forControlEvents:UIControlEventTouchUpInside];
    previewSlider.minimumRange = 0;
    previewSlider.upperHandleHidden = YES;
    UIImage *img = [UIImage imageNamed:@"slider_track_bg.png"];
    img = [img resizableImageWithCapInsets:UIEdgeInsetsMake(0.0, 5.0, 0.0, 5.0)];
    previewSlider.trackBackgroundImage = img;
    img = [UIImage imageNamed:@"slider_track.png"];
    img = [img resizableImageWithCapInsets:UIEdgeInsetsMake(0.0, 5.0, 0.0, 5.0)];
    previewSlider.trackImage = img;
    
    img = [UIImage imageNamed:@"slider_handle"];
    [img resizableImageWithCapInsets:UIEdgeInsetsMake(1,1,1,1)];
    previewSlider.lowerHandleImageNormal = img;
    previewSlider.lowerHandleImageHighlighted = img;
    
    [bottomToolBarControlView addSubview:previewSlider];
    [bottomToolBar addSubview:bottomToolBarControlView];
    [self.view addSubview:bottomToolBar];
    
    //play control
    playBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 55, 55)];
    playBtn.center = CGPointMake(screenRect.size.width/2.0, screenRect.size.height/2.0);
    [playBtn setBackgroundImage:[UIImage imageNamed:@"play_transparent.png"] forState:UIControlStateNormal];
    [playBtn addTarget:self action:@selector(playAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:playBtn];
    
    status = ViewStatusPreview;
    
    //handle media
    [self updateMerge];
    
    //frames
    [self initFrameView];
}

- (void)initPhotoDurationSettingView
{
    //photo duration setting view
    photoDurationSettingView = [[UIView alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height + 10, screenRect.size.width, 95)];
    photoDurationSettingView.backgroundColor = [UIColor colorWithRed:34/255.0 green:30/255.0 blue:30/255.0 alpha:1.0];
    //
    UIView *photoDurationSettingTitleView = [[UIView alloc] initWithFrame:CGRectMake(0,photoDurationSettingView.frame.size.height-34,photoDurationSettingView.frame.size.width,34)];
    photoDurationSettingTitleView.backgroundColor = [UIColor colorWithRed:21/255.0 green:19/255.0 blue:19/255.0 alpha:1.0];
    //
    int btnSize=34;
    int marginSize=10;
    UIButton *cancelPhotoDurationSetting = [[UIButton alloc] initWithFrame:CGRectMake(marginSize,0, btnSize,btnSize)];
    [cancelPhotoDurationSetting setImageEdgeInsets:UIEdgeInsetsMake(0,0,0,0)];
    [cancelPhotoDurationSetting setImage:[UIImage imageNamed:@"photo_duration_cancel.png"] forState:UIControlStateNormal];
    [cancelPhotoDurationSetting setImage:[UIImage imageNamed:@"photo_duration_cancel_selected.png"] forState:UIControlStateHighlighted];
    [cancelPhotoDurationSetting addTarget:self action:@selector(cancelPhotoDurationSettingAction:) forControlEvents:UIControlEventTouchUpInside];
    [photoDurationSettingTitleView addSubview:cancelPhotoDurationSetting];
    //
    UIButton *confirmPhotoDurationSetting = [[UIButton alloc] initWithFrame:CGRectMake(photoDurationSettingTitleView.frame.size.width -marginSize - btnSize, 0, btnSize,btnSize)];
    [confirmPhotoDurationSetting setImageEdgeInsets:UIEdgeInsetsMake(0,0,0,0)];
    [confirmPhotoDurationSetting setImage:[UIImage imageNamed:@"photo_duration_confirm.png"] forState:UIControlStateNormal];
    [confirmPhotoDurationSetting setImage:[UIImage imageNamed:@"photo_duration_confirm_selected.png"] forState:UIControlStateHighlighted];
    [confirmPhotoDurationSetting addTarget:self action:@selector(confirmPhotoDurationSettingAction:) forControlEvents:UIControlEventTouchUpInside];
    [photoDurationSettingTitleView addSubview:confirmPhotoDurationSetting];
    //
    UILabel *photoDuraionTitle = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100, 34)];
    photoDuraionTitle.text = NSLocalizedString(@"Duration", nil);
    photoDuraionTitle.backgroundColor = [UIColor clearColor];
    photoDuraionTitle.textColor = [UIColor whiteColor];
    photoDuraionTitle.textAlignment = NSTextAlignmentCenter;
    photoDuraionTitle.center = CGPointMake(photoDurationSettingTitleView.frame.size.width/2, photoDurationSettingTitleView.frame.size.height/2);
    [photoDurationSettingTitleView addSubview:photoDuraionTitle];
    [photoDurationSettingView addSubview:photoDurationSettingTitleView];
    //
    UILabel *photoDurationLabel = [[UILabel alloc] initWithFrame:CGRectMake(3, 30, 70, 20)];
    photoDurationLabel.textColor = [UIColor whiteColor];
    photoDurationLabel.backgroundColor = [UIColor clearColor];
    photoDurationLabel.font = [UIFont systemFontOfSize:14];
    photoDurationLabel.text = NSLocalizedString(@"Photo Duration", nil);
    [photoDurationSettingView addSubview:photoDurationLabel];
    //
    photoDurationSlider = [[NMRangeSlider alloc] initWithFrame:CGRectMake(70, 35, photoDurationSettingView.frame.size.width - 75, 13)];
    photoDurationSlider.upperHandleHidden = YES;
    photoDurationSlider.maximumValue = 10;
    photoDurationSlider.minimumValue = 0.5;
    photoDurationSlider.lowerValue = 0.5;
    [photoDurationSlider addTarget:self action:@selector(photoDurationSliderValueChanged:) forControlEvents:UIControlEventValueChanged];
    [photoDurationSlider addTarget:self action:@selector(photoDurationSliderTouchUpInside:) forControlEvents:UIControlEventTouchUpInside];
    
    UIImage *img = [UIImage imageNamed:@"slider_track_bg.png"];
    img = [img resizableImageWithCapInsets:UIEdgeInsetsMake(0.0, 5.0, 0.0, 5.0)];
    photoDurationSlider.trackBackgroundImage = img;
    img = [UIImage imageNamed:@"slider_track.png"];
    img = [img resizableImageWithCapInsets:UIEdgeInsetsMake(0.0, 5.0, 0.0, 5.0)];
    photoDurationSlider.trackImage = img;
    img = [UIImage imageNamed:@"slider_handler_clock.png"];
    [img resizableImageWithCapInsets:UIEdgeInsetsMake(1,1,1,1)];
    photoDurationSlider.lowerHandleImageNormal = img;
    photoDurationSlider.lowerHandleImageHighlighted = img;
    [photoDurationSettingView addSubview:photoDurationSlider];
    //
    photoDurationValue = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 80, 20)];
    photoDurationValue.center = CGPointMake(photoDurationSlider.lowerCenter.x + photoDurationSlider.frame.origin.x + img.size.width/2, photoDurationSlider.frame.origin.y-photoDurationValue.frame.size.height/2-8);
    photoDurationValue.textColor = [UIColor colorWithRed:190/255.0 green:95/255.0 blue:98/255.0 alpha:1.0];
    photoDurationValue.font = [UIFont systemFontOfSize:12];
    photoDurationValue.backgroundColor = [UIColor clearColor];
    photoDurationValue.textAlignment = NSTextAlignmentCenter;
    photoDurationValue.text = @"0.5s";
    [photoDurationSettingView addSubview:photoDurationValue];
    [self.view addSubview:photoDurationSettingView];
}

- (void)initRecordView
{
    if(!recordView){
        recordView = [[UIView alloc] initWithFrame:CGRectMake(0, screenRect.size.height + 10, screenRect.size.width, 165)];
        
        UIView *middleView = [[UIView alloc] initWithFrame:CGRectMake(0, 20, screenRect.size.width, 145)];
        middleView.backgroundColor = [UIColor colorWithRed:34/255.0 green:30/255.0 blue:30/255.0 alpha:1.0];
        [recordView addSubview:middleView];
        [self.view addSubview:recordView];
        //title
        UIView *recordTitleView = [[UIView alloc] initWithFrame:CGRectMake(0,middleView.frame.size.height-34,middleView.frame.size.width,34)];
        recordTitleView.backgroundColor = [UIColor colorWithRed:21/255.0 green:19/255.0 blue:19/255.0 alpha:1.0];
        [middleView addSubview:recordTitleView];
        //
        int btnSize=34;
        int marginSize=10;
        UIButton *cancelAddRecording = [[UIButton alloc] initWithFrame:CGRectMake(marginSize,0, btnSize,btnSize)];
        [cancelAddRecording setImageEdgeInsets:UIEdgeInsetsMake(0,0,0,0)];
        [cancelAddRecording setImage:[UIImage imageNamed:@"photo_duration_cancel.png"] forState:UIControlStateNormal];
        [cancelAddRecording setImage:[UIImage imageNamed:@"photo_duration_cancel_selected.png"] forState:UIControlStateHighlighted];
        [cancelAddRecording addTarget:self action:@selector(cancelAddRecordingAction:) forControlEvents:UIControlEventTouchUpInside];
        [recordTitleView addSubview:cancelAddRecording];
        //
        UIButton *confirmAddRecording = [[UIButton alloc] initWithFrame:CGRectMake(recordTitleView.frame.size.width -marginSize - btnSize, 0, btnSize,btnSize)];
        [confirmAddRecording setImageEdgeInsets:UIEdgeInsetsMake(0,0,0,0)];
        [confirmAddRecording setImage:[UIImage imageNamed:@"photo_duration_confirm.png"] forState:UIControlStateNormal];
        [confirmAddRecording setImage:[UIImage imageNamed:@"photo_duration_confirm_selected.png"] forState:UIControlStateHighlighted];
        [confirmAddRecording addTarget:self action:@selector(confirmAddRecordingAction:) forControlEvents:UIControlEventTouchUpInside];
        [recordTitleView addSubview:confirmAddRecording];
        
        //
        UILabel *recordAudioTitle = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100, 34)];
        recordAudioTitle.backgroundColor = [UIColor clearColor];
        recordAudioTitle.text = NSLocalizedString(@"Recording", nil);
        recordAudioTitle.textColor = [UIColor whiteColor];
        recordAudioTitle.textAlignment = NSTextAlignmentCenter;
        recordAudioTitle.center = CGPointMake(recordTitleView.frame.size.width/2, recordTitleView.frame.size.height/2);
        [recordTitleView addSubview:recordAudioTitle];
        
        //record button
        record = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 50, 50)];
        record.center = CGPointMake(middleView.frame.size.width/2, 78);
        [record setBackgroundImage:[UIImage imageNamed:@"record.png"] forState:UIControlStateNormal];
        [record addTarget:self action:@selector(recordFinish:) forControlEvents:UIControlEventTouchUpInside];
        [record addTarget:self action:@selector(recordStart:) forControlEvents:UIControlEventTouchDown];
        [middleView addSubview:record];
        
        UIImage * deleteImage=[UIImage imageNamed:@"delete.png"];
        //delete
        deleteRecording = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 30, deleteImage.size.height/deleteImage.size.width*30)];
        deleteRecording.center = record.center;
        [deleteRecording setBackgroundImage:deleteImage forState:UIControlStateNormal];
        [deleteRecording addTarget:self action:@selector(deleteRecording:) forControlEvents:UIControlEventTouchUpInside];
        [middleView addSubview:deleteRecording];
        deleteRecording.center=record.center;
        deleteRecording.hidden = YES;
        
        //progress label
        addRecordingCurrentProgressLabel = [[MyLabel alloc] initWithFrame:CGRectMake(3, 0, 90, 20)];
        addRecordingCurrentProgressLabel.font = [UIFont systemFontOfSize:13];
        addRecordingCurrentProgressLabel.textAlignment = NSTextAlignmentLeft;
        addRecordingCurrentProgressLabel.drawOutline = YES;
        addRecordingCurrentProgressLabel.outlineColor = [UIColor blackColor];
        addRecordingCurrentProgressLabel.textColor = [UIColor whiteColor];
        [recordView addSubview:addRecordingCurrentProgressLabel];
        
        //
        addRecordingTotalProgressLabel = [[MyLabel alloc] initWithFrame:CGRectMake(recordView.frame.size.width - 93, 0, 90, 20)];
        addRecordingTotalProgressLabel.font = [UIFont systemFontOfSize:13];
        addRecordingTotalProgressLabel.textAlignment = NSTextAlignmentRight;
        addRecordingTotalProgressLabel.drawOutline = YES;
        addRecordingTotalProgressLabel.outlineColor = [UIColor blackColor];
        addRecordingTotalProgressLabel.textColor = [UIColor whiteColor];
        [recordView addSubview:addRecordingTotalProgressLabel];
    }
    //frames
    if([frameView superview]){
        [frameView removeFromSuperview];
    }
    //48 p
    frameView.frame = CGRectMake(0, 20, self.view.frame.size.width, frameView.frame.size.height);
    [recordView addSubview:frameView];
    //
    addRecordingCurrentProgressLabel.text = [Util stringWithSeconds:0];
    addRecordingTotalProgressLabel.text = [Util stringWithSeconds:round(CMTimeGetSeconds(playbackHelper.playerItem.duration))];
}

- (void)initFrameView
{
    frameView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 48)];
    frameScrollableView = [[FrameView alloc] initWithMedias:[self.timeline getTrackFromTimeline:0].mpMediaObjArray frame:CGRectMake(0, 1.5, self.view.frame.size.width, 45)];
    frameScrollableView.delegate = self;
    frameScrollableView.contentSize = CGSizeMake(self.view.frame.size.width, 45);
    frameScrollableView.backgroundColor = [UIColor whiteColor];
    [frameView addSubview:frameScrollableView];
    
    frameViewMark = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 3, frameView.frame.size.height)];
    frameViewMark.backgroundColor = [UIColor whiteColor];
    [frameView addSubview:frameViewMark];
}

- (void)initMusicSettingView
{
    if(!musicSettingView){
        musicSettingView = [[UIView alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height -178, screenRect.size.width, 178)];
        UIView *middleView = [[UIView alloc] initWithFrame:CGRectMake(0, 65, screenRect.size.width, 80)];
        middleView.backgroundColor = [UIColor colorWithRed:34/255.0 green:30/255.0 blue:30/255.0 alpha:1.0];
        [musicSettingView addSubview:middleView];
        //title view
        UIView *musicSettingTitleView = [[UIView alloc] initWithFrame:CGRectMake(0,musicSettingView.frame.size.height-34,musicSettingView.frame.size.width,34)];
        musicSettingTitleView.backgroundColor = [UIColor colorWithRed:21/255.0 green:19/255.0 blue:19/255.0 alpha:1.0];
        
        int btnSize=34;
        int marginSize=10;
        //
        UIButton *cancelMusicSetting = [[UIButton alloc] initWithFrame:CGRectMake(marginSize, 0, btnSize,btnSize)];
        [cancelMusicSetting setImageEdgeInsets:UIEdgeInsetsZero];
        [cancelMusicSetting setImage:[UIImage imageNamed:@"photo_duration_cancel.png"] forState:UIControlStateNormal];
        [cancelMusicSetting setImage:[UIImage imageNamed:@"photo_duration_cancel_selected.png"] forState:UIControlStateHighlighted];
        [cancelMusicSetting addTarget:self action:@selector(cancelMusicSettingAction:) forControlEvents:UIControlEventTouchUpInside];
        [musicSettingTitleView addSubview:cancelMusicSetting];
        //
        UIButton *confirmMusicSetting = [[UIButton alloc] initWithFrame:CGRectMake(musicSettingTitleView.frame.size.width -marginSize - btnSize, 0, btnSize, btnSize)];
        [confirmMusicSetting setImageEdgeInsets:UIEdgeInsetsZero];
        [confirmMusicSetting setImage:[UIImage imageNamed:@"photo_duration_confirm.png"] forState:UIControlStateNormal];
        [confirmMusicSetting setImage:[UIImage imageNamed:@"photo_duration_confirm_selected.png"] forState:UIControlStateHighlighted];
        [confirmMusicSetting addTarget:self action:@selector(confirmMusicSettingAction:) forControlEvents:UIControlEventTouchUpInside];
        [musicSettingTitleView addSubview:confirmMusicSetting];
        //
        UILabel *musicSettingLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 150, musicSettingTitleView.frame.size.height)];
        musicSettingLabel.center = CGPointMake(musicSettingTitleView.frame.size.width/2, musicSettingTitleView.frame.size.height/2);
        musicSettingLabel.backgroundColor = [UIColor clearColor];
        musicSettingLabel.textAlignment = NSTextAlignmentCenter;
        musicSettingLabel.textColor = [UIColor whiteColor];
        musicSettingLabel.font = [UIFont systemFontOfSize:17];
        musicSettingLabel.text = NSLocalizedString(@"Setting Music", nil);
        [musicSettingTitleView addSubview:musicSettingLabel];
        [musicSettingView addSubview:musicSettingTitleView];
        //
        NMRangeSlider *volumeSlider = [[NMRangeSlider alloc] initWithFrame:CGRectMake(0, 0, 240, 20)];
        volumeSlider.center = CGPointMake(middleView.frame.size.width/2, 20);
        [volumeSlider addTarget:self action:@selector(volumeSliderValueChanged:) forControlEvents:UIControlEventValueChanged];
        [volumeSlider addTarget:self action:@selector(volumeSliderTouchUpInside:) forControlEvents:UIControlEventTouchUpInside];
        volumeSlider.maximumValue = 1;
        volumeSlider.minimumValue = 0;
        volumeSlider.upperHandleHidden = YES;
        UIImage *trackimg = [UIImage imageNamed:@"slider_track_bg.png"];
        trackimg = [trackimg resizableImageWithCapInsets:UIEdgeInsetsMake(0.0, 5.0, 0.0, 5.0)];
        volumeSlider.trackBackgroundImage = trackimg;
        trackimg = [UIImage imageNamed:@"slider_track.png"];
        trackimg = [trackimg resizableImageWithCapInsets:UIEdgeInsetsMake(0.0, 5.0, 0.0, 5.0)];
        volumeSlider.trackImage=trackimg;
        UIImage *img = [UIImage imageNamed:@"volume.png"];
        volumeSlider.lowerHandleImageNormal = img;
        volumeSlider.lowerHandleImageHighlighted = img;
        [volumeSlider setLowerValue:0.5 animated:YES];
        [middleView addSubview:volumeSlider];

        //
        UIImageView *videoVol = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 20, 17)];
        videoVol.center = CGPointMake(volumeSlider.center.x - volumeSlider.frame.size.width/2 - 5 - 10, volumeSlider.center.y);
        videoVol.image = [UIImage imageNamed:@"video_vol.png"];
        [middleView addSubview:videoVol];
        //
        UIImageView *musicVol = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 16, 17)];
        musicVol.center = CGPointMake(volumeSlider.center.x + volumeSlider.frame.size.width/2 + 5 + 8, volumeSlider.center.y);
        musicVol.image = [UIImage imageNamed:@"music_vol.png"];
        [middleView addSubview:musicVol];
        
        videoPrecent=[[UILabel alloc] initWithFrame:CGRectMake(0,0,80,15)];
        musicPrecent=[[UILabel alloc] initWithFrame:CGRectMake(0,0,80,15)];
        videoPrecent.font=[UIFont systemFontOfSize:10];
        musicPrecent.font=[UIFont systemFontOfSize:10];
        videoPrecent.textAlignment=NSTextAlignmentCenter;
        musicPrecent.textAlignment=NSTextAlignmentCenter;
        
        videoPrecent.textColor=[UIColor whiteColor];
        musicPrecent.textColor=[UIColor whiteColor];
        videoPrecent.center=CGPointMake(videoVol.center.x, videoVol.center.y+15);
        musicPrecent.center=CGPointMake(musicVol.center.x, musicVol.center.y+15);
        videoPrecent.text=@"50%";
        musicPrecent.text=@"50%";
        [middleView addSubview:videoPrecent];
        [middleView addSubview:musicPrecent];
        //
        UIButton *musicLoop = [[UIButton alloc] initWithFrame:CGRectMake(videoVol.frame.origin.x + 35, musicPrecent.frame.origin.y+musicPrecent.frame.size.height+5, 50, 27)];
        [musicLoop setImage:[UIImage imageNamed:@"loop.png"] forState:UIControlStateNormal];
        [musicLoop setImage:[UIImage imageNamed:@"loop_selected.png"] forState:UIControlStateSelected];
        [musicLoop addTarget:self action:@selector(loopAction:) forControlEvents:UIControlEventTouchUpInside];
        [musicLoop setImageEdgeInsets:UIEdgeInsetsMake(0, 10, 0, 10)];
        [middleView addSubview:musicLoop];
        musicLoop.hidden=YES;
        //
        UIImage * deleteImage=[UIImage imageNamed:@"music_delete.png"];
        UIButton *musicDelete = [[UIButton alloc] initWithFrame:CGRectMake(musicVol.frame.origin.x - 55, musicPrecent.frame.origin.y+musicPrecent.frame.size.height+2, 40, 27)];
        [musicDelete addTarget:self action:@selector(deleteMusic:) forControlEvents:UIControlEventTouchUpInside];
        [musicDelete setImage:deleteImage forState:UIControlStateNormal];
        [musicDelete setImageEdgeInsets:UIEdgeInsetsMake(0, 10, 0, 10)];
        [middleView addSubview:musicDelete];
        musicDelete.center=CGPointMake(middleView.center.x, musicDelete.center.y);
        //
        //current time label
        musicSettingCurrentProgressLabel = [[MyLabel alloc] initWithFrame:CGRectMake(3, 0, 90, 20)];
        musicSettingCurrentProgressLabel.font = [UIFont systemFontOfSize:13];
        musicSettingCurrentProgressLabel.textAlignment = NSTextAlignmentLeft;
        musicSettingCurrentProgressLabel.drawOutline = YES;
        musicSettingCurrentProgressLabel.outlineColor = [UIColor blackColor];
        musicSettingCurrentProgressLabel.textColor = [UIColor whiteColor];
        [musicSettingView addSubview:musicSettingCurrentProgressLabel];
        
        //total time label
        musicSettingTotalProgressLabel = [[MyLabel alloc] initWithFrame:CGRectMake(musicSettingView.frame.size.width - 93, 0, 90, 20)];
        musicSettingTotalProgressLabel.font = [UIFont systemFontOfSize:13];
        musicSettingTotalProgressLabel.textAlignment = NSTextAlignmentRight;
        musicSettingTotalProgressLabel.drawOutline = YES;
        musicSettingTotalProgressLabel.outlineColor = [UIColor blackColor];
        musicSettingTotalProgressLabel.textColor = [UIColor whiteColor];
        [musicSettingView addSubview:musicSettingTotalProgressLabel];

        [self.view addSubview:musicSettingView];
    }    
    //frames
    if([frameView superview]){
        [frameView removeFromSuperview];
    }
    frameView.frame = CGRectMake(0, 20, self.view.frame.size.width, 45);
    if([self.timeline getTrackFromTimeline:1].mpMediaObjArray.count > 0){
        CGFloat dur = CMTimeGetSeconds(((qxMediaObject*)[self.timeline getTrackFromTimeline:1].mpMediaObjArray[0]).actualTimeRange.duration);
        CGFloat w = FrameWidthPerSecond * dur;
        [frameScrollableView updateSelectView:CGRectMake(0, 0, w, frameScrollableView.frame.size.height)];
        frameViewMark.hidden = YES;
    }else{
        [frameScrollableView updateSelectView:CGRectMake(0, 0, 0, frameScrollableView.frame.size.height)];
        frameViewMark.hidden = NO;
    }
    [musicSettingView addSubview:frameView];
    musicSettingCurrentProgressLabel.text = [Util stringWithSeconds:0];
    musicSettingTotalProgressLabel.text = [Util stringWithSeconds:round(CMTimeGetSeconds(playbackHelper.playerItem.duration))];
}

-(void)loopAction:(UIButton*)sender
{
    sender.selected=!sender.selected;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self addObserver:self forKeyPath:@"exporting" options:NSKeyValueObservingOptionNew context:NULL];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if(status == ViewStatusAddMusic){
        [self hideNavigationBar];
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self pausePreview];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [self removeObserver:self forKeyPath:@"exporting"];
}

- (BOOL)shouldAutorotate
{
    return NO;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
    return UIInterfaceOrientationPortrait;
}

#pragma mark - button event
- (void)addMediaAction:(id)sender
{
    if(playbackHelper){
        [self stopPreview];
    }
    [Util clearPhotoTrack:[self.timeline getTrackFromTimeline:0]];
    AGImagePickerController *pickerController = (AGImagePickerController*)self.navigationController;
    pickerController.isEditWithTimeline = YES;
    pickerController.reeditTimeline = self.timeline;
    [self.navigationController popViewControllerAnimated:YES];
    [self.navigationController.view addSubview:self.toolbarView];
}

- (void)setMediaDurationAction:(id)sender
{
    if(!currentMediaObject){
        currentMediaObject = [[self.timeline getTrackFromTimeline:0] getMediaObjectFromTrack:0];
    }
    if(currentMediaObject.eType == eMT_Photo){
        [self hideNavigationBar];
        [self hideMainControlBar];
        [self showPhotoDurationSettingView];
        status = ViewStatusPhotoDurationSetting;
        photoLastDuration = CMTimeGetSeconds(currentMediaObject.mediaOriginalDuration);
    }else if(currentMediaObject.eType == eMT_Video){
        status = ViewStatusVideoClip;
        VideoClipViewController *videoClipViewController = [[VideoClipViewController alloc] init];
        videoClipViewController.delegate = self;
        videoClipViewController.videoObject = currentMediaObject;
        [self.navigationController presentViewController:videoClipViewController animated:YES completion:nil];
    }
}

- (void)addSubtitleAction:(id)sender
{
    SubtitleViewController *svc = [[SubtitleViewController alloc] init];
    svc.timeline = self.timeline;
    svc.videoViewRect = videoView.frame;
    svc.delegate = self;
    [self presentViewController:svc animated:YES completion:nil];
}

- (void)addMusicAction:(id)sender
{
    [self openMusicpickerViewController];
}

- (void)openMusicpickerViewController
{
    status = ViewStatusAddMusic;
    MusicPickerViewController *musicPickerViewController = [[MusicPickerViewController alloc] initWithStyle:UITableViewStylePlain];
    musicPickerViewController.delegate = self;
    UINavigationController *nav = [[PortraitNavigationController alloc] initWithRootViewController:musicPickerViewController];
    [self presentViewController:nav animated:YES completion:nil];
}

- (void)recordAudioAction:(id)sender
{
    [self hideNavigationBar];
    [self hideMainControlBar];
    [self showAudioRecordingView];
    status = ViewStatusRecordAudio;
}

- (void)playAction:(id)sender
{
    [self startPreview];
    if(status == ViewStatusPreview){
        [self hideStatusbar];
        [self hideNavigationBar];
        [self hideMainControlBar];
    }
}

- (void)cancelPhotoDurationSettingAction:(id)sender
{
    [self hidePhotoDurationSettingView];
    [self showNavigationBar];
    [self showMainControlBar];
    status = ViewStatusPreview;
    if(CMTimeGetSeconds(currentMediaObject.mediaOriginalDuration) != photoLastDuration){
        [self resetPhotoDuration:photoLastDuration*1000];
    }
    [self seekTo:0];
    [self pausePreview];
}

- (void)confirmPhotoDurationSettingAction:(id)sender
{
    if((int)photoDurationSlider.lowerValue != (int)CMTimeGetSeconds(currentMediaObject.mediaOriginalDuration)){
        [self resetPhotoDuration:photoDurationSlider.lowerValue * 1000];
    }
    [self seekTo:0];
    [self pausePreview];
    [self hidePhotoDurationSettingView];
    [self showNavigationBar];
    [self showMainControlBar];
    status = ViewStatusPreview;
}

- (void)cancelAddRecordingAction:(id)sender
{
    if(audioRecorder && audioRecorder.isRecording){
        return;
    }
    [self pausePreview];
    if(recordAudioChanged){
        NSMutableArray *audioArray = [self.timeline getTrackFromTimeline:2].mpMediaObjArray;
        [audioArray removeAllObjects];
    }
    [self hideAudioRecordingView];
    [self showMainControlBar];
    [self showNavigationBar];
    [self prepareForPreview];
    status = ViewStatusPreview;
}

- (void)confirmAddRecordingAction:(id)sender
{
    if(audioRecorder && audioRecorder.isRecording){
        return;
    }
    [self pausePreview];
    [self hideAudioRecordingView];
    [self showMainControlBar];
    [self showNavigationBar];
    status = ViewStatusPreview;
}

- (void)deleteRecording:(id)sender
{
    NSMutableArray *audioArray = [self.timeline getTrackFromTimeline:2].mpMediaObjArray;
    [audioArray removeAllObjects];
    [self updateRecordingView];
    [self prepareForPreview];
}

- (void)closeTrackVolume
{
    qxTrack *videoTrack = [self.timeline getTrackFromTimeline:0];
    qxTrack *musicTrack = [self.timeline getTrackFromTimeline:1];
    videoTrackVolumePercent = [videoTrack getAudioPercent];
    [videoTrack setAudioPercent:0];
    musicTrackVolumePercent = [musicTrack getAudioPercent];
    [musicTrack setAudioPercent:0];
    [self prepareForPreview];
}

- (void)resumeTrackVolume
{
    qxTrack *videoTrack = [self.timeline getTrackFromTimeline:0];
    [videoTrack setAudioPercent:videoTrackVolumePercent];
    qxTrack *musicTrack = [self.timeline getTrackFromTimeline:1];
    [musicTrack setAudioPercent:musicTrackVolumePercent];
}

- (void)recordStart:(id)sender
{
    [frameScrollableView scrollTo:CGPointMake(0, 0)];
    prepareForRecordAudio = YES;
    NSArray *documentPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *recordDir = [(NSString*)documentPaths[0] stringByAppendingPathComponent:@"Record"];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if(![fileManager fileExistsAtPath:recordDir]){
        [fileManager createDirectoryAtPath:recordDir withIntermediateDirectories:YES attributes:nil error:nil];
    }
    long long time = [[NSDate date] timeIntervalSince1970] * 1000;
    recordCache = [recordDir stringByAppendingPathComponent:[NSString stringWithFormat:@"%@%lld%@",@"rec_",time,@".caf"]];
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
    NSError *error;
    audioRecorder = [[AVAudioRecorder alloc] initWithURL:[NSURL fileURLWithPath:recordCache isDirectory:NO] settings:[self recorderSetting] error:&error];
    audioRecorder.meteringEnabled = YES;
    if(!error && [audioRecorder prepareToRecord]){
        [self closeTrackVolume];
        frameScrollableView.scrollEnabled = NO;
    }else{
        NSLog(@"parepare record failed !!!");
    }
}

- (void)startRecord
{
    [self startRecordTimer];
    [self startPreview];
    [audioRecorder record];
    recordAudioChanged = YES;
}

-(NSDictionary*)recorderSetting
{
    NSMutableDictionary *recordSettings = [[NSMutableDictionary alloc] init];
    [recordSettings setObject:[NSNumber numberWithInt: kAudioFormatLinearPCM] forKey: AVFormatIDKey];
    [recordSettings setObject:[NSNumber numberWithFloat:44100.0] forKey: AVSampleRateKey];
    [recordSettings setObject:[NSNumber numberWithInt:2]forKey:AVNumberOfChannelsKey];
    [recordSettings setObject:[NSNumber numberWithInt:16] forKey:AVLinearPCMBitDepthKey];
    [recordSettings setObject:[NSNumber numberWithBool:YES] forKey:AVLinearPCMIsBigEndianKey];
    [recordSettings setObject:[NSNumber numberWithBool:YES] forKey:AVLinearPCMIsFloatKey];
    return recordSettings;
}

- (void)recordFinish:(id)sender
{
    if([audioRecorder isRecording]){
        [audioRecorder stop];
        audioRecorder = nil;
    }
    [self pausePreview];
    [self stopRecordTimer];
    frameScrollableView.scrollEnabled = YES;
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:nil];
    //add audio
    qxMediaObject *mediaObj = [[qxMediaObject alloc] init];
    [mediaObj setFilePath:recordCache withType:eMT_Audio fromAssetLibrary:NO];
    
    if(![self addAudio:mediaObj WithTrack:[self.timeline getTrackFromTimeline:2]]){//audio track
        [Util showErrorAlertWithMessage:NSLocalizedString(@"Add audio failed", nil)];
    }else{
        [[self.timeline getTrackFromTimeline:2] setAudioPercent:1];
        [self updateRecordingView];
        [self resumeTrackVolume];
        [self prepareForPreview];
    }
    prepareForRecordAudio = NO;
}

- (void)cancelMusicSettingAction:(id)sender
{
    [[self.timeline getTrackFromTimeline:1].mpMediaObjArray removeAllObjects];
    [self prepareForPreview];
    status = ViewStatusPreview;
    [self hideMusicSettingView];
    [self showMainControlBar];
    [self showNavigationBar];
}

- (void)confirmMusicSettingAction:(id)sender
{
    status = ViewStatusPreview;
    [self hideMusicSettingView];
    [self showMainControlBar];
    [self showNavigationBar];
}

- (void)deleteMusic:(id)sender
{
    [[self.timeline getTrackFromTimeline:1].mpMediaObjArray removeAllObjects];
    [self prepareForPreview];
    [self openMusicpickerViewController];
}

- (void)exportAction:(id)sender
{
    [self startExport];
}


#pragma mark - handle gesture
- (void)backViewTap:(UITapGestureRecognizer*)gesture
{
    backAlert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Exit Video Editing", nil) message:nil delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel", nil) otherButtonTitles:NSLocalizedString(@"Confirm", nil),NSLocalizedString(@"Save to drafts", nil), nil];
    [backAlert show];
}

- (void)playbackViewTap:(UITapGestureRecognizer*)gesture
{
    if(self.exporting){
        return;
    }
    
    if(self.playing){
        [self pausePreview];
        if(status == ViewStatusPreview){
            [self showStatusbar];
            [self showNavigationBar];
            [self showMainControlBar];
        }
    }else{
        [self startPreview];
        if(status == ViewStatusPreview){
            [self hideStatusbar];
            [self hideNavigationBar];
            [self hideMainControlBar];
        }
    }
}

#pragma mark - UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    VideoDraft *draft = nil;
    if(alertView == backAlert){
        switch (buttonIndex) {
            case 0://cancel

                break;
                
            case 1://confirm
                
                if(playbackHelper){
                    [self stopPreview];
                }
                [Util clearPhotoTrack:[self.timeline getTrackFromTimeline:0]];
                [self dismissViewControllerAnimated:YES completion:nil];
                break;
            
            case 2://save to drafts
                draft = [[VideoDraft alloc] initWithTimeline:self.timeline];
                if(![Util archiveDraft:draft]){//archive failed
                    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Draft Saving Failed", nil) message:nil delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil, nil];
                    [alertView show];
                    return;
                }
                if(playbackHelper){
                    [self stopPreview];
                }
                [Util clearPhotoTrack:[self.timeline getTrackFromTimeline:0]];
                [self.navigationController dismissViewControllerAnimated:YES completion:nil];
                break;
        }
    }
}

#pragma mark - StatusBar Hide/Show
-(void)hideStatusbar{
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationSlide];
    [UIView beginAnimations:@"StatusBarHide" context:nil];
    [UIView setAnimationDuration:0.05];
    [UIView commitAnimations];
}

-(void)showStatusbar{
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationSlide];
    [UIView beginAnimations:@"StatusBarShow" context:nil];
    [UIView setAnimationDuration:0.05];
    [UIView commitAnimations];
}

#pragma mark - Navigation bar / bottom control bar Hide/Show
- (void)showNavigationBar
{
    __weak PlayerViewController *weakSelf = self;
    [UIView animateWithDuration:0.5 animations:^{
        weakSelf.navigationController.navigationBar.frame = CGRectMake(0, 20, screenRect.size.width, 44);
    }];
}

- (void)hideNavigationBar
{
    __weak PlayerViewController *weakSelf = self;
    [UIView animateWithDuration:0.5 animations:^{
        weakSelf.navigationController.navigationBar.frame = CGRectMake(0, -54, screenRect.size.width, 44);
    }];
}

- (void)showMainControlBar
{
    __weak UIView *weakRef = bottomToolBar;
    [UIView animateWithDuration:0.5 animations:^{
        weakRef.frame = CGRectMake(0, self.view.frame.size.height - 95, screenRect.size.width, 95);
    }];
}

- (void)hideMainControlBar
{
     __weak UIView *weakRef = bottomToolBar;
    [UIView animateWithDuration:0.5 animations:^{
        weakRef.frame = CGRectMake(0, self.view.frame.size.height + 10, screenRect.size.width, 95);
    }];
}

- (void)showPhotoDurationSettingView
{
    if(!photoDurationSettingView){
        [self initPhotoDurationSettingView];
    }
    __weak UIView *weakRef = photoDurationSettingView;
    [UIView animateWithDuration:0.5 animations:^{
        weakRef.frame = CGRectMake(0, self.view.frame.size.height - 95, screenRect.size.width, 95);
    }];
}

- (void)hidePhotoDurationSettingView
{
    __weak UIView *weakRef = photoDurationSettingView;
    [UIView animateWithDuration:0.5 animations:^{
        weakRef.frame = CGRectMake(0, self.view.frame.size.height + 10, screenRect.size.width, 95);
    }];
}

- (void)showMusicSettingView
{
    [self initMusicSettingView];
    __weak UIView *weakRef = musicSettingView;
    [UIView animateWithDuration:0.5 animations:^{
        weakRef.frame = CGRectMake(0, self.view.frame.size.height - musicSettingView.frame.size.height, screenRect.size.width, musicSettingView.frame.size.height);
    }];
}

- (void)hideMusicSettingView
{
    __weak UIView *weakRef = musicSettingView;
    [UIView animateWithDuration:0.5 animations:^{
        weakRef.frame = CGRectMake(0, self.view.frame.size.height + 10, screenRect.size.width, musicSettingView.frame.size.height);
    }];
}

- (void)showAudioRecordingView
{
    [self initRecordView];
    [self updateRecordingView];
    recordAudioChanged = NO;
    __weak UIView *weakRef = recordView;
    [UIView animateWithDuration:0.5 animations:^{
        weakRef.frame = CGRectMake(0, self.view.frame.size.height - 165, screenRect.size.width, 165);
    }];
}

- (void)hideAudioRecordingView
{
    __weak UIView *weakRef = recordView;
    [UIView animateWithDuration:0.5 animations:^{
        weakRef.frame = CGRectMake(0, self.view.frame.size.height + 10, screenRect.size.width, 165);
    }];
}

#pragma mark - media handle
-(void)updateMerge
{
    @autoreleasepool {
        [SVProgressHUD showWithStatus:NSLocalizedString(@"Processing", nil) maskType:SVProgressHUDMaskTypeClear];
        NSOperationQueue *queue = [[NSOperationQueue alloc] init];
        __weak qxTimeline *qxTL = self.timeline;
        __weak PlayerViewController *wearkSelf = self;
        [queue addOperationWithBlock:^{
            
            for (qxMediaObject * px in [qxTL getTrackFromTimeline:0].mpMediaObjArray) {
                if (px.eType == eMT_Photo){
                    [px makeUsable:CGSizeMake(9*screenRect.size.height/16, screenRect.size.height)];
                }
            }
            
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                [SVProgressHUD dismiss];
                [wearkSelf prepareForPreview];
            }];
        }];
    }
}

-(void)prepareForPreview
{
    if(playbackHelper){
        playbackHelper.delegate = nil;
        [playbackHelper stop];
        [playbackHelper destroy];
        playbackHelper = nil;
    }
    playbackHelper = [[qxPlaybackHelper alloc] init];
    int timelineStatus = [self.timeline getTimelineSizeStatus];
    if([UIScreen mainScreen].bounds.size.height >= 568){
        if(timelineStatus == 1){//horizontal
            self.timeline.timelineSize = CGSizeMake(1136, 640);
        }else if(timelineStatus == 2){//vertical
            self.timeline.timelineSize = CGSizeMake(640, 1136);
        }else{
            self.timeline.timelineSize = CGSizeMake(640, 640);
        }
    }else{
        if(timelineStatus == 1){//horizontal
            self.timeline.timelineSize = CGSizeMake(640, 360);
        }else if(timelineStatus == 2){//vertical
            self.timeline.timelineSize = CGSizeMake(360, 640);
        }else{
            self.timeline.timelineSize = CGSizeMake(360, 360);
        }
    }

    float videoWidth = 320;
    float videoHeight = self.timeline.timelineSize.height * videoWidth / self.timeline.timelineSize.width;
    if(videoHeight > self.view.frame.size.height){
        videoHeight = self.view.frame.size.height;
        videoWidth = self.timeline.timelineSize.width * videoHeight / self.timeline.timelineSize.height;
    }
    videoView.frame = CGRectMake((self.view.frame.size.width - videoWidth)/2, (self.view.frame.size.height - videoHeight)/2, videoWidth, videoHeight);

    //
    playbackHelper.mpTimeline = self.timeline;
    [playbackHelper initWithUIView:videoView];
    playbackHelper.delegate = self;
    duration = playbackHelper.playerItem.duration;
    previewSlider.maximumValue = CMTimeGetSeconds(duration);
    currentProgressLabel.text = [Util stringWithSeconds:0];
    totalProgressLabel.text = [Util stringWithSeconds:round(previewSlider.maximumValue)];
    [self seekTo:0];
    
    for (UIView * pv in videoView.subviews) {
        if (![pv isKindOfClass:NSClassFromString(@"qxPlaybackView")]){
            [videoView bringSubviewToFront:pv];
        }
    }
    [previewSlider setMaximumValue:duration.value/duration.timescale];
}

#pragma mark - qxPlaybackDelegate
- (void)readyForPlayback
{
    playBtn.hidden = NO;
    if(status == ViewStatusRecordAudio && prepareForRecordAudio){
        [self startRecord];
    }
}

- (void)FinishPlayback
{
    [self pausePreview];
    [self seekTo:0];
    if(status == ViewStatusPreview){
        [self showStatusbar];
        [self showNavigationBar];
        [self showMainControlBar];
    }
}

#pragma mark - VideoClipViewControllerDelegate
- (void)videoClipDone
{
    //video duration had change, reload frames
    [frameScrollableView reloadFrames];
    status = ViewStatusPreview;
    [self prepareForPreview];
}

- (void)videoClipCancel
{
    //video duration had change, reload frames
    [frameScrollableView reloadFrames];
    status = ViewStatusPreview;
    [self prepareForPreview];
}

#pragma mark - MusicPickerViewControllerDelegate
- (void)musicPickerViewController:(MusicPickerViewController *)controller didFinishPickMediaItem:(qxMediaObject *)mediaObj
{
    status = ViewStatusAddMusic;
    [[self.timeline getTrackFromTimeline:1].mpMediaObjArray removeAllObjects];
    if(![self addAudio:mediaObj WithTrack:[self.timeline getTrackFromTimeline:1]]){//music track
        [Util showErrorAlertWithMessage:NSLocalizedString(@"Add music failed", nil)];
    }
    [self prepareForPreview];
    [self hideNavigationBar];
    [self hideMainControlBar];
    [self showMusicSettingView];
}

- (void)musicPickerCanceled
{
    status = ViewStatusPreview;
}

#pragma mark - SubtitleViewControllerDelegate
- (void)subtitleEditDone
{
    [self prepareForPreview];
}

#pragma mark - Preview control
-(void)stopPreview
{
    [self stopUpdatePlayStatus];
    if(playbackHelper){
        [playbackHelper stop];
        [playbackHelper destroy];
    }
    self.playing = NO;
}

-(void)startPreview
{
    if(audioRecorder && audioRecorder.isRecording){
        return;
    }
    if(!self.playing && playbackHelper){
        [playbackHelper playPause:YES];
        self.playing = YES;
        if(status == ViewStatusPreview || status == ViewStatusAddMusic || status == ViewStatusRecordAudio){
            [self startUpdatePlayStatus];
        }
    }
    playBtn.hidden = YES;
}

-(void)pausePreview
{
    if(audioRecorder && audioRecorder.isRecording){
        return;
    }
    if(self.playing && playbackHelper){
        [playbackHelper playPause:NO];
        self.playing = NO;
        [self stopUpdatePlayStatus];
    }
    playBtn.hidden = NO;
}

#pragma mark - Timer
-(void)updatePlayStatusTask
{
    NSTimeInterval tm = [playbackHelper playbackProgress];
    previewSlider.lowerValue = tm/1000;
    NSString *s = [Util stringWithSeconds:round(previewSlider.lowerValue)];
    if(status == ViewStatusPreview){
        currentProgressLabel.text = s;
    }else if(status == ViewStatusAddMusic){
        musicSettingCurrentProgressLabel.text = s;
    }else if(status == ViewStatusRecordAudio){
        addRecordingCurrentProgressLabel.text = s;
    }
    [self updateCurrentMediaObject];
}

- (void)updateCurrentMediaObject
{
    NSTimeInterval tm = [playbackHelper playbackProgress];
    double time = 0;
    int index = -1;
    qxTrack *videoTrack = [self.timeline getTrackFromTimeline:0];
    for (int i = 0; i < videoTrack.mpMediaObjArray.count; i++) {
        qxMediaObject *qx = videoTrack.mpMediaObjArray[i];
        
        if (qx.eType == eMT_Photo||qx.eType == eMT_Video){
            index++;
            time = time+CMTimeGetSeconds(qx.actualTimeRange.duration);
        }
        if (time>=tm/1000) {
            currentMediaObject = qx;
            break;
        }
    }
}

-(void)startUpdatePlayStatus
{
    if(![playControlTimer isValid]){
        playControlTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(updatePlayStatusTask) userInfo:nil repeats:YES];
    }
}

-(void)stopUpdatePlayStatus
{
    if([playControlTimer isValid]){
        [playControlTimer invalidate];
    }
}

- (void)sliderValueChanged:(id)sender
{
    [self seekTo:previewSlider.lowerValue];
}

- (void)sliderTouchUpInside:(id)sender
{
    [self updateCurrentMediaObject];
}

- (void)seekTo:(float)second
{
    [playbackHelper.player seekToTime:CMTimeMakeWithSeconds(second/previewSlider.maximumValue*CMTimeGetSeconds(duration), duration.timescale) toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero];
    NSString *timeStr = [Util stringWithSeconds:round(second)];
    if(status == ViewStatusPreview){
        currentProgressLabel.text = timeStr;
        previewSlider.lowerValue = second;
    }else if(status == ViewStatusRecordAudio){
        addRecordingCurrentProgressLabel.text = timeStr;
    }else if(status == ViewStatusAddMusic){
        musicSettingCurrentProgressLabel.text = timeStr;
    }
}

- (void)photoDurationSliderValueChanged:(NMRangeSlider*)sender
{
    if(self.playing){
        [self pausePreview];
    }
    photoDurationValue.center = CGPointMake(sender.lowerCenter.x + sender.frame.origin.x, photoDurationSlider.frame.origin.y-photoDurationValue.frame.size.height/2-8);
    photoDurationValue.text = [NSString stringWithFormat:@"%.1fs",sender.lowerValue];
}

- (void)photoDurationSliderTouchUpInside:(NMRangeSlider*)sender
{
    if(CMTimeGetSeconds(currentMediaObject.mediaOriginalDuration) != photoDurationSlider.lowerValue){
        [self resetPhotoDuration:photoDurationSlider.lowerValue * 1000];
    }
}

- (void)volumeSliderTouchUpInside:(NMRangeSlider*)sender
{
    if(hasVolumeChanged){
        float lowerValue = sender.lowerValue;
        float delta = (0.5 - lowerValue) * 2;
        qxTrack *videoTrack = [self.timeline getTrackFromTimeline:0];
        qxTrack *audioTrack = [self.timeline getTrackFromTimeline:2];
        qxTrack *musicTrack = [self.timeline getTrackFromTimeline:1];
        if(delta > 0){
            [videoTrack setAudioPercent:1 - delta];
            [audioTrack setAudioPercent:1 - delta];
            [musicTrack setAudioPercent:1];
        }else if(delta < 0){
            [videoTrack setAudioPercent:1];
            [audioTrack setAudioPercent:1];
            [musicTrack setAudioPercent:1 + delta];
        }
        [self prepareForPreview];
        [self seekTo:previewPosBeforeVolumeChanged];
    }
    hasVolumeChanged = NO;
}

- (void)volumeSliderValueChanged:(NMRangeSlider*)sender
{
    int videop=sender.lowerValue*100;
    videoPrecent.text=[NSString stringWithFormat:@"%d%%",videop];
    musicPrecent.text=[NSString stringWithFormat:@"%d%%",100-videop];
    [self pausePreview];
    previewPosBeforeVolumeChanged = [playbackHelper playbackProgress]/1000;
    hasVolumeChanged = YES;
}

- (void)resetPhotoDuration:(float)milsec
{
    NSMutableArray *mediaArray = [self.timeline getTrackFromTimeline:0].mpMediaObjArray;
    for(qxMediaObject *obj in mediaArray){
        if(obj.eType == eMT_Photo){
            [obj setDuration:milsec];
        }
    }
    [self prepareForPreview];
    //photo duration had change, reload frames
    [frameScrollableView reloadFrames];
}

- (void)startRecordTimer
{
    [self stopRecordTimer];
    scrollX = 0;
    recordDuraion = 0;
    recordTimer = [NSTimer scheduledTimerWithTimeInterval:0.05 target:self selector:@selector(recordTimerTask) userInfo:nil repeats:YES];
}

- (void)recordTimerTask
{
    recordDuraion += 0.05;
    if(recordDuraion >= CMTimeGetSeconds(duration)){
        [self stopRecordTimer];
        return;
    }
    CGFloat x = frameViewMark.frame.origin.x;
    if(x < frameScrollableView.frame.size.width*2/3){
        x += 15 * 0.05;
        if(x > frameScrollableView.frame.size.width*2/3){
            scrollX = x - frameScrollableView.frame.size.width*2/3;
            x = frameScrollableView.frame.size.width*2/3;
        }
        frameViewMark.frame = CGRectMake(x, frameViewMark.frame.origin.y, frameViewMark.frame.size.width, frameViewMark.frame.size.height);
        [frameScrollableView updateSelectView:CGRectMake(0, 0, frameViewMark.frame.origin.x, frameScrollableView.frame.size.height)];
    }else{
        scrollX += 15 * 0.05;
    }
    if(scrollX > 0){
        [frameScrollableView scrollTo:CGPointMake(scrollX, 0)];
        [frameScrollableView updateSelectView:CGRectMake(0, 0, frameViewMark.frame.origin.x + scrollX, frameScrollableView.frame.size.height)];
    }
}

- (void)stopRecordTimer
{
    if(recordTimer && [recordTimer isValid]){
        [recordTimer invalidate];
    }
    recordTimer = nil;
}

- (void)updateRecordingView
{
    NSMutableArray *audioObjArray = [self.timeline getTrackFromTimeline:2].mpMediaObjArray;
    if(audioObjArray && audioObjArray.count > 0){
        record.hidden = YES;
        deleteRecording.hidden = NO;
        frameViewMark.hidden = YES;
    }else{
        record.hidden = NO;
        deleteRecording.hidden = YES;
        frameViewMark.hidden = NO;
        frameViewMark.frame = CGRectMake(0, 0, frameViewMark.frame.size.width, frameViewMark.frame.size.height);
        [frameScrollableView updateSelectView:CGRectMake(0, 0, 0, 0)];
    }
}

-(BOOL)addAudio:(qxMediaObject*)audioObj WithTrack:(qxTrack*)track
{
    if(audioObj && track && audioObj.eType == eMT_Audio && track.eType == eMT_Audio){
        CMTime temp = audioObj.actualTimeRange.duration;
        double audioDuration = (double)temp.value/temp.timescale;
        double videoDuration = (double)duration.value/duration.timescale;
        
        if(audioDuration > videoDuration){
            long leftTrim = round((double)audioObj.actualTimeRange.start.value/audioObj.actualTimeRange.start.timescale);
            long rightTrim = round((double)audioObj.mediaOriginalDuration.value/audioObj.mediaOriginalDuration.timescale -  videoDuration - leftTrim);
            [audioObj setTrim:leftTrim*1000  withRight:rightTrim * 1000];
        }
        if([track addMediaObject:audioObj]){
            return YES;
        }
    }
    return NO;
}

#pragma mark - Export
- (void) showExportView
{
    if(!exportView){
        exportView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 280, 180)];
        exportView.center = CGPointMake(self.view.frame.size.width/2, self.view.frame.size.height/2);
        exportView.layer.cornerRadius = 5;
        exportView.backgroundColor = [UIColor whiteColor];
        [self.view addSubview:exportView];
        //title
        UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(0, 15, exportView.frame.size.width, 30)];
        title.textColor = [UIColor blackColor];
        title.textAlignment = NSTextAlignmentCenter;
        title.font = [UIFont systemFontOfSize:20];
        title.text = NSLocalizedString(@"Exporting", nil);
        [exportView addSubview:title];
        //slider
        exportSlider = [[NMRangeSlider alloc] initWithFrame:CGRectMake(10, (exportView.frame.size.height - 10)/2 - 5, exportView.frame.size.width - 20, 10)];
        exportSlider.upperHandleHidden = YES;
        exportSlider.trackEnable = NO;
        exportSlider.minimumValue = 0;
        exportSlider.maximumValue = 1;
        //
        UIImage *img = [UIImage imageNamed:@"slider_track_bg.png"];
        img = [img resizableImageWithCapInsets:UIEdgeInsetsMake(0.0, 5.0, 0.0, 5.0)];
        exportSlider.trackBackgroundImage = img;
        img = [UIImage imageNamed:@"slider_track.png"];
        img = [img resizableImageWithCapInsets:UIEdgeInsetsMake(0.0, 5.0, 0.0, 5.0)];
        exportSlider.trackImage = img;
        //
        img = [UIImage imageNamed:@"slider_handle"];
        [img resizableImageWithCapInsets:UIEdgeInsetsMake(1,1,1,1)];
        exportSlider.lowerHandleImageNormal = img;
        exportSlider.lowerHandleImageHighlighted = img;
        [exportView addSubview:exportSlider];
        //button
        UIButton *stopExport = [[UIButton alloc] initWithFrame:CGRectMake((exportView.frame.size.width - 120)/2, exportView.frame.size.height - 15 - 40, 120, 40)];
        [stopExport setTitle:NSLocalizedString(@"Stop Export", nil) forState:UIControlStateNormal];
        [stopExport setTitleColor:[UIColor colorWithRed:221/255.0 green:107/255.0 blue:111/255.0 alpha:1.0] forState:UIControlStateNormal];
        [stopExport setTitleColor:[UIColor grayColor] forState:UIControlStateHighlighted];
        [stopExport addTarget:self action:@selector(stopExportAction:) forControlEvents:UIControlEventTouchUpInside];
        stopExport.layer.borderWidth = 1;
        stopExport.layer.borderColor = [[UIColor colorWithRed:221/255.0 green:107/255.0 blue:111/255.0 alpha:1.0] CGColor];
        stopExport.layer.cornerRadius = 5;
        [exportView addSubview:stopExport];
    }
    exportSlider.lowerValue = 0;
    exportView.hidden = NO;
    self.exporting = YES;
}

- (void)hideExportView
{
    if(exportView){
        exportView.hidden = YES;
    }
    self.exporting = NO;
}

- (void)startExport
{
    [self pausePreview];
    [self showExportView];
    CGSize size = CGSizeMake(1280, 720);
    int quality = 2;
    if([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0){
        size = CGSizeMake(1920, 1080);
        quality = 1;
    }
    exportHelper = [[qxExportHelper alloc] init];
    exportHelper.mpTimeline = [self.timeline clone:NO];
    qxTrack *videoTrack = [exportHelper.mpTimeline getTrackFromTimeline:0];
    for (qxMediaObject * px in videoTrack.mpMediaObjArray) {
        if (px.eType == eMT_Photo){
            [px makeUsable:size];
        }
    }
    
    //记录事件   判断是否有背景音乐
    qxTrack * musicTrack=[exportHelper.mpTimeline getTrackFromTimeline:1];
    qxTrack * recordTrack=[exportHelper.mpTimeline getTrackFromTimeline:2];
    qxTrack * fontTrack=[exportHelper.mpTimeline getTrackFromTimeline:3];
    if(musicTrack.mpMediaObjArray.count>0){
        [MobClick event: OUTPUT_MUSIC_USED];
    }
    //判断是否有录音
    if(recordTrack.mpMediaObjArray.count>0){
        [MobClick event: OUTPUT_VOICE_USED];
    }
    //判断是否有字幕
    if(fontTrack.mpMediaObjArray.count>0){
        [MobClick event: OUTPUT_SUBTITLE_USED];
    }
    //判断是否仅有视频
    if(musicTrack.mpMediaObjArray.count==0&&recordTrack.mpMediaObjArray.count==0&&fontTrack.mpMediaObjArray.count==0){
        [MobClick event:OUTPUT_ONE_VIDEO_EDIT];
    }
    long long timeLen=duration.value%duration.timescale==0?duration.value/duration.timescale:duration.value/duration.timescale+1;
    if (timeLen<10) {
        [MobClick event:OUTPUT_DURATION_UNDER_10S];
    }else if(timeLen<30){
        [MobClick event: OUTPUT_DURATION_10S_30S];
    }else if(timeLen<60){
        [MobClick event: OUTPUT_DURATION_30S_60S];
    }else if(timeLen<300){
        [MobClick event: OUTPUT_DURATION_60S_5MIN];
    }else{
        [MobClick event: OUTPUT_DURATION_5MIN_BEYOND];
    }
    
    exportHelper.mpTimeline.timelineSize = size;
    exportHelper.strOutput = [NSTemporaryDirectory() stringByAppendingPathComponent:@"exportVideo.mp4"];
    exportHelper.delegate = self;
    [exportHelper doSave:quality];
}

- (void)stopExportAction:(id)sender
{
    if (isStopExport) {
        isStopExport=NO;
        [exportHelper cancelSave];
    }else{//启动计时器
        isStopExport=YES;
        [self.view makeToast:NSLocalizedString(@"Stop Export Hint", nil)];
        if(stopExportTimer!=nil){
            [stopExportTimer invalidate];
        }
        stopExportTimer=[NSTimer scheduledTimerWithTimeInterval:STOP_INTERVAL target:self selector:@selector(calStopTimer) userInfo:nil repeats:NO];
    }
}

-(void) calStopTimer
{
    isStopExport=NO;
}

#pragma mark - qxExportDelegate
- (void)exportProgress:(float)fPercent
{
    exportSlider.lowerValue = fPercent;
}

- (void)exportStatus:(int)exportStatus
{
    if(exportStatus == 0){//fail
        [self showExportErrorAlert];
    }else if(exportStatus == 1){//success
        __weak PlayerViewController *weakSelf = self;
        ALAssetsLibrary *library = [Util defaultAssetsLibrary];
        __weak ALAssetsLibrary *weakLibrary = library;
        [Util saveVideo:[NSURL URLWithString:exportHelper.strOutput] toAlbum:VideoShowAlbum completionBlock:^(NSURL *videoUrl){
            [Util deleteFile:exportHelper.strOutput];
            [weakSelf hideExportView];
            [weakLibrary assetForURL:videoUrl resultBlock:^(ALAsset *asset){
                [MobClick event: EXPORT_VIDEO_SUCCESS];
                VideoShareViewController *shareViewController = [[VideoShareViewController alloc] init];
                shareViewController.asset = asset;
                [weakSelf.navigationController pushViewController:shareViewController animated:YES];
            } failureBlock:^(NSError *error){
                [MobClick event: EXPORT_VIDEO_ERROR];
                [weakSelf showExportErrorAlert];
            }];
        } failureBlock:^(NSError *error){
            [Util deleteFile:exportHelper.strOutput];
            [weakSelf hideExportView];
            [weakSelf showExportErrorAlert];
        }];
    }else if(exportStatus == 2){//export break
        [self hideExportView];
    }
}

- (void)showExportErrorAlert
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:NSLocalizedString(@"Export Failed", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil];
    [alertView show];
}

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if([keyPath isEqualToString:@"exporting"]){
        if ([(NSNumber*)change[NSKeyValueChangeNewKey] boolValue]) {
            leftBtnView.userInteractionEnabled = NO;
            exportBtn.userInteractionEnabled = NO;
            previewSlider.trackEnable = NO;
            addMediaBtn.enabled = NO;
            setMediaDurationBtn.enabled = NO;
            addSubtitleBtn.enabled = NO;
            addMusicBtn.enabled = NO;
            recordAudioBtn.enabled = NO;
        }else{
            leftBtnView.userInteractionEnabled = YES;
            exportBtn.userInteractionEnabled = YES;
            previewSlider.trackEnable = YES;
            addMediaBtn.enabled = YES;
            setMediaDurationBtn.enabled = YES;
            addSubtitleBtn.enabled = YES;
            addMusicBtn.enabled = YES;
            recordAudioBtn.enabled = YES;
        }
    }
}

#pragma mark - FrameViewDelegate
- (void)scrollToSecond:(float)second
{
    [self seekTo:second];
}
@end
