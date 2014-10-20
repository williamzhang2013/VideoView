//
//  ToolBarView.h
//  viewDemo
//
//  Created by Andy.Cao on 14-3-7.
//  Copyright (c) 2014年 xiang_ying. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseView.h"


@protocol ToolBarViewDelegate;

@interface ToolBarView : UIView

@property (nonatomic,retain) id<ToolBarViewDelegate> delegate;

@property(nonatomic,retain)UILabel *totalCountLabel;
@property(atomic,retain)NSMutableArray *itemArray;
@property(nonatomic,retain)UIScrollView   *scrollView;


- (void)addBaseView:(AGIPCGridItem*)item;

- (void)removeBaseView:(AGIPCGridItem*)item;

@end

@protocol ToolBarViewDelegate <NSObject>

-(void) dataChange:(NSMutableArray *)itemArray currentItem:(BaseView*)baseView addFlag:(BOOL)flag;

@end