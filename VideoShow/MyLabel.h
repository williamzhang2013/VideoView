//
//  MyLabel.h
//  VideoShow
//
//  Created by Jerry Chen  on 14-7-29.
//  Copyright (c) 2014年 energy. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MyLabel : UILabel
{
    CGFloat gradientColors[8];
}

@property BOOL drawOutline;
@property (strong, nonatomic) UIColor *outlineColor;

@property BOOL enableInset;
@property (assign, nonatomic) UIEdgeInsets insets;

@property BOOL drawGradient;
-(void) setGradientColors: (CGFloat [8]) colors;

@end
