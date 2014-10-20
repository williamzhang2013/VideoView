//
//  qxPlaybackHelper.h
//  videoeditor
//
//  Created by MingweiShen on 14-3-2.
//  Copyright (c) 2014年 quxun. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "qxTimeline.h"
#import "qxPlaybackView.h"

@protocol qxPlaybackDelegate <NSObject>
-(void)readyForPlayback;
-(void)FinishPlayback;
@end

@interface qxPlaybackHelper : NSObject
@property(nonatomic, assign) qxTimeline * mpTimeline;
@property (nonatomic, retain) AVPlayerItem *playerItem;
@property (nonatomic, retain) AVPlayer *player;

@property (nonatomic, assign) id<qxPlaybackDelegate> delegate;

//DEPRECATED, DO NOT use it any more
-(void)initWithView:(qxPlaybackView*)region;

-(void)initWithUIView:(UIView*)region;
-(void)destroy;

//Called after readyForPlayback delegate, in the main loop
//support play and pause
-(void)playPause:(BOOL)bPlay;
//Called after play(), in the main loop
//return milli-seconds
-(NSTimeInterval)playbackProgress;
//Called after play(), in the main loop
//auto seek back to 0
-(void)stop;

//Need to be called after prepareForPreview() and qxPlaybakHelper::playPause(NO)
-(void)rebuildForTextEdit:(BOOL)bShowText;
@end
