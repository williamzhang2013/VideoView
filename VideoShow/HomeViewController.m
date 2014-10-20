//
//  HomeViewController.m
//  VideoShow
//
//  Created by Jerry Chen  on 14-7-15.
//  Copyright (c) 2014年 energy. All rights reserved.
//

#import "HomeViewController.h"
#import "MyStudioViewController.h"
#import "AdViewController.h"
#import "JSONKit.h"
#import "AdItem.h"
#import "MobClick.h"
#import "qxTimeline.h"
#import "AGIPCAlbumsController.h"
#import "SVProgressHUD.h"
#import "Util.h"
#import "UIImageView+WebCache.h"
#import "PortraitNavigationController.h"
#import "AppEvent.h"

#define AdImageHeight 163

@implementation HomeViewController

#pragma mark - ViewController life cycle
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //view
    screenBounds = [UIScreen mainScreen].bounds;
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"black_bg.png"]];
        
    //ad
    adScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 10, screenBounds.size.width, AdImageHeight)];
    adScrollView.delegate = self;
    adScrollView.bounces = YES;
    adScrollView.scrollEnabled = YES;
    adScrollView.pagingEnabled = YES;
    adScrollView.showsHorizontalScrollIndicator = NO;
    adScrollView.showsVerticalScrollIndicator = NO;
    [self.view addSubview:adScrollView];
    
    pageControl = [[UIPageControl alloc] initWithFrame:CGRectMake(0, 0 , 100, 30)];
    pageControl.center = CGPointMake(screenBounds.size.width/2, adScrollView.frame.origin.y+adScrollView.frame.size.height - pageControl.frame.size.height/2);
    [pageControl addTarget:self action:@selector(pageChanged:) forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:pageControl];
    
    //module view
    CGFloat imgCenterOffset = 20;
    if(screenBounds.size.height == 480){
        imgCenterOffset = 10;
    }
    
    CGFloat h = (screenBounds.size.height - 64 - 10 - 163 - 30)/2;
    CGFloat w = (screenBounds.size.width - 30)/2;
    UIView *advancedEditView = [[UIView alloc] initWithFrame:CGRectMake(10, adScrollView.frame.origin.y + adScrollView.frame.size.height + 10, w, h)];
    advancedEditView.userInteractionEnabled = YES;
    advancedEditView.layer.cornerRadius = 6;
    advancedEditView.layer.masksToBounds = YES;
    advancedEditView.backgroundColor = [UIColor colorWithRed:52/255.0 green:170/255.0 blue:220/255.0 alpha:1.0];
    UITapGestureRecognizer *advancedEditTapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleAdvancedEditTapGesture:)];
    [advancedEditView addGestureRecognizer:advancedEditTapGestureRecognizer];
    UIImageView *advancedEditViewImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"video_edit.png"]];
    CGRect rect = advancedEditViewImageView.frame;
    rect.size = CGSizeMake(rect.size.width/2, rect.size.height/2);
    advancedEditViewImageView.frame = rect;
    advancedEditViewImageView.center = CGPointMake(advancedEditView.frame.size.width/2, advancedEditView.frame.size.height/2-imgCenterOffset);
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, advancedEditView.frame.size.width, 20)];
    label.textAlignment = NSTextAlignmentCenter;
    CGPoint point = advancedEditViewImageView.center;
    point.y += (advancedEditViewImageView.frame.size.height/2 + 15);
    label.center = point;
    label.text = NSLocalizedString(@"Advanced Edit", nil);
    label.backgroundColor = [UIColor clearColor];
    label.textColor = [UIColor whiteColor];
    [advancedEditView addSubview:label];
    [advancedEditView addSubview:advancedEditViewImageView];
    [self.view addSubview:advancedEditView];
    //----------------------------------------------
    UIView *videoView = [[UIView alloc] initWithFrame:CGRectMake(advancedEditView.frame.origin.x + advancedEditView.frame.size.width +10, adScrollView.frame.origin.y + adScrollView.frame.size.height + 10, w, h)];
    videoView.userInteractionEnabled = YES;
    videoView.layer.cornerRadius = 6;
    videoView.layer.masksToBounds = YES;
    videoView.backgroundColor = [UIColor colorWithRed:245/255.0 green:150/255.0 blue:14/255.0 alpha:1.0];
    UITapGestureRecognizer *videoTapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleVideoTapGesture:)];
    [videoView addGestureRecognizer:videoTapGestureRecognizer];
    UIImageView *videoViewImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"video_record.png"]];
    rect = videoViewImageView.frame;
    rect.size = CGSizeMake(rect.size.width/2, rect.size.height/2);
    videoViewImageView.frame = rect;
    videoViewImageView.center = CGPointMake(videoView.frame.size.width/2, videoView.frame.size.height/2-imgCenterOffset);
    label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, videoView.frame.size.width, 20)];
    label.textAlignment = NSTextAlignmentCenter;
    point = videoViewImageView.center;
    point.y += (videoViewImageView.frame.size.height/2 + 15);
    label.center = point;
    label.text = NSLocalizedString(@"The Video", nil);
    label.backgroundColor = [UIColor clearColor];
    label.textColor = [UIColor whiteColor];
    [videoView addSubview:label];
    [videoView addSubview:videoViewImageView];
    [self.view addSubview:videoView];
    //-------------------------------------------------
    UIView *photoVideoView = [[UIView alloc] initWithFrame:CGRectMake(10, advancedEditView.frame.origin.y + advancedEditView.frame.size.height + 10, w, h)];
    photoVideoView.userInteractionEnabled = YES;
    photoVideoView.layer.cornerRadius = 6;
    photoVideoView.layer.masksToBounds = YES;
    photoVideoView.backgroundColor = [UIColor colorWithRed:249/255.0 green:67/255.0 blue:18/255.0 alpha:1.0];
    UITapGestureRecognizer *photoVideoTapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handlePhotoVideoTapGesture:)];
    [photoVideoView addGestureRecognizer:photoVideoTapGestureRecognizer];
    UIImageView *photoVideoViewImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"photo.png"]];
    rect = photoVideoViewImageView.frame;
    rect.size = CGSizeMake(rect.size.width/2, rect.size.height/2);
    photoVideoViewImageView.frame = rect;
    photoVideoViewImageView.center = CGPointMake(photoVideoView.frame.size.width/2, photoVideoView.frame.size.height/2-imgCenterOffset);
    label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, photoVideoView.frame.size.width, 20)];
    label.textAlignment = NSTextAlignmentCenter;
    point = photoVideoViewImageView.center;
    point.y += (photoVideoViewImageView.frame.size.height/2 + 15);
    label.center = point;
    label.text = NSLocalizedString(@"Photo Video", nil);
    label.backgroundColor = [UIColor clearColor];
    label.textColor = [UIColor whiteColor];
    [photoVideoView addSubview:label];
    [photoVideoView addSubview:photoVideoViewImageView];
    [self.view addSubview:photoVideoView];
    //----------------------------------------------------
    UIView *studioView = [[UIView alloc] initWithFrame:CGRectMake(photoVideoView.frame.origin.x + photoVideoView.frame.size.width +10, videoView.frame.origin.y + videoView.frame.size.height + 10, w, h)];
    studioView.userInteractionEnabled = YES;
    studioView.layer.cornerRadius = 6;
    studioView.layer.masksToBounds = YES;
    studioView.backgroundColor = [UIColor colorWithRed:119/255.0 green:55/255.0 blue:120/255.0 alpha:1.0];
    UITapGestureRecognizer *studioTapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleStudioTapGesture:)];
    [studioView addGestureRecognizer:studioTapGestureRecognizer];
    UIImageView *studioViewImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"my_studio.png"]];
    rect = studioViewImageView.frame;
    rect.size = CGSizeMake(rect.size.width/2, rect.size.height/2);
    studioViewImageView.frame = rect;
    studioViewImageView.center = CGPointMake(studioView.frame.size.width/2, studioView.frame.size.height/2-imgCenterOffset);
    label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, studioView.frame.size.width, 20)];
    label.textAlignment = NSTextAlignmentCenter;
    point = studioViewImageView.center;
    point.y += (studioViewImageView.frame.size.height/2 + 15);
    label.center = point;
    label.text = NSLocalizedString(@"My Studio", nil);
    label.backgroundColor = [UIColor clearColor];
    label.textColor = [UIColor whiteColor];
    [studioView addSubview:label];
    [studioView addSubview:studioViewImageView];
    [self.view addSubview:studioView];
    
    totalAdCount = 0;
    [self loadAd];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [MobClick beginLogPageView:@"HomeViewController"];
    //load ad
    if(adlist.count == 0){
        [self requestAdInfo];

    }
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self startPageControlTimer];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [MobClick endLogPageView:@"HomeViewController"];
}

