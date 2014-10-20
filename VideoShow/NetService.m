//
//  NetService.m
//  VideoShow
//
//  Created by chengkai.gan on 14-9-24.
//  Copyright (c) 2014年 energy. All rights reserved.
//

#import "NetService.h"

#import "BaseService.h"
#import "AppMacros.h"

@implementation NetService

/** 点赞/取消点赞 flag=YES 执行点赞 */
+ (NSString*) reqLikeMedia:(NSString*)mediaId flag:(BOOL)flag token:(NSString*)token
{
    NSString * prefix=[NetService prefix];
    NSString * method=nil;
    if (flag) {
        method=@"like_media";
    }else{
        method=@"unlike_media";
    }
    NSString * url=[NSString stringWithFormat:@"%@%@/%@",prefix,mediaId,method];
    NSMutableDictionary * dict=[NSMutableDictionary dictionary];
    [dict setObject:token forKey:@"access_token"];
    [dict setObject:@"en-US" forKey:@"lang"];
    return [BaseService doPostSyncUrl:url dict:dict];
}

//封装前缀
+(NSString*) prefix
{
    return [NSString stringWithFormat:@"%@%@",SERVICE_HOST,@"/api/v1/medium/"];
}

@end
