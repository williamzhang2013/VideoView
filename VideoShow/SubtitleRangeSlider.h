//
//  SubtitleRangeSlider.h
//  VideoShow
//
//  Created by Jerry Chen  on 14-8-14.
//  Copyright (c) 2014年 energy. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SubtitleRangeSlider;
@protocol SubtitleRangeSliderDelegate <NSObject>

//lower min : 0 , upper max : 1
- (void)subtitleRangeSliderValueChange:(SubtitleRangeSlider*)slider;

@end

@interface SubtitleRangeSlider : UIView

@property (nonatomic,weak) id<SubtitleRangeSliderDelegate> delegate;

- (id)initWithFrame:(CGRect)frame;
- (void)showWithFrame:(CGRect)frame maxRect:(CGRect)maxRect;
- (void)hideSlider;

@end
