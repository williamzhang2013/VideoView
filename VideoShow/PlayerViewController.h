//
//  PlayerViewController.h
//  VideoShow
//
//  Created by Jerry Chen  on 14-7-24.
//  Copyright (c) 2014年 energy. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "qxTimeline.h"
#import "ToolBarView.h"
#import "qxPlaybackHelper.h"
#import "qxExportHelper.h"
#import "VideoClipViewController.h"
#import "MusicPickerViewController.h"
#import "SubtitleViewController.h"
#import "FrameView.h"

typedef NS_ENUM(NSInteger, ViewStatus){
    ViewStatusPreview,
    ViewStatusPhotoDurationSetting,
    ViewStatusVideoClip,
    ViewStatusRecordAudio,
    ViewStatusAddMusic
};

@class MyLabel;
@class NMRangeSlider;
@interface PlayerViewController : UIViewController<UIAlertViewDelegate,UIAlertViewDelegate,qxPlaybackDelegate,qxExportDelegate,VideoClipViewControllerDelegate,MusicPickerViewControllerDelegate,SubtitleViewControllerDelegate,FrameViewDelegate>
{
    UIAlertView *backAlert;
    UIButton *addMediaBtn;
    UIButton *setMediaDurationBtn;
    UIButton *addSubtitleBtn;
    UIButton *addMusicBtn;
    UIButton *recordAudioBtn;
    //
    UIView *exportView;
    UIView *leftBtnView;
    UIButton *exportBtn;
    UIView *videoView;
    qxPlaybackHelper *playbackHelper;
    qxExportHelper *exportHelper;
    CMTime duration;//视频时长
    NMRangeSlider *previewSlider;
    NMRangeSlider *photoDurationSlider;
    NMRangeSlider *exportSlider;
    MyLabel *currentProgressLabel;
    MyLabel *totalProgressLabel;
    MyLabel *musicSettingCurrentProgressLabel;
    MyLabel *musicSettingTotalProgressLabel;
    MyLabel *addRecordingCurrentProgressLabel;
    MyLabel *addRecordingTotalProgressLabel;
    UILabel *photoDurationValue;
    UIView *bottomToolBar;
    UIView *photoDurationSettingView;
    UIView *musicSettingView;
    UIView *recordView;
    FrameView *frameScrollableView;
    UIButton *playBtn;
    NSTimer *playControlTimer;
    qxMediaObject *currentMediaObject;
    NSString *recordCache;
    AVAudioRecorder *audioRecorder;
    UIView *frameViewMark;
    UIView *frameView;
    NSTimer *recordTimer;
    UIButton *record;
    UIButton *deleteRecording;
    CGFloat scrollX;
    CGFloat recordDuraion;
    
    CGRect screenRect;
    ViewStatus status;
    float photoLastDuration;
    BOOL hasVolumeChanged;
    Float64 previewPosBeforeVolumeChanged;
    float videoTrackVolumePercent;
    float musicTrackVolumePercent;
    BOOL prepareForRecordAudio;
    BOOL recordAudioChanged;
}

@property (nonatomic,assign) BOOL exporting;
@property (nonatomic,assign) BOOL playing;
@property (strong, nonatomic) ToolBarView *toolbarView;
//0 : video track,  1 : music track,  2 : audio track,  3 : overlay track
@property (strong, nonatomic) qxTimeline  *timeline;



@end
