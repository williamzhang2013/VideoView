//
//  ToolBarView.m
//  viewDemo
//
//  Created by Andy.Cao on 14-3-7.
//  Copyright (c) 2014年 xiang_ying. All rights reserved.
//

#import "ToolBarView.h"

#define LABEL_SIZE_HEIGHT 13

@interface ToolBarView ()<BaseViewDelegate>{
    UIView      *rublishView;
}

@end

@implementation ToolBarView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        UIImageView *topline = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, 2)];
        [topline setImage:[UIImage imageNamed:@"photo_bar_top.png"]];
        [self addSubview:topline];

        UIView *bgView = [[UIView alloc] initWithFrame:CGRectMake(0, topline.frame.size.height, frame.size.width, frame.size.height - topline.frame.size.height)];
        bgView.backgroundColor = [UIColor colorWithRed:239/255.0 green:239/255.0 blue:239/255.0 alpha:1.0];
        self.scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, LABEL_SIZE_HEIGHT+Y_OFFSET, frame.size.width, BASE_SIZE.height+Y_OFFSET*2)];
        self.scrollView.showsHorizontalScrollIndicator = NO;
        self.scrollView.showsVerticalScrollIndicator = NO;
        [bgView addSubview:self.scrollView];
        
        UILabel * hintLabel=[[UILabel alloc] initWithFrame:CGRectZero];
        hintLabel.backgroundColor=[UIColor clearColor];
        hintLabel.font=[UIFont systemFontOfSize:10];
        hintLabel.textColor=[UIColor grayColor];
        hintLabel.textAlignment=NSTextAlignmentCenter;
        hintLabel.text=NSLocalizedString(@"Touch Move", nil);
        [hintLabel sizeToFit];

        
        [bgView addSubview:hintLabel];
        
        //
        self.totalCountLabel = [[UILabel alloc] initWithFrame:CGRectMake(bgView.frame.size.width - 100, Y_OFFSET, 95, LABEL_SIZE_HEIGHT)];
        self.totalCountLabel.backgroundColor = [UIColor clearColor];
        self.totalCountLabel.font = [UIFont systemFontOfSize:LABEL_SIZE_HEIGHT];
        self.totalCountLabel.textColor=[UIColor grayColor];
        self.totalCountLabel.textAlignment = NSTextAlignmentRight;
        //[self.totalCountLabel sizeToFit];
        [self setTotalCountLabel];
        [bgView addSubview:self.totalCountLabel];
        
        hintLabel.center=CGPointMake(bgView.frame.size.width/2, self.totalCountLabel.center.y);
        
        [self addSubview:bgView];
        
        self.itemArray = [NSMutableArray array];
    }
    return self;
}

- (void)setTotalCountLabel
{
    self.totalCountLabel.text = [NSString stringWithFormat:@"%@ %lu",NSLocalizedString(@"Total", nil),(unsigned long)_itemArray.count];
}

- (void)addBaseView:(AGIPCGridItem*)item{
    BaseView *b = [[BaseView alloc] initWithFrame:CGRectMake(X_OFFSET+_itemArray.count*(X_OFFSET+BASE_SIZE.width), Y_OFFSET, BASE_SIZE.width, BASE_SIZE.height) data:item];
    b.m_delegate = self;
    b.location = _itemArray.count;
    
    [_scrollView addSubview:b];
    [_itemArray addObject:b];
    float width = _itemArray.count*(X_OFFSET+BASE_SIZE.width)+X_OFFSET;
    _scrollView.contentSize = CGSizeMake(width, _scrollView.frame.size.height);
    [_scrollView scrollRectToVisible:CGRectMake(width - _scrollView.frame.size.width, 0, _scrollView.frame.size.width, _scrollView.frame.size.height) animated:YES];
    [self setTotalCountLabel];
}

- (void)removeBaseView:(AGIPCGridItem*)item{
    int sum = _itemArray.count;
    int location = 0;
    
    for (int i = 0; i<sum; i++) {
        BaseView *b = [_itemArray objectAtIndex:i];
        if ([b.item.asset isEqual:item.asset]) {
            location = i;
            [b removeFromSuperview];
            [_itemArray removeObject:b];
            [self setTotalCountLabel];
            break;
        }
    }
    for (int i = location; i<_itemArray.count; i++) {
        BaseView *b = [_itemArray objectAtIndex:i];
        b.location = i;
        [UIView animateWithDuration:0.1 animations:^{
            b.center = CGPointMake(X_OFFSET+BASE_SIZE.width/2+(BASE_SIZE.width+X_OFFSET)*b.location, _scrollView.frame.size.height/2);
        } completion:^(BOOL finished) {
            b.center = CGPointMake(X_OFFSET+BASE_SIZE.width/2+(BASE_SIZE.width+X_OFFSET)*b.location, _scrollView.frame.size.height/2);
        }];
    }
    _scrollView.contentSize = CGSizeMake(_itemArray.count*(X_OFFSET+BASE_SIZE.width)+X_OFFSET, _scrollView.frame.size.height);
}

