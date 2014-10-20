//
//  SubtitleRangeSlider.m
//  VideoShow
//
//  Created by Jerry Chen  on 14-8-14.
//  Copyright (c) 2014年 energy. All rights reserved.
//

#import "SubtitleRangeSlider.h"

@implementation SubtitleRangeSlider
{
    UIImageView *leftSlider;
    UIImageView *rightSlider;
    CGRect availableRect;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor colorWithRed:221/255.0 green:107/255.0 blue:111/255.0 alpha:0.8];
        self.hidden = YES;
    }
    return self;
}

- (void)showWithFrame:(CGRect)frame maxRect:(CGRect)maxRect
{
    self.frame = frame;
    availableRect = maxRect;
    [self setNeedsLayout];
    self.hidden = NO;
}

- (void)hideSlider
{
    self.hidden = YES;
}

- (void)layoutSubviews
{
    if(!leftSlider){
        leftSlider = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 13, 45)];
        [leftSlider setImage:[UIImage imageNamed:@"subtitle_range_slider_left_handle.png"]];
        UIPanGestureRecognizer *leftSliderPanGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(leftSliderPanGestureHandler:)];
        [leftSlider addGestureRecognizer:leftSliderPanGesture];
        leftSlider.userInteractionEnabled = YES;
        [self addSubview:leftSlider];
        //--------------------------
        rightSlider = [[UIImageView alloc] initWithFrame:CGRectMake(self.frame.size.width - 13, 0, 13, 45)];
        [rightSlider setImage:[UIImage imageNamed:@"subtitle_range_slider_right_handle"]];
        UIPanGestureRecognizer *rightSliderPanGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(rightSliderPanGestureHandler:)];
        [rightSlider addGestureRecognizer:rightSliderPanGesture];
        rightSlider.userInteractionEnabled = YES;
        [self addSubview:rightSlider];
    }
    leftSlider.frame = CGRectMake(0, 0, 20, 45);
    rightSlider.frame = CGRectMake(self.frame.size.width - 20, 0, 20, 45);
}

- (void)leftSliderPanGestureHandler:(UIPanGestureRecognizer*)gesture
{
    CGPoint translation = [gesture translationInView:self];
    float x = translation.x + self.frame.origin.x;
    x = fmaxf(x, availableRect.origin.x);
    x = fmin(x, self.frame.origin.x + self.frame.size.width - leftSlider.frame.size.width - rightSlider.frame.size.width);
    CGRect rect = self.frame;
    rect.size.width += rect.origin.x - x;
    rect.origin.x = x;
    self.frame = rect;
    [gesture setTranslation:CGPointZero inView:self];
    [self setNeedsLayout];
    if(gesture.state == UIGestureRecognizerStateEnded){
        [self notifyValueChange];
    }
}

- (void)rightSliderPanGestureHandler:(UIPanGestureRecognizer*)gesture
{
    CGPoint translation = [gesture translationInView:self];
    float w = self.frame.size.width + translation.x;
    w = fmaxf(leftSlider.frame.size.width + rightSlider.frame.size.width, w);
    w = fminf(w, availableRect.size.width - (self.frame.origin.x - availableRect.origin.x));
    CGRect rect = self.frame;
    rect.size.width = w;
    self.frame = rect;
    [gesture setTranslation:CGPointZero inView:self];
    [self setNeedsLayout];
    if(gesture.state == UIGestureRecognizerStateEnded){
        [self notifyValueChange];
    }
}

- (void)notifyValueChange
{
    if([self.delegate respondsToSelector:@selector(subtitleRangeSliderValueChange:)]){
        [self.delegate subtitleRangeSliderValueChange:self];
    }
}
@end
