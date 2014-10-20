//
//  Prefs.h
//  VideoShow
//
//  Created by chengkai.gan on 14-9-25.
//  Copyright (c) 2014年 energy. All rights reserved.
//

#import <Foundation/Foundation.h>

/** 操作参数的工具类 */
@interface Prefs : NSObject

//保存访问令牌
+(void)saveInstagramToken:(NSString*)token;

+(NSString*) getInstagramToken;

+(void) clearInstagramToken;


//////////////////////////////////////////////////////////////通用操作//////////////////////////////////////////////////////////////////////

/** 保存键值对 */
+(void)savePref:(NSString*)key value:(id)value;

/** 根据key取出保存的数据 */
+(id)retrieveForKey:(NSString*) key;
/** 清空指定的参数 */
+(void) clearForKey:(NSString*)key;
/** 移除指定的key */
+(void) removeKey:(NSString*)key;
/** 清空用户参数 */
+(void)clearAllPrefs;

@end
