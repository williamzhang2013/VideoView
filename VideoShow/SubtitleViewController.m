//
//  SubtitleViewController.m
//  VideoShow
//
//  Created by Jerry Chen  on 14-8-8.
//  Copyright (c) 2014年 energy. All rights reserved.
//

#import "SubtitleViewController.h"
#import "MyLabel.h"
#import "SVProgressHUD.h"
#import "Util.h"
#import "SubtitleTextView.h"

#define MAX_NUM_SUBTITLE_CHARACTERS  150


@implementation SubtitleViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self addObserver:self forKeyPath:@"framesLoadFinished" options:NSKeyValueObservingOptionNew context:NULL];
    
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
    [self initView];
    [self updateMerge];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(screenTouchNotification:) name:@"ScreenTouchNotification" object:nil];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self stopPreview];
    [self removeObserver:self forKeyPath:@"framesLoadFinished"];
}

- (BOOL)shouldAutorotate
{
    return NO;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
    return UIInterfaceOrientationPortrait;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"ScreenTouchNotification" object:nil];
}

- (void)initView
{
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGRect viewRect = self.view.frame;
    
    //bottom view
    UIView *bottomControlView = [[UIView alloc] initWithFrame:CGRectMake(0, 30, viewRect.size.width, 144)];
    bottomControlView.backgroundColor=[UIColor colorWithRed:34/255.0 green:30/255.0 blue:30/255.0 alpha:1.0];
    //
    UIView *bottomTitleView = [[UIView alloc] initWithFrame:CGRectMake(0, bottomControlView.frame.size.height - 34, viewRect.size.width, 34)];
    bottomTitleView.backgroundColor = [UIColor colorWithRed:21/255.0 green:19/255.0 blue:19/255.0 alpha:1.0];

    [bottomControlView addSubview:bottomTitleView];
    int btnSize=34;
    int btnMargin=10;
    //cancel
    UIButton *cancelSubtitleSetting = [[UIButton alloc] initWithFrame:CGRectMake(btnMargin,0, btnSize,btnSize)];
    [cancelSubtitleSetting setImageEdgeInsets:UIEdgeInsetsMake(0,0,0,0)];
    [cancelSubtitleSetting setImage:[UIImage imageNamed:@"photo_duration_cancel.png"] forState:UIControlStateNormal];
    [cancelSubtitleSetting setImage:[UIImage imageNamed:@"photo_duration_cancel_selected.png"] forState:UIControlStateHighlighted];
    [cancelSubtitleSetting addTarget:self action:@selector(cancelSubtitleSettingAction:) forControlEvents:UIControlEventTouchUpInside];
    [bottomTitleView addSubview:cancelSubtitleSetting];
    //confirm
    UIButton *confirmSubtitleSetting = [[UIButton alloc] initWithFrame:CGRectMake(bottomTitleView.frame.size.width - btnMargin - btnSize,0, btnSize,btnSize)];
    [confirmSubtitleSetting setImageEdgeInsets:UIEdgeInsetsMake(0,0,0,0)];
    [confirmSubtitleSetting setImage:[UIImage imageNamed:@"photo_duration_confirm.png"] forState:UIControlStateNormal];
    [confirmSubtitleSetting setImage:[UIImage imageNamed:@"photo_duration_confirm_selected.png"] forState:UIControlStateHighlighted];
    [confirmSubtitleSetting addTarget:self action:@selector(confirmSubtitleSettingAction:) forControlEvents:UIControlEventTouchUpInside];
    [bottomTitleView addSubview:confirmSubtitleSetting];
    //title
    UILabel *subtitleSettingLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 250, bottomTitleView.frame.size.height)];
    subtitleSettingLabel.center = CGPointMake(bottomTitleView.frame.size.width/2, bottomTitleView.frame.size.height/2);
    subtitleSettingLabel.textAlignment = NSTextAlignmentCenter;
    subtitleSettingLabel.backgroundColor = [UIColor clearColor];
    subtitleSettingLabel.textColor = [UIColor whiteColor];
    subtitleSettingLabel.font = [UIFont systemFontOfSize:17];
    subtitleSettingLabel.text = NSLocalizedString(@"Setting Subtitle", nil);
    //[subtitleSettingLabel sizeToFit];
    [bottomTitleView addSubview:subtitleSettingLabel];
    
    //middle view
    UIView *middleView = [[UIView alloc] initWithFrame:CGRectMake(0, 65, bottomControlView.frame.size.width, 45)];
    middleView.backgroundColor = [UIColor clearColor];
    [bottomControlView addSubview:middleView];
    
    //add subtitle
    addSubtitle = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 21, 27)];
    addSubtitle.center = CGPointMake(middleView.frame.size.width/2, middleView.frame.size.height/2);
    [addSubtitle setImage:[UIImage imageNamed:@"add_subtitle.png"] forState:UIControlStateNormal];
    [addSubtitle addTarget:self action:@selector(addSubtitleAction:) forControlEvents:UIControlEventTouchUpInside];
    [middleView addSubview:addSubtitle];
    //delete subtitle
    deleteSubtitle = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 25.5, 27)];
    deleteSubtitle.center = addSubtitle.center;
    [deleteSubtitle setImage:[UIImage imageNamed:@"music_delete.png"] forState:UIControlStateNormal];
    [deleteSubtitle addTarget:self action:@selector(deleteSubtitleAction:) forControlEvents:UIControlEventTouchUpInside];
    deleteSubtitle.hidden = YES;
    [middleView addSubview:deleteSubtitle];
    //frame view
    self.framesLoadFinished = NO;
    frameView = [[MediaFrameView alloc] initWithMedias:self.timeline frame:CGRectMake(0, 20, self.view.frame.size.width, 45)];
    frameView.delegate = self;
    frameView.contentSize = CGSizeMake(self.view.frame.size.width, 45);
    frameView.backgroundColor = [UIColor grayColor];
    [bottomControlView addSubview:frameView];
    
    //current progress label
    currentLabel = [[MyLabel alloc] initWithFrame:CGRectMake(3, 0, 90, 20)];
    currentLabel.font = [UIFont systemFontOfSize:13];
    currentLabel.textAlignment = NSTextAlignmentLeft;
    currentLabel.drawOutline = YES;
    currentLabel.outlineColor = [UIColor blackColor];
    currentLabel.textColor = [UIColor whiteColor];
    [bottomControlView addSubview:currentLabel];
    //total progress label
    totalLabel = [[MyLabel alloc] initWithFrame:CGRectMake(bottomControlView.frame.size.width - 93, 0, 90, 20)];
    totalLabel.font = [UIFont systemFontOfSize:13];
    totalLabel.textAlignment = NSTextAlignmentRight;
    totalLabel.drawOutline = YES;
    totalLabel.outlineColor = [UIColor blackColor];
    totalLabel.textColor = [UIColor whiteColor];
    [bottomControlView addSubview:totalLabel];
    
    //playback view
    videoView = [[UIView alloc] initWithFrame:self.videoViewRect];
    videoView.backgroundColor = [UIColor blackColor];
    
    //play view
    btnPlayStatus = [[UIButton alloc] initWithFrame:CGRectMake(5, 0, 30, 30)];
    [btnPlayStatus setImage:[UIImage imageNamed:@"play_transparent.png"] forState:UIControlStateSelected];
    [btnPlayStatus setImage:[UIImage imageNamed:@"pause.png"] forState:UIControlStateNormal];
    [btnPlayStatus addTarget:self action:@selector(playViewAction:) forControlEvents:UIControlEventTouchUpInside];
    
    //
    controlBtn = [[UIButton alloc] initWithFrame:CGRectMake(self.view.frame.size.width - 40, 5, 35, 25)];
    [controlBtn setImage:[UIImage imageNamed:@"arrow_down.png"] forState:UIControlStateNormal];
    [controlBtn addTarget:self action:@selector(showOrHideControlView:) forControlEvents:UIControlEventTouchUpInside];
    
    //contorl view
    controlView = [[UIView alloc] initWithFrame:CGRectMake(0, viewRect.size.height - btnPlayStatus.frame.size.height - bottomControlView.frame.size.height, self.view.frame.size.width, btnPlayStatus.frame.size.height + bottomControlView.frame.size.height)];
    controlView.backgroundColor = [UIColor clearColor];
    [controlView addSubview:controlBtn];
    [controlView addSubview:bottomControlView];
    [controlView addSubview:btnPlayStatus];
    [self.view addSubview:controlView];
    
    //bg
    UIView *bgView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    UIImage *bgImg = [UIImage imageNamed:@"bg_video_view.png"];
    bgView.backgroundColor = [UIColor colorWithPatternImage:bgImg];
    [bgView addSubview:videoView];
    [self.view addSubview:bgView];
    
    //subtitle textview
    subtitleTextView = [[SubtitleTextView alloc] initWithFrame:CGRectMake((self.view.frame.size.width - 200)/2, 155, 200, 100)];
    subtitleTextView.delegate = self;
    [videoView addSubview:subtitleTextView];
    UIPanGestureRecognizer *subtitlePanGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handleSubtitlePanGestureRecognizer:)];
    subtitlePanGestureRecognizer.minimumNumberOfTouches = 1;
    subtitlePanGestureRecognizer.maximumNumberOfTouches = 1;
    [subtitleTextView addGestureRecognizer:subtitlePanGestureRecognizer];
    subtitleTextView.hidden = YES;
    
    //
    [self.view bringSubviewToFront:btnPlayStatus];
    [self.view bringSubviewToFront:bottomControlView];
    
    //color selector
    colorSelector = [[ColorSelectorView alloc] initWithFrame:CGRectMake(10, screenRect.origin.y + 25, screenRect.size.width - 10, 35)];
    colorSelector.delegate = self;
    [self.view addSubview:colorSelector];
    
    //font selector
    fontSelector = [[FontSelectorView alloc] initWithFrame:CGRectMake(10, colorSelector.frame.origin.y + 35 + 20, colorSelector.frame.size.width, 35)];
    fontSelector.delegate = self;
    [self.view addSubview:fontSelector];
    [self.view bringSubviewToFront:controlView];
}

