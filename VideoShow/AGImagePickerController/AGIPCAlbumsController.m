//
//  AGIPCAlbumsController.m
//  AGImagePickerController
//
//  Created by Artur Grigor on 2/16/12.
//  Copyright (c) 2012 - 2013 Artur Grigor. All rights reserved.
//  
//  For the full copyright and license information, please view the LICENSE
//  file that was distributed with this source code.
//  

#import "AGIPCAlbumsController.h"

#import "AGImagePickerController.h"
#import "PlayerViewController.h"
#import "qxPlaybackView.h"
#import "qxTimeline.h"
#import "qxMediaObject.h"
#import "qxTrack.h"
#import "ToolBarView.h"
#import "AlbumTableCell.h"

static NSString *cellIdentifier = @"Cell";

@interface AGIPCAlbumsController ()<ToolBarViewDelegate>
{
    NSMutableArray *_assetsGroups;
    AGImagePickerController *_imagePickerController;
}

@property (ag_weak, nonatomic, readonly) NSMutableArray *assetsGroups;

@end

@interface AGIPCAlbumsController ()

- (void)registerForNotifications;
- (void)unregisterFromNotifications;

- (void)didChangeLibrary:(NSNotification *)notification;

- (void)loadAssetsGroups;
- (void)reloadData;

- (void)cancelAction:(id)sender;

@end

@implementation AGIPCAlbumsController

#pragma mark - Properties


- (NSMutableArray *)assetsGroups
{
    if (_assetsGroups == nil)
    {
        _assetsGroups = [[NSMutableArray alloc] init];
        [self loadAssetsGroups];
    }
    
    return _assetsGroups;
}

#pragma mark - Object Lifecycle

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.navigationController setToolbarHidden:YES animated:YES];
    
    [self.navigationController.navigationBar setBackgroundImage:nil forBarMetrics:UIBarMetricsDefault];
    if([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0){
        self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:40/255.0 green:35/255.0 blue:35/255.0 alpha:1.0];
    }else{
        self.navigationController.navigationBar.tintColor = [UIColor colorWithRed:40/255.0 green:35/255.0 blue:35/255.0 alpha:1.0];
    }
    self.navigationController.navigationBar.barStyle = UIBarStyleDefault;
    ((AGImagePickerController*)self.navigationController).toolBar.delegate=self;
    [self checkLayout];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    ((AGImagePickerController*)self.navigationController).toolBar.delegate=nil;
}

-(void) dataChange:(NSMutableArray *)itemArray currentItem:(BaseView*)baseView addFlag:(BOOL)flag
{
    if (!flag) {//删除的情况
        [self checkLayout];
    }
}

