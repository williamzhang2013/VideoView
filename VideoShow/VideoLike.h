//
//  VideoLike.h
//  VideoShow
//
//  Created by chengkai.gan on 14-9-25.
//  Copyright (c) 2014年 energy. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface VideoLike : NSManagedObject

@property (nonatomic, retain) NSNumber * id;
@property (nonatomic, retain) NSString * videoUrl;
// 0表示未点赞 1表示已经点赞
@property (nonatomic, retain) NSNumber * likeState;
// 当前用户id为token
@property (nonatomic, retain) NSString * userId;
@property (nonatomic, retain) NSString * videoOwner;

@end