#pragma mark - BaseViewDelegate
-(void)startMove:(BaseView*)baseView{
    if (!rublishView) {
        rublishView = [self.superview viewWithTag:967];
    }
    rublishView.hidden = NO;
    [_scrollView bringSubviewToFront:baseView];
    _scrollView.scrollEnabled = NO;
    _scrollView.clipsToBounds = NO;
}

-(void)moveing:(BaseView *)baseView{

    CGPoint point = [self convertPoint:CGPointMake(baseView.center.x+_scrollView.frame.origin.x-_scrollView.contentOffset.x, baseView.center.y) toView:self.superview];
    if(CGRectContainsPoint(rublishView.frame,point)){
        rublishView.backgroundColor = [UIColor redColor];
    }else{
        rublishView.backgroundColor = [UIColor blueColor];
    }
    
    if (baseView.center.x-baseView.location*(BASE_SIZE.width+X_OFFSET)-(BASE_SIZE.width/2+X_OFFSET)>X_OFFSET+BASE_SIZE.width/2) {
        if (baseView.location == _itemArray.count-1) {
            return;
        }
        [_itemArray exchangeObjectAtIndex:baseView.location+1 withObjectAtIndex:baseView.location];
        BaseView *next = _itemArray[baseView.location];
        next.location--;
        baseView.location++;
        
        [UIView animateWithDuration:0.1 animations:^{
            next.center = CGPointMake(X_OFFSET+BASE_SIZE.width/2+(BASE_SIZE.width+X_OFFSET)*next.location, next.center.y);
        } completion:^(BOOL finished) {

        }];
        
    }else if(baseView.location*(BASE_SIZE.width+X_OFFSET)-baseView.center.x+(X_OFFSET+BASE_SIZE.width/2)>X_OFFSET+BASE_SIZE.width/2){
        if (baseView.location == 0) {
            return;
        }
        [_itemArray exchangeObjectAtIndex:baseView.location-1 withObjectAtIndex:baseView.location];
        BaseView *next = _itemArray[baseView.location];
        next.location++;
        baseView.location--;
        
        [UIView animateWithDuration:0.1 animations:^{
            next.center = CGPointMake(X_OFFSET+BASE_SIZE.width/2+(BASE_SIZE.width+X_OFFSET)*next.location, next.center.y);
        } completion:^(BOOL finished) {

        }];
    }
}

-(void)endMove:(BaseView*)baseView{
    _scrollView.scrollEnabled = YES;
    _scrollView.clipsToBounds = YES;
    rublishView.hidden = YES;

    rublishView.backgroundColor = [UIColor blueColor];

    CGPoint point = [self convertPoint:CGPointMake(baseView.center.x+_scrollView.frame.origin.x-_scrollView.contentOffset.x, baseView.center.y) toView:self.superview];
    if(CGRectContainsPoint(rublishView.frame,point)){
        //在垃圾箱范围内,删除
        [self remove:baseView];
    }else{
        [UIView animateWithDuration:0.1 animations:^{
            baseView.center = CGPointMake(X_OFFSET+BASE_SIZE.width/2+(BASE_SIZE.width+X_OFFSET)*baseView.location, _scrollView.frame.size.height/2);
        } completion:^(BOOL finished) {
            baseView.center = CGPointMake(X_OFFSET+BASE_SIZE.width/2+(BASE_SIZE.width+X_OFFSET)*baseView.location, _scrollView.frame.size.height/2);
        }];
        
    }
}

//移除当前滚动视图
-(void)remove:(BaseView*)baseView
{
    [_itemArray removeObject:baseView];
    [UIView animateWithDuration:0.1 animations:^{
        for (int i = 0; i<_itemArray.count; i++) {
            BaseView *b = _itemArray[i];
            b.location = i;
            b.center = CGPointMake(X_OFFSET+BASE_SIZE.width/2+(BASE_SIZE.width+X_OFFSET)*b.location, _scrollView.frame.size.height/2);
        }
        baseView.alpha = 0.0;
    } completion:^(BOOL finished) {
        [baseView removeFromSuperview];
        [self setTotalCountLabel];
        
    }];
    if(self.delegate!=nil){
        [self.delegate dataChange:_itemArray currentItem:baseView addFlag:NO];
    }
}

@end
