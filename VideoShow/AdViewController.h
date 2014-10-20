//
//  AdViewController.h
//  VideoShow
//
//  Created by Jerry Chen  on 14-7-18.
//  Copyright (c) 2014年 energy. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AdViewController : UIViewController<UIWebViewDelegate>

@property (nonatomic,strong) NSString *urlStr;
@property (nonatomic,strong) NSString *titleStr;

@end