- (void)cancelSubtitleSettingAction:(id)sender
{
    qxTrack *overlayTrack = [self.timeline getTrackFromTimeline:3];
    if(newSubtitles && overlayTrack){
        for(qxMediaObject *obj in newSubtitles){
            if(obj){
                [overlayTrack delMediaObject:[overlayTrack findMediaObject:obj]];
            }
        }
    }
    [newSubtitles removeAllObjects];
    newSubtitles = nil;
    [self stopPreview];
    [playbackHelper destroy];
    playbackHelper = nil;
    if([self.delegate respondsToSelector:@selector(subtitleEditDone)]){
        [self.delegate subtitleEditDone];
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)showOrHideControlView:(id)sender
{
    __block float w = controlView.frame.size.width;
    __block float h = controlView.frame.size.height;
    if(controlView.frame.origin.y < self.view.frame.size.height - 30){//hide
        [UIView animateWithDuration:0.5 animations:^{
            controlView.frame = CGRectMake(0, self.view.frame.size.height - 30, w, h);
            [controlBtn setImage:[UIImage imageNamed:@"arrow_up.png"] forState:UIControlStateNormal];
        }];
    }else{//show
        [UIView animateWithDuration:0.5 animations:^{
            controlView.frame = CGRectMake(0, self.view.frame.size.height - h, w, h);
            [controlBtn setImage:[UIImage imageNamed:@"arrow_down.png"] forState:UIControlStateNormal];
        }];
    }
}

- (void)confirmSubtitleSettingAction:(id)sender
{
    [Util clearPhotoTrack:[self.timeline getTrackFromTimeline:3]];
    [self stopPreview];
    [playbackHelper destroy];
    playbackHelper = nil;
    if([self.delegate respondsToSelector:@selector(subtitleEditDone)]){
        [self.delegate subtitleEditDone];
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)addSubtitleAction:(id)sender
{
    [self pausePreview];
    [self resetSubtitleTextView];
    [subtitleTextView triggerSubtitleViewTapped];
}

- (void)resetSubtitleTextView
{
    [subtitleTextView setTextWithOverlayObj:nil];
    [subtitleTextView setTextFont:@"default"];
    [subtitleTextView resetTextSize];
    [subtitleTextView setTextColor:[UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:1.0]];
    subtitleTextView.frame = CGRectMake((videoView.frame.size.width - 200)/2, (videoView.frame.size.height - 100)/2, 200, 100);
}

- (void)deleteSubtitleAction:(id)sender
{
    [self pausePreview];
    if(currentOverlayObj){
        qxTrack *textTrack = [self.timeline getTrackFromTimeline:3];
        int index = [textTrack findMediaObject:currentOverlayObj];
        if(index >= 0 && index < textTrack.mpMediaObjArray.count){
            [textTrack delMediaObject:index];
            [frameView refreshSubtitleView];
        }
    }
    currentOverlayObj = nil;
    subtitleTextView.hidden = YES;
    deleteSubtitle.hidden = YES;
    addSubtitle.hidden = NO;
    [fontSelector selectFont:nil];
    [colorSelector setSelect:nil];
    needRefreshVideoBeforePreview = NO;
    [self prepareForPreview];
}

- (void)setTextDisplayRect:(qxMediaObject*)textObj
{
    if(textObj && textObj.eType == eMT_Text){
        CGRect subtitleRect = [subtitleTextView subtitleRect];
        CGSize viewSize = videoView.frame.size;
        int status = [self.timeline getTimelineSizeStatus];
        float subtitleY = subtitleRect.origin.y;
        if(status == 1){
            viewSize = CGSizeMake(viewSize.width, viewSize.width/640*360);
            subtitleY -= (videoView.frame.size.height - viewSize.height)/2;
        }else if(status == 0){
            viewSize = CGSizeMake(viewSize.width, viewSize.width);
            subtitleY -= (videoView.frame.size.height - viewSize.height)/2;
        }
        CGRect rect = CGRectMake(subtitleRect.origin.x/viewSize.width, subtitleY/viewSize.height, subtitleRect.size.width/viewSize.width, subtitleRect.size.height/viewSize.height);
        [textObj setDisplayRect:rect];
        [self updateCurrentOverlayWithTextObj:textObj];
        needRefreshVideoBeforePreview = YES;
    }
}

- (CGRect)displayRectOfText:(qxMediaObject*)textObj
{
    CGRect rect = CGRectMake(0, 0, 0, 0);
    if(textObj && textObj.eType == eMT_Text){
        CGSize viewSize = videoView.frame.size;
        int status = [self.timeline getTimelineSizeStatus];
        if(status == 1){
            viewSize = CGSizeMake(videoView.frame.size.width, videoView.frame.size.width/640*360);
        }else if(status == 0){
            viewSize = CGSizeMake(videoView.frame.size.width, videoView.frame.size.width);
        }

        CGRect displayRect = textObj.textDisplayRect;
        rect.origin.x = viewSize.width * displayRect.origin.x;
        rect.origin.y = viewSize.height * displayRect.origin.y;
        rect.origin.y += (videoView.frame.size.height - viewSize.height)/2;
        rect.size.width = viewSize.width * displayRect.size.width;
        rect.size.height = viewSize.height * displayRect.size.height;
        rect = [subtitleTextView calTextViewRectFromSubtitleRect:rect];
    }
    return rect;
}

- (qxMediaObject*)overlayObjFromTextObj:(qxMediaObject*)textObj
{
    qxMediaObject *overlayObj = nil;
    NSString *file = [self imageFromTextObj:textObj];
    if(file){
        overlayObj = [[qxMediaObject alloc] init];
        overlayObj.overlayCustomObj = textObj;
        [Util deleteFile:overlayObj.strFilePath];
        [overlayObj setFilePath:file withType:eMT_Overlay fromAssetLibrary:NO];
        [overlayObj setDisplayRect:textObj.textDisplayRect];
    }
    return overlayObj;
}

- (void)addTextObj:(NSString *)text
{
    if(currentOverlayObj && currentOverlayObj.overlayCustomObj){
        qxTrack *overlayTrack = [self.timeline getTrackFromTimeline:3];
        int index = [overlayTrack findMediaObject:currentOverlayObj];
        if(index >= 0 && index < overlayTrack.mpMediaObjArray.count){
            [overlayTrack delMediaObject:index];
        }
    }
    currentOverlayObj = nil;
    qxMediaObject *textObj = [[qxMediaObject alloc] init];
    [textObj setFilePath:nil withType:eMT_Text fromAssetLibrary:NO];
    textObj.text = text;
    [self setTextDisplayRect:textObj];
    //------------------------------
    UIFont *font = [UIFont systemFontOfSize:17];
    [textObj setTextFont:font.fontName size:font.pointSize];
    UIColor *color = [UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:1.0];
    [textObj setTextColor:color];
    //---------------
    qxMediaObject *nearestOverlayTextObj = [self findNearestSubtitleObjAfterTime:currentPosOnTrack];
    Float64 dur = 0;
    if(nearestOverlayTextObj){
        dur = (CMTimeGetSeconds(nearestOverlayTextObj.startTimeOfTrack) - currentPosOnTrack) > 10 + 0.2 ? 10 : (CMTimeGetSeconds(nearestOverlayTextObj.startTimeOfTrack) - currentPosOnTrack - 0.2);
    }else{
        dur = (CMTimeGetSeconds(duration) - currentPosOnTrack) > 10 ? 10 : (CMTimeGetSeconds(duration) - currentPosOnTrack);
    }
    qxTrack *overlayTrack = [self.timeline getTrackFromTimeline:3];
    qxMediaObject *overlayObj = [self overlayObjFromTextObj:textObj];
    [overlayTrack addMediaObject:overlayObj];
    [overlayTrack updateTimeAtIndex:(int)(overlayTrack.mpMediaObjArray.count - 1) startTime:CMTimeMakeWithSeconds(currentPosOnTrack, duration.timescale) duration:CMTimeMakeWithSeconds(dur, duration.timescale)];
    currentOverlayObj = overlayObj;
    if(!newSubtitles){
        newSubtitles = [[NSMutableArray alloc] init];
    }
    [newSubtitles addObject:overlayObj];
    [frameView refreshSubtitleView];
    [self updateSelectionFont:font Color:color];
}

- (qxMediaObject*)findNearestSubtitleObjAfterTime:(Float64)time
{
    qxMediaObject *obj = nil;
    qxTrack *overlayTrack = [self.timeline getTrackFromTimeline:3];
    if(overlayTrack && overlayTrack.mpMediaObjArray.count > 0){
        NSMutableArray *tmpOverlayArray = [NSMutableArray arrayWithArray:overlayTrack.mpMediaObjArray];
        NSMutableArray *tmpSubtitleArray = [[NSMutableArray alloc] init];
        for(qxMediaObject *overlay in tmpOverlayArray){
            if([self isTextObj:overlay]){
                [tmpSubtitleArray addObject:overlay];
            }
        }
        //sort text object by start time on track
        NSArray *tmp = [tmpSubtitleArray sortedArrayUsingComparator:^(qxMediaObject *obj1, qxMediaObject *obj2){
            NSComparisonResult result = NSOrderedSame;
            Float64 t1 = CMTimeGetSeconds(obj1.startTimeOfTrack);
            Float64 t2 = CMTimeGetSeconds(obj2.startTimeOfTrack);
            if(t1 > t2){
                result = NSOrderedDescending;
            }else if(t1 < t2){
                result = NSOrderedAscending;
            }
            return result;
        }];
        [tmpSubtitleArray removeAllObjects];
        [tmpSubtitleArray addObjectsFromArray:tmp];
        //find text object
        for(qxMediaObject *tmpObj in tmpSubtitleArray){
            Float64 start = CMTimeGetSeconds(tmpObj.startTimeOfTrack);
            if(start > time){
                 obj = tmpObj;
                break;
            }
        }
    }
    return obj;
}

- (void)updateSelectionFont:(UIFont*)font Color:(UIColor*)color
{
    if(currentOverlayObj && currentOverlayObj.overlayCustomObj){
        [colorSelector setSelect:color];
        [fontSelector selectFont:font];
    }else{
        [colorSelector setSelect:nil];
        [fontSelector selectFont:nil];
    }
}

- (void)playViewAction:(UIButton*)button
{
    if(!self.playing){
        if(needRefreshVideoBeforePreview){
            [self prepareForPreview];
        }else{
            [self startPreview];
        }
    }else{
        [self pausePreview];
    }
}

- (void)playbackViewTap:(UITapGestureRecognizer*)gesture
{
    if(self.playing){
        [self pausePreview];
    }
}

#pragma mark - media handle
-(void)updateMerge
{
    [SVProgressHUD showWithStatus:NSLocalizedString(@"Processing", nil) maskType:SVProgressHUDMaskTypeClear];
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    __weak qxTimeline *qxTL = self.timeline;
    __weak SubtitleViewController *weakSelf = self;
    [queue addOperationWithBlock:^{
        
        for (qxMediaObject * px in [qxTL getTrackFromTimeline:0].mpMediaObjArray) {
            if (px.eType == eMT_Photo){
                [px makeUsable:CGSizeMake(9*videoView.frame.size.height/16, videoView.frame.size.height)];
            }
        }
        
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            [SVProgressHUD dismiss];
            [weakSelf prepareForPreview];
        }];
    }];
}