-(void) checkLayout
{
    float tableViewTopInset = 0;
    if([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0){
    }else{
        tableViewTopInset = 64;
    }
    ToolBarView *toolbar = ((AGImagePickerController*)self.navigationController).toolBar;
    
    if (toolbar.itemArray.count>0) {
        //
        self.tableView.frame = CGRectMake(0, 0, self.view.frame.size.width, self.navigationController.view.frame.size.height - toolbar.frame.size.height);
        self.tableView.contentInset = UIEdgeInsetsMake(tableViewTopInset, 0, toolbar.frame.size.height, 0);
        [((AGImagePickerController*)self.navigationController).view addSubview:toolbar];
    }else{
        //
        self.tableView.frame = CGRectMake(0, 0, self.view.frame.size.width, self.navigationController.view.frame.size.height);
        self.tableView.contentInset = UIEdgeInsetsMake(tableViewTopInset, 0, 0, 0);
        [toolbar removeFromSuperview];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //navigation bar
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
    
    //title
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 80, 30)];
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.text = NSLocalizedString(@"Select Clip", nil);
    titleLabel.font = [UIFont boldSystemFontOfSize:17];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.textColor = [UIColor whiteColor];
    [titleLabel sizeToFit];
    self.navigationItem.titleView = titleLabel;
    
    //left bar button
    UIView *leftBtnView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 50, 44)];
    leftBtnView.userInteractionEnabled = YES;
    UITapGestureRecognizer *backBtnTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(backViewTap:)];
    [leftBtnView addGestureRecognizer:backBtnTapGesture];
    UIImageView *leftArrow = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"back.png"]];
    leftArrow.frame = CGRectMake(0, 0, 11, 19);
    [leftBtnView addSubview:leftArrow];
    UILabel *leftLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 0, 45, 44)];
    leftLabel.backgroundColor = [UIColor clearColor];
    leftLabel.text = NSLocalizedString(@"Back", nil);
    leftLabel.font = [UIFont boldSystemFontOfSize:17];
    leftLabel.textColor = [UIColor colorWithRed:221/255.0 green:107/255.0 blue:111/255.0 alpha:1.0];
    [leftBtnView addSubview:leftLabel];
    UIBarButtonItem *leftBarButton = [[UIBarButtonItem alloc] initWithCustomView:leftBtnView];
    leftBarButton.style = UIBarButtonItemStylePlain;
    leftArrow.center = CGPointMake(5.5, leftLabel.center.y);
    self.navigationItem.leftBarButtonItem = leftBarButton;
    
    //right bar button
    UILabel *rightLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 80, 44)];
    rightLabel.userInteractionEnabled = YES;
    UITapGestureRecognizer *nextBtnTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(nextAction:)];
    [rightLabel addGestureRecognizer:nextBtnTapGesture];
    rightLabel.backgroundColor = [UIColor clearColor];
    rightLabel.textAlignment = NSTextAlignmentRight;
    rightLabel.font = [UIFont boldSystemFontOfSize:17];
    rightLabel.text = NSLocalizedString(@"Next", nil);
    rightLabel.textColor = [UIColor colorWithRed:221/255.0 green:107/255.0 blue:111/255.0 alpha:1.0];
    UIBarButtonItem *nextButton = [[UIBarButtonItem alloc] initWithCustomView:rightLabel];
    self.navigationItem.rightBarButtonItem = nextButton;
    
    // Fullscreen
    if (((AGImagePickerController*)self.navigationController).shouldChangeStatusBarStyle) {
        self.wantsFullScreenLayout = YES;
    }
    
    // Setup Notifications
    [self registerForNotifications];
    
    //load cell xib
    UINib *nib = [UINib nibWithNibName:@"AlbumTableCell" bundle:nil];
    [self.tableView registerNib:nib forCellReuseIdentifier:cellIdentifier];
    
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Destroy Notifications
    [self unregisterFromNotifications];
}

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

#pragma mark - UITableViewDataSource Methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.assetsGroups.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    AlbumTableCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    ALAssetsGroup *group = (self.assetsGroups)[indexPath.row];
    NSUInteger numberOfAssets = group.numberOfAssets;
    
    cell.subtitle.text = [NSString stringWithFormat:@"%@", [group valueForProperty:ALAssetsGroupPropertyName]];
    cell.detail.text = [NSString stringWithFormat:@"%u", numberOfAssets];
    [cell.image setImage:[UIImage imageWithCGImage:[(ALAssetsGroup *)self.assetsGroups[indexPath.row] posterImage]]];
    return cell;
}

