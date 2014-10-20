//
//  SharedVideoCell.h
//  VideoShow
//
//  Created by Jerry Chen  on 14-7-21.
//  Copyright (c) 2014年 energy. All rights reserved.
//

#import <UIKit/UIKit.h>


@class SharedVideoCell;
@protocol SharedVideoCellDelegate <NSObject>
@required
- (void)sharedVideoCellPlayAction:(SharedVideoCell*)cell;
- (void)sharedVideoCellLikeAction:(SharedVideoCell*)cell;
- (void)shareVideoCellShareAction:(SharedVideoCell*)cell;
- (void)requestInstagramAccessToken;

@end

@interface SharedVideoCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIButton *like;
@property (weak, nonatomic) IBOutlet UIImageView *userImg;
@property (weak, nonatomic) IBOutlet UILabel *userName;
@property (weak, nonatomic) IBOutlet UILabel *createTime;
@property (weak, nonatomic) IBOutlet UIImageView *videoImg;
@property (weak, nonatomic) IBOutlet UILabel *likeCount;
@property (weak, nonatomic) id<SharedVideoCellDelegate> delegate;
@property (strong,nonatomic) NSString *videoUrl;
@property (strong,nonatomic) NSString *itemId;
@property (nonatomic,assign) int tag;//当前index



- (IBAction)shareAction:(id)sender;
- (IBAction)likeAction:(id)sender;
- (IBAction)play:(id)sender;


@end
