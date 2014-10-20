//
//  FontItemView.m
//  VideoShow
//
//  Created by Jerry Chen  on 14-8-12.
//  Copyright (c) 2014年 energy. All rights reserved.
//

#import "FontItemView.h"

@implementation FontItemView

- (id)initWithFrame:(CGRect)frame fontDict:(NSDictionary*)dict
{
    self = [super initWithFrame:CGRectMake(frame.origin.x, frame.origin.y, frame.size.width, frame.size.height)];
    if (self) {
        _fontImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, FontImageViewWidth, FontImageViewHeight)];
        _fontImageView.image = [UIImage imageNamed:dict[@"ImageName"]];
        _font = [dict[@"FontName"] isEqualToString:@"default"] ? [UIFont systemFontOfSize:17].fontName : [UIFont fontWithName:dict[@"FontName"] size:17].fontName;        
        [self addSubview:_fontImageView];
        //
        _bottomLine = [[UIView alloc] initWithFrame:CGRectMake(0, _fontImageView.frame.size.height + 3, frame.size.width, 2)];
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

    if(isNotify && [self.delegate respondsToSelector:@selector(fontSelected:)]){
        [self.delegate fontSelected:self];
    }
}

-(void)clearSelection
{
    _selected = NO;
    _bottomLine.hidden = YES;
}

@end
