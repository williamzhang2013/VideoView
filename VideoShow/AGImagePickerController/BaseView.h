//
//  BaseView.h
//  viewDemo
//
//  Created by xiang_ying on 14-2-28.
//  Copyright (c) 2014年 xiang_ying. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AGIPCGridItem.h"

#define BASE_SIZE CGSizeMake(55, 55)
#define X_OFFSET 5
#define Y_OFFSET 5

@class BaseView;

@protocol BaseViewDelegate <NSObject>


-(void)startMove:(BaseView*)baseView;

-(void)moveing:(BaseView*)baseView;

-(void)endMove:(BaseView*)baseView;

-(void)remove:(BaseView*)baseView;

@end

@interface BaseView : UIView

@property(nonatomic,assign)id<BaseViewDelegate> m_delegate;

@property(nonatomic,assign)NSUInteger location;

@property(nonatomic,retain)AGIPCGridItem *item;

@property(nonatomic,retain)UILabel *titleLabelView;

- (void)setTitle:(NSString*)t;

- (id)initWithFrame:(CGRect)frame data:(AGIPCGridItem*)info;

@end
