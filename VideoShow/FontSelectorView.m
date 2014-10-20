//
//  FontSelectorView.m
//  VideoShow
//
//  Created by Jerry Chen  on 14-8-12.
//  Copyright (c) 2014年 energy. All rights reserved.
//

#import "FontSelectorView.h"
#import "AppEvent.h"
#import "MobClick.h"

@implementation FontSelectorView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        //
        UIButton *controlBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 29, 29)];
        [controlBtn setImageEdgeInsets:UIEdgeInsetsMake(5, 0, 5, 5)];
        [controlBtn setImage:[UIImage imageNamed:@"subtitle_font_selector.png"] forState:UIControlStateNormal];
        [controlBtn addTarget:self action:@selector(selectorControlTochUp:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:controlBtn];
        //
        NSString *path = [[NSBundle mainBundle] pathForResource:@"Fonts" ofType:@"plist"];
        NSArray *fontArray = [NSArray arrayWithContentsOfFile:path];
        itemViewArray = [[NSMutableArray alloc] initWithCapacity:fontArray.count];
        //
        scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(34, 0, frame.size.width - 34, frame.size.height)];
        scrollView.backgroundColor = [UIColor clearColor];
        scrollView.showsHorizontalScrollIndicator = NO;
        for(int i = 0; i < fontArray.count; i++){
            FontItemView *itemView = [[FontItemView alloc] initWithFrame:CGRectMake(i * (FontImageViewWidth + 5) + 5, 0, FontImageViewWidth, FontImageViewHeight + 5) fontDict:fontArray[i]];
            itemView.index = i;
            itemView.delegate = self;
            [scrollView addSubview:itemView];
            [itemViewArray addObject:itemView];
        }
        scrollView.contentSize = CGSizeMake(fontArray.count * (FontImageViewWidth + 5) + 5, 30);
        self.backgroundColor = [UIColor clearColor];
        [self addSubview:scrollView];
        selectedIndex = -1;
    }
    return self;
}

-(void)selectorControlTochUp:(id)sender
{
    scrollView.hidden = !scrollView.hidden;
}

- (void)fontSelected:(FontItemView *)view
{
//    switch (view.index) {
//        case 0:
//            [MobClick event:OUTPUT_FONT_TYPE_1];
//            break;
//        case 1:
//            [MobClick event:OUTPUT_FONT_TYPE_2];
//            break;
//        case 2:
//            [MobClick event:OUTPUT_FONT_TYPE_3];
//            break;
//        case 3:
//            [MobClick event:OUTPUT_FONT_TYPE_4];
//            break;
//        case 4:
//            [MobClick event:OUTPUT_FONT_TYPE_5];
//            break;
//        case 5:
//            [MobClick event:OUTPUT_FONT_TYPE_6];
//            break;
//        case 6:
//            [MobClick event:OUTPUT_FONT_TYPE_7];
//            break;
//        case 7:
//            [MobClick event:OUTPUT_FONT_TYPE_8];
//            break;
//        case 8:
//            [MobClick event:OUTPUT_FONT_TYPE_9];
//            break;
//        case 9:
//            [MobClick event:OUTPUT_FONT_TYPE_10];
//            break;
//        default:
//            break;
//    }
    if(view.index != selectedIndex){
        for(FontItemView *item in itemViewArray){
            if(item.index != view.index){
                [item clearSelection];
            }
        }
        selectedIndex = view.index;
    }
    if([self.delegate respondsToSelector:@selector(selectFont:)]){
        [self.delegate selectFont:view.font];
    }
}

- (void)selectFont:(UIFont*)font
{
    for(FontItemView *view in itemViewArray){
        if(font){
            if([font.fontName isEqualToString:view.font]){
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