-(void)prepareForPreview
{
    [Util clearPhotoTrack:[self.timeline getTrackFromTimeline:3]];
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
    
    //
    playbackHelper.mpTimeline = self.timeline;
    [playbackHelper initWithUIView:videoView];
    playbackHelper.delegate = self;
    duration = playbackHelper.playerItem.duration;
    currentLabel.text = [Util stringWithSeconds:0];;
    totalLabel.text = [Util stringWithSeconds:round(CMTimeGetSeconds(duration))];
    
    for (UIView * pv in videoView.subviews) {
        if (![pv isKindOfClass:NSClassFromString(@"qxPlaybackView")]){
            [videoView bringSubviewToFront:pv];
        }
    }
}

#pragma mark - qxPlaybackDelegate
- (void)readyForPlayback
{
    if(needRefreshVideoBeforePreview){
        needRefreshVideoBeforePreview = NO;
        [self startPreview];
    }else{
        self.playing = NO;
        btnPlayStatus.selected=YES;
        [self pausePreview];
    }
}

- (void)FinishPlayback
{
    self.playing = NO;
    btnPlayStatus.selected=YES;
    [self seekTo:0.0];
}

#pragma mark - MediaFrameViewDelegate
- (void)mediaFrameView:(MediaFrameView *)view didScrollTo:(CGFloat)second
{
    [self pausePreview];
    [self seekTo:second];
    currentPosOnTrack = second;
    qxMediaObject *overlayObj = [self getTextObjectAtTime:second];
    if(((second == 0 || currentOverlayObj) && ![currentOverlayObj isEqual:overlayObj]) || (overlayObj && !currentOverlayObj)){
        currentOverlayObj = overlayObj;
        [subtitleTextView setTextWithOverlayObj:currentOverlayObj];
        CGRect rect = [self displayRectOfText:currentOverlayObj.overlayCustomObj];
        if(!CGRectIsEmpty(rect)){
            subtitleTextView.frame = rect;
        }
        BOOL b = currentOverlayObj == nil;
        subtitleTextView.hidden = b;
        deleteSubtitle.hidden = b;
        addSubtitle.hidden = !b;
        if(currentOverlayObj && currentOverlayObj.overlayCustomObj){
            [self updateSelectionFont:((qxMediaObject*)currentOverlayObj.overlayCustomObj).textFont Color:((qxMediaObject*)currentOverlayObj.overlayCustomObj).textColor];
        }else{
            [self updateSelectionFont:nil Color:nil];
        }
    }
}

