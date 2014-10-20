//
//  VideoDraft.h
//  VideoShow
//
//  Created by Jerry Chen  on 14-8-27.
//  Copyright (c) 2014年 energy. All rights reserved.
//

#import <Foundation/Foundation.h>

@class qxTimeline;
@interface VideoDraft : NSObject<NSCoding>

@property (nonatomic,strong) qxTimeline *timeline;
@property (nonatomic,strong,readonly) NSDate *createDate;
@property (nonatomic,strong) NSString *draftPath;

- (id)initWithTimeline:(qxTimeline*)timeline;

@end
