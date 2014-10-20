//
//  MyStudioViewController.m
//  VideoShow
//
//  Created by Jerry Chen  on 14-7-16.
//  Copyright (c) 2014年 energy. All rights reserved.
//

#import "MyStudioViewController.h"
#import "MobClick.h"
#import "MyStudioVideoCell.h"
#import "VideoPlayerViewController.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import "Util.h"
#import "VideoDraft.h"
#import "AGImagePickerController.h"
#import "AGIPCAlbumsController.h"
#import "qxTimeline.h"
#import "SettingViewController.h"
#import "SVProgressHUD.h"
#import "AppMacros.h"
#import "AppEvent.h"
#import "IconActionSheet.h"
#import "PortraitNavigationController.h"

static int lineWidth = 100;
static NSString *cellIdentifier = @"MyStudioVideoCell";

@interface MyStudioViewController()
@property (nonatomic,assign) CGRect screenBounds;

@property (nonatomic,retain) UIView * naviLine;
@property (nonatomic,retain) UIButton * btnDraft;
@property (nonatomic,retain) UIButton * btnMyVideo;

@end

@implementation MyStudioViewController
{
    NSURL *deleteURL;
}

@synthesize screenBounds;
@synthesize naviLine;
@synthesize btnDraft;
@synthesize btnMyVideo;

#pragma mark - view life cycle
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    myDraftArray = [[NSMutableArray alloc] init];
    myVideoArray = [[NSMutableArray alloc] init];
    
    screenBounds = [UIScreen mainScreen].bounds;
    
    //navigation bar
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
        self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:40/255.0 green:35/255.0 blue:35/255.0 alpha:1.0];
    }else{
        self.navigationController.navigationBar.tintColor = [UIColor colorWithRed:40/255.0 green:35/255.0 blue:35/255.0 alpha:1.0];
    }
    self.navigationController.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"black_bg.png"]];
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100, 30)];
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.text =NSLocalizedString(@"My Studio", nil);
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.textColor = [UIColor whiteColor];
    titleLabel.font=[UIFont boldSystemFontOfSize:17];
    [titleLabel sizeToFit];
    self.navigationItem.titleView = titleLabel;
    self.view.backgroundColor = [UIColor clearColor];

    //left barbutton
    UIButton *closeBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 22, 38)];
    [closeBtn setImage:[UIImage imageNamed:@"back.png"] forState:UIControlStateNormal];
    [closeBtn setImageEdgeInsets:UIEdgeInsetsMake(9.5, 0, 9.5, 11)];
    [closeBtn addTarget:self action:@selector(closeButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *leftBarButton = [[UIBarButtonItem alloc] initWithCustomView:closeBtn];
    self.navigationItem.leftBarButtonItem = leftBarButton;
    
    //right barbutton
    UIButton *settingBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 25, 25)];
    [settingBtn setImage:[UIImage imageNamed:@"setting.png"] forState:UIControlStateNormal];
    [settingBtn addTarget:self action:@selector(settingButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *rightBarButton = [[UIBarButtonItem alloc] initWithCustomView:settingBtn];
    self.navigationItem.rightBarButtonItem = rightBarButton;
    
    
    //top white line
    UIView *whiteLine = [[UIView alloc] initWithFrame:CGRectMake(0, 0, screenBounds.size.width, 0.5)];
    whiteLine.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.3];
    [self.view addSubview:whiteLine];
    
    //view control
    btnDraft = [[UIButton alloc] initWithFrame:CGRectMake(0, 0.5, screenBounds.size.width/2, 45)];
    btnDraft.tag=0;
    btnDraft.backgroundColor=[UIColor clearColor];
    [btnDraft setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [btnDraft setTitle:NSLocalizedString(@"My Draft", nil) forState:UIControlStateNormal];
    btnDraft.contentMode=UIViewContentModeCenter;
    btnDraft.titleLabel.font=[UIFont systemFontOfSize:17];
    [btnDraft addTarget:self action:@selector(tabAction:) forControlEvents:UIControlEventTouchUpInside];
    //-------------------------------------
    btnMyVideo = [[UIButton alloc] initWithFrame:CGRectMake(screenBounds.size.width/2, 0.5, screenBounds.size.width/2, 45)];
    btnMyVideo.tag=1;
    btnMyVideo.backgroundColor=[UIColor clearColor];
    [btnMyVideo setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [btnMyVideo setTitle:NSLocalizedString(@"My Video", nil) forState:UIControlStateNormal];
    btnMyVideo.contentMode=UIViewContentModeCenter;
    btnMyVideo.titleLabel.textAlignment=NSTextAlignmentCenter;
    btnMyVideo.titleLabel.font=[UIFont systemFontOfSize:17];
    [btnMyVideo addTarget:self action:@selector(tabAction:) forControlEvents:UIControlEventTouchUpInside];
    
    UIView * tabView=[[UIView alloc] initWithFrame:CGRectMake(0,0,screenBounds.size.width, 45)];
    tabView.backgroundColor = [UIColor colorWithRed:40/255.0 green:35/255.0 blue:35/255.0 alpha:1];
    
    UIView * spaceLine=[[UIView alloc] initWithFrame:CGRectMake(screenBounds.size.width/2-0.5, 3, 1, tabView.frame.size.height-6)];
    spaceLine.backgroundColor=[UIColor colorWithRed:31/255.0 green:4/255.0 blue:4/255.0 alpha:1];
    
    naviLine=[[UIView alloc] initWithFrame:CGRectMake(0, tabView.frame.size.height-3, lineWidth, 3)];
    naviLine.backgroundColor=[UIColor colorWithRed:221/255.0 green:107/255.0 blue:111/255.0 alpha:1.0];
    
    [tabView addSubview:btnDraft];
    [tabView addSubview:btnMyVideo];
    [tabView addSubview:spaceLine];
    [tabView addSubview:naviLine];
    [self.view addSubview:tabView];
    
    // UITableView
    videoTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, tabView.frame.origin.y + tabView.frame.size.height, screenBounds.size.width, screenBounds.size.height - 64 - tabView.frame.size.height) style:UITableViewStylePlain];

    [self.view addSubview:videoTableView];
    videoTableView.dataSource = self;
    videoTableView.delegate = self;
    videoTableView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"black_bg.png"]];
    videoTableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    if (sysVersion >= 7) {
        videoTableView.separatorInset = UIEdgeInsetsZero;
    }
    if ([videoTableView respondsToSelector:@selector(setLayoutMargins:)]) {
        [videoTableView setLayoutMargins:UIEdgeInsetsZero];
    }
    //需要修改颜色
    videoTableView.separatorColor = [UIColor colorWithRed:23/255.0 green:2/255.0 blue:2/255.0 alpha:1.0];
    //remove the header/footer separator line
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 0.001)];
    view.backgroundColor = [UIColor clearColor];
    [videoTableView setTableFooterView:view];
    [videoTableView setTableHeaderView:view];
    
    //load cell nib
    UINib *nib = [UINib nibWithNibName:@"MyStudioVideoCell" bundle:nil];
    [videoTableView registerNib:nib forCellReuseIdentifier:cellIdentifier];
    
    //
    [self tabAction:btnMyVideo];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(screenTouchNotification:) name:@"ScreenTouchNotification" object:nil];
}

