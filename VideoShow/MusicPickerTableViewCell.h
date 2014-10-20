//
//  MusicPickerTableViewCell.h
//  X-VideoShow
//
//  Created by Jerry Chen  on 14-6-24.
//  Copyright (c) 2014年 energy. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NMRangeSlider.h"

#define Title_Width_Max 200

@class MusicPickerTableViewCell;
@protocol MusicPickerTableViewCellDelegate <NSObject>
@optional
-(void)musicPickerTableViewCellSliderTouchDown:(MusicPickerTableViewCell*)cell;
-(void)musicPickerTableViewCellSliderTouchUp:(MusicPickerTableViewCell*)cell;
-(void)musicpickerTableViewCellAddAction;
-(void)musicPlayAction:(UIButton*)sender;

@end

@interface MusicPickerTableViewCell : UITableViewCell

@property (strong,nonatomic) UIImageView *artwork;
@property (strong,nonatomic) UIImageView *tagImg;
@property (strong,nonatomic) UIButton *btnPlayStatus;
@property (strong,nonatomic) UIButton *add;
@property (strong,nonatomic) UILabel *title;
@property (strong,nonatomic) UILabel *artist;
@property (strong,nonatomic) UILabel *duration;
@property (strong,nonatomic) UILabel *startTime;
@property (strong,nonatomic) UILabel *endTime;
@property (strong,nonatomic) NMRangeSlider *rangeSlider;
@property (strong,nonatomic) UIView *topBgView;
@property (strong,nonatomic) UIView *bottomBgView;

@property (weak,nonatomic) id<MusicPickerTableViewCellDelegate> delegate;

- (void)resizeTitle;

@end