-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [self stopPageControlTimer];
}

- (BOOL)shouldAutorotate
{
    return NO;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
    return UIInterfaceOrientationPortrait;
}

#pragma mark - PageContorl ValueChanged
- (void)pageChanged:(UIPageControl*)page
{
    NSInteger index = page.currentPage;
    [adScrollView scrollRectToVisible:CGRectMake(320*index, 0, 320, adScrollView.frame.size.height) animated:YES];
}

#pragma mark - ScrollView Delegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    CGFloat pageWith = scrollView.frame.size.width;
    int page = floor((scrollView.contentOffset.x - pageWith/2)/pageWith)+1;
    pageControl.currentPage = page;
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [self stopPageControlTimer];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    [self startPageControlTimer];
}

#pragma mark - PageControl Timer
- (void)startPageControlTimer
{
    if(totalAdCount > 1 && ![pageControlTimer isValid]){
        pageControlTimer = [NSTimer scheduledTimerWithTimeInterval:3.5 target:self selector:@selector(pageControlTask) userInfo:nil repeats:YES];
    }
}

- (void)stopPageControlTimer
{
    if([pageControlTimer isValid]){
        [pageControlTimer invalidate];
    }
}

- (void)pageControlTask
{
    NSInteger pageNum = pageControl.currentPage;
    CGSize viewSize = adScrollView.frame.size;
    pageNum++;
    CGRect newRect;
    if (pageNum == totalAdCount) {
        newRect=CGRectMake(0, 0, viewSize.width, viewSize.height);
        
    }else{
        newRect = CGRectMake(pageNum*viewSize.width, 0, viewSize.width, viewSize.height);
    }
    [adScrollView scrollRectToVisible:newRect animated:YES];
}