#pragma mark - UITableViewDelegate Methods

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	AGIPCAssetsController *controller = [[AGIPCAssetsController alloc] initWithAssetsGroup:self.assetsGroups[indexPath.row]];
    controller.delegate = self;
	[self.navigationController pushViewController:controller animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{	
	return 60;
}

#pragma mark - Private

- (void)loadAssetsGroups
{
    __ag_weak AGIPCAlbumsController *weakSelf = self;
    
    [self.assetsGroups removeAllObjects];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        
        @autoreleasepool {
            
            void (^assetGroupEnumerator)(ALAssetsGroup *, BOOL *) = ^(ALAssetsGroup *group, BOOL *stop) 
            {
                if (group == nil) 
                {
                    return;
                }
                if(weakSelf.filterType == FilterTypeVideo){
                    [group setAssetsFilter:[ALAssetsFilter allVideos]];
                }else if(weakSelf.filterType == FilterTypePhoto){
                    [group setAssetsFilter:[ALAssetsFilter allPhotos]];
                }else{
                    [group setAssetsFilter:[ALAssetsFilter allAssets]];
                }
                
                if (((AGImagePickerController*)weakSelf.navigationController).shouldShowSavedPhotosOnTop) {
                    if ([[group valueForProperty:ALAssetsGroupPropertyType] intValue] == ALAssetsGroupSavedPhotos && weakSelf.assetsGroups.count > 0) {
                        [weakSelf.assetsGroups insertObject:group atIndex:0];
                    } else if ([[group valueForProperty:ALAssetsGroupPropertyType] intValue] > ALAssetsGroupSavedPhotos && weakSelf.assetsGroups.count > 0) {
                        [weakSelf.assetsGroups insertObject:group atIndex:1];
                    } else {
                        [weakSelf.assetsGroups addObject:group];
                    }
                } else {
                    [weakSelf.assetsGroups addObject:group];
                }
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    [weakSelf reloadData];
                });
            };
            
            void (^assetGroupEnumberatorFailure)(NSError *) = ^(NSError *error) {
                NSLog(@"A problem occured. Error: %@", error.localizedDescription);
                [(AGImagePickerController*)weakSelf.navigationController performSelector:@selector(didFail:) withObject:error];
            };	
            
            [[AGImagePickerController defaultAssetsLibrary] enumerateGroupsWithTypes:ALAssetsGroupAll
                                   usingBlock:assetGroupEnumerator 
                                 failureBlock:assetGroupEnumberatorFailure];
            
        }
        
    });
}

- (void)reloadData
{
    [self.tableView reloadData];
    self.title = NSLocalizedStringWithDefaultValue(@"AGIPC.Albums", nil, [NSBundle mainBundle], @"Albums", nil);
}

- (void)backViewTap:(UITapGestureRecognizer*)tapGesture
{
    [(AGImagePickerController*)self.navigationController performSelector:@selector(didCancelPickingAssets)];
}

-(void)nextAction:(UITapGestureRecognizer*)tapGesture
{
    ToolBarView *toolBar = ((AGImagePickerController*)self.navigationController).toolBar;
    if(toolBar.itemArray.count <= 0){
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Select Element First", nil) message:nil delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil, nil];
        [alertView show];
        return;
    }
    
    PlayerViewController *playerController = [[PlayerViewController alloc] init];
    AGImagePickerController *pickerController = (AGImagePickerController*)self.navigationController;
    qxTrack *videoTrack = nil;
    qxTrack *musicTrack = nil;
    qxTrack *audioTrack = nil;
    qxTrack *overlayTrack = nil;
    qxTimeline *timeline = [[qxTimeline alloc] init];
    if(pickerController.isEditWithTimeline){
        musicTrack = [pickerController.reeditTimeline getTrackFromTimeline:1];
        audioTrack = [pickerController.reeditTimeline getTrackFromTimeline:2];
        overlayTrack = [pickerController.reeditTimeline getTrackFromTimeline:3];
        [pickerController.reeditTimeline delTrack:0];
        [pickerController.reeditTimeline delTrack:1];
        [pickerController.reeditTimeline delTrack:2];
        [pickerController.reeditTimeline delTrack:3];
    }else{
        musicTrack = [[qxTrack alloc] initWithTrackType:eMT_Audio];
        audioTrack = [[qxTrack alloc] initWithTrackType:eMT_Audio];
        overlayTrack = [[qxTrack alloc] initWithTrackType:eMT_Overlay];
    }
    videoTrack = [[qxTrack alloc] initWithTrackType:eMT_Video];
    
    for (BaseView *baseView in  toolBar.itemArray) {
        ALAsset *asset = baseView.item.asset;
        qxMediaObject *mediaObj = [[qxMediaObject alloc] init];
        int type = eMT_Video;
        if([asset valueForProperty:ALAssetPropertyType] == ALAssetTypePhoto){
            type = eMT_Photo;
        }
        
        NSURL *url = [asset valueForProperty:ALAssetPropertyAssetURL];
        [mediaObj setFilePath:[url absoluteString] withType:type fromAssetLibrary:YES];
        
        if(type == eMT_Photo){
            [mediaObj setDuration:3000];
        }
        [videoTrack addMediaObject:mediaObj];
    }
    [timeline addTrack:videoTrack];//0
    [timeline addTrack:musicTrack];//1
    [timeline addTrack:audioTrack];//2
    [timeline addTrack:overlayTrack];//3
    
    playerController.toolbarView = toolBar;
    playerController.timeline = timeline;
    pickerController.isEditWithTimeline = NO;
    pickerController.reeditTimeline = nil;
    [toolBar removeFromSuperview];
    [self.navigationController pushViewController:playerController animated:YES];
}

