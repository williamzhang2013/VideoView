//
//  MediaFrameView.h
//  VideoShow
//
//  Created by Jerry Chen  on 14-8-9.
//  Copyright (c) 2014年 energy. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SubtitleRectView.h"
#import "SubtitleRangeSlider.h"

#define FrameWidthPerSecond 15

@class qxTimeline;
@class MediaFrameView;
@protocol MediaFrameViewDelegate <NSObject>
@optional
- (void)mediaFrameView:(MediaFrameView*)view didScrollTo:(CGFloat)second;
- (void)needRefreshVideo;
- (void)framesLoadDone;
@end

@interface MediaFrameView : UIView<SubtitleRectViewDelegate,SubtitleRangeSliderDelegate>

- (void)scrollTo:(CGPoint)point;
- (id)initWithMedias:(qxTimeline*)tl frame:(CGRect)rect;
- (void)reloadFrames;
- (void)refreshSubtitleView;

@property (nonatomic,assign) CGSize contentSize;
@property (nonatomic,assign) BOOL scrollEnabled;
@property (nonatomic,weak) id<MediaFrameViewDelegate> delegate;
@end
