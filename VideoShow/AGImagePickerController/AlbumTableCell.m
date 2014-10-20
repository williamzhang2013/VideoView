//
//  AlbumTableCell.m
//  VideoShow
//
//  Created by Jerry Chen  on 14-7-24.
//  Copyright (c) 2014年 energy. All rights reserved.
//

#import "AlbumTableCell.h"

@implementation AlbumTableCell

- (void)awakeFromNib
{
    self.subtitle.textColor = [UIColor colorWithRed:40/255.0 green:35/255.0 blue:35/255.0 alpha:1.0];
    self.detail.textColor = [UIColor colorWithRed:40/255.0 green:35/255.0 blue:35/255.0 alpha:1.0];
}

@end