- (void)framesLoadDone
{
    self.framesLoadFinished = YES;
}

//
- (qxMediaObject*)getTextObjectAtTime:(CGFloat)timeInSecond
{
    qxMediaObject *textObj = nil;
    if(self.timeline){
        NSArray *overlayObjArray = [self.timeline getTrackFromTimeline:3].mpMediaObjArray;
        CGFloat s, d;
        for(qxMediaObject *temp in overlayObjArray){
            if([self isTextObj:temp]){
                s = CMTimeGetSeconds(temp.startTimeOfTrack);
                d = CMTimeGetSeconds(temp.mediaOriginalDuration);
                if(timeInSecond >= s && timeInSecond <= s + d + 0.2){
                    textObj = temp;
                    break;
                }
            }
        }
    }
    return textObj;
}

#pragma mark - Preview control
-(void)stopPreview
{
    [self stopUpdatePlayStatus];
    if(playbackHelper){
        [playbackHelper stop];
    }
    self.playing = NO;
    btnPlayStatus.selected=YES;
}

-(void)startPreview
{
    if(!self.playing && playbackHelper){
        [playbackHelper rebuildForTextEdit:YES];
        self.playing = YES;
        [self startUpdatePlayStatus];
        [playbackHelper playPause:YES];
    }
    btnPlayStatus.selected=NO;
    subtitleTextView.hidden = YES;
}

