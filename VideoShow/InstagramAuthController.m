//
//  InstagramAuthControllerViewController.m
//  VideoShow
//
//  Created by chengkai.gan on 14-9-24.
//  Copyright (c) 2014年 energy. All rights reserved.
//

#import "InstagramAuthController.h"
#import "Prefs.h"
#import "NSString+Util.h"
#import "UIDevice+Resolutions.h"
#import "Toast+UIView.h"
#import "MobClick.h"

@interface InstagramAuthController ()

//@property (nonatomic,retain) IBOutlet UIActivityIndicatorView * indicatorView;
@property (nonatomic,retain) IBOutlet UIWebView * mWebView;
@property (nonatomic,retain) IBOutlet UIView * bottomView;

-(IBAction)closeAuth:(id)sender;

@end

@implementation InstagramAuthController

@synthesize authDelegate;

//@synthesize indicatorView;
@synthesize mWebView;
@synthesize bottomView;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    NSURLRequest * url=[[NSURLRequest alloc] initWithURL:[NSURL URLWithString:@"http://api.videoshowapp.com:8087/api/v1/oauth/connect"]];
    
    [self initView];
    [mWebView loadRequest:url];
}

-(void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [MobClick beginLogPageView:NSStringFromClass([self class])];
}

-(void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [MobClick endLogPageView:NSStringFromClass([self class])];
}

-(void) initView
{
    UIImageView * bottomLine=[[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 320, 1)];
    bottomLine.backgroundColor=[UIColor blueColor];
    UIButton * cancelButton=[UIButton buttonWithType:UIButtonTypeCustom];
    cancelButton.frame=CGRectMake(0, 0, 320, 40);
    [cancelButton setTitle:NSLocalizedString(@"Cancel", nil) forState:UIControlStateNormal];
    [cancelButton setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [cancelButton addTarget:self action:@selector(closeAuth:) forControlEvents:UIControlEventTouchUpInside];
    
    if (![UIDevice isRunningOniPhone5]) {
        self.view=[[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 480)];
        self.bottomView=[[UIView alloc] initWithFrame:CGRectMake(0, 440, 320, 40)];
    }else{
        self.view=[[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 568)];
        self.bottomView=[[UIView alloc] initWithFrame:CGRectMake(0, 528, 320, 40)];
    }
    
    self.mWebView=[[UIWebView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    self.mWebView.delegate=self;
    
    UILabel * label=[[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 20)];
    label.font=[UIFont systemFontOfSize:20];
    label.textAlignment=NSTextAlignmentCenter;
    label.textColor=[UIColor blackColor];
    label.text=NSLocalizedString(@"Auth Hint", nil);
    label.center=self.view.center;
    
    
    [bottomView addSubview:cancelButton];
    [bottomView addSubview:bottomLine];
    [self.view addSubview:self.mWebView];
    [self.view addSubview:bottomView];
    [self.view addSubview:label];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    NSString *absoluteUrl=request.mainDocumentURL.absoluteString;
    //NSLog(@"传来的地址--->%@",absoluteUrl);
    NSString * url=request.mainDocumentURL.relativePath;
    NSRange range=[url rangeOfString:@"/home/callback"];
    if(range.length>0){//如果成功回调---这里的js会调用iOS的本地代码
        
        NSRange tmpRange=[absoluteUrl rangeOfString:@"="];
        NSString *token=[absoluteUrl substringFromIndex:tmpRange.location+1];
        if (![NSString isNull:token]) {
            [Prefs saveInstagramToken:token];
            NSLog(@"认证后成功回调!token--->%@",token);
            [self dismissViewControllerAnimated:YES completion:^{
                if (authDelegate!=nil) {
                    [authDelegate authFinish:YES];
                }
            }];
        }
        
        return NO;
    }

    return YES;
}

//- (void)webView:(UIWebView *)sender didClearWindowObject:(UIWebScriptObject *)windowObject forFrame:(UIWebFrame *)frame
//{
//    [windowObject setValue:self forKey:@"login_interface"];
//}

- (void)webViewDidStartLoad:(UIWebView *)webView
{
    //[indicatorView startAnimating];
    NSString *title = [webView stringByEvaluatingJavaScriptFromString:@"document.title"];
    NSLog(@"start title1=%@",title);
}
- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    //[indicatorView stopAnimating];
    NSString *title = [webView stringByEvaluatingJavaScriptFromString:@"document.title"];
    NSLog(@"finish title1=%@",title);
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    //[indicatorView stopAnimating];
    [self.view makeToast:NSLocalizedString(@"Load Failed", nil)];
}

-(IBAction)closeAuth:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:^{
        NSLog(@"关闭面板!");
        if (authDelegate!=nil) {
            [authDelegate authFinish:NO];
        }
    }];
    
}

@end
