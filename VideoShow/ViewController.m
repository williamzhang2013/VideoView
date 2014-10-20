//
//  ViewController.m
//  VideoShow
//
//  Created by Jerry Chen  on 14-7-15.
//  Copyright (c) 2014年 energy. All rights reserved.
//

#import "ViewController.h"
#import "HomeViewController.h"
#import "FeaturedViewController.h"
#import "RecentViewController.h"
#import "MyLabel.h"
#import "MobClick.h"
#import "AppEvent.h"

#define TAB_COUNT 2


@implementation ViewController

#pragma mark - ViewController life cycle
- (void)viewDidLoad
{
    self.dataSource = self;
    self.delegate = self;
    
    self.tabWidth = [UIScreen mainScreen].bounds.size.width/TAB_COUNT;
    //self.tabWidth = 60;
    // Keeps tab bar below navigation bar on iOS 7.0+
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
        self.tabHeight = 64;
    }else{
        self.tabHeight = 44;
    }
    [super viewDidLoad];
}

- (BOOL)shouldAutorotate
{
    return NO;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
    return UIInterfaceOrientationPortrait;
}

#pragma mark - ViewPagerDataSource
- (NSUInteger)numberOfTabsForViewPager:(ViewPagerController *)viewPager {
    return TAB_COUNT;
}

- (UIView *)viewPager:(ViewPagerController *)viewPager viewForTabAtIndex:(NSUInteger)index {
    
    NSString *title = NSLocalizedString(@"Home", nil);
    if(index == 1){
        title = NSLocalizedString(@"Featured", nil);
    }else if(index == 2){
        title = NSLocalizedString(@"Recent", nil);
    }


    MyLabel *label = [[MyLabel alloc] init];
    label.enableInset = YES;
    label.insets = UIEdgeInsetsMake(15, 0, 0, 0);
    label.textAlignment=NSTextAlignmentCenter;
    label.font=[UIFont boldSystemFontOfSize:17.0];
    label.backgroundColor = [UIColor clearColor];
    label.text = title;
    label.textColor = [UIColor whiteColor];
    [label sizeToFit];
    
    return label;
}

- (UIViewController *)viewPager:(ViewPagerController *)viewPager contentViewControllerForTabAtIndex:(NSUInteger)index {
    
    if(index == 0){
        HomeViewController *hvc = [[HomeViewController alloc] init];
        hvc.pageControler = self;
        return hvc;
    }else if(index == 1){
        [MobClick event: FEATURED_APP_CLICK];
        FeaturedViewController *fvc = [[FeaturedViewController alloc] initWithStyle:UITableViewStylePlain];
        fvc.pageControler = self;
        return fvc;
    }else if(index == 2){
        RecentViewController *rvc = [[RecentViewController alloc] initWithStyle:UITableViewStylePlain];
        rvc.pageControler = self;
        return rvc;
    }
    return nil;
}

#pragma mark - ViewPagerDelegate
- (UIColor *)viewPager:(ViewPagerController *)viewPager colorForComponent:(ViewPagerComponent)component withDefault:(UIColor *)color {
    
    if(component == ViewPagerIndicator){
        return [UIColor colorWithRed:221/255.0 green:107/255.0 blue:111/255.0 alpha:1.0];
    }else if(component == ViewPagerTabsView){
        return [UIColor colorWithRed:40/255.0 green:35/255.0 blue:35/255.0 alpha:1.0];
    }else if(component == ViewPagerContent){
        return [UIColor colorWithPatternImage:[UIImage imageNamed:@"black_bg.png"]];
    }
    
    return color;
}


@end
