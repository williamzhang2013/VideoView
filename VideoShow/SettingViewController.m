//
//  SettingViewController.m
//  VideoShow
//
//  Created by Jerry Chen  on 14-9-5.
//  Copyright (c) 2014年 energy. All rights reserved.
//

#import "SettingViewController.h"
#import "AppMacros.h"
#import "AppEvent.h"
#import "MobClick.h"
#import "YouTubeHelper.h"
#import "SVProgressHUD.h"
#import "UIColor+Util.h"

/** 工作室设置 */
@interface SettingViewController ()

@end

@implementation SettingViewController

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
    
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
        self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:40/255.0 green:35/255.0 blue:35/255.0 alpha:1.0];
    }else{
        self.navigationController.navigationBar.tintColor = [UIColor colorWithRed:40/255.0 green:35/255.0 blue:35/255.0 alpha:1.0];
    }
    self.navigationController.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"black_bg.png"]];
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100, 30)];
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.text =NSLocalizedString(@"Setting", nil);
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.textColor = [UIColor whiteColor];
    titleLabel.font=[UIFont boldSystemFontOfSize:17];
    [titleLabel sizeToFit];
    self.navigationItem.titleView = titleLabel;
    
    //left barbutton
    UIButton *closeBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 22, 38)];
    [closeBtn setImage:[UIImage imageNamed:@"back.png"] forState:UIControlStateNormal];
    [closeBtn setImageEdgeInsets:UIEdgeInsetsMake(9.5, 0, 9.5, 11)];
    [closeBtn addTarget:self action:@selector(closeButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *leftBarButton = [[UIBarButtonItem alloc] initWithCustomView:closeBtn];
    self.navigationItem.leftBarButtonItem = leftBarButton;
    
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

- (void)closeButtonAction:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Table view data source

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section==0) {
        return 10;
    }
    return 15;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0.001f;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(section == 0){
        return 3;
    }else{
        return 1;
    }
}

- (NSString*)textForIndexPath:(NSIndexPath*)indexPath
{
    NSString *str = nil;
    if(indexPath.section == 0){
        switch (indexPath.row) {
            case 0:
                str = NSLocalizedString(@"Follow us on Facebook", nil);
                break;
                
            case 1:
                str = NSLocalizedString(@"Follow us on Instagram", nil);
                break;
                
            case 2:
                str = NSLocalizedString(@"Follow us on Twitter", nil);
                break;
        }
    }else if(indexPath.section == 2){
        switch (indexPath.row) {
            case 0:
                str = NSLocalizedString(@"Version", nil);
                break;
        }
    }else if(indexPath.section == 1){
        if(indexPath.row == 0){
            str = NSLocalizedString(@"Remove YTB Authorization", nil);
        }
    }
    return str;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    if(!cell){
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"Cell"];
        UIView * selectedView=[[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 0)];
        selectedView.backgroundColor=[UIColor colorWithHexString:@"#cecece"];
        cell.selectedBackgroundView=selectedView;
    }
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    cell.textLabel.text = [self textForIndexPath:indexPath];
    if(indexPath.section == 2 && indexPath.row == 0){
        cell.detailTextLabel.text = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];;
        cell.accessoryType = UITableViewCellAccessoryNone;
    }else{
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    return cell;
}

#pragma mark - Table view delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if(indexPath.section == 0){
        switch (indexPath.row) {
            case 0:
            {
                [MobClick endEvent: MENU_FOLLOW_ON_FACEBOOK];
                NSURL *facebookURL = [NSURL URLWithString:[NSString stringWithFormat:@"fb://profile/%@",FACEBOOK_USERID]];
                if ([[UIApplication sharedApplication] canOpenURL:facebookURL]) {
                    [[UIApplication sharedApplication] openURL:facebookURL];
                }else{//如果安装了app,通过浏览器打开会自动启动app
                    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://www.facebook.com/videoshowapp"]];
                }
            }
                break;
                
            case 1:
            {
                [MobClick endEvent: MENU_FOLLOW_ON_INSTAGRAM];
                NSURL *instagramURL = [NSURL URLWithString:@"instagram://user?username=videoshowapp"];
                if ([[UIApplication sharedApplication] canOpenURL:instagramURL]) {
                    [[UIApplication sharedApplication] openURL:instagramURL];
                }else{
                    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://instagram.com/videoshowapp"]];
                }
            }
                break;
                
            case 2:
            {
                [MobClick endEvent: MENU_FOLLOW_ON_TWITTER];
                NSURL *twitterURL = [NSURL URLWithString:[NSString stringWithFormat:@"twitter://user?id=%@",TWITTER_USERID]];
                if ([[UIApplication sharedApplication] canOpenURL:twitterURL]) {
                    [[UIApplication sharedApplication] openURL:twitterURL];
                }else{
                    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://twitter.com/videoshowapp"]];
                }
            }
                break;
        }
    }else if (indexPath.section == 1){
        if(indexPath.row == 0){
            YouTubeHelper *helper = [[YouTubeHelper alloc] initWithDelegate:nil];
            [helper signOut];
            [SVProgressHUD showSuccessWithStatus:NSLocalizedString(@"Remove Success", nil) duration:1];
        }
    }
}
@end
