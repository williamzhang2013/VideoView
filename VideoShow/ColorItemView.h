//
//  ColorView.h
//  X-VideoShow
//
//  Created by Jerry Chen  on 14-7-4.
//  Copyright (c) 2014年 energy. All rights reserved.
//

#import <UIKit/UIKit.h>


#define ColorImageViewWidth 30
#define ColorImageViewHeight 30

@class ColorItemView;
@protocol ColorItemViewDelegate <NSObject>

@required
-(void)colorSelected:(ColorItemView*)view;

@end

@interface ColorItemView : UIView

@property (strong,nonatomic,readonly) UIView *bottomLine;
@property (strong,nonatomic,readonly) UIView *colorView;
@property (assign,nonatomic) NSUInteger index;
@property (weak,nonatomic) id<ColorItemViewDelegate> delegate;
@property (assign,nonatomic,readonly) BOOL selected;

- (id)initWithFrame:(CGRect)frame color:(UIColor*)color;
- (void)clearSelection;
-(void)setSelection:(BOOL)isNotify;
@end
