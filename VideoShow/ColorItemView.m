//
//  ColorView.m
//  X-VideoShow
//
//  Created by Jerry Chen  on 14-7-4.
//  Copyright (c) 2014年 energy. All rights reserved.
//

#import "ColorItemView.h"


@implementation ColorItemView

- (id)initWithFrame:(CGRect)frame color:(UIColor*)color
{
    self = [super initWithFrame:CGRectMake(frame.origin.x, frame.origin.y, frame.size.width, frame.size.height)];
    if (self) {
        _colorView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, ColorImageViewWidth, ColorImageViewHeight)];
        _colorView.backgroundColor = color;
        [self addSubview:_colorView];
        _bottomLine = [[UIView alloc] initWithFrame:CGRectMake(0, _colorView.frame.size.height + 3, frame.size.width, 2)];
        _bottomLine.backgroundColor = [UIColor colorWithRed:221/255.0 green:107/255.0 blue:111/255.0 alpha:1.0];
        [self addSubview:_bottomLine];
        [self clearSelection];
    }
    return self;
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    if(!_selected){
        [self setSelection:YES];
    }
}

-(void)setSelection:(BOOL)isNotify
{
    _selected = YES;
    _bottomLine.hidden = NO;
    
    if(isNotify && [self.delegate respondsToSelector:@selector(colorSelected:)]){
        [self.delegate colorSelected:self];
    }
}

-(void)clearSelection
{
    _selected = NO;
    _bottomLine.hidden = YES;
}
@end