//
//  VideoClipViewController.m
//  VideoShow
//
//  Created by Jerry Chen  on 14-7-30.
//  Copyright (c) 2014年 energy. All rights reserved.
//

#import "VideoClipViewController.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import "Util.h"


@implementation VideoClipViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self initView];
    videoActualRange = self.videoObject.actualTimeRange;
    [self setMediaBegin:0 End:CMTimeGetSeconds(self.videoObject.mediaOriginalDuration)];
    [self prepareForPreview];
    playing = NO;
}

- (void)initView
{
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    //video view
    videoView = [[UIView alloc] initWithFrame:CGRectMake(0, 20, screenRect.size.width, screenRect.size.height - 115 - 20)];
    videoView.backgroundColor = [UIColor blackColor];
    UITapGestureRecognizer *playbackViewTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(playbackViewTap:)];
    [videoView addGestureRecognizer:playbackViewTapGesture];
    
    //bg
    UIView *bgView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    UIImage *bgImg = [UIImage imageNamed:@"bg_video_view.png"];
    bgView.backgroundColor = [UIColor colorWithPatternImage:bgImg];
    [bgView addSubview:videoView];
    [self.view addSubview:bgView];
    
    //play control
    playBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 55, 55)];
    playBtn.center = CGPointMake(videoView.frame.size.width/2.0, videoView.frame.size.height/2.0);
    [playBtn setBackgroundImage:[UIImage imageNamed:@"play_transparent.png"] forState:UIControlStateNormal];
    [playBtn addTarget:self action:@selector(playAction:) forControlEvents:UIControlEventTouchUpInside];
    [videoView addSubview:playBtn];
    
    //-----------------------------------------------
    //bottom view
    float delta = 20;
    if([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0){
        delta = 0;
    }
    UIView *bottomView = [[UIView alloc] initWithFrame:CGRectMake(0, screenRect.size.height - 115 - delta, screenRect.size.width, 115)];
    bottomView.backgroundColor = [UIColor colorWithRed:34/255.0 green:30/255.0 blue:30/255.0 alpha:1.0];
    [self.view addSubview:bottomView];
    //bottom title
    UIView *videoClipTitleView = [[UIView alloc] initWithFrame:CGRectMake(0,bottomView.frame.size.height-34,bottomView.frame.size.width,34)];
    videoClipTitleView.backgroundColor = [UIColor colorWithRed:21/255.0 green:19/255.0 blue:19/255.0 alpha:1.0];
    //
    UIButton *cancelVideoClip = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 34, 34)];
//    [cancelVideoClip setImageEdgeInsets:UIEdgeInsetsMake(11, 19, 11, 19)];
    [cancelVideoClip setImage:[UIImage imageNamed:@"photo_duration_cancel.png"] forState:UIControlStateNormal];
    [cancelVideoClip addTarget:self action:@selector(cancelVideoClipAction:) forControlEvents:UIControlEventTouchUpInside];
    [videoClipTitleView addSubview:cancelVideoClip];
    //
    UIButton *confirmVideoClip = [[UIButton alloc] initWithFrame:CGRectMake(videoClipTitleView.frame.size.width - 34, 0, 34, 34)];
//    [confirmVideoClip setImageEdgeInsets:UIEdgeInsetsMake(11, 19, 11, 19)];
    [confirmVideoClip setImage:[UIImage imageNamed:@"photo_duration_confirm.png"] forState:UIControlStateNormal];
    [confirmVideoClip addTarget:self action:@selector(confirmVideoClipAction:) forControlEvents:UIControlEventTouchUpInside];
    [videoClipTitleView addSubview:confirmVideoClip];
    //
    UILabel *videoClipTitle = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 50, 34)];
    videoClipTitle.backgroundColor = [UIColor clearColor];
    videoClipTitle.text = NSLocalizedString(@"Video Clip", nil);
    videoClipTitle.textColor = [UIColor whiteColor];
    videoClipTitle.textAlignment = NSTextAlignmentCenter;
    videoClipTitle.center = CGPointMake(videoClipTitleView.frame.size.width/2, videoClipTitleView.frame.size.height/2);
    [videoClipTitleView addSubview:videoClipTitle];
    [bottomView addSubview:videoClipTitleView];
    
    //video range slider
    videoRnageSlider = [[SAVideoRangeSlider alloc] initWithFrame:CGRectMake(10, 30, bottomView.frame.size.width - 20, 51) videoUrl:[NSURL URLWithString:self.videoObject.strFilePath]];
    videoRnageSlider.delegate = self;
    [bottomView addSubview:videoRnageSlider];
    float start = CMTimeGetSeconds(self.videoObject.actualTimeRange.start);
    float actualDuration = CMTimeGetSeconds(self.videoObject.actualTimeRange.duration);
    [videoRnageSlider setLeft:start right:(start + actualDuration)];
    
    //start time label
    leftTimeLabel = [[UILabel alloc] initWithFrame:CGRectMake(5, 0, 90, 30)];
    leftTimeLabel.backgroundColor = [UIColor clearColor];
    leftTimeLabel.font = [UIFont systemFontOfSize:14];
    leftTimeLabel.textColor  = [UIColor whiteColor];
    [bottomView addSubview:leftTimeLabel];
    
    //end time label
    rightTimeLabel = [[UILabel alloc] initWithFrame:CGRectMake(bottomView.frame.size.width - 90 - 5, 0, 90, 30)];
    rightTimeLabel.backgroundColor = [UIColor clearColor];
    rightTimeLabel.font = [UIFont systemFontOfSize:14];
    rightTimeLabel.textColor = [UIColor whiteColor];
    rightTimeLabel.textAlignment = NSTextAlignmentRight;
    [bottomView addSubview:rightTimeLabel];
    
    [self updateTimeLabelValue];
}