-(void)pausePreview
{
    if(self.playing && playbackHelper){
        [playbackHelper playPause:NO];
        self.playing = NO;
        [self stopUpdatePlayStatus];
    }
    [playbackHelper rebuildForTextEdit:NO];
    btnPlayStatus.selected=YES;
    if(currentOverlayObj){
        subtitleTextView.hidden = NO;
    }
}

-(void)startUpdatePlayStatus
{
    if(![previewControlTimer isValid]){
        previewControlTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(updatePlayStatusTask) userInfo:nil repeats:YES];
    }
}

-(void)stopUpdatePlayStatus
{
    if([previewControlTimer isValid]){
        [previewControlTimer invalidate];
    }
}

-(void)updatePlayStatusTask
{
    NSTimeInterval tm = [playbackHelper playbackProgress];
    currentLabel.text = [Util stringWithSeconds:round(tm/1000)];
}

- (void)seekTo:(float)second
{
    [playbackHelper.player seekToTime:CMTimeMakeWithSeconds(second, duration.timescale) toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero];
    currentLabel.text = [Util stringWithSeconds:round(second)];
}

-(void)handleSubtitlePanGestureRecognizer:(UIPanGestureRecognizer*)recognizer
{
    if(recognizer.state == UIGestureRecognizerStateChanged){
        [self pausePreview];
        CGPoint translation = [recognizer translationInView:recognizer.view.superview];
        CGFloat x = recognizer.view.center.x + translation.x;
        CGFloat y = recognizer.view.center.y + translation.y;
        CGFloat minX = recognizer.view.frame.size.width/2;
        CGFloat minY = recognizer.view.frame.size.height/2;
        CGFloat maxX = recognizer.view.superview.frame.size.width - recognizer.view.frame.size.width/2;
        CGFloat maxY = recognizer.view.superview.frame.size.height - recognizer.view.frame.size.height/2;
        if(x < minX){
            x = minX;
        }else if(x > maxX){
            x = maxX;
        }
        
        if(y < minY){
            y = minY;
        }else if(y > maxY){
            y = maxY;
        }
        recognizer.view.center = CGPointMake(x,y);
        [recognizer setTranslation:CGPointMake(0, 0) inView:recognizer.view.superview];
    }else if(recognizer.state == UIGestureRecognizerStateEnded){
        [self setTextDisplayRect:currentOverlayObj.overlayCustomObj];
    }
}

