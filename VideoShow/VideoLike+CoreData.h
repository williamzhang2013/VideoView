//
//  VideoLike+CoreData.h
//  VideoShow
//
//  Created by chengkai.gan on 14-9-25.
//  Copyright (c) 2014年 energy. All rights reserved.
//

#import "VideoLike.h"

@interface VideoLike (CoreData)

/** 查询所有点赞记录 */
+(NSArray*)queryAll:(int)count;
/** 查询该媒体是否已经点赞 */
+(VideoLike*) queryLiked:(NSString*)userId mediaid:(NSString*)mediaId;
/** 标记点赞状态 */
+(BOOL) remarkLiked:(NSString*)userId mediaid:(NSString*)mediaId mediaowner:(NSString*)owner state:(int)likeState;
/** 保存点赞记录 */
+(BOOL) insertLiked:(NSString*)userId mediaid:(NSString*)mediaId mediaowner:(NSString*)owner state:(int)likeState;
/** 根据属性和值查询 */
+(NSArray*)queryWithAttr:(NSString*)attr value:(NSString*)value limit:(int)count;
/** 根据属性值模糊查询 */
+(NSArray*)queryObscureWithAttr:(NSString*)attr value:(NSString*)value limit:(int)count;
/** 删除所有记录 */
+(BOOL)deleteAll;

@end