#pragma mark - TapGesture
- (void)handleAdvancedEditTapGesture:(UITapGestureRecognizer*)gesture
{
    [MobClick endEvent: CLICK_EDITOR_SCREEN_EXPORT];
    AGImagePickerController *agImagePickerController = [self imagePickerWithFilterType:FilterTypeNone];
    [self.pageControler presentViewController:agImagePickerController animated:YES completion:nil];
}

- (AGImagePickerController *)imagePickerWithFilterType:(FilterType)filter
{
    AGImagePickerController *agImagePickerController = [[AGImagePickerController alloc] initWithFilterType:filter];
    return agImagePickerController;
}

- (void)handleVideoTapGesture:(UITapGestureRecognizer*)gesture
{
    [MobClick endEvent: CLICK_MAINMENU_RECORD];
    if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]){
        UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
        imagePickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
        imagePickerController.delegate = self;
        imagePickerController.mediaTypes = @[@"public.movie"];
        imagePickerController.cameraCaptureMode = UIImagePickerControllerCameraCaptureModeVideo;
        [self.pageControler presentViewController:imagePickerController animated:YES completion:nil];
    }else{
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:NSLocalizedString(@"Camera not available", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil, nil];
        [alertView show];
    }
}

- (void)handlePhotoVideoTapGesture:(UITapGestureRecognizer*)gesture
{
    AGImagePickerController *agImagePickerController = [self imagePickerWithFilterType:FilterTypePhoto];
    [self.pageControler presentViewController:agImagePickerController animated:YES completion:nil];
}