#pragma mark - SubtitleTextViewDelegate
- (void)subtitlePositionViewTapped
{
    [self showSubtitlePostionView];
}

- (void)subtitleTextViewTapped
{
    [UIView animateWithDuration:0.3f animations:^{
        [self showSubtitleEiditAlertView];
    }];
}

- (void)subtitleTextSizeChanged:(UIFont*)font
{
    if(currentOverlayObj){
        [(qxMediaObject*)currentOverlayObj.overlayCustomObj setTextFont:font.fontName size:font.pointSize];
        [self setTextDisplayRect:currentOverlayObj.overlayCustomObj];
    }
}

#pragma mark - ColorSelectorViewDelegate
- (void)selectColor:(UIColor *)color
{
    [self pausePreview];
    if(currentOverlayObj){
        [subtitleTextView setTextColor:color];
        [(qxMediaObject*)currentOverlayObj.overlayCustomObj setTextColor:color];
        [self updateCurrentOverlayWithTextObj:currentOverlayObj.overlayCustomObj];
        needRefreshVideoBeforePreview = YES;
    }
}

#pragma mark - FontSelectorViewDelegate
- (void)selectFont:(NSString *)fontName
{
    [self pausePreview];
    if(currentOverlayObj && fontName){
        UIFont *font = [subtitleTextView setTextFont:fontName];
        if(font){
            [currentOverlayObj.overlayCustomObj setTextFont:font.fontName size:font.pointSize];
            [self updateCurrentOverlayWithTextObj:currentOverlayObj.overlayCustomObj];
            needRefreshVideoBeforePreview = YES;
        }
    }
}

- (void)showSubtitlePostionView
{
    if(!subtitlePositionView){
        subtitlePositionView = [[SubtitlePositionView alloc] init];
        subtitlePositionView.delegate = self;
        [self.view addSubview:subtitlePositionView];
    }
    [self.view bringSubviewToFront:subtitlePositionView];
    [subtitlePositionView show];

}

- (void)hideSubtitlePositionView
{
    if(subtitlePositionView){
        [subtitlePositionView hide];
    }
}

