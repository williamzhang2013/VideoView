//
//  AppDelegate.h
//  VideoShow
//
//  Created by Jerry Chen  on 14-7-15.
//  Copyright (c) 2014年 energy. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

/** CoreData相关 */
@property (readonly,strong,nonatomic) NSManagedObjectContext * managedObjectContext;
@property (readonly,strong,nonatomic) NSManagedObjectModel * managedObjectModel;
@property (readonly,strong,nonatomic) NSPersistentStoreCoordinator * persistentStoreCoordinator;

- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;

+ (AppDelegate *) shareInstance;

@end