- (void)handleStudioTapGesture:(UITapGestureRecognizer*)gesture
{
    [MobClick endEvent: CLICK_MAINMENU_MY_WORKS];
    MyStudioViewController *studioViewController = [[MyStudioViewController alloc] init];
    UINavigationController *nav = [[PortraitNavigationController alloc] initWithRootViewController:studioViewController];
    nav.modalPresentationStyle = UIModalPresentationFullScreen;
    [self.pageControler presentViewController:nav animated:YES completion:nil];
}

- (void)handleAdTapGesture:(UITapGestureRecognizer*)gesture
{
    AdViewController *avc = nil;
    UINavigationController *nav = nil;
    NSInteger index =  gesture.view.tag;
    if(index >= 0 && adlist && adlist.count > index){
        AdItem *item = adlist[index];
        switch (item.type.intValue) {
            case 1://to FeaturedViewController
                [self.pageControler jump2PageAtIndex:1];
                break;
                
            case 2://show web dialog
                avc = [[AdViewController alloc] init];
                avc.urlStr = item.advertUrl;
                avc.titleStr = item.name;
                nav = [[UINavigationController alloc] initWithRootViewController:avc];
                [self.pageControler presentViewController:nav animated:YES completion:nil];
                break;
                
            case 3://open web by browser
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:item.advertUrl]];
                break;
                
            case 4://no action
                
                break;
        }
    }
}

#pragma mark - AD
- (void)loadAd
{
    UITapGestureRecognizer *adTapGestureRecognizer = nil;
    UIImageView *imageView = nil;
    UIImage *defaultImg = [UIImage imageNamed:@"ad.png"];
    
    if(adlist.count == 0){//load default ad image
        imageView = [[UIImageView alloc] initWithImage:defaultImg];
        imageView.userInteractionEnabled = NO;
        imageView.frame = CGRectMake(0, 0, screenBounds.size.width, AdImageHeight);
        adScrollView.contentSize = CGSizeMake(screenBounds.size.width, AdImageHeight);
        [adScrollView addSubview:imageView];
        totalAdCount = 1;
        pageControl.numberOfPages = totalAdCount;
    }else{
        AdItem *item = nil;
        for(int i = 0; i < adlist.count; i++){
            item = adlist[i];
            imageView = [[UIImageView alloc] initWithFrame:CGRectMake(i * screenBounds.size.width, 0, screenBounds.size.width, AdImageHeight)];
            adTapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleAdTapGesture:)];
            adTapGestureRecognizer.numberOfTapsRequired = 1;
            adTapGestureRecognizer.numberOfTouchesRequired = 1;
            [imageView addGestureRecognizer:adTapGestureRecognizer];
            imageView.tag = i;
            imageView.userInteractionEnabled = YES;
            [imageView setImageWithURL:[NSURL URLWithString:item.picUrl] placeholderImage:defaultImg];
            [adScrollView addSubview:imageView];
        }
        totalAdCount = adlist.count;
        adScrollView.contentSize = CGSizeMake(screenBounds.size.width*adlist.count, AdImageHeight);
        pageControl.numberOfPages = totalAdCount;
    }
    if(pageControl.numberOfPages > 1){
        pageControl.hidden = NO;
    }else{
        pageControl.hidden = YES;
    }
    [self startPageControlTimer];
}

- (void) requestAdInfo
{
    adlist = [[NSMutableArray alloc] init];
    
    NSString * localString=[NSLocale currentLocale].localeIdentifier;
    localString=[localString stringByReplacingOccurrencesOfString:@"_" withString:@"-"];
    NSString *urlStr=[NSString stringWithFormat:@"http://api.videoshowapp.com:8090/videoshow/api/v2/config?type=homeTopAdvert&page=1&item=5&osType=%d&lang=%@",2,localString];
    
    NSURL *url = [NSURL URLWithString:urlStr];
    ASIHTTPRequest *request = [[ASIHTTPRequest alloc] initWithURL:url];
    request.delegate = self;
    [request startAsynchronous];
    
}