- (BOOL)shouldAutorotate
{
    return NO;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
    return UIInterfaceOrientationPortrait;
}

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

-(void)screenTouchNotification:(NSNotification  *)notificatioin
{
    UIEvent *event = [[notificatioin userInfo] objectForKey:@"event"];
    if ([[[event allTouches] allObjects] count] > 0) {
        UITouch *touch = [[[event allTouches] allObjects] objectAtIndex:0];
        CGPoint touchPoint = [touch locationInView:self.view];
        if(![self isPointInActionView:touchPoint]){
            [shareActionSheet dismissView];
        }
    }
}

- (BOOL)isPointInActionView:(CGPoint)point
{
    BOOL res = NO;
    if(shareActionSheet && shareActionSheet.isShowing){
        if(point.x >= shareActionSheet.frame.origin.x &&
           point.x < shareActionSheet.frame.origin.x + shareActionSheet.frame.size.width &&
           point.y >= shareActionSheet.frame.origin.y &&
           point.y <= shareActionSheet.frame.origin.y + shareActionSheet.frame.size.height){
            res = YES;
        }
    }
    return res;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewWillAppear:(BOOL)animated
{
    [self addObserver:self forKeyPath:@"currentStatusMyVideo" options:NSKeyValueObservingOptionNew context:NULL];
    [super viewWillAppear:animated];
    [MobClick beginLogPageView:@"MyStudioViewController"];
    //
    [self loadData];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [self removeObserver:self forKeyPath:@"currentStatusMyVideo"];
    [super viewWillDisappear:animated];
    [MobClick endLogPageView:@"MyStudioViewController"];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if([keyPath isEqualToString:@"currentStatusMyVideo"]){
        [videoTableView reloadData];
    }
}

#pragma mark - button acion
- (void)closeButtonAction:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark 设置
- (void)settingButtonAction:(id)sender
{
    [MobClick endEvent: CLICK_MAINMENU_SETTING];
    SettingViewController *settingVC = [[SettingViewController alloc] initWithStyle:UITableViewStyleGrouped];
    UINavigationController *nav = [[PortraitNavigationController alloc] initWithRootViewController:settingVC];
    [self presentViewController:nav animated:YES completion:nil];
}

-(void) tabAction:(UIButton *)sender
{
    switch (sender.tag) {
        case 0://草稿箱
        {
            [MobClick endEvent: CLICK_MAINMENU_DRAFTBOX];
            self.currentStatusMyVideo = NO;
        }
            break;
        case 1://我的视频
        {
            [MobClick endEvent: CLICK_MAINMENU_MY_WORKS];
            self.currentStatusMyVideo = YES;
        }
        default:
            break;
    }
    [UIView animateWithDuration:.3f animations:^{
        int tabWitdh=screenBounds.size.width/2;
        CGRect tmpRect=self.naviLine.frame;
        tmpRect.origin.x=sender.frame.origin.x+(tabWitdh-lineWidth)/2;
        self.naviLine.frame=tmpRect;
    }completion:^(BOOL finish){
    }];
}

- (NSString*)localizedTime:(NSDate*)date
{
    NSString *s = @"";
    if(date){
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm"];
        s = [NSString stringWithFormat:@"%@",[dateFormatter stringFromDate:date]];
    }
    return s;
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(self.currentStatusMyVideo){
        return myVideoArray.count;
    }else{
        return myDraftArray.count;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    MyStudioVideoCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        [cell setLayoutMargins:UIEdgeInsetsZero];
    }
    cell.delegate = self;
    if(self.currentStatusMyVideo){
        cell.isDraft = NO;
        cell.draft = nil;
        cell.shareButton.hidden = NO;
        ALAsset *asset = myVideoArray[indexPath.row];
        cell.videoURL = [asset valueForProperty:ALAssetPropertyAssetURL];
        NSDate *date = [asset valueForProperty:ALAssetPropertyDate];
        cell.timeLabel.text = [self localizedTime:date];
        
        __weak MyStudioVideoCell *weakCellRef = cell;
        __weak MyStudioViewController *weakSelf = self;
        //使用异步加载图片避免显示列表滑动不流畅
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            UIImage * image=[weakSelf imageFromALAsset:asset];
            dispatch_sync(dispatch_get_main_queue(), ^{
                if(weakCellRef.videoImage!=nil){
                    weakCellRef.videoImage.image = image;
                }
            });
        });
        [cell.controlButton setImage:[UIImage imageNamed:@"play.png"] forState:UIControlStateNormal];
    }else{
        VideoDraft *draft = myDraftArray[indexPath.row];
        cell.timeLabel.text = [self localizedTime:draft.createDate];
        cell.videoURL = [NSURL URLWithString:draft.draftPath];
        cell.isDraft = YES;
        cell.draft = draft;
        cell.shareButton.hidden = YES;
        [cell.controlButton setImage:[UIImage imageNamed:@"draft_edit.png"] forState:UIControlStateNormal];
        ALAssetsLibrary *library = [Util defaultAssetsLibrary];
        qxTrack *track = [draft.timeline getTrackFromTimeline:0];
        qxMediaObject *obj = track.mpMediaObjArray[0];
        cell.videoImage.image=[UIImage imageNamed:@"icon_net_default.png"];
        __weak MyStudioVideoCell *weakCellRef = cell;
        __weak MyStudioViewController *weakSelf = self;
        [library assetForURL:[NSURL URLWithString:obj.strFilePath] resultBlock:^(ALAsset *asset){
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                UIImage * image=[weakSelf imageFromALAsset:asset];
                dispatch_async(dispatch_get_main_queue(), ^{
                    if(weakCellRef.videoImage!=nil){
                        weakCellRef.videoImage.image = image;
                    }
                });
            });
        } failureBlock:^(NSError *error){
            weakCellRef.videoImage.image = nil;
        }];
    }
    return cell;
}

