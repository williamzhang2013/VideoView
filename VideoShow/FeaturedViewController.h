//
//  FeaturedViewController.h
//  VideoShow
//
//  Created by Jerry Chen  on 14-7-15.
//  Copyright (c) 2014年 energy. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SharedListViewController.h"
#import "ViewPagerController.h"

@interface FeaturedViewController : SharedListViewController<SharedListViewControllerDataSource,SharedListViewControllerDelegate>

@property (strong,nonatomic) ViewPagerController *pageControler;

@end
