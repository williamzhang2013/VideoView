//
//  qxTrack.h
//  videoeditor
//
//  Created by MingweiShen on 14-3-1.
//  Copyright (c) 2014年 quxun. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "qxMediaObject.h"

@interface qxTrack : NSObject<NSCoding>
//Should not set outside
@property (nonatomic) CGSize timelineSize;

@property (nonatomic, readonly) enum QxMediaType eType;
@property (nonatomic, readonly) NSMutableArray * mpMediaObjArray;
@property (nonatomic, readonly) NSMutableArray * mpInstrctionsArray;

//Should not set outside
@property (nonatomic, strong) NSString* codingId;

-(id)initWithTrackType:(enum QxMediaType)eType;

-(qxMediaObject*)getMediaObjectFromTrack:(int)index;
-(BOOL)addMediaObject:(qxMediaObject*)obj;
-(BOOL)insertMediaObject:(qxMediaObject*)obj atIndex:(int)index;
-(BOOL)delMediaObject:(int)index;
-(int)findMediaObject:(qxMediaObject*)obj;

//For Text & Overlay only
-(BOOL)updateTimeAtIndex:(int)index startTime:(CMTime)start duration:(CMTime)duration;
//For Audio & Voice Only
-(BOOL)updateTimeAtIndex:(int)index startTime:(CMTime)start;

//For Preview&Export
-(void)buildForComposition:(AVMutableCompositionTrack*)track;

//CallByTimeline
-(id)initWithCoder:(NSCoder *)aDecoder withId:(NSString*)codingId;

//For Audio&Video Only, range is 0-1.0
-(void)setAudioPercent:(float)fPercent;
-(float)getAudioPercent;

@end
