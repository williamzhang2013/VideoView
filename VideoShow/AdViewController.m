//
//  AdViewController.m
//  VideoShow
//
//  Created by Jerry Chen  on 14-7-18.
//  Copyright (c) 2014年 energy. All rights reserved.
//

#import "AdViewController.h"
#import "MobClick.h"

@implementation AdViewController

#pragma mark - View life cycle
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    CGRect screenBounds = [UIScreen mainScreen].bounds;
    
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
        self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:40/255.0 green:35/255.0 blue:35/255.0 alpha:1.0];
    }else{
        self.navigationController.navigationBar.tintColor = [UIColor colorWithRed:40/255.0 green:35/255.0 blue:35/255.0 alpha:1.0];
    }
    self.navigationController.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"black_bg.png"]];
    
    //title view
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100, 30)];
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.text = self.titleStr;
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.textColor = [UIColor whiteColor];
    [titleLabel sizeToFit];
    self.navigationItem.titleView = titleLabel;
    
    //navigation right button
    UIBarButtonItem *close = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Close", nil) style:UIBarButtonItemStylePlain target:self action:@selector(closeAction:)];
    close.tintColor = [UIColor whiteColor];
    self.navigationItem.rightBarButtonItem = close;
    //webview
    UIWebView *webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 0, screenBounds.size.width, screenBounds.size.height - 64)];
    webView.delegate = self;
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:self.urlStr]];
    [webView loadRequest:request];
    webView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:webView];
    
    self.view.backgroundColor = [UIColor clearColor];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [MobClick beginLogPageView:@"AdViewController"];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [MobClick endLogPageView:@"AdViewController"];
}

- (BOOL)shouldAutorotate
{
    return NO;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
    return UIInterfaceOrientationPortrait;
}

- (void)closeAction:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - UIWebViewDelegate
- (void)webViewDidStartLoad:(UIWebView *)webView
{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}

@end
