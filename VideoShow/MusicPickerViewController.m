//
//  MusicPickerTableViewController.m
//  X-VideoShow
//
//  Created by Jerry Chen  on 14-6-24.
//  Copyright (c) 2014年 energy. All rights reserved.
//

#import "MusicPickerViewController.h"
#include "qxMediaObject.h"
#import "Util.h"
#import "AppMacros.h"
#import "UIColor+Util.h"

static NSString *cellIdentifier = @"MusicPickerTableViewCell";

@interface MusicPickerViewController()

@property (nonatomic,retain) UIView * noMusicHintView;

@end

@implementation MusicPickerViewController

@synthesize noMusicHintView;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self performSelectorInBackground:@selector(queryMedia) withObject:nil];
    
    if([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0){
        self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:40/255.0 green:35/255.0 blue:35/255.0 alpha:1.0];
    }else{
        self.navigationController.navigationBar.tintColor = [UIColor colorWithRed:40/255.0 green:35/255.0 blue:35/255.0 alpha:1.0];
    }
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    [self.tableView registerClass:[MusicPickerTableViewCell class] forCellReuseIdentifier:cellIdentifier];
    if ([self.tableView respondsToSelector:@selector(setSeparatorInset:)]){
        [self.tableView setSeparatorInset:UIEdgeInsetsZero];
    }
    if ([self.tableView respondsToSelector:@selector(setLayoutMargins:)]) {
        [self.tableView setLayoutMargins:UIEdgeInsetsZero];
    }
    //title
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 80, 30)];
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.text =NSLocalizedString(@"Add Music", nil);
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.textColor = [UIColor whiteColor];
    titleLabel.font=[UIFont boldSystemFontOfSize:17.0];
    [titleLabel sizeToFit];
    self.navigationItem.titleView = titleLabel;
    //left button
    UIButton *closeBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 16, 15)];
    [closeBtn setImage:[UIImage imageNamed:@"close_red.png"] forState:UIControlStateNormal];
    [closeBtn addTarget:self action:@selector(cancelAction:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *leftBarButton = [[UIBarButtonItem alloc] initWithCustomView:closeBtn];
    self.navigationItem.leftBarButtonItem = leftBarButton;
    
    [self addObserver:self forKeyPath:@"selectedIndex" options:NSKeyValueObservingOptionNew context:NULL];
    
    self.selectedIndex = -1;
    self.preIndex=self.selectedIndex;
    [self initHintView];
    
}

- (BOOL)shouldAutorotate
{
    return NO;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
    return UIInterfaceOrientationPortrait;
}

//无音乐提示
-(void) initHintView
{
    self.noMusicHintView=[[UIView alloc] initWithFrame:self.view.frame];
    self.noMusicHintView.backgroundColor=[UIColor whiteColor];

    //330*260
    UIImage * image=[UIImage imageNamed:@"ic_no_music.png"];
    UIImageView *imageView=[[UIImageView alloc] initWithFrame:CGRectMake(0, 100, 100, 100*image.size.height/image.size.width)];
    imageView.contentMode=UIViewContentModeScaleAspectFill;
    imageView.image=image;
    imageView.center=CGPointMake(self.view.frame.size.width/2, imageView.frame.origin.y);
    UIColor * labelColor=[UIColor colorWithHexString:@"#b8b8b8"];
    UILabel * label1=[[UILabel alloc] initWithFrame:CGRectMake(0, imageView.frame.origin.y+imageView.frame.size.height+30, self.noMusicHintView.frame.size.width, 0)];
    label1.textAlignment=NSTextAlignmentCenter;
    label1.font=[UIFont systemFontOfSize:22.0];
    label1.text=NSLocalizedString(@"No Music", nil);
    label1.textColor=labelColor;
    [label1 sizeToFit];
    label1.center=CGPointMake(self.noMusicHintView.frame.size.width/2, label1.frame.origin.y);

    UILabel * label2=[[UILabel alloc] initWithFrame:CGRectMake(0, label1.frame.origin.y+label1.frame.size.height+20, self.view.frame.size.width, 0)];
    label2.textAlignment=NSTextAlignmentCenter;
    label2.font=[UIFont systemFontOfSize:18.0];
    label2.text=NSLocalizedString(@"iTunes Download", nil);
    label2.textColor=labelColor;
    [label2 sizeToFit];
    label2.center=CGPointMake(self.noMusicHintView.frame.size.width/2, label2.frame.origin.y);
    
    [self.noMusicHintView addSubview:imageView];
    [self.noMusicHintView addSubview:label1];
    [self.noMusicHintView addSubview:label2];
    
    [self.view addSubview:self.noMusicHintView];
    self.noMusicHintView.hidden=YES;
}

-(void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    [self stop];
    [self removeObserver:self forKeyPath:@"selectedIndex"];
}

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if([keyPath isEqualToString:@"selectedIndex"]){
        if(self.selectedIndex >= 0){
            self.navigationItem.rightBarButtonItem.enabled = YES;
        }else{
            self.navigationItem.rightBarButtonItem.enabled = NO;
        }
    }
}