-(UIImage*)imageFromALAsset:(ALAsset*)asset
{
    UIImage *img = nil;
    if(asset){
        ALAssetRepresentation *representation = [asset defaultRepresentation];
        if(representation){
            NSNumber *orientation = [asset valueForProperty:ALAssetPropertyOrientation];
            switch (orientation.intValue) {
                case 1:
                    img = [UIImage imageWithCGImage:representation.fullResolutionImage scale:1.0 orientation:UIImageOrientationDown];
                    break;
                    
                case 2:
                    img = [UIImage imageWithCGImage:representation.fullResolutionImage scale:1.0 orientation:UIImageOrientationLeft];
                    break;
                    
                case 3:
                    img = [UIImage imageWithCGImage:representation.fullResolutionImage scale:1.0 orientation:UIImageOrientationRight];
                    break;
                    
                default:
                    img = [UIImage imageWithCGImage:representation.fullResolutionImage];
            }
        }
    }
    return img;
}

#pragma mark - UITableViewDelegate
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 400.0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0.001;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 0.001;
}

#pragma mark - MyStudioVideoCellDelegate
- (void)playVideo:(NSURL *)videoUrl
{
    VideoPlayerViewController *videoPlayerViewController = [[VideoPlayerViewController alloc] initWithContentURL:videoUrl];
    videoPlayerViewController.moviePlayer.shouldAutoplay = YES;
    videoPlayerViewController.moviePlayer.controlStyle = MPMovieControlStyleFullscreen;
    [videoPlayerViewController.moviePlayer prepareToPlay];
    [self presentViewController:videoPlayerViewController animated:YES completion:nil];
}

