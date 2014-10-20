//
//  Application.m
//  VideoShow
//
//  Created by Jerry Chen  on 14-8-19.
//  Copyright (c) 2014年 energy. All rights reserved.
//

#import "Application.h"

@implementation Application

-(void)sendEvent:(UIEvent *)event
{
    if([event type] == UIEventTypeTouches){
        NSDictionary *dict=[NSDictionary dictionaryWithObject:event forKey:@"event"];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"ScreenTouchNotification" object:nil userInfo:dict];
    }
    [super sendEvent:event];
}

@end
