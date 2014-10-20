//
//  AlbumTableCell.h
//  VideoShow
//
//  Created by Jerry Chen  on 14-7-24.
//  Copyright (c) 2014年 energy. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AlbumTableCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *image;
@property (weak, nonatomic) IBOutlet UILabel *subtitle;
@property (weak, nonatomic) IBOutlet UILabel *detail;

@end
