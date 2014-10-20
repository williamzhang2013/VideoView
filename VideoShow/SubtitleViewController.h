//
//  SubtitleViewController.h
//  VideoShow
//
//  Created by Jerry Chen  on 14-8-8.
//  Copyright (c) 2014年 energy. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "qxTimeline.h"
#import "qxPlaybackHelper.h"
#import "MediaFrameView.h"
#import "SubtitleTextView.h"
#import "ColorSelectorView.h"
#import "FontSelectorView.h"
#import "SubtitlePositionView.h"
#import "CustomAlertView.h"

@class MyLabel;
@class SubtitleTextView;

@protocol SubtitleViewControllerDelegate <NSObject>

- (void)subtitleEditDone;

@end

//
@interface SubtitleViewController : UIViewController<UITextViewDelegate,CustomAlertViewDelegate,qxPlaybackDelegate,MediaFrameViewDelegate,SubtitleTextViewDelegate,ColorSelectorViewDelegate,FontSelectorViewDelegate,SubtitlePositionViewDelegate>
{
    UIButton *controlBtn;
    UIView *controlView;
    UITextView *subtitleEditTextView;
    CustomAlertView *subtitleEditAlertView;
    CMTime duration;
    UIView *videoView;
    UIButton *btnPlayStatus;
    UIImageView *pauseView;
    MyLabel *currentLabel;
    MyLabel *totalLabel;
    qxPlaybackHelper *playbackHelper;
    NSTimer *previewControlTimer;
    SubtitlePositionView *subtitlePositionView;
    SubtitleTextView *subtitleTextView;
    UIButton *deleteSubtitle;
    UIButton *addSubtitle;
    ColorSelectorView *colorSelector;
    FontSelectorView *fontSelector;
    qxMediaObject *currentOverlayObj;
    Float64 currentPosOnTrack;// time in second
    MediaFrameView *frameView;
    NSMutableArray *newSubtitles;// subtitles added newest
    BOOL needRefreshVideoBeforePreview;
}


//0 : video track,  1 : music track,  2 : audio track,  3 : overlay track
@property (strong,nonatomic) qxTimeline *timeline;
@property (assign,nonatomic) CGRect videoViewRect;
@property (weak,nonatomic) id<SubtitleViewControllerDelegate> delegate;
@property (assign,nonatomic) BOOL playing;
@property (assign,nonatomic) BOOL framesLoadFinished;


@end