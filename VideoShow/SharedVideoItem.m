//
//  SharedVideoItem.m
//  VideoShow
//
//  Created by Jerry Chen  on 14-7-18.
//  Copyright (c) 2014年 energy. All rights reserved.
//

#import "SharedVideoItem.h"
#import "VideoLike+CoreData.h"
#import "JSONKit.h"
#import "Prefs.h"
#import "NSString+Util.h"

@implementation SharedVideoItem

@synthesize isLiked;

- (id)init
{
    if(self = [super init]){
        
    }
    return self;
}

- (NSString *)description
{
    NSString *desc = [NSString stringWithFormat:@"id = %@, create_time = %@, likesCount = %u, userName = %@, userPic = %@, videoUrl = %@, videoWidth = %u, videoHeight = %u, imageUrl = %@, imageWdith = %u, imageHeight = %u",self.itemId,self.createTime,self.likesCount,self.userName,self.userProfilePictureUrl,self.videoUrl,self.videoWidth,self.videoHeight,self.imageUrl,self.imageWidth,self.imageHeight];
    return desc;
}

- (NSString*)localizedCreateTime
{
    NSTimeInterval seconds = [_createTime longLongValue];
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:seconds];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm"];
    return [NSString stringWithFormat:@"%@",[dateFormatter stringFromDate:date]];
}

+(NSMutableArray*) initFromJson:(NSString*)jsonStr
{
    NSMutableArray *list = [[NSMutableArray alloc] init];
    __block NSDictionary * tempDict=[jsonStr objectFromJSONString];
    NSArray *tempList = tempDict[@"datalist"];
    if(tempList){
        list = [[NSMutableArray alloc] init];
        [tempList enumerateObjectsUsingBlock:^(NSDictionary *dict,NSUInteger index, BOOL *stop){
            SharedVideoItem * item = [[SharedVideoItem alloc] init];
            //video
            tempDict = [((NSDictionary*)dict[@"videos"]) objectForKey:@"standard_resolution"];
            item.videoUrl = tempDict[@"url"];
            item.videoWidth  = [((NSNumber*)tempDict[@"width"]) unsignedIntegerValue];
            item.videoHeight = [((NSNumber*)tempDict[@"height"]) unsignedIntegerValue];
            //image
            tempDict = [((NSDictionary*)dict[@"images"]) objectForKey:@"standard_resolution"];
            item.imageUrl = tempDict[@"url"];
            item.imageWidth = [((NSNumber*)tempDict[@"width"]) unsignedIntegerValue];
            item.imageHeight = [((NSNumber*)tempDict[@"height"]) unsignedIntegerValue];
            //user
            tempDict = dict[@"user"];
            item.userName = tempDict[@"username"];
            item.userProfilePictureUrl = tempDict[@"profile_picture"];
            //other
            item.createTime = dict[@"created_time"];
            item.likesCount = [(NSNumber*)[((NSDictionary*)dict[@"likes"]) objectForKey:@"count"] unsignedIntegerValue];
            item.itemId = dict[@"id"];
            BOOL flag=NO;
            if([NSString isNull:[Prefs getInstagramToken]]){
                flag=NO;
            }else{
                flag=[VideoLike queryLiked:[Prefs getInstagramToken] mediaid:item.itemId]!=nil?YES:NO;
            }
            item.isLiked=flag;//这里要执行查询得到结果
            [list addObject:item];
        }];
    }
    return list;
}


@end
