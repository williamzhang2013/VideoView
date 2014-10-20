//
//  FontItemView.h
//  VideoShow
//
//  Created by Jerry Chen  on 14-8-12.
//  Copyright (c) 2014年 energy. All rights reserved.
//

#import <UIKit/UIKit.h>


#define FontImageViewWidth 30
#define FontImageViewHeight 30


@class FontItemView;
@protocol FontItemViewDelegate <NSObject>

@required
-(void)fontSelected:(FontItemView*)view;

@end

@interface FontItemView : UIView

@property (weak,nonatomic) id<FontItemViewDelegate> delegate;
@property (strong,nonatomic,readonly) UIView *bottomLine;
@property (strong,nonatomic,readonly) UIImageView *fontImageView;
@property (strong,nonatomic,readonly) NSString *font;
@property (assign,nonatomic) NSUInteger index;
@property (assign,nonatomic,readonly) BOOL selected;


- (id)initWithFrame:(CGRect)frame fontDict:(NSDictionary*)dict;
-(void)clearSelection;
-(void)setSelection:(BOOL)isNotify;

@end
