//
//  FrameView.h
//  VideoShow
//
//  Created by Jerry Chen  on 14-8-6.
//  Copyright (c) 2014年 energy. All rights reserved.
//

#import <UIKit/UIKit.h>

#define FrameWidthPerSecond 15

typedef void (^GenerateFrameComplementionHandler)(NSMutableArray *frames, float spi, Float64 duraion);


@protocol FrameViewDelegate <NSObject>

-(void)scrollToSecond:(float)second;

@end

@interface FrameView : UIView

- (void)scrollTo:(CGPoint)point;
- (void)updateSelectView:(CGRect)frame;
- (id)initWithMedias:(NSMutableArray*)medias frame:(CGRect)rect;
- (void)reloadFrames;

@property (nonatomic,assign) CGSize contentSize;
@property (nonatomic,assign) BOOL scrollEnabled;
@property (nonatomic,weak) id<FrameViewDelegate> delegate;

@end
