//
//  ColorSelectorView.m
//  VideoShow
//
//  Created by Jerry Chen  on 14-8-12.
//  Copyright (c) 2014年 energy. All rights reserved.
//

#import "ColorSelectorView.h"


@implementation ColorSelectorView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        UIButton *controlBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 29, 29)];
        [controlBtn setImageEdgeInsets:UIEdgeInsetsMake(5, 0, 5, 5)];
        [controlBtn setImage:[UIImage imageNamed:@"subtitle_color_selector.png"] forState:UIControlStateNormal];
        [controlBtn addTarget:self action:@selector(selectorControlTouchUp:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:controlBtn];
        //
        NSString *path = [[NSBundle mainBundle] pathForResource:@"Colors" ofType:@"plist"];
        NSArray *colorArray = [NSArray arrayWithContentsOfFile:path];
        itemViewArray = [[NSMutableArray alloc] initWithCapacity:colorArray.count];
        scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(34, 0, frame.size.width - 34, frame.size.height)];
        scrollView.backgroundColor = [UIColor clearColor];
        scrollView.showsHorizontalScrollIndicator = NO;
        for(int i = 0; i < colorArray.count; i ++){
            NSDictionary *dict = colorArray[i];
            float red = ((NSNumber*)dict[@"Red"]).floatValue / 255.0;
            float green = ((NSNumber*)dict[@"Green"]).floatValue / 255.0;
            float blue = ((NSNumber*)dict[@"Blue"]).floatValue / 255.0;
            
            ColorItemView *itemView = [[ColorItemView alloc] initWithFrame:CGRectMake(i * (ColorImageViewWidth + 5) + 5, 0, ColorImageViewWidth, ColorImageViewHeight + 5) color:[UIColor colorWithRed:red green:green blue:blue alpha:1.0]];
            itemView.index = i;
            itemView.delegate = self;
            [scrollView addSubview:itemView];
            [itemViewArray addObject:itemView];
        }
        scrollView.contentSize = CGSizeMake(colorArray.count * (ColorImageViewWidth + 5) + 5, ColorImageViewHeight + 5);
        self.backgroundColor = [UIColor clearColor];
        [self addSubview:scrollView];
        selectedIndex = -1;
    }
    return self;
}

- (void)selectorControlTouchUp:(id)sender
{
    scrollView.hidden = !scrollView.hidden;
}

- (void)colorSelected:(ColorItemView *)view
{
    if(view.index != selectedIndex){
        for(ColorItemView *item in itemViewArray){
            if(item.index != view.index){
                [item clearSelection];
            }
        }
        selectedIndex = view.index;
    }
    if([self.delegate respondsToSelector:@selector(selectColor:)]){
        [self.delegate selectColor:view.colorView.backgroundColor];
    }
}

- (void)setSelect:(UIColor*)color
{
    for(ColorItemView *view in itemViewArray){
        if(color){
            if([view.colorView.backgroundColor isEqual:color]){
                [view setSelection:NO];
            }else{
                [view clearSelection];
            }
        }else{
            [view clearSelection];
        }
    }
}

@end
