//
//  HomeViewController.h
//  VideoShow
//
//  Created by Jerry Chen  on 14-7-15.
//  Copyright (c) 2014年 energy. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ViewPagerController.h"
#import "ASIHTTPRequest.h"
#import "AGImagePickerController.h"

@interface HomeViewController : UIViewController<UIScrollViewDelegate,ASIHTTPRequestDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate>
{
    UIScrollView *adScrollView;
    UIPageControl *pageControl;
    NSTimer *pageControlTimer;
    NSMutableArray *adlist;
    NSMutableString *adJSONStr;
    CGRect screenBounds;
    NSUInteger totalAdCount;
    __block NSString *savedVideoPath;
}

@property (strong,nonatomic) ViewPagerController *pageControler;

@end