-(void)cancelAction:(id)sender
{
    if([self.delegate respondsToSelector:@selector(musicPickerCanceled)]){
        [self.delegate musicPickerCanceled];
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    CGFloat height = 0.0;
    if([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0){
        height = 0.1;
    }
    return height;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat height = 55.0;
    if(self.selectedIndex == indexPath.row){
        height = 120.0;
    }
    return height;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return mediaList.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //
    MusicPickerTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if ([self.tableView respondsToSelector:@selector(setSeparatorInset:)]){
        [self.tableView setSeparatorInset:UIEdgeInsetsZero];
    }
    if ([self.tableView respondsToSelector:@selector(setLayoutMargins:)]) {
        [self.tableView setLayoutMargins:UIEdgeInsetsZero];
    }
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        [cell setLayoutMargins:UIEdgeInsetsZero];
    }
    cell.delegate = self;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    MPMediaItem *mediaItem = mediaList[indexPath.row];
    MPMediaItemArtwork *artwork = [mediaItem valueForProperty: MPMediaItemPropertyArtwork];
    UIImage *artworkImage = [artwork imageWithSize: cell.artwork.bounds.size];
    
    if (artworkImage) {
        cell.artwork.image = artworkImage;
    }else{
        cell.artwork.image = [UIImage imageNamed:@"default_artist.png"];
    }
    cell.title.text = [mediaItem valueForProperty:MPMediaItemPropertyTitle];
    NSString * artistStr = [mediaItem valueForProperty:MPMediaItemPropertyArtist];
    if (artistStr==nil) {
        cell.artist.text=NSLocalizedString(@"No Artist", nil);
    }else{
        cell.artist.text=artistStr;
    }
    long seconds = (long)[(NSNumber*)[mediaItem valueForProperty:MPMediaItemPropertyPlaybackDuration] doubleValue];
    NSString *durationStr = [Util stringWithSeconds:round(seconds)];
    cell.duration.text = durationStr;
    cell.startTime.text = @"00 : 00";
    cell.endTime.text = durationStr;
    cell.rangeSlider.minimumValue = 0;
    cell.rangeSlider.maximumValue = seconds;
    cell.rangeSlider.lowerValue = 0;
    cell.rangeSlider.upperValue = seconds;
    if(self.selectedIndex == indexPath.row){
        if(!cell.bottomBgView.superview){
            [cell addSubview:cell.bottomBgView];
        }
        cell.btnPlayStatus.hidden = NO;
        
        cell.tagImg.hidden = YES;
        cell.add.hidden = NO;
        if(audioPlayer.playing){
            cell.btnPlayStatus.selected=YES;
        }else{
            cell.btnPlayStatus.selected=NO;
        }
    }else{
        cell.btnPlayStatus.hidden = YES;
        cell.tagImg.hidden = NO;
        cell.add.hidden = YES;
        [cell.bottomBgView removeFromSuperview];
    }
    [cell resizeTitle];
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(self.selectedIndex != indexPath.row){
        if (self.selectedIndex!=-1) {
            self.preIndex=self.selectedIndex;
        }
        self.selectedIndex = indexPath.row;
        NSIndexPath * prePath=[NSIndexPath indexPathForRow:self.preIndex inSection:0];
        if(self.preIndex!=-1){
            [tableView reloadRowsAtIndexPaths:@[prePath,indexPath] withRowAnimation:UITableViewRowAnimationFade];
        }else{
            [tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        }
        [self resetAudioPlayerWithMediaItem:mediaList[indexPath.row]];
    }else{
//        if(audioPlayer.isPlaying){
//            [self pause];
//        }else{
//            [self play];
//        }
    }
}

-(void)queryMedia
{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    MPMediaQuery *query = [MPMediaQuery playlistsQuery];
    mediaList = [query items];
    [self performSelectorOnMainThread:@selector(queryDone) withObject:nil waitUntilDone:NO];
}

-(void)resetAudioPlayerWithMediaItem:(MPMediaItem*)item
{
    NSURL *url = [item valueForProperty:MPMediaItemPropertyAssetURL];
    audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:nil];
    audioPlayer.numberOfLoops = -1;
    audioPlayer.delegate = self;
    [audioPlayer prepareToPlay];
    [self play];
}

-(void)queryDone
{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    if (mediaList.count>0) {
        [self.noMusicHintView removeFromSuperview];
        [self.tableView reloadData];
    }else{
        self.noMusicHintView.hidden=NO;
    }
    
}

-(void)play
{
    MusicPickerTableViewCell *cell = (MusicPickerTableViewCell*)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForItem:self.selectedIndex inSection:0]];
    cell.btnPlayStatus.selected=YES;
    [audioPlayer play];
    [self startPlayControlTask];
}

