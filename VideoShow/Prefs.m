//
//  Prefs.m
//  VideoShow
//
//  Created by chengkai.gan on 14-9-25.
//  Copyright (c) 2014年 energy. All rights reserved.
//

#import "Prefs.h"

#import "AppMacros.h"

@implementation Prefs

#pragma mark -
#pragma mark NSUserDefaults

//保存访问令牌
+(void)saveInstagramToken:(NSString*)token
{
    [Prefs savePref:INSTAGRAM_TOKEN value:token];
}

+(NSString*) getInstagramToken{
    return [Prefs retrieveForKey:INSTAGRAM_TOKEN];
}

+(void) clearInstagramToken{
    [Prefs clearForKey:INSTAGRAM_TOKEN];
}


//////////////////////////////////////////////////////////////通用操作//////////////////////////////////////////////////////////////////////

/** 保存键值对 */
+(void)savePref:(NSString*)key value:(id)value{
	NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
	if (standardUserDefaults) {
		[standardUserDefaults setObject:value forKey:key];
		[standardUserDefaults synchronize];
	}
}

/** 根据key取出保存的数据 */
+(id)retrieveForKey:(NSString*) key{
	NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
	if (standardUserDefaults) {
        return [standardUserDefaults objectForKey:key];
    }
	return nil;
}

/** 清空指定的参数 */
+(void) clearForKey:(NSString*)key
{
    NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
    if (standardUserDefaults) {
		[standardUserDefaults setObject:@"" forKey:key];
		[standardUserDefaults synchronize];
	}
}

/** 移除指定的key */
+(void) removeKey:(NSString*)key
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults removeObjectForKey:key];
}

/** 清空用户参数 */
+(void)clearAllPrefs{
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	NSArray *keys = [[[defaults dictionaryRepresentation] allKeys] copy];
	for(NSString *key in keys) {
		[defaults removeObjectForKey:key];
	}
}

@end