- (void)updateTimeLabelValue
{
    leftTimeLabel.text = [Util stringWithSeconds:round(videoRnageSlider.leftPosition)];
    rightTimeLabel.text = [Util stringWithSeconds:round(videoRnageSlider.rightPosition)];
}

- (void)cancelVideoClipAction:(id)sender
{
    long end = CMTimeGetSeconds(videoActualRange.start) + CMTimeGetSeconds(videoActualRange.duration);
    [self setMediaBegin:CMTimeGetSeconds(videoActualRange.start) End:end];
    [self stopPreview];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)confirmVideoClipAction:(id)sender
{
    [self stopPreview];
    if([self.delegate respondsToSelector:@selector(videoClipDone)]){
        [self.delegate videoClipDone];
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)playAction:(id)sender
{
    [self startPreview];
}

- (void)playbackViewTap:(id)sender
{
    if(playing){
        [self pausePreview];
    }else{
        [self startPreview];
    }
}

- (void)startPreview
{
    playing = YES;
    playBtn.hidden = YES;
    [playbackHelper playPause:YES];
}

- (void)pausePreview
{
    playing = NO;
    playBtn.hidden = NO;
    [playbackHelper playPause:NO];
}

- (void) stopPreview
{
    playing = NO;
    if(playbackHelper){
        [playbackHelper stop];
        playbackHelper.delegate = nil;
        [playbackHelper destroy];
    }
}

#pragma mark - qxPlaybackDelegate
- (void)readyForPlayback
{

}

- (void)FinishPlayback
{
    [self pausePreview];
    [self seekTo:0];
}

-(void)prepareForPreview
{
    [self stopPreview];
    //
    timeline = [[qxTimeline alloc] init];
    qxTrack *track = [[qxTrack alloc] initWithTrackType:eMT_Video];
    [track addMediaObject:self.videoObject];
    [timeline addTrack:track];
    
    playbackHelper = [[qxPlaybackHelper alloc] init];
    int timelineStatus = [timeline getTimelineSizeStatus];
    if([UIScreen mainScreen].bounds.size.height >= 568){
        if(timelineStatus == 1){//horizontal
            timeline.timelineSize = CGSizeMake(1136, 640);
        }else if(timelineStatus == 2){//vertical
            timeline.timelineSize = CGSizeMake(640, 1136);
        }else{
            timeline.timelineSize = CGSizeMake(640, 640);
        }
    }else{
        if(timelineStatus == 1){//horizontal
            timeline.timelineSize = CGSizeMake(640, 360);
        }else if(timelineStatus == 2){//vertical
            timeline.timelineSize = CGSizeMake(360, 640);
        }else{
            timeline.timelineSize = CGSizeMake(360, 360);
        }
    }
    //
    float videoWidth = 320;
    float videoHeight = timeline.timelineSize.height * videoWidth / timeline.timelineSize.width;
    if(videoHeight > self.view.frame.size.height){
        videoHeight = self.view.frame.size.height;
        videoWidth = timeline.timelineSize.width * videoHeight / timeline.timelineSize.height;
    }
    videoView.frame = CGRectMake((self.view.frame.size.width - videoWidth)/2, (self.view.frame.size.height - videoHeight)/2, videoWidth, videoHeight);
    playBtn.center = CGPointMake(videoView.frame.size.width/2.0, videoView.frame.size.height/2.0);
    //
    playbackHelper.mpTimeline = timeline;
    [playbackHelper initWithUIView:videoView];
    playbackHelper.delegate = self;
    for (UIView * pv in videoView.subviews) {
        if (![pv isKindOfClass:NSClassFromString(@"qxPlaybackView")]){
            [videoView bringSubviewToFront:pv];
        }
    }
    duration = playbackHelper.playerItem.duration;
}

- (void)seekTo:(float)second
{
    [playbackHelper.player seekToTime:CMTimeMakeWithSeconds(second, duration.timescale) toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero];
}

/*
 begin : second
 end   : second
 */
-(void)setMediaBegin:(long)begin End:(long)end
{
    end = (long)(CMTimeGetSeconds(self.videoObject.mediaOriginalDuration) - end);
    [self.videoObject setTrim:begin*1000 withRight:end*1000];
}

#pragma mark - SAVideoRangeSliderDelegate
- (void)videoRange:(SAVideoRangeSlider *)videoRange didChangeLeftPosition:(CGFloat)leftPosition rightPosition:(CGFloat)rightPosition
{
    CGFloat currentLowerValue = leftPosition;
    CGFloat currentUpperValue = rightPosition;
    if(playing){
        [self pausePreview];
    }
    if(currentLowerValue != lastLeftPosition){
        lastLeftPosition = currentLowerValue;
        [self seekTo:leftPosition];
    }else if(currentUpperValue != lastRightPosition){
        lastRightPosition = currentUpperValue;
        [self seekTo:rightPosition];
    }
    [self updateTimeLabelValue];
}

- (void)videoRange:(SAVideoRangeSlider *)videoRange didGestureStateEndedLeftPosition:(CGFloat)leftPosition rightPosition:(CGFloat)rightPosition
{
    [self setMediaBegin:leftPosition End:rightPosition];
    [self prepareForPreview];
}
@end