-(void)pause
{
    MusicPickerTableViewCell *cell = (MusicPickerTableViewCell*)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForItem:self.selectedIndex inSection:0]];
    cell.btnPlayStatus.selected=NO;
    [audioPlayer pause];
    [self stopPlayControlTask];
}

-(void)stop
{
    [audioPlayer stop];
    [self stopPlayControlTask];
}

-(void)playControlTask
{
    if(audioPlayer.playing){
        MusicPickerTableViewCell *cell = (MusicPickerTableViewCell*)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForItem:self.selectedIndex inSection:0]];
        if(audioPlayer.currentTime >= cell.rangeSlider.upperValue){
            [audioPlayer setCurrentTime:cell.rangeSlider.lowerValue];
        }
    }
}

-(void)startPlayControlTask
{
    if([playControlTimer isValid]){
        [playControlTimer invalidate];
    }
    playControlTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(playControlTask) userInfo:nil repeats:YES];
}

-(void)stopPlayControlTask
{
    if ([playControlTimer isValid]) {
        [playControlTimer invalidate];
    }
}

-(void)musicPlayAction:(UIButton*)sender
{
    if(audioPlayer.isPlaying){
        [self pause];
    }else{
        [self play];
    }
}

-(void)musicPickerTableViewCellSliderTouchUp:(MusicPickerTableViewCell *)cell
{
    [audioPlayer setCurrentTime:cell.rangeSlider.lowerValue];
    [self play];
}

-(void)musicPickerTableViewCellSliderTouchDown:(MusicPickerTableViewCell *)cell
{
    [self pause];
}

- (void)musicpickerTableViewCellAddAction
{
    if([self.delegate respondsToSelector:@selector(musicPickerViewController:didFinishPickMediaItem:)]){
        qxMediaObject *mediaObj = [[qxMediaObject alloc] init];
        MPMediaItem *mediaItem = mediaList[self.selectedIndex];
        NSURL *url = [mediaItem valueForProperty:MPMediaItemPropertyAssetURL];
        [mediaObj setFilePath:[url absoluteString] withType:eMT_Audio fromAssetLibrary:YES];
        MusicPickerTableViewCell *cell = (MusicPickerTableViewCell*)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:self.selectedIndex inSection:0]];
        [mediaObj setTrim:cell.rangeSlider.lowerValue * 1000 withRight:(cell.rangeSlider.maximumValue - cell.rangeSlider.upperValue) * 1000];
        if([self.delegate respondsToSelector:@selector(musicPickerViewController:didFinishPickMediaItem:)]){
            [self.delegate musicPickerViewController:self didFinishPickMediaItem:mediaObj];
        }
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
