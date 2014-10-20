//
//  InstagramAuthControllerViewController.h
//  VideoShow
//
//  Created by chengkai.gan on 14-9-24.
//  Copyright (c) 2014年 energy. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol InstagramAuthDelegate;

@interface InstagramAuthController : UIViewController<UIWebViewDelegate>

@property (nonatomic,retain) id<InstagramAuthDelegate> authDelegate;

@end

@protocol InstagramAuthDelegate <NSObject>

-(void) authFinish:(BOOL)isAuthed;

@end