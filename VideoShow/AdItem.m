//
//  AdItem.m
//  VideoShow
//
//  Created by Jerry Chen  on 14-7-17.
//  Copyright (c) 2014年 energy. All rights reserved.
//

#import "AdItem.h"

@implementation AdItem
- (id)init
{
    if(self = [super init]){
        
    }
    return self;
}

- (NSString *)description
{
    NSString *desc = [NSString stringWithFormat:@"id = %@, type = %@, name = %@, activity = %@, adurl = %@, pic = %@",self.id,self.type,self.name,self.advertActivity,self.advertUrl,self.picUrl];
    return desc;
}

@end