- (void)deleteVideo:(NSURL *)videoUrl
{
    deleteURL = videoUrl;
    videoDeleteAlertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Confirm to Delete", nil) message:nil delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel", nil) otherButtonTitles:NSLocalizedString(@"Confirm", nil), nil];
    [videoDeleteAlertView show];
}

- (void)editDraft:(VideoDraft *)draft
{
    if(draft){
        [self handleDraftEditing:draft];
    }
}

- (void)deleteDraft:(NSURL *)draftUrl
{
    deleteURL = draftUrl;
    draftDeleteAlertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Confirm to Delete", nil) message:nil delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel", nil) otherButtonTitles:NSLocalizedString(@"Confirm", nil), nil];
    [draftDeleteAlertView show];
}

- (void)shareVideo:(NSURL *)videoUrl
{
    shareURL = videoUrl;
    [self showActionSheet];
}

- (void)showActionSheet
{
    shareActionSheet = [IconActionSheet sheetWithTitle:nil];
    __weak IconActionSheet *weakActionSheetRef = shareActionSheet;
    __weak MyStudioViewController *weakSelfRef = self;
    //
    [shareActionSheet addIconWithTitle:@"Facebook" image:[UIImage imageNamed:@"facebook.png"] block:^{
        [weakSelfRef shareToFB];
        [weakActionSheetRef dismissView];
    } atIndex:-1];
    //
    [shareActionSheet addIconWithTitle:@"YouTube" image:[UIImage imageNamed:@"youtube.png"] block:^{
        [weakSelfRef shareToYTB];
        [weakActionSheetRef dismissView];
    } atIndex:-1];
    [shareActionSheet showInView:self.view];
}

- (void)shareToFB
{
    ALAssetsLibrary *library = [Util defaultAssetsLibrary];
    [library assetForURL:shareURL resultBlock:^(ALAsset *asset){
        [Util uploadVideoALAssetToFacebook:asset];
    } failureBlock:^(NSError *error){
        [SVProgressHUD showSuccessWithStatus:NSLocalizedString(@"Upload Failed", nil) duration:2.0];
    }];
}

- (void) shareToYTB
{
    if(!ytbHelper){
        ytbHelper = [[YouTubeHelper alloc] initWithDelegate:self];
    }
    [ytbHelper storedAuth];
    if([ytbHelper isAuthValid]){
        [self uploadVideoToYTB:shareURL.absoluteString];
    }else{
        [ytbHelper authenticate];
    }
}

