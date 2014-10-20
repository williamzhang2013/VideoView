//
//  SharedVideoCell.m
//  VideoShow
//
//  Created by Jerry Chen  on 14-7-21.
//  Copyright (c) 2014年 energy. All rights reserved.
//

#import "SharedVideoCell.h"
#import "Util.h"
#import "UMsocial.h"
#import "Prefs.h"

@implementation SharedVideoCell

- (void)awakeFromNib
{
    self.userImg.layer.masksToBounds = YES;
    self.userImg.layer.cornerRadius = 25.0;
}

//分享视频
- (IBAction)shareAction:(id)sender
{
    if([self.delegate respondsToSelector:@selector(shareVideoCellShareAction:)]){
        [self.delegate shareVideoCellShareAction:self];
    }
}

//执行点赞
- (IBAction)likeAction:(id)sender
{
        if([self.delegate respondsToSelector:@selector(sharedVideoCellLikeAction:)]){
            [self.delegate sharedVideoCellLikeAction:self];
        }
}

//播放视频
- (IBAction)play:(id)sender
{
    if([self.delegate respondsToSelector:@selector(sharedVideoCellPlayAction:)]){
        [self.delegate sharedVideoCellPlayAction:self];
    }
}

@end
