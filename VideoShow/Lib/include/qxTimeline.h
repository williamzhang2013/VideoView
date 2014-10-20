//
//  qxTimeline.h
//  videoeditor
//
//  Created by MingweiShen on 14-3-1.
//  Copyright (c) 2014年 quxun. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "qxTrack.h"

@interface qxTimeline : NSObject<NSCoding>

@property (nonatomic) CGSize timelineSize;

//Internal use only, DO not modify
@property (nonatomic) CGSize timelineSizeForPhoto;

@property (nonatomic, readonly) AVMutableComposition * avComposition;
@property (nonatomic, readonly) AVMutableVideoComposition * avVideoComposition;
@property (nonatomic, readonly) AVMutableAudioMix * avAudioMixer;
@property (nonatomic, readonly) CALayer * imageLayer;
@property (nonatomic, readonly) CALayer * textLayer;
@property (nonatomic, readonly) CALayer * overlayLayer;

-(int)getTrackCount;
-(qxTrack *)getTrackFromTimeline:(int)index;
-(BOOL)addTrack:(qxTrack*)obj;
-(BOOL)delTrack:(int)index;
-(int)findTrack:(qxTrack*)obj;

-(BOOL)prepareForPreview;
-(BOOL)prepareForExport;

-(qxTimeline*)clone:(BOOL)bNeedCreateQxMO;

-(CGSize)getTimelineNatureSize;

//1  Horizontal, 2 vertical, 0 unknown
-(int)getTimelineSizeStatus;

@end
