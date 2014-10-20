//
//  SharedVideoItem.h
//  VideoShow
//
//  Created by Jerry Chen  on 14-7-18.
//  Copyright (c) 2014年 energy. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SharedVideoItem : NSObject

@property (nonatomic,strong) NSString *videoUrl;
@property (nonatomic,assign) NSUInteger videoWidth;
@property (nonatomic,assign) NSUInteger videoHeight;
@property (nonatomic,strong,getter = localizedCreateTime) NSString *createTime;
@property (nonatomic,strong) NSString *imageUrl;
@property (nonatomic,assign) NSUInteger imageWidth;
@property (nonatomic,assign) NSUInteger imageHeight;
@property (nonatomic,strong) NSString *itemId;
@property (nonatomic,strong) NSString *userName;
@property (nonatomic,assign) NSUInteger likesCount;
@property (nonatomic,strong) NSString *userProfilePictureUrl;

@property (nonatomic,assign) BOOL isLiked;//是否已经点赞过

/** 从json数据中初始化列表数据 */
+(NSMutableArray*) initFromJson:(NSString*)jsonStr;

@end