-(NSArray*)parseAdListWithAdArray:(NSArray*)array
{
    NSMutableArray *list = [[NSMutableArray alloc] init];
    __weak NSMutableArray *weakList = list;
    __block AdItem *item = nil;
    [array enumerateObjectsUsingBlock:^(NSDictionary *dict, NSUInteger index, BOOL *stop){
        if(dict){
            item = [[AdItem alloc] init];
            item.advertActivity = dict[@"advert_activity"];
            item.advertUrl = dict[@"advert_url"];
            item.id = dict[@"id"];
            item.name = dict[@"name"];
            item.picUrl = dict[@"pic_url"];
            item.type = dict[@"type"];
            [weakList addObject:item];
        }
    }];
    return list;
}

#pragma mark - ASIHTTPRequestDelegate
- (void)request:(ASIHTTPRequest *)request didReceiveData:(NSData *)data
{
    NSString *content = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    if(!adJSONStr){
        adJSONStr = [[NSMutableString alloc] initWithString:content];
    }else{
        [adJSONStr appendString:content];
    }
}

-(void)requestFinished:(ASIHTTPRequest *)request
{
    if(adJSONStr){
        NSDictionary *dict = [adJSONStr objectFromJSONString];
        if(dict){
            NSNumber *ret = (NSNumber*)dict[@"ret"];
            if (ret.intValue == 1) {
                NSArray *templist = dict[@"advertlist"];
                NSArray *list = [self parseAdListWithAdArray:templist];
                [adlist removeAllObjects];
                [adlist addObjectsFromArray:list];
            }
        }
    }
    adJSONStr = nil;
    if(adlist.count > 0){
        [self loadAd];
    }
}

#pragma mark - UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    NSString *mediaType = [info objectForKey:UIImagePickerControllerMediaType];
    if ([mediaType isEqualToString:@"public.movie"]) {
        NSURL *mediaUrl = [info objectForKey:UIImagePickerControllerMediaURL];
        if(UIVideoAtPathIsCompatibleWithSavedPhotosAlbum(mediaUrl.path)){
            [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeClear];
            ALAssetsLibrary *library = [Util defaultAssetsLibrary];
            __weak HomeViewController *weakRef = self;
            [library writeVideoAtPathToSavedPhotosAlbum:mediaUrl completionBlock:^(NSURL *assetURL, NSError *error){
                if(!error){
                    savedVideoPath = [assetURL absoluteString];
                    [weakRef performSelector:@selector(handleVideo) withObject:weakRef afterDelay:1.0];
                }else{
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [SVProgressHUD dismiss];
                        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Save Video Failed", nil) message:nil delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil, nil];
                        [alert show];
                    });
                }
            }];
        }
        
        [self.pageControler dismissViewControllerAnimated:YES completion:nil];
    }
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self.pageControler dismissViewControllerAnimated:YES completion:nil];
}

- (void)handleVideo
{
    __block qxTimeline *timeline = [self timelineWithVideo:savedVideoPath];
    if(timeline){
        AGImagePickerController *agImagePickerController = [self imagePickerWithFilterType:FilterTypeNone];
        __weak AGImagePickerController *weakRef = agImagePickerController;
        [self.pageControler presentViewController:agImagePickerController animated:YES completion:^{
            [SVProgressHUD dismiss];
            [(AGIPCAlbumsController*)weakRef.topViewController resetPikcerWithTimeline:timeline];
        }];
    }
}

- (qxTimeline*)timelineWithVideo:(NSString*)videoUrl
{
    if(!videoUrl){
        return nil;
    }
    qxTimeline *timeline = [[qxTimeline alloc] init];
    //
    qxTrack *track = [[qxTrack alloc] initWithTrackType:eMT_Video];
    qxMediaObject *obj = [[qxMediaObject alloc] init];
    [obj setFilePath:videoUrl withType:eMT_Video fromAssetLibrary:YES];
    [track addMediaObject:obj];
    [timeline addTrack:track];
    //
    track = [[qxTrack alloc] initWithTrackType:eMT_Audio];
    [timeline addTrack:track];
    //
    track = [[qxTrack alloc] initWithTrackType:eMT_Audio];
    [timeline addTrack:track];
    //
    track = [[qxTrack alloc] initWithTrackType:eMT_Overlay];
    [timeline addTrack:track];
    return timeline;
}

@end