#pragma mark - SubtitlePositionViewDelegate
- (void)selectPosition:(SubtitlePosition)position
{
    if(!currentOverlayObj){
        return;
    }
    CGRect tmp = [subtitleTextView subtitleRect];
    CGRect rect = CGRectMake(-1, -1, tmp.size.width/videoView.frame.size.width, tmp.size.height/videoView.frame.size.height);
    CGRect subtitleTextViewRect = subtitleTextView.frame;
    switch (position) {
        case LeftTop:
            rect.origin.x = 0;
            rect.origin.y = 0;
            subtitleTextViewRect.origin.x = 0;
            subtitleTextViewRect.origin.y = 0;
            break;
            
        case LeftBottom:
            rect.origin.x = 0;
            rect.origin.y = (videoView.frame.size.height - tmp.size.height)/videoView.frame.size.height;
            subtitleTextViewRect.origin.x = 0;
            subtitleTextViewRect.origin.y = videoView.frame.size.height - subtitleTextView.frame.size.height;
            break;
            
        case RightTop:
            rect.origin.x = (videoView.frame.size.width - tmp.size.width)/videoView.frame.size.width;
            rect.origin.y = 0;
            subtitleTextViewRect.origin.x = videoView.frame.size.width - subtitleTextView.frame.size.width;
            subtitleTextViewRect.origin.y = 0;
            break;
            
        case RightBottom:
            rect.origin.x = (videoView.frame.size.width - tmp.size.width)/videoView.frame.size.width;
            rect.origin.y = (videoView.frame.size.height - tmp.size.height)/videoView.frame.size.height;
            subtitleTextViewRect.origin.x = videoView.frame.size.width - subtitleTextView.frame.size.width;
            subtitleTextViewRect.origin.y = videoView.frame.size.height - subtitleTextView.frame.size.height;
            break;
            
        case MiddleTop:
            rect.origin.x = (videoView.frame.size.width - tmp.size.width)/(videoView.frame.size.width*2);
            rect.origin.y = 0;
            subtitleTextViewRect.origin.x = (videoView.frame.size.width - subtitleTextView.frame.size.width)/2;
            subtitleTextViewRect.origin.y = 0;
            break;
            
        case MiddleBottom:
            rect.origin.x = (videoView.frame.size.width - tmp.size.width)/(videoView.frame.size.width*2);
            rect.origin.y = (videoView.frame.size.height - tmp.size.height)/videoView.frame.size.height;
            subtitleTextViewRect.origin.x = (videoView.frame.size.width - subtitleTextView.frame.size.width)/2;
            subtitleTextViewRect.origin.y = videoView.frame.size.height - subtitleTextView.frame.size.height;
            break;
            
        case Center:
            rect.origin.x = (videoView.frame.size.width - tmp.size.width)/(videoView.frame.size.width*2);
            rect.origin.y = (videoView.frame.size.height - tmp.size.height)/(videoView.frame.size.height*2);
            subtitleTextViewRect.origin.x = (videoView.frame.size.width - subtitleTextView.frame.size.width)/2;
            subtitleTextViewRect.origin.y = (videoView.frame.size.height - subtitleTextView.frame.size.height)/2;
            break;
    }
    if(rect.origin.x != -1 && rect.origin.y != -1){
        needRefreshVideoBeforePreview = YES;
        subtitleTextView.frame = subtitleTextViewRect;
        rect.origin.y = rect.origin.y;
        rect.origin.x = rect.origin.x;
        [(qxMediaObject*)currentOverlayObj.overlayCustomObj setDisplayRect:rect];
        [self updateCurrentOverlayWithTextObj:currentOverlayObj.overlayCustomObj];
    }
}

-(void)screenTouchNotification:(NSNotification  *)notificatioin
{
    UIEvent *event = [[notificatioin userInfo] objectForKey:@"event"];
    if ([[[event allTouches] allObjects] count] > 0) {
        UITouch *touch = [[[event allTouches] allObjects] objectAtIndex:0];
        CGPoint touchPoint = [touch locationInView:self.view];
        if(subtitlePositionView && !subtitlePositionView.hidden){
            if(![self isPointInSubtitlePositionView:touchPoint]){
                [self hideSubtitlePositionView];
            }
        }
    }
}

- (BOOL)isPointInSubtitlePositionView:(CGPoint)point
{
    BOOL res = NO;
    if(subtitlePositionView && !subtitlePositionView.hidden){
        if(point.x >= subtitlePositionView.frame.origin.x &&
           point.x < subtitlePositionView.frame.origin.x + subtitlePositionView.frame.size.width &&
           point.y >= subtitlePositionView.frame.origin.y &&
           point.y <= subtitlePositionView.frame.origin.y + subtitlePositionView.frame.size.height){
           res = YES;
        }
    }
    return res;
}

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if([keyPath isEqualToString:@"framesLoadFinished"]){
        if ([(NSNumber*)change[NSKeyValueChangeNewKey] boolValue]) {
            addSubtitle.enabled = YES;
            deleteSubtitle.enabled = YES;
        }else{
            addSubtitle.enabled = NO;
            deleteSubtitle.enabled = NO;
        }
    }
}

