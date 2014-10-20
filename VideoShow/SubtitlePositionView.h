//
//  SubtitlePositionView.h
//  VideoShow
//
//  Created by Jerry Chen  on 14-8-18.
//  Copyright (c) 2014年 energy. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, SubtitlePosition){
    LeftTop,
    LeftBottom,
    RightTop,
    RightBottom,
    Center,
    MiddleTop,
    MiddleBottom
};

@protocol SubtitlePositionViewDelegate <NSObject>

- (void)selectPosition:(SubtitlePosition)position;

@end

@interface SubtitlePositionView : UIView

@property (weak,nonatomic) id<SubtitlePositionViewDelegate> delegate;

- (void)show;
- (void)hide;
@end
