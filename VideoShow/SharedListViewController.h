//
//  SharedListViewController.h
//  VideoShow
//
//  Created by Jerry Chen  on 14-7-18.
//  Copyright (c) 2014年 energy. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ASIHTTPRequest.h"
#import "ASIFormDataRequest.h"
#import "SharedVideoCell.h"
#import "InstagramAuthController.h"
#import "UIImageView+WebCache.h"

@class SharedVideoItem;

@protocol SharedListViewControllerDataSource <NSObject>
@required
- (NSString*)requestUrl;
- (BOOL)orderResult;

@end
//点击单元格的回调
@protocol SharedListViewControllerDelegate <NSObject>
@optional
- (void)playUrl:(NSURL*)url;
- (void)likeItem:(NSString*)itemId;
- (void)shareItem:(NSString*)url;
- (void)requestInstagramAccessToken;

@end

@interface SharedListViewController : UITableViewController<ASIHTTPRequestDelegate,SharedVideoCellDelegate,InstagramAuthDelegate>
{
    BOOL orderResult;
    BOOL hasMorePage;
    NSUInteger pageIndex;
    NSUInteger firstVisibleIndex;
    NSString *urlStr;
    NSMutableString *receivedJSONStr;
    NSMutableArray *sharedItemList;
    UIView *authView;
}

@property (weak,nonatomic) id<SharedListViewControllerDataSource> datasource;
@property (weak,nonatomic) id<SharedListViewControllerDelegate> delegate;

//执行点赞
-(void) execLike:(SharedVideoItem *)item position:(int)row;

@end
