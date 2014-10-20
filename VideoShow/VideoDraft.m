//
//  VideoDraft.m
//  VideoShow
//
//  Created by Jerry Chen  on 14-8-27.
//  Copyright (c) 2014年 energy. All rights reserved.
//

#import "VideoDraft.h"


@implementation VideoDraft

- (id)initWithTimeline:(qxTimeline*)timeline
{
    if(self = [super init]){
        _createDate = [NSDate date];
        _timeline = timeline;
    }
    return self;
}

#pragma mark - NSCoding
- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:_timeline forKey:@"timeline"];
    [aCoder encodeObject:_createDate forKey:@"createDate"];
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if(self = [super init]){
        _timeline = [aDecoder decodeObjectForKey:@"timeline"];
        _createDate = [aDecoder decodeObjectForKey:@"createDate"];
    }
    return self;
}

@end