#pragma mark - Notifications

- (void)registerForNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(didChangeLibrary:) 
                                                 name:ALAssetsLibraryChangedNotification 
                                               object:[AGImagePickerController defaultAssetsLibrary]];
}

- (void)unregisterFromNotifications
{
    [[NSNotificationCenter defaultCenter] removeObserver:self 
                                                    name:ALAssetsLibraryChangedNotification 
                                                  object:[AGImagePickerController defaultAssetsLibrary]];
}

- (void)didChangeLibrary:(NSNotification *)notification
{
    [self loadAssetsGroups];
}

#pragma mark - AGIPCAssetsControllerDelegate
- (void)selectDoneAndNextStep
{
    [self nextAction:nil];
}

#pragma init view with timeline
- (void)resetPikcerWithTimeline:(qxTimeline*)timeline
{
    if(timeline && [timeline getTrackCount] > 0){
        qxTrack *videoTrack = [timeline getTrackFromTimeline:0];
        ALAssetsLibrary *assetsLibrary = [AGImagePickerController defaultAssetsLibrary];
        __ag_weak AGIPCAlbumsController *weakSelf = self;
        __weak ToolBarView *toolBarViewWeakRef = ((AGImagePickerController*)self.navigationController).toolBar;
        __block int i = 0;
        for(qxMediaObject *obj in videoTrack.mpMediaObjArray){
            if(obj){
                [assetsLibrary assetForURL:[NSURL URLWithString:obj.strFilePath] resultBlock:^(ALAsset *asset){
                    AGIPCGridItem *gridItem = [[AGIPCGridItem alloc] initWithImagePickerController:(AGImagePickerController*)weakSelf.navigationController asset:asset andDelegate:nil];
                    [gridItem loadImageFromAsset];
                    [toolBarViewWeakRef addBaseView:gridItem];
                    //-------------------------
                    if(++i == videoTrack.mpMediaObjArray.count){
                        [weakSelf previewWithTimeline:timeline];
                    }
                } failureBlock:^(NSError *error){
                    if(++i == videoTrack.mpMediaObjArray.count){
                        [weakSelf previewWithTimeline:timeline];
                        
                    }
                }];
            }
        }
    }
}

- (void)previewWithTimeline:(qxTimeline*)timeline
{
    ToolBarView *toolBar = ((AGImagePickerController*)self.navigationController).toolBar;
    PlayerViewController *playerController = [[PlayerViewController alloc] init];
    playerController.toolbarView = toolBar;
    playerController.timeline = timeline;
    [toolBar removeFromSuperview];
    [self.navigationController pushViewController:playerController animated:YES];
}

- (void)dealloc
{
    NSLog(@"AGIPCAlbumsController dealloc *****");
}
@end
