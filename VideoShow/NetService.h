//
//  NetService.h
//  VideoShow
//
//  Created by chengkai.gan on 14-9-24.
//  Copyright (c) 2014年 energy. All rights reserved.
//

#import <Foundation/Foundation.h>

/** 应用网络接口 */
@interface NetService : NSObject

//封装前缀
+(NSString*) prefix;

/** 点赞/取消点赞 flag=YES 执行点赞 */
+ (NSString*) reqLikeMedia:(NSString*)mediaId flag:(BOOL)flag token:(NSString*)token;


@end
