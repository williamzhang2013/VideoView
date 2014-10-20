//
//  VideoClipViewController.h
//  VideoShow
//
//  Created by Jerry Chen  on 14-7-30.
//  Copyright (c) 2014年 energy. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "qxMediaObject.h"
#import "qxTimeline.h"
#import "qxPlaybackHelper.h"
#import "SAVideoRangeSlider.h"

@protocol VideoClipViewControllerDelegate <NSObject>
- (void)videoClipDone;
- (void)videoClipCancel;
@end

@class ALAssetsLibrary;
@interface VideoClipViewController : UIViewController<qxPlaybackDelegate,SAVideoRangeSliderDelegate>
{
    CGFloat lastLeftPosition;
    CGFloat lastRightPosition;
    BOOL playing;
    CMTime duration;
    UIView *videoView;
    UIButton *playBtn;
    UILabel *leftTimeLabel;
    UILabel *rightTimeLabel;
    SAVideoRangeSlider *videoRnageSlider;
    CMTimeRange videoActualRange;
    qxTimeline *timeline;
    qxPlaybackHelper *playbackHelper;

}

@property (weak,nonatomic) id<VideoClipViewControllerDelegate> delegate;
@property (strong,nonatomic) qxMediaObject *videoObject;

@end
