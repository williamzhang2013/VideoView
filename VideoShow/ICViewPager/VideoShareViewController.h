//
//  VideoShareViewController.h
//  VideoShow
//
//  Created by Jerry Chen  on 14-8-21.
//  Copyright (c) 2014年 energy. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UMSocial.h"
#import "YouTubeHelper.h"

@class qxTimeline;


@interface VideoShareViewController : UIViewController<UMSocialUIDelegate,YouTubeHelperDelegate>
{
    YouTubeHelper *ytbHelper;
}

@property (nonatomic,strong) ALAsset *asset;

@end
