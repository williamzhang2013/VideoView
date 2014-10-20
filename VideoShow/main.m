//
//  main.m
//  VideoShow
//
//  Created by Jerry Chen  on 14-7-15.
//  Copyright (c) 2014年 energy. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "AppDelegate.h"
#import "Application.h"

int main(int argc, char * argv[])
{
    @try {
        @autoreleasepool {
            return UIApplicationMain(argc, argv, NSStringFromClass([Application class]), NSStringFromClass([AppDelegate class]));
        }
    }
    @catch (NSException *exception) {
        NSLog(@"exception : reason : %@ , %@",exception.reason,[exception callStackSymbols]);
    }
}
