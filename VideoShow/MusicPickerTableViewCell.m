//
//  MusicPickerTableViewCell.m
//  X-VideoShow
//
//  Created by Jerry Chen  on 14-6-24.
//  Copyright (c) 2014年 energy. All rights reserved.
//

#import "MusicPickerTableViewCell.h"
#import "Util.h"
#import "UIColor+Util.h"

static float smallSize=12.0f;

@implementation MusicPickerTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.topBgView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 55)];
        self.bottomBgView = [[UIView alloc] initWithFrame:CGRectMake(0, 55, 320, 55)];
        
        self.artwork = [[UIImageView alloc] initWithFrame:CGRectMake(5, 5, 45, 45)];
        [self.topBgView addSubview:self.artwork];
        
        self.btnPlayStatus = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 36, 36)];
        self.btnPlayStatus.center = self.artwork.center;
        [self.btnPlayStatus setImage:[UIImage imageNamed:@"play.png"] forState:UIControlStateNormal];
        [self.btnPlayStatus setImage:[UIImage imageNamed:@"pause.png"] forState:UIControlStateSelected];
        [self.topBgView addSubview:self.btnPlayStatus];
        self.btnPlayStatus.hidden = YES;
        [self.btnPlayStatus addTarget:self action:@selector(playAction:) forControlEvents:UIControlEventTouchUpInside];
        
        self.title = [[UILabel alloc] initWithFrame:CGRectMake(55, 8, Title_Width_Max, 15)];
        self.title.textAlignment = NSTextAlignmentLeft;
        self.title.font = [UIFont systemFontOfSize:15.0];
        [self.topBgView addSubview:self.title];
        
        self.artist = [[UILabel alloc] initWithFrame:CGRectMake(55, 25, 30, 25)];
        self.artist.textAlignment = NSTextAlignmentLeft;
        self.artist.font = [UIFont systemFontOfSize:smallSize+1];
        self.artist.textColor = [UIColor colorWithHexString:@"#4b4b4b"];
        [self.topBgView addSubview:self.artist];
        
        self.duration = [[UILabel alloc] initWithFrame:CGRectMake(self.artist.frame.origin.x + self.artist.frame.size.width + 10, self.artist.frame.origin.y, 120, 25)];
        self.duration.font = [UIFont systemFontOfSize:smallSize];
        self.duration.textColor = [UIColor grayColor];
        [self.topBgView addSubview:self.duration];
        
        self.tagImg = [[UIImageView alloc] initWithFrame:CGRectMake(self.frame.size.width-25, self.artwork.center.y, 9, 7)];
        self.tagImg.image = [UIImage imageNamed:@"down_arrow.png"];
        [self.topBgView addSubview:self.tagImg];
        
        self.add = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 44, 44)];
        self.add.center = CGPointMake(293, 27.5);
        [self.add addTarget:self action:@selector(addAction:) forControlEvents:UIControlEventTouchUpInside];
        [self.add setImageEdgeInsets:UIEdgeInsetsMake(10, 10, 10, 10)];
        [self.add setImage:[UIImage imageNamed:@"add.png"] forState:UIControlStateNormal];
        self.add.hidden = YES;
        [self.topBgView addSubview:self.add];
        
        self.startTime = [[UILabel alloc] initWithFrame:CGRectMake(5, 0, 70, 25)];
        self.startTime.font = [UIFont systemFontOfSize:smallSize];
        [self.bottomBgView addSubview:self.startTime];
        
        self.endTime = [[UILabel alloc] initWithFrame:CGRectMake(245, 0, 70, 25)];
        self.endTime.font = [UIFont systemFontOfSize:smallSize];
        self.endTime.textAlignment = NSTextAlignmentRight;
        [self.bottomBgView addSubview:self.endTime];
        
        self.rangeSlider = [[NMRangeSlider alloc] initWithFrame:CGRectMake(5, 30, 310, 20)];
        [self.rangeSlider addTarget:self action:@selector(sliderValueChanged:) forControlEvents:UIControlEventValueChanged];
        [self.rangeSlider addTarget:self action:@selector(sliderTouchDown:) forControlEvents:UIControlEventTouchDown];
        [self.rangeSlider addTarget:self action:@selector(sliderTouchUpInside:) forControlEvents:UIControlEventTouchUpInside];
        
        UIImage *img = [UIImage imageNamed:@"slider_track.png"];
        img = [img resizableImageWithCapInsets:UIEdgeInsetsMake(0.0, 5.0, 0.0, 5.0)];
        self.rangeSlider.trackBackgroundImage = img;
        img = [UIImage imageNamed:@"slider_track_bg.png"];
        img = [img resizableImageWithCapInsets:UIEdgeInsetsMake(0.0, 5.0, 0.0, 5.0)];
        self.rangeSlider.trackImage = img;
        img = [UIImage imageNamed:@"range_slider_left_handle.png"];
        [img resizableImageWithCapInsets:UIEdgeInsetsMake(1,1,1,1)];
        self.rangeSlider.lowerHandleImageNormal = img;
        self.rangeSlider.lowerHandleImageHighlighted = img;
        img = [UIImage imageNamed:@"range_slider_right_handle.png"];
        [img resizableImageWithCapInsets:UIEdgeInsetsMake(1,1,1,1)];
        self.rangeSlider.upperHandleImageNormal = img;
        self.rangeSlider.upperHandleImageHighlighted = img;

        [self.bottomBgView addSubview:self.rangeSlider];
        
        [self addSubview:self.topBgView];
        [self addSubview:self.bottomBgView];
    }
    return self;
}

- (void)resizeTitle
{
    NSString *str = self.artist.text;
    if(str && ![str isEqualToString:@""]){
        CGSize size = [str sizeWithFont:[UIFont systemFontOfSize:smallSize+1] constrainedToSize:CGSizeMake(MAXFLOAT, smallSize+1) lineBreakMode:NSLineBreakByWordWrapping];
        self.artist.frame = CGRectMake(self.artist.frame.origin.x, self.artist.frame.origin.y, size.width, self.artist.frame.size.height);
        CGRect druationRect=self.duration.frame;
        druationRect.origin.x=self.artist.frame.origin.x+self.artist.frame.size.width+10;
        self.duration.frame = druationRect;
    }
}

-(void)playAction:(UIButton*)sender
{
    sender.selected=!sender.selected;
    if ([self.delegate respondsToSelector:@selector(musicPlayAction:)]) {
        [self.delegate musicPlayAction:sender];
    }
}
- (void)addAction:(id)sender
{
    if([self.delegate respondsToSelector:@selector(musicpickerTableViewCellAddAction)]){
        [self.delegate musicpickerTableViewCellAddAction];
    }
}

-(void)sliderValueChanged:(id)sender
{
    self.startTime.text = [Util stringWithSeconds:round(self.rangeSlider.lowerValue)];
    self.endTime.text = [Util stringWithSeconds:round(self.rangeSlider.upperValue)];
}

-(void)sliderTouchDown:(id)sender
{
    if ([self.delegate respondsToSelector:@selector(musicPickerTableViewCellSliderTouchDown:)]) {
        [self.delegate musicPickerTableViewCellSliderTouchDown:self];
    }
}

-(void)sliderTouchUpInside:(id)sender
{
    if([self.delegate respondsToSelector:@selector(musicPickerTableViewCellSliderTouchUp:)]){
        [self.delegate musicPickerTableViewCellSliderTouchUp:self];
    }
}

-(void)dealloc
{
    [_rangeSlider removeTarget:self action:@selector(sliderValueChanged:) forControlEvents:UIControlEventValueChanged];
}
@end
