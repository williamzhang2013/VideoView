//
//  BaseView.m
//  viewDemo
//
//  Created by xiang_ying on 14-2-28.
//  Copyright (c) 2014年 xiang_ying. All rights reserved.
//

#import "BaseView.h"


@interface BaseView(){
    BOOL            shouldMove;
    CGPoint         previousPoint;
}

@property(nonatomic,retain) NSSet  *previousTouch;

@end

@implementation BaseView

- (id)initWithFrame:(CGRect)frame data:(AGIPCGridItem*)info
{
    self = [super initWithFrame:frame];
    if (self) {
        shouldMove = NO;
        previousPoint = CGPointMake(0, 0);
        self.item = info;
        
        self.backgroundColor = [UIColor colorWithWhite:0.5 alpha:0.6];
        self.layer.borderWidth = 1;
        self.layer.borderColor = [UIColor clearColor].CGColor;
        
        UIImageView *icon = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
        icon.image = self.item.thumbnailImageView.image;
        [self addSubview:icon];
        
        UIButton *closeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [closeBtn setImage:[UIImage imageNamed:@"photo_delete.png"] forState:UIControlStateNormal];
        closeBtn.frame = CGRectMake(frame.size.width-20, 0, 20, 20);
        [closeBtn addTarget:self action:@selector(removeSelf:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:closeBtn];
        
        self.titleLabelView  = [[UILabel alloc] initWithFrame:self.bounds];
        self.titleLabelView .backgroundColor = [UIColor clearColor];
        self.titleLabelView .textAlignment = NSTextAlignmentCenter;
        [self addSubview:self.titleLabelView ];
    }
    return self;
}

- (void)setTitle:(NSString*)t{
    self.titleLabelView.text = t;
}

- (void)addHandleGesture{
    if (!shouldMove) {
        shouldMove = YES;
        UITouch *touch = [self.previousTouch anyObject];
        CGPoint translation=[touch locationInView:self.superview];
        previousPoint = translation;
        self.layer.borderColor = [UIColor redColor].CGColor;
        if ([self.m_delegate respondsToSelector:@selector(startMove:)]) {
            [self.m_delegate startMove:self];
        }
    }
}

- (void)removeHandleGesture{
    if (shouldMove) {
        //
        if ([self.m_delegate respondsToSelector:@selector(endMove:)]) {
            [self.m_delegate endMove:self];
        }
    }
    
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(addHandleGesture) object:nil];
    self.layer.borderColor = [UIColor clearColor].CGColor;
    shouldMove = NO;
}

#pragma mark - UITouch Methodes

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    shouldMove = NO;
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(addHandleGesture) object:nil];
    self.previousTouch = touches;
    [self performSelector:@selector(addHandleGesture) withObject:nil afterDelay:0.5];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event{

    if (!shouldMove) {
  //      [self removeHandleGesture];
    }else{
        UITouch *touch = [touches anyObject];
        CGPoint translation=[touch locationInView:self.superview];
        self.center = CGPointMake(self.center.x+translation.x-previousPoint.x,self.center.y+translation.y-previousPoint.y);
        previousPoint = translation;
        if ([self.m_delegate respondsToSelector:@selector(moveing:)]) {
            [self.m_delegate moveing:self];
        }
    }
   
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
    [self removeHandleGesture];

}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event{
    [self removeHandleGesture];
}

- (void)removeSelf:(id)sender{
    if ([self.m_delegate respondsToSelector:@selector(remove:)]) {
        [self.m_delegate remove:self];
    }
}

@end
