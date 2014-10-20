//
//  FontSelectorView.h
//  VideoShow
//
//  Created by Jerry Chen  on 14-8-12.
//  Copyright (c) 2014年 energy. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FontItemView.h"

@protocol FontSelectorViewDelegate <NSObject>

@required
-(void)selectFont:(NSString*)fontName;

@end

@interface FontSelectorView : UIView<FontItemViewDelegate>
{
    NSMutableArray *itemViewArray;
    UIScrollView *scrollView;
    NSInteger selectedIndex;
}

@property (weak,nonatomic) id<FontSelectorViewDelegate> delegate;


- (void)selectFont:(UIFont*)font;

@end