- (BOOL)isTextObj:(qxMediaObject*)overlayObj
{
    BOOL ret = NO;
    if(overlayObj && ((qxMediaObject*)overlayObj.overlayCustomObj).eType == eMT_Text){
        ret = YES;
    }
    return ret;
}

-(void)updateCurrentOverlayWithTextObj:(qxMediaObject*)textObj
{
    if(textObj && currentOverlayObj){
        currentOverlayObj.overlayCustomObj = textObj;
        [currentOverlayObj setDisplayRect:textObj.textDisplayRect];
        [Util deleteFile:currentOverlayObj.strFilePath];
        NSString *imgFile = [self imageFromTextObj:textObj];
        [currentOverlayObj setFilePath:imgFile withType:eMT_Overlay fromAssetLibrary:NO];
    }
}

-(NSString*)imageFromTextObj:(qxMediaObject*)textObj
{
    if(!textObj){
        return nil;
    }
    //
    NSString *overlayDir = [Util overlayImgDir];
    if(!overlayDir){
        return nil;
    }
    //
    long long time = [[NSDate date] timeIntervalSince1970] * 1000;
    NSString *overlayFile = [overlayDir stringByAppendingPathComponent:[NSString stringWithFormat:@"%lld%@",time,@".png"]];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if(![fileManager fileExistsAtPath:overlayFile]){
        BOOL ret = [fileManager createFileAtPath:overlayFile contents:nil attributes:nil];
        if(!ret){
            return nil;
        }
    }
    //--------------------
    UIFont *font = textObj.textFont;
    CGSize size = [subtitleTextView subtitleRect].size;
    UIGraphicsBeginImageContext(size);
    // draw in context
    if([[[UIDevice currentDevice] systemVersion] floatValue] < 7.0){
        [textObj.textColor set];
        [textObj.text drawInRect:CGRectMake(0, 0, size.width, size.height) withFont:font lineBreakMode:NSLineBreakByWordWrapping];
    }else{
        NSMutableParagraphStyle *style = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
        [style setLineBreakMode:NSLineBreakByWordWrapping];
        NSDictionary *attrsDictionary = @{NSFontAttributeName : font, NSParagraphStyleAttributeName : style, NSForegroundColorAttributeName : textObj.textColor};
    
        [textObj.text drawInRect:CGRectMake(0, 0, size.width, size.height) withAttributes:attrsDictionary];
    }
    // transfer image
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    if(![UIImagePNGRepresentation(image) writeToFile:overlayFile atomically:YES]){
        return nil;
    }
    return overlayFile;
}

- (void)showSubtitleEiditAlertView
{
    if(!subtitleEditAlertView){
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 280, 130)];
        view.backgroundColor = [UIColor clearColor];
        subtitleEditAlertView = [[CustomAlertView alloc] init];
        subtitleEditTextView = [[UITextView alloc] initWithFrame:CGRectMake(10, 10, 230, 110)];
        subtitleEditTextView.backgroundColor = [UIColor clearColor];
        subtitleEditTextView.font = [UIFont systemFontOfSize:17];
        subtitleEditTextView.delegate = self;
        [view addSubview:subtitleEditTextView];
        // Add some custom content to the alert view
        [subtitleEditAlertView setContainerView:view];
        // Modify the parameters
        [subtitleEditAlertView setButtonTitles:[NSMutableArray arrayWithObjects:NSLocalizedString(@"Cancel", nil), NSLocalizedString(@"Confirm", nil), nil]];
        [subtitleEditAlertView setDelegate:self];
    }
    subtitleEditTextView.text = subtitleTextView.text;
    if([subtitleEditTextView hasText]){
        subtitleEditTextView.selectedRange = NSMakeRange(subtitleEditTextView.text.length, 0);
    }
    [subtitleEditAlertView show];
    [subtitleEditTextView becomeFirstResponder];
}

#pragma mark - CustomAlertView
- (void)customdialogButtonTouchUpInside:(id)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(alertView == subtitleEditAlertView){
        if(buttonIndex == 0){//cancel
            NSString *text = [subtitleTextView text];
            subtitleTextView.hidden = (text == nil || [text isEqualToString:@""]);
        }else if(buttonIndex == 1){//confirm
            [subtitleTextView updateText:subtitleEditTextView.text];
            subtitleTextView.center =  CGPointMake(self.view.frame.size.width/2, self.view.frame.size.height/2);
            addSubtitle.hidden = YES;
            deleteSubtitle.hidden = NO;
            [self addTextObj:[subtitleTextView text]];
            subtitleTextView.center = CGPointMake(videoView.frame.size.width/2, videoView.frame.size.height/2);
        }
        [subtitleEditAlertView close];
    }
}

#pragma mark - UITextViewDelegate
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if(textView == subtitleEditTextView){
        NSString *temp = textView.text;
        NSUInteger len = temp.length;
        if(len > MAX_NUM_SUBTITLE_CHARACTERS){
            [textView.undoManager removeAllActions];
            [textView setText:[temp substringToIndex:MAX_NUM_SUBTITLE_CHARACTERS]];
            return NO;
        }
    }
    return YES;
}
@end