- (void)shareToInstagram
{
    NSURL *instagramURL = [NSURL URLWithString:@"instagram://app"];
    if ([[UIApplication sharedApplication] canOpenURL:instagramURL]) {
        [[UIApplication sharedApplication] openURL:instagramURL];
    }else{
        [Util showErrorAlertWithMessage:NSLocalizedString(@"Please install Instagram first", nil)];
    }
}

#pragma AGImagePickerController
- (void)handleDraftEditing:(VideoDraft*)draft
{
    AGImagePickerController *agImagePickerController = [[AGImagePickerController alloc] initWithFilterType:FilterTypeNone];
    __weak AGImagePickerController *weakRef = agImagePickerController;
    [self presentViewController:agImagePickerController animated:YES completion:^{
        [(AGIPCAlbumsController*)weakRef.topViewController resetPikcerWithTimeline:draft.timeline];
    }];
}

#pragma mark - data handler
- (void)loadData
{
    __weak UITableView *videoTableViewRef = videoTableView;
    __weak MyStudioViewController *weakSelf = self;
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        MyStudioViewController *tmpSelf = weakSelf;
        [tmpSelf loadMyVideo];
        [tmpSelf loadDrafts];
        dispatch_async(dispatch_get_main_queue(), ^{
            UITableView *tmpTableViewRef = videoTableViewRef;
            [tmpTableViewRef reloadData];
            [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        });
    });
}

- (void)loadDrafts
{
    [myDraftArray removeAllObjects];
    NSString *draftDir = [Util draftDir];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if(draftDir && [fileManager fileExistsAtPath:draftDir]){
        NSDirectoryEnumerator *dirEnumerator = [fileManager enumeratorAtPath:draftDir];
        NSString *filename ;
        VideoDraft *draft = nil;
        while (filename = [dirEnumerator nextObject]) {
            filename = [draftDir stringByAppendingPathComponent:filename];
            draft = [Util unArchiveDraft:filename];
            if(draft){
                draft.draftPath = filename;
                [myDraftArray addObject:draft];
            }else{
                [Util deleteDraft:filename];
            }
        }
        [self sortDraftArray];
    }
}

- (void)sortDraftArray
{
    if(myDraftArray && myDraftArray.count > 0){
        NSArray *tmp = [myDraftArray sortedArrayUsingComparator:^(VideoDraft *draft1, VideoDraft *draft2){
            NSComparisonResult result = NSOrderedSame;
            if([draft1.createDate laterDate:draft2.createDate]){
                result = NSOrderedDescending;
            }else if([draft1.createDate earlierDate:draft2.createDate]){
                result = NSOrderedAscending;
            }
            return result;
        }];
        [myDraftArray removeAllObjects];
        [myDraftArray addObjectsFromArray:tmp];
    }
}

- (void)sortMyVideoArray
{
    __weak UITableView *videoTableViewRef = videoTableView;
    if(myVideoArray && myVideoArray.count > 0){
        NSArray *tmp = [myVideoArray sortedArrayUsingComparator:^(ALAsset *asset1, ALAsset *asset2){
            NSComparisonResult result = NSOrderedSame;
            NSDate *date1 = [asset1 valueForProperty:ALAssetPropertyDate];
            NSDate *date2 = [asset2 valueForProperty:ALAssetPropertyDate];
            if([date1 laterDate:date2]){
                result = NSOrderedDescending;
            }else if([date1 earlierDate:date2]){
                result = NSOrderedAscending;
            }
            return result;
        }];
        [myVideoArray removeAllObjects];
        [myVideoArray addObjectsFromArray:tmp];
        dispatch_async(dispatch_get_main_queue(), ^{
            UITableView *tmpTableViewRef = videoTableViewRef;
            [tmpTableViewRef reloadData];
            [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        });
    }
}

- (void)loadMyVideo
{
    [myVideoArray removeAllObjects];
    __weak NSMutableArray *videoArrayWeakRef = myVideoArray;
    __weak MyStudioViewController *selfWeakRef = self;
    void (^assetGroupEnumerator)(ALAssetsGroup *, BOOL *) = ^(ALAssetsGroup *group, BOOL *stop)
    {
        if (group == nil)
        {
            return;
        }
        NSString *groupName = [group valueForProperty:ALAssetsGroupPropertyName];
        if(groupName != nil && [groupName isEqualToString:@"VideoShow"]){
            [group setAssetsFilter:[ALAssetsFilter allVideos]];
            [group enumerateAssetsUsingBlock:^(ALAsset *asset, NSUInteger index, BOOL *stop){
                if(asset){
                    NSMutableArray *tmpVideoArrayRef = videoArrayWeakRef;
                    [tmpVideoArrayRef addObject:asset];
                }
                if(!asset){
                    *stop = YES;
                    [selfWeakRef sortMyVideoArray];
                }
            }];
            *stop = YES;
        }
    };
    
    void (^assetGroupEnumberatorFailure)(NSError *) = ^(NSError *error) {
        NSLog(@"Group Enumberation Failure  : %@",error);
    };
    
    ALAssetsLibrary *assetsLibrary = [Util defaultAssetsLibrary];
   [assetsLibrary enumerateGroupsWithTypes:ALAssetsGroupAll usingBlock:assetGroupEnumerator failureBlock:assetGroupEnumberatorFailure];
}

#pragma mark - UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(!deleteURL){
        return;
    }
    if(buttonIndex == 1){//confirm
        if(alertView == videoDeleteAlertView){
            __weak UITableView *weakTableViewRef = videoTableView;
            __weak NSMutableArray *weakVideoArrayRef = myVideoArray;
            ALAssetsLibrary *assetsLibrary = [Util defaultAssetsLibrary];
            [assetsLibrary assetForURL:deleteURL resultBlock:^(ALAsset *asset){
                if(asset){
                    [weakVideoArrayRef removeObject:asset];
                    [weakTableViewRef reloadData];
                    [asset setImageData:nil metadata:nil completionBlock:nil];
                }
            } failureBlock:nil];
        }else if(alertView == draftDeleteAlertView){
            for(VideoDraft *draft in myDraftArray){
                if([draft.draftPath isEqualToString:[deleteURL absoluteString]]){
                    [myDraftArray removeObject:draft];
                    break;
                }
            }
            [Util deleteDraft:[deleteURL absoluteString]];
            [videoTableView reloadData];
        }
    }
}

#pragma mark - YouTubeHelperDelegate
- (NSString *)youtubeAPIClientID
{
    return youtube_key;
}

- (NSString *)youtubeAPIClientSecret
{
    return youtube_secret;
}

- (void)showAuthenticationViewController:(UIViewController *)authView
{
    [self presentViewController:authView animated:YES completion:nil];
}

- (void)authenticationEndedWithError:(NSError *)error
{
    [self dismissViewControllerAnimated:YES completion:nil];
    if(error){
        [Util showErrorAlertWithMessage:NSLocalizedString(@"Authorization Failure", nil)];
    }else{
        [self uploadVideoToYTB:shareURL.absoluteString];
    }
}

- (void)uploadProgressPercentage:(int)percentage
{
    if(percentage >= 100){
        [SVProgressHUD dismiss];
        [SVProgressHUD showSuccessWithStatus:NSLocalizedString(@"Upload Success", nil) duration:2.0];
    }
}

- (void)uploadVideoDoneWithError:(NSError *)error
{
    [SVProgressHUD dismiss];
    if(error){
        [SVProgressHUD showSuccessWithStatus:NSLocalizedString(@"Upload Failed", nil) duration:2.0];
    }
}

- (void)uploadVideoToYTB:(NSString*)videoPath
{
    if(!ytbHelper){
        ytbHelper = [[YouTubeHelper alloc] initWithDelegate:self];
    }
    [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeClear];
    ALAssetsLibrary *library = [Util defaultAssetsLibrary];
    __weak YouTubeHelper *weakHelper = ytbHelper;
    [library assetForURL:shareURL resultBlock:^(ALAsset *asset){
        NSString *file = [Util generateTempFileFromALAsset:asset];
        if(file){
            [weakHelper uploadPrivateVideoWithTitle:@"VideoShow" description:nil commaSeperatedTags:@"VideoShow" andPath:file];
        }else{
            [SVProgressHUD dismiss];
            [Util showErrorAlertWithMessage:NSLocalizedString(@"Upload Failed", nil)];
        }
    } failureBlock:^(NSError *error){
        [SVProgressHUD dismiss];
        [Util showErrorAlertWithMessage:NSLocalizedString(@"Upload Failed", nil)];
    }];
}
@end
