//
//  SubtitlePositionView.m
//  VideoShow
//
//  Created by Jerry Chen  on 14-8-18.
//  Copyright (c) 2014年 energy. All rights reserved.
//

#import "SubtitlePositionView.h"
#import "UIColor+Util.h"


//位置控制对话框
@implementation SubtitlePositionView
{
    UILabel *title;
    UIButton *leftTop;
    UIButton *middleTop;
    UIButton *rightTop;
    UIButton *center;
    UIButton *leftBottom;
    UIButton *middleBotton;
    UIButton *rightBottom;
}

- (id)init
{
    if(self = [super initWithFrame:CGRectMake(0, 0, 280, 245)]){
        self.backgroundColor = [UIColor whiteColor];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [self init];
    if (self) {

    }
    return self;
}

- (UILabel*)titleLable
{
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 50, 40)];
    label.textColor = [UIColor blackColor];
    label.font = [UIFont systemFontOfSize:20];
    return label;
}

- (void)layoutSubviews
{
    title = [[UILabel alloc] initWithFrame:CGRectMake(10, 5, 100, 30)];
    title.font = [UIFont systemFontOfSize:20];
    title.textColor = [UIColor grayColor];
    title.text = NSLocalizedString(@"Subtitle Position", nil);
    [self addSubview:title];
    
    int btnWidth=50;
    int btnHeight=40;
    int btnMargin=10;
    //
    leftTop = [[UIButton alloc] initWithFrame:CGRectMake(title.frame.origin.x, title.frame.origin.y + btnMargin + title.frame.size.height, btnWidth, btnHeight)];
    leftTop.tag=LeftTop;
    [self selectStatus:leftTop flag:NO];
    [leftTop setTitle:NSLocalizedString(@"Left Top", nil) forState:UIControlStateNormal];
    [leftTop setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [leftTop addTarget:self action:@selector(positionAction:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:leftTop];
    
    //
    middleTop = [[UIButton alloc] initWithFrame:CGRectMake((self.frame.size.width - btnWidth)/2, leftTop.frame.origin.y, btnWidth, btnHeight)];
    middleTop.tag=MiddleTop;
    [self selectStatus:middleTop flag:NO];
    [middleTop setTitle:NSLocalizedString(@"Middle Top", nil) forState:UIControlStateNormal];
    [middleTop addTarget:self action:@selector(positionAction:) forControlEvents:UIControlEventTouchUpInside];
    [middleTop setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self addSubview:middleTop];
    
    //----------------------
    rightTop = [[UIButton alloc] initWithFrame:CGRectMake(self.frame.size.width - btnWidth - btnMargin, leftTop.frame.origin.y, btnWidth, btnHeight)];
    rightTop.tag=RightTop;
    [self selectStatus:rightTop flag:NO];
    [rightTop setTitle:NSLocalizedString(@"Right Top", nil) forState:UIControlStateNormal];
    [rightTop addTarget:self action:@selector(positionAction:) forControlEvents:UIControlEventTouchUpInside];
    [rightTop setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self addSubview:rightTop];
    
    //------------------
    leftBottom = [[UIButton alloc] initWithFrame:CGRectMake(title.frame.origin.x, self.frame.size.height - btnMargin - btnHeight, btnWidth, btnHeight)];
    leftBottom.tag=LeftBottom;
    [self selectStatus:leftBottom flag:NO];
    [leftBottom setTitle:NSLocalizedString(@"Left Bottom", nil) forState:UIControlStateNormal];
    [leftBottom addTarget:self action:@selector(positionAction:) forControlEvents:UIControlEventTouchUpInside];
    [leftBottom setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self addSubview:leftBottom];
    
    //
    middleBotton = [[UIButton alloc] initWithFrame:CGRectMake((self.frame.size.width - btnWidth)/2, self.frame.size.height - btnMargin - btnHeight, btnWidth, btnHeight)];
    middleBotton.tag=MiddleBottom;
    [self selectStatus:middleBotton flag:NO];
    [middleBotton setTitle:NSLocalizedString(@"Middle Bottom", nil) forState:UIControlStateNormal];
    [middleBotton addTarget:self action:@selector(positionAction:) forControlEvents:UIControlEventTouchUpInside];
    [middleBotton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self addSubview:middleBotton];
    
    //
    rightBottom = [[UIButton alloc] initWithFrame:CGRectMake(self.frame.size.width - btnWidth - btnMargin, self.frame.size.height - btnMargin - btnHeight, btnWidth, btnHeight)];
    rightBottom.tag=RightBottom;
    [self selectStatus:rightBottom flag:NO];
    [rightBottom setTitle:NSLocalizedString(@"Right Bottom", nil) forState:UIControlStateNormal];
    [rightBottom addTarget:self action:@selector(positionAction:) forControlEvents:UIControlEventTouchUpInside];
    [rightBottom setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self addSubview:rightBottom];
    
    //
    center = [[UIButton alloc] initWithFrame:CGRectMake(self.frame.size.width - btnWidth - btnMargin, leftTop.frame.origin.y, btnWidth, btnHeight)];
    center.tag=Center;
    [self selectStatus:center flag:NO];
    [center setTitle:NSLocalizedString(@"Center", nil) forState:UIControlStateNormal];
    [center addTarget:self action:@selector(positionAction:) forControlEvents:UIControlEventTouchUpInside];
    [center setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self addSubview:center];
    center.center = CGPointMake(self.frame.size.width/2, middleBotton.frame.origin.y - (middleBotton.frame.origin.y - middleTop.frame.origin.y - middleTop.frame.size.height)/2);
}

-(void) selectStatus:(UIButton *)sender flag:(BOOL)flag
{
    if (flag) {
        sender.layer.borderWidth=2;
        sender.layer.borderColor=[UIColor colorWithHexString:@"#dd6b6f"].CGColor;
    }else{
        sender.layer.borderWidth=1;
        sender.layer.borderColor=[UIColor colorWithHexString:@"#d1d1d1"].CGColor;
    }
}

- (void)show
{
    if(self.superview){
        CGPoint centerPoint = CGPointMake(self.superview.frame.size.width/2, self.superview.frame.size.height/2);
        if(self.center.x != centerPoint.x && self.center.y != centerPoint.y){
            self.center = centerPoint;
            [self setNeedsLayout];
        }
        self.hidden = NO;
    }
}

- (void)hide
{
    self.hidden = YES;
}

-(void) positionAction:(UIButton*)sender
{
    leftTop.selected=NO;
    middleTop.selected=NO;
    rightTop.selected=NO;
    center.selected=NO;
    leftBottom.selected=NO;
    middleBotton.selected=NO;
    rightBottom.selected=NO;
    [self selectStatus:leftTop flag:NO];
    [self selectStatus:middleTop flag:NO];
    [self selectStatus:rightTop flag:NO];
    [self selectStatus:center flag:NO];
    [self selectStatus:leftBottom flag:NO];
    [self selectStatus:middleBotton flag:NO];
    [self selectStatus:rightBottom flag:NO];
    
    [self selectStatus:sender flag:YES];
    if([self.delegate respondsToSelector:@selector(selectPosition:)]){
        [self.delegate selectPosition:(int)sender.tag];
    }
}

@end
