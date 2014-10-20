//
//  SharedListViewController.m
//  VideoShow
//
//  Created by Jerry Chen  on 14-7-18.
//  Copyright (c) 2014年 energy. All rights reserved.
//
#import <MediaPlayer/MediaPlayer.h>
#import "SharedListViewController.h"
#import "SharedVideoItem.h"
#import "JSONKit.h"
#import "NetService.h"
#import "Prefs.h"
#import "VideoLike+CoreData.h"
#import "Toast+UIView.h"
#import "SVProgressHUD.h"

#define RequestTypeGetListData 1
#define RequestTypeLikeItem    2
#define RequestTypeUnLikeItem  3


static NSString *cellIdentifier = @"SharedVideoCell";

@interface SharedListViewController()

@property (nonatomic,assign) int likePosition;//当前点赞的位置

@end

@implementation SharedListViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"black_bg.png"]];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    self.tableView.separatorColor = [UIColor colorWithRed:23/255.0 green:2/255.0 blue:2/255.0 alpha:1.0];
    
    if ([self.tableView respondsToSelector:@selector(setSeparatorInset:)]) {
        [self.tableView setSeparatorInset:UIEdgeInsetsZero];
    }
    if ([self.tableView respondsToSelector:@selector(setLayoutMargins:)]) {
        [self.tableView setLayoutMargins:UIEdgeInsetsZero];
    }

    //remove the header/footer separator line
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 0.001)];
    view.backgroundColor = [UIColor clearColor];
    [self.tableView setTableFooterView:view];
    [self.tableView setTableHeaderView:view];
    
    //UIRefreshControl
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self setRefreshTitle:NSLocalizedString(@"Drop to Refresh", nil)];
    self.refreshControl.tintColor = [UIColor whiteColor];
    [self.refreshControl addTarget:self action:@selector(refreshControlValueChanged:) forControlEvents:UIControlEventValueChanged];
    
    //load cell nib
    UINib *nib = [UINib nibWithNibName:@"SharedVideoCell" bundle:nil];
    [self.tableView registerNib:nib forCellReuseIdentifier:cellIdentifier];
    //
    sharedItemList = [[NSMutableArray alloc] init];
    
    if([self.datasource respondsToSelector:@selector(requestUrl)]){
        urlStr = [self.datasource requestUrl];
    }
    if([self.datasource respondsToSelector:@selector(orderResult)]){
        orderResult = [self.datasource orderResult];
    }
}

- (BOOL)shouldAutorotate
{
    return NO;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
    return UIInterfaceOrientationPortrait;
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if(sharedItemList.count <= 0){
        pageIndex = 0;
        hasMorePage = YES;
        [self requestWithPageIndex:++pageIndex];
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{

    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return sharedItemList.count;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 430.0;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    SharedVideoCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if ([self.tableView respondsToSelector:@selector(setSeparatorInset:)]) {
        [self.tableView setSeparatorInset:UIEdgeInsetsZero];
    }
    if ([self.tableView respondsToSelector:@selector(setLayoutMargins:)]) {
        [self.tableView setLayoutMargins:UIEdgeInsetsZero];
    }
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        [cell setLayoutMargins:UIEdgeInsetsZero];
    }
    SharedVideoItem *item = sharedItemList[indexPath.row];
    cell.videoImg.backgroundColor = [UIColor colorWithRed:28.0/255 green:28.0/255 blue:30.0/255 alpha:1];
    [cell.videoImg setImageWithURL:[NSURL URLWithString:item.imageUrl] placeholderImage:[UIImage imageNamed:@"icon_net_default.png"]];
    [cell.userImg setImageWithURL:[NSURL URLWithString:item.userProfilePictureUrl] placeholderImage:[UIImage imageNamed:@"user_img_default.png"]];
    cell.userName.text = item.userName;
    NSString * likeCountText=nil;
    if (item.likesCount>=10000) {
        likeCountText=[NSString stringWithFormat:@"%d%@",item.likesCount/10000,NSLocalizedString(@"Big Like", nil)];
    }else{
        likeCountText=[NSString stringWithFormat:@"%lu",(unsigned long)item.likesCount];
    }
    cell.likeCount.text = likeCountText;
    cell.createTime.text = [item localizedCreateTime];
    cell.videoUrl = item.videoUrl;
    cell.itemId = item.itemId;
    cell.like.selected=item.isLiked;
    cell.tag = (int)indexPath.row;

    cell.delegate = self;
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0.001;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 0.001;
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    if(sharedItemList.count > 0){
        NSArray *visibleIndexPath = [self.tableView indexPathsForVisibleRows];
        if([(NSIndexPath*)visibleIndexPath[0] row] > firstVisibleIndex){
            NSIndexPath *lastVisibleIndexPath = [visibleIndexPath lastObject];
            if(hasMorePage && sharedItemList.count - lastVisibleIndexPath.row <= 10){
                [self requestWithPageIndex:++pageIndex];
            }
        }
        firstVisibleIndex = [(NSIndexPath*)visibleIndexPath[0] row];
    }
}

#pragma mark - Request
- (void)requestWithPageIndex:(NSUInteger)index
{
    urlStr = [NSString stringWithFormat:@"%@%@%d",[self.datasource requestUrl],@"?page=",index];
    NSURL *url = [NSURL URLWithString:urlStr];
    ASIHTTPRequest *request = [[ASIHTTPRequest alloc] initWithURL:url];
    request.tag = RequestTypeGetListData;
    request.delegate = self;
    [request startAsynchronous];
    NSLog(@"url = %@",url);
}

#pragma mark - ASIHTTPRequestDelegate
- (void)request:(ASIHTTPRequest *)request didReceiveData:(NSData *)data
{
    int requestTag = request.tag;
    if(requestTag == RequestTypeGetListData){
        NSString *content = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        if(content){
            if(!receivedJSONStr){
                receivedJSONStr = [[NSMutableString alloc] initWithString:content];
            }else{
                [receivedJSONStr appendString:content];
            }
            NSLog(@"接收到得结果--->%@",receivedJSONStr);
        }
    }else if(requestTag == RequestTypeLikeItem){
        
    }
}

- (void)requestFinished:(ASIHTTPRequest *)request
{
    int requestTag = request.tag;
    if(requestTag == RequestTypeGetListData){
        if(self.refreshControl.refreshing){
            [self.refreshControl endRefreshing];
        }
        NSDictionary *tempDict = [receivedJSONStr objectFromJSONString];
        int page = [(NSNumber*)tempDict[@"page"] intValue];
        if([(NSNumber*)tempDict[@"ret"] intValue] != 1){
            if(page > 1){
                hasMorePage = NO;
            }
            return;
        }
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            NSArray *temp = [SharedVideoItem initFromJson:receivedJSONStr];
        if(temp){
            if(temp && temp.count > 0 && page == 1){
                [sharedItemList removeAllObjects];
            }
            [sharedItemList addObjectsFromArray:temp];
            if(orderResult){
                temp = [sharedItemList sortedArrayUsingComparator:^(SharedVideoItem *item1, SharedVideoItem *item2){
                    NSComparisonResult result = NSOrderedSame;
                    if(item1.createTime.longLongValue > item2.createTime.longLongValue){
                        result = NSOrderedAscending;
                    }else if(item1.createTime.longLongValue < item2.createTime.longLongValue){
                        result = NSOrderedDescending;
                    }
                    return result;
                }];
                [sharedItemList removeAllObjects];
                [sharedItemList addObjectsFromArray:temp];
            }
        }
            dispatch_sync(dispatch_get_main_queue(), ^{
                
        [self.tableView reloadData];
            });
        });
        

    }else if(requestTag == RequestTypeLikeItem){
        
    }
}

- (void)requestFailed:(ASIHTTPRequest *)request
{
    if(self.refreshControl.refreshing){
        [self.refreshControl endRefreshing];
    }
    switch(request.tag)
    {
        case RequestTypeGetListData:
{
            [self.view makeToast:@"社区数据请求失败!"];
        }
            break;
        case RequestTypeLikeItem:
            break;
        default:
            break;
    }
}

#pragma mark - refresh control
- (void)refreshControlValueChanged:(UIRefreshControl*)refreshControl
{
    if(refreshControl.refreshing){
        [self setRefreshTitle:NSLocalizedString(@"Loading", nil)];
        [self requestWithPageIndex:1];
    }
}

- (void)setRefreshTitle:(NSString*)title
{
    NSMutableAttributedString *attriStr = [[NSMutableAttributedString alloc] initWithString:title];
    [attriStr setAttributes:@{NSForegroundColorAttributeName:[UIColor whiteColor]} range:NSMakeRange(0, title.length)];
    self.refreshControl.attributedTitle = attriStr;
}

#pragma mark - SharedVideoCellDelegate --- 播放视频由子类处理
- (void)sharedVideoCellPlayAction:(SharedVideoCell *)cell
{
    if([self.delegate respondsToSelector:@selector(playUrl:)]){
        [self.delegate playUrl:[NSURL URLWithString:cell.videoUrl]];
    }
}

//执行点赞---回调给子类处理
- (void)sharedVideoCellLikeAction:(SharedVideoCell *)cell
{
    self.likePosition=cell.tag;
    NSString *token = [Prefs getInstagramToken];
    if(token && ![token isEqualToString:@""]){
        [self execLike:[sharedItemList objectAtIndex:cell.tag] position:cell.tag];
    }else{
        if ([self.delegate respondsToSelector:@selector(requestInstagramAccessToken)]) {
            [self.delegate requestInstagramAccessToken];
        }
    }
    
}

//分享视频
- (void)shareVideoCellShareAction:(SharedVideoCell *)cell
{
    if([self.delegate respondsToSelector:@selector(shareItem:)]){
        [self.delegate shareItem:cell.videoUrl];
    }
}

//执行点赞 flag=NO 取消点赞 ---这里直接用同步方法
-(void) execLike:(SharedVideoItem *)item position:(int)row
{
    [SVProgressHUD showWithStatus:NSLocalizedString(@"like_loading", nil)];
//    [MBProgressHUD showHUDAddedTo:self.view animated:YES].labelText=@"请稍后...";
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSString *result=[NetService reqLikeMedia:item.itemId flag:!item.isLiked token:[Prefs getInstagramToken]];
        NSDictionary * dict=[result objectFromJSONString];
        int resultCode=[[[[dict objectForKey:@"like_status"] objectForKey:@"meta"] objectForKey:@"code"] intValue];
        dispatch_sync(dispatch_get_main_queue(), ^{
            [SVProgressHUD dismiss];
//            [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
            if (resultCode==200) {//标记状态---如果有记录更新数据,如果没有记录插入数据
                if (item.isLiked) {
                    item.likesCount--;
                }else{
                    item.likesCount++;
                }
                int state=item.isLiked?0:1;
                [VideoLike remarkLiked:[Prefs getInstagramToken] mediaid:item.itemId mediaowner:item.userName state:state];
                item.isLiked=!item.isLiked;
                
                NSIndexPath *indexPath=[NSIndexPath indexPathForRow:row inSection:0];
                [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            }else{
                [self.view makeToast:@"点赞失败!"];
            }
        });
    });
    
}

-(void) authFinish:(BOOL)isAuthed
{
    if(isAuthed){
        NSString * token=[Prefs getInstagramToken];
        NSLog(@"返回令牌--->%@",token);
        [self execLike:[sharedItemList objectAtIndex:self.likePosition] position:self.likePosition];
    }else{
        [self.view makeToast:@"授权失败!"];
    }
    
}

@end
