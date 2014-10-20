//
//  BaseService.h
//  VideoShow
//
//  Created by chengkai.gan on 14-9-24.
//  Copyright (c) 2014年 energy. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ASIHTTPRequest.h"
#import "ASIDownloadCache.h"

@protocol BaseServiceDelegate;

/** 通用的网络请求 */
@interface BaseService : NSObject


/** 返回字符串 */
+ (NSString *) callHttpSync:(NSString *) methodName dict:(NSDictionary *) paramDict;

/** webservice url通用接口已经拼接好参数或者不带参数 */
+ (NSString *) callHttpSync:(NSString *) urlStr;

/* 通过url POST请求数据 post如果是表单需要替换成下面的提交方式 */
+ (NSString *) callPostSyncUrl:(NSString *) urlStr;

/* 通过url POST请求数据 post如果是表单需要替换成下面的提交方式 */
+ (NSString *) doPostSyncUrl:(NSString *) urlStr dict:(NSDictionary *)dictParams;

/** 模拟表单提交数据 */
+ (ASIHTTPRequest *) postFormData:(NSURL *)urlParam dictParams:(NSDictionary *)dictParams;

/** 调用http请求 返回ASIHTTPRequest对象 */
+ (ASIHTTPRequest *) callHttpSync:(NSString *) methodName paramDict:(NSDictionary *) paramDict;

/** 通过url GET请求数据 主要是对于下载数据的缓存 */
+ (ASIHTTPRequest *) callSyncWithURL:(NSURL *) urlStr cache:(ASIDownloadCache *)cache;

+ (NSString *) callSyncWithMethodName:(NSString *) methodName paramDict:(NSDictionary *) paramDict;

//==========================================Webservice SOAP方法======================================

+ (NSString *) callSyncWithMethodName:(NSString *)methodName paramDict:(NSDictionary *)paramDict userInfo:(NSDictionary *) userInfo;

+ (NSData *) downloadSync:(NSString *) urlParam;

+ (BOOL) downloadSync:(NSString *) urlParam saveTo:(NSString *)dir fileName:(NSString *)fileName;

//==================================异步方法===================================

//通过方法名调用指定的接口
+ (void) callService:(NSString *)methodName paramsDict:(NSMutableDictionary *)param delegate:(id<BaseServiceDelegate>)delegate message:(int)msgid;

//这个地方返回的委托需要特别处理
+(void) callAsyncWithDelegate:(id<ASIHTTPRequestDelegate>) delegate methodName:(NSString *)methodName paramsDict:(NSMutableDictionary *) paramsDict;
//这个地方返回的委托需要特别处理
+(void) callAsyncWithDelegate:(id<ASIHTTPRequestDelegate>) delegate methodName:(NSString *)methodName paramsDict:(NSMutableDictionary *) paramsDict userInfo:(NSDictionary *)userIfo;

//异步下载图片文件
+ (void) downloadAsync:(NSString *) urlParam fileName:(NSString *) fileName delegate:(id<BaseServiceDelegate>) delegate message:(int) msgid;

/** 判断远程文件是否存在 */
+ (BOOL) isExistsRemoteFile:(NSString *)url;

/** 下载图片---定义缓存策略 需要在AppDelegate中定义缓存策略 */
+ (ASIHTTPRequest *) downloadSyncData:(NSURL *)urlParam;

@end

//这里定义一个回调协议
@protocol BaseServiceDelegate <NSObject>
@optional
//这里返回字符串数据
-(void) callFinish:(NSString *)result message:(int)msgid;
//这里返回图像数据
-(void) callDataFinish:(NSData *)result message:(int)msgid;

@end