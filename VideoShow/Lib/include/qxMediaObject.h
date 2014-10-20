//
//  qxMediaObject.h
//  videoeditor
//
//  Created by MingweiShen on 14-3-1.
//  Copyright (c) 2014年 quxun. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

enum QxMediaType{
    eMT_Video,
    eMT_Audio,
    eMT_Photo,
    eMT_Text,
    eMT_Overlay,
};

@interface qxMediaObject : NSObject<NSCoding>
@property (nonatomic, readonly) enum QxMediaType eType;
@property (nonatomic, readonly) AVAsset * mpAsset;
@property (nonatomic, readonly) NSString * strFilePath;
@property (nonatomic, readonly) BOOL mbFromAssetLibrary;
@property (nonatomic, readonly) int mOriginalRotationDegree;

@property (nonatomic, readonly) CMTime mediaOriginalDuration;
@property (nonatomic, readonly) CMTimeRange actualTimeRange;
@property (nonatomic, readonly) CMTime startTimeOfTrack;

@property (nonatomic, readonly) NSString* text;
@property (nonatomic, readonly) UIFont* textFont;
@property (nonatomic, readonly) UIColor* textColor;
@property (nonatomic, readonly) CGRect textDisplayRect;
@property (nonatomic, readonly) int textFontSize;

//Photo Property Only
@property (nonatomic, copy) NSString * strPlaceholderVideo;
@property (nonatomic, readonly) UIImage * photoImage;

//Overlay Custome Object
@property (nonatomic, retain) id overlayCustomObj;

//Should not set outside
@property (nonatomic, strong) NSString* codingId;

-(void)setFilePath:(NSString*)strFile withType:(enum QxMediaType)eType fromAssetLibrary:(BOOL)from;

//Only for Video & Audio Type, set -2 to ignore input value
-(BOOL)setTrim:(long)uMilisecsFromLeft withRight:(long)uMillisecsFromRight;

//Only for Photo & Text Type
-(BOOL)setDuration:(long)uMilliSecs;

//Only for Photo and Overlay
-(void)makeUsable:(CGSize)size;
-(void)clearPhoto;
//Internal use
-(void)genPhoto;

//Only for Text and Overlay
-(void)updateStartTime:(CMTime)startOfTrack;
//Only for Text
-(void)setText:(NSString*)text;
-(void)setTextFont:(NSString*)fontName size:(int)fontSize;
-(void)setTextColor:(UIColor*)color;

//Only for Text, rect.point/size is relative position to the timelineSize, should be in (0,1)
-(BOOL)setDisplayRect:(CGRect)rect;

//CallByTrack, not used outside
-(id)initWithCoder:(NSCoder *)aDecoder withId:(NSString*)codingId;
@end
