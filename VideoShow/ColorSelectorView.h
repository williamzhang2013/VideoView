//
//  ColorSelectorView.h
//  VideoShow
//
//  Created by Jerry Chen  on 14-8-12.
//  Copyright (c) 2014年 energy. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ColorItemView.h"


@protocol ColorSelectorViewDelegate <NSObject>

@required
-(void)selectColor:(UIColor*)color;

@end

@interface ColorSelectorView : UIView<ColorItemViewDelegate>
{
    NSMutableArray *itemViewArray;
    UIScrollView *scrollView;
    NSInteger selectedIndex;
}

@property (weak,nonatomic) id<ColorSelectorViewDelegate> delegate;

- (void)setSelect:(UIColor*)color;

@end
