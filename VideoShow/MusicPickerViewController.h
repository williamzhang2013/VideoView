//
//  MusicPickerTableViewController.h
//  X-VideoShow
//
//  Created by Jerry Chen  on 14-6-24.
//  Copyright (c) 2014年 energy. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MediaPlayer/MediaPlayer.h>
#import <AVFoundation/AVFoundation.h>
#import "MusicPickerTableViewCell.h"

@class MusicPickerViewController;
@class qxMediaObject;
@protocol MusicPickerViewControllerDelegate <NSObject>
@optional
-(void)musicPickerViewController:(MusicPickerViewController*)controller didFinishPickMediaItem:(qxMediaObject*)mediaObj;
-(void)musicPickerCanceled;

@end

@interface MusicPickerViewController : UITableViewController<AVAudioPlayerDelegate,MusicPickerTableViewCellDelegate>
{
    NSTimer *playControlTimer;
    NSArray *mediaList;
    AVAudioPlayer *audioPlayer;
}

@property (weak,nonatomic) id<MusicPickerViewControllerDelegate> delegate;
@property (assign,nonatomic) NSInteger preIndex;
@property (assign,nonatomic) NSInteger selectedIndex;
@end
