//
//  MyStudioVideoCell.h
//  VideoShow
//
//  Created by Jerry Chen  on 14-8-23.
//  Copyright (c) 2014年 energy. All rights reserved.
//

#import <UIKit/UIKit.h>

@class VideoDraft;
@protocol MyStudioVideoCellDelegate <NSObject>

- (void)editDraft:(VideoDraft*)draft;
- (void)deleteDraft:(NSURL*)draftUrl;
- (void)playVideo:(NSURL*)videoUrl;
- (void)deleteVideo:(NSURL*)videoUrl;
- (void)shareVideo:(NSURL*)videoUrl;

@end

@interface MyStudioVideoCell : UITableViewCell

@property (weak,nonatomic) id<MyStudioVideoCellDelegate> delegate;
@property (weak, nonatomic) IBOutlet UIButton *controlButton;
@property (weak, nonatomic) IBOutlet UIButton *shareButton;
@property (strong,nonatomic) NSURL *videoURL;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UIImageView *videoImage;
@property (assign,nonatomic) BOOL isDraft;
@property (strong,nonatomic) VideoDraft *draft;

- (IBAction)controlAction:(id)sender;

- (IBAction)shareAction:(id)sender;
- (IBAction)deleteAction:(id)sender;

@end
