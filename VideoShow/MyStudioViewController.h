//
//  MyStudioViewController.h
//  VideoShow
//
//  Created by Jerry Chen  on 14-7-16.
//  Copyright (c) 2014年 energy. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MyStudioVideoCell.h"
#import "YouTubeHelper.h"


/** 我的工作室 */
@class IconActionSheet;
@interface MyStudioViewController : UIViewController<UITableViewDataSource,UITableViewDelegate,MyStudioVideoCellDelegate,UIAlertViewDelegate,YouTubeHelperDelegate>
{
    UITableView *videoTableView;
    UIAlertView *videoDeleteAlertView;
    UIAlertView *draftDeleteAlertView;
    NSMutableArray *myVideoArray;
    NSMutableArray *myDraftArray;
    NSURL *shareURL;
    YouTubeHelper *ytbHelper;
    IconActionSheet *shareActionSheet;
}

@property (assign,nonatomic) BOOL currentStatusMyVideo;

@end
