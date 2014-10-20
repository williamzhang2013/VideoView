//
//  NSString+ArrayUtil.m
//  wallintermobile
//
//  Created by lance on 13-11-26.
//  Copyright (c) 2013年 ganchengkai. All rights reserved.
//

#import "NSString+Util.h"
#import "AppMacros.h"
#import <CommonCrypto/CommonDigest.h>

@implementation NSString (Util)

//去掉换行符
-(NSString*) removeLine {
    NSString * str=[self stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    str = [str stringByReplacingOccurrencesOfString:@"\r" withString:@""];
    return [str stringByReplacingOccurrencesOfString:@"\t" withString:@""];
}

//检测是否包含指定的字符
-(BOOL) containString:(NSString*)containString{
    NSRange foundObj=[self rangeOfString:containString options:NSCaseInsensitiveSearch];
    return foundObj.length>0;
}


//修复空白
-(NSString *)trim{
    return [self stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
}

- (void) convertToArray:(float*)rotatef
{
    NSArray * arr=[self componentsSeparatedByString:@","];
    for (int i=0; i<arr.count; i++) {
        rotatef[i]=[[arr objectAtIndex:i] floatValue];
    }
}

+ (BOOL) isNull:(NSString *)string
{
    if (string == nil || string == NULL) {
        return YES;
    }
    if ([string isKindOfClass:[NSNull class]]) {
        return YES;
    }
    if ([[string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] length]==0) {
        return YES;
    }
    return NO;
}

//将字符串进行MD5加密---32位算法
-(NSString *) md5HexDigest{
    const char *original_str = [self UTF8String];
    unsigned char result[CC_MD5_DIGEST_LENGTH];
    CC_MD5(original_str, strlen(original_str), result);
    NSMutableString *hash = [NSMutableString string];
    for (int i = 0; i < CC_MD5_DIGEST_LENGTH; i++){
        [hash appendFormat:@"%02X", result[i]];
    }
    return [hash lowercaseString];
}

/** 判断是否匹配手机号 */
-(BOOL) isMatchePhone{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",PHONE_REGEX];
    return [predicate evaluateWithObject:self];
}

/** 判断是否匹配邮箱 */
-(BOOL) isMatcheEmail{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",EMAIL_REGEX];
    return [predicate evaluateWithObject:self];
}

@end
