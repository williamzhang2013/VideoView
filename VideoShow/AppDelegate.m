//
//  AppDelegate.m
//  VideoShow
//
//  Created by Jerry Chen  on 14-7-15.
//  Copyright (c) 2014年 energy. All rights reserved.
//

#import "AppDelegate.h"
#import "UMSocial.h"
#import "UMSocialInstagramHandler.h"
#import "UMSocialSinaHandler.h"
#import "UMSocialWechatHandler.h"
#import "UMSocialFacebookHandler.h"
#import "UMSocialTwitterHandler.h"
#import "MobClick.h"
#import <CoreData/CoreData.h>
#import "AppMacros.h"
#import "FileHandle.h"
#import "ViewController.h"

@interface AppDelegate()

@property (nonatomic,retain) UIImageView * splashView;

@end

@implementation AppDelegate

@synthesize splashView;

@synthesize managedObjectContext=_managedObjectContext;
@synthesize managedObjectModel=_managedObjectModel;
@synthesize persistentStoreCoordinator=_persistentStoreCoordinator;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    application.statusBarStyle = UIStatusBarStyleLightContent;
    application.idleTimerDisabled = YES;
    [self.window makeKeyAndVisible];
    //umeng analyze
    [self setUMAnalyze];
    [self registerUMSNS];
    return YES;
}

+ (AppDelegate *) shareInstance{
    return (AppDelegate *)[UIApplication sharedApplication].delegate;
}

- (void)setUMAnalyze
{
    [MobClick startWithAppkey:umeng_key reportPolicy:BATCH channelId:nil];
    NSString *version = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    [MobClick setAppVersion:version];
}

-(void) registerUMSNS
{
    //log
    [UMSocialData openLog:YES];
    //umeng appkey
    [UMSocialData setAppKey:umeng_key];
    //instagram
    [UMSocialInstagramHandler openInstagramWithScale:NO paddingColor:[UIColor blackColor]];
    //sina weibo sso
    [UMSocialSinaHandler openSSOWithRedirectURL:@"http://sns.whalecloud.com/sina2/callback"];
    //wechat
    [UMSocialWechatHandler setWXAppId:wechat_key appSecret:wechat_secret url:nil];
    //facebook
    [UMSocialFacebookHandler setFacebookAppID:facebook_key shareFacebookWithURL:nil];
    //twitter
    [UMSocialTwitterHandler openTwitter];
}

- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url {
    if ([[url scheme] isEqualToString:@"videoshow"]) {
        NSString*text = [[url host] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Text"
                                               message:text
                                              delegate:nil
                                     cancelButtonTitle:@"OK"
                                     otherButtonTitles:nil];
        [alertView show];
        return YES;
    }
    return NO;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    [UMSocialSnsService  applicationDidBecomeActive];
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    return [UMSocialSnsService handleOpenURL:url];
}

/** 应用结束是保存数据 */
- (void)applicationWillTerminate:(UIApplication *)application {
    // Saves changes in the application's managed object context before the application terminates.
    [self saveContext];
}

#pragma mark -
#pragma mark - Private Methods

- (void)saveContext {
    NSError *error = nil;
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
}

#pragma mark - 主要有三个方法
#pragma mark - Core Data stack

// Returns the managed object context for the application.
// If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
- (NSManagedObjectContext *)managedObjectContext {
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        _managedObjectContext = [[NSManagedObjectContext alloc] init];
        [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    }
    return _managedObjectContext;
}

// Returns the managed object model for the application.
// If the model doesn't already exist, it is created from the application's model.
- (NSManagedObjectModel *)managedObjectModel {
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:[NSString stringWithFormat:@"%@",DB_NAME] withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}
//检测数据库残留文件并删除
-(void) prepareCheck
{
    NSArray * array=[FileHandle contentOfDir:[FileHandle getDocumentDir]];
    for(int i=0;i<array.count;i++){
        NSString * fileName=[array objectAtIndex:i];
        NSRange range = [fileName rangeOfString:[NSString stringWithFormat:@"%@",DB_NAME]];//判断字符串是否包含
        
        NSString* rangeName=[NSString stringWithFormat:@"%@%@",DB_NAME,[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"]];
        NSRange range2= [fileName rangeOfString:rangeName];
        if (range.location == 0&& range2.length <= 0){
            [FileHandle deleteFile:[NSString  stringWithFormat:@"%@/%@",[FileHandle getDocumentDir],fileName]];
        }
    }
}

// Returns the persistent store coordinator for the application.
// If the coordinator doesn't already exist, it is created and the application's store added to it.
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    [self prepareCheck];
    NSString* sqliteName=[NSString stringWithFormat:@"%@%@.sqlite",DB_NAME,[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"]];
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:sqliteName];
    
    NSError *error = nil;
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    
    // 升级目录
    NSDictionary *optionsDictionary = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:YES],NSMigratePersistentStoresAutomaticallyOption, [NSNumber numberWithBool:YES],NSInferMappingModelAutomaticallyOption, nil];
    
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType
                                                   configuration:nil
                                                             URL:storeURL
                                                         options:optionsDictionary error:&error]) {
        //这里打印错误日志
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    return _persistentStoreCoordinator;
}

#pragma mark -
#pragma mark - Application's Documents directory

// Returns the URL to the application's Documents directory.
- (NSURL *)applicationDocumentsDirectory {
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory
                                                   inDomains:NSUserDomainMask] lastObject];
}
@end
