//
//  BaseService.m
//  VideoShow
//
//  Created by chengkai.gan on 14-9-24.
//  Copyright (c) 2014年 energy. All rights reserved.
//

#import "BaseService.h"
#import "NetService.h"
#import "ASIHTTPRequest.h"
#import "ASIFormDataRequest.h"
#import "AppMacros.h"
#import "FileHandle.h"
#import "NSString+Util.h"
//#import "base64.h"

#import "AppDelegate.h"

@implementation BaseService

/** 返回字符串 */
+ (NSString *) callHttpSync:(NSString *) methodName dict:(NSDictionary *) paramDict
{
    return [self callHttpSync:methodName paramDict:paramDict].responseString;
}

/** webservice url通用接口已经拼接好参数或者不带参数 */
+ (NSString *) callHttpSync:(NSString *) urlStr
{
    NSURL * url=[NSURL URLWithString:[urlStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    ASIHTTPRequest * req=[ASIHTTPRequest requestWithURL:url];
    [req setRequestMethod:@"GET"];
    [req startSynchronous];
    NSError * error=[req error];
    if(!error){//如果没有错误
        return [req responseString];
    }else{
        //NSLog(@"接口错误:%@",[error localizedDescription]);
    }
    return [req responseString];
}

/* 通过url POST请求数据 post如果是表单需要替换成下面的提交方式 */
+ (NSString *) callPostSyncUrl:(NSString *) urlStr
{
    NSURL * url=[NSURL URLWithString:[urlStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    ASIHTTPRequest * req=[ASIHTTPRequest requestWithURL:url];
    [req setRequestMethod:@"POST"];
    [req startSynchronous];
    NSError * error=[req error];
    if(!error){//如果没有错误
        return [req responseString];
    }else{
        //NSLog(@"接口错误:%@",[error localizedDescription]);
    }
    return nil;
}

/* 通过url POST请求数据 post如果是表单需要替换成下面的提交方式 */
+ (NSString *) doPostSyncUrl:(NSString *) urlStr dict:(NSDictionary *)dictParams
{
    NSURL * url=[NSURL URLWithString:[urlStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    ASIHTTPRequest *req=[BaseService postFormData:url dictParams:dictParams];
    NSError * error=[req error];
    if(!error){//如果没有错误
        return [req responseString];
    }else{
        //NSLog(@"接口错误:%@",[error localizedDescription]);
    }
    return nil;
}

/** 模拟表单提交数据 */
+ (ASIHTTPRequest *) postFormData:(NSURL *)urlParam dictParams:(NSDictionary *)dictParams
{
    NSArray * keys=[dictParams allKeys];
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:urlParam];
    [request setDelegate:self];
    request.tag = 1020;
    for (int i=0; i<keys.count; i++) {
        NSString * key=[keys objectAtIndex:i];
        [request setPostValue:[dictParams objectForKey:key] forKey:key];
    }
    //[request addSecret];
    [request setRequestMethod:@"POST"];
    [request startSynchronous];
    return request;
}


/** 调用http请求 返回ASIHTTPRequest对象 */
+ (ASIHTTPRequest *) callHttpSync:(NSString *) methodName paramDict:(NSDictionary *) paramDict
{
    NSMutableString * urlStr=[NSMutableString stringWithFormat:@"%@%@%@?",SERVICE_HOST,@"",methodName];
    NSArray * keys=[paramDict allKeys];
    for (int i=0; i<keys.count; i++) {
        NSString *key=[keys objectAtIndex:i];
        if(i!=keys.count-1){
            [urlStr appendFormat:@"%@=%@&",key,[paramDict objectForKey:key]];
        }else{
            [urlStr appendFormat:@"%@=%@",key,[paramDict objectForKey:key]];
        }
    }
    NSURL * url=[NSURL URLWithString:[urlStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    ASIHTTPRequest * request=[ASIHTTPRequest requestWithURL:url];
    [request setRequestMethod:@"GET"];
    [request startSynchronous];
    return request;
    
}

/** 通过url GET请求数据 主要是对于下载数据的缓存 */
+ (ASIHTTPRequest *) callSyncWithURL:(NSURL *) urlStr cache:(ASIDownloadCache *)cache
{
    ASIHTTPRequest * request=[ASIHTTPRequest requestWithURL:urlStr];
    [request setRequestMethod:@"GET"];
    [request setDownloadCache:cache];
    [request setCacheStoragePolicy:ASICachePermanentlyCacheStoragePolicy];
    [request startSynchronous];
    return request;
}

+ (NSString *) callSyncWithMethodName:(NSString *) methodName paramDict:(NSDictionary *) paramDict
{
    return [BaseService callSyncWithMethodName:methodName
                                      paramDict:paramDict userInfo:nil];
}

//==========================================Webservice SOAP方法======================================

+ (NSData *) downloadSync:(NSString *) urlParam
{
    NSURL * url=[NSURL URLWithString:[urlParam stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    //NSLog(@"远程下载地址-->%@",urlParam);
    ASIHTTPRequest * req=[ASIHTTPRequest requestWithURL:url];
    [req setRequestMethod:@"GET"];
    
    [req startSynchronous];
    
    NSError * error=[req error];
    if(!error){
        return [req responseData];
    }else{
        //NSLog(@"down fail:%@",[error localizedDescription]);
    }
    return nil;
}

+ (BOOL) downloadSync:(NSString *) urlParam saveTo:(NSString *)dir fileName:(NSString *)fileName
{
    if ([[FileHandle class] existFile:dir fileName:fileName]) {//如果文件存在
        return YES;
    }
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:urlParam]];
    [request startSynchronous];
    int statusCode = [request responseStatusCode];
    if(statusCode==200){//远程文件存在
        NSError * error=[request error];
        if(!error){
            NSData *data=[request responseData];
            return [[FileHandle class] writeImage:data toDir:dir fileName:fileName];
        }
    }
    return NO;
}

//==================================异步方法===================================

//通过方法名调用指定的接口
+ (void) callService:(NSString *)methodName paramsDict:(NSMutableDictionary *)param delegate:(id<BaseServiceDelegate>)delegate message:(int)msgid{
    dispatch_queue_t pool = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(pool, ^{
        NSString * result=[[self class] callSyncWithMethodName:methodName paramDict:param];
        dispatch_async(dispatch_get_main_queue(), ^{
            if(delegate!=nil){
                [delegate callFinish:result message:msgid];
            }
        });
    });
}


//这个地方返回的委托需要特别处理
+(void) callAsyncWithDelegate:(id<ASIHTTPRequestDelegate>) delegate methodName:(NSString *)methodName paramsDict:(NSMutableDictionary *) paramsDict
{
    [[self class] callAsyncWithDelegate:delegate methodName:methodName paramsDict:paramsDict userInfo:nil];
}
//这个地方返回的委托需要特别处理
+(void) callAsyncWithDelegate:(id<ASIHTTPRequestDelegate>) delegate methodName:(NSString *)methodName paramsDict:(NSMutableDictionary *) paramsDict userInfo:(NSDictionary *)userIfo
{
    NSMutableString *url_string=[NSMutableString stringWithFormat:@"%@",WSDL];
    [url_string appendString:methodName];
    
    NSArray * keys=[paramsDict allKeys];
    
    for (int i=0; i<keys.count; i++) {
        NSString * key= [keys objectAtIndex:i];
        if(i!=keys.count-1){
            [url_string appendFormat:@"%@=%@&",key,[paramsDict objectForKey:key]];
        }else{
            [url_string appendFormat:@"%@=%@",key,[paramsDict objectForKey:key]];
        }
    }
    NSURL * url=[NSURL URLWithString:[url_string stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding]];
    ASIHTTPRequest * req=[ASIHTTPRequest requestWithURL:url];
    
    [req setRequestMethod:@"GET"];
    [req setUserInfo:userIfo];
    
    [req setDelegate:delegate];
    
    [req startAsynchronous];
}

//异步下载图片文件
+ (void) downloadAsync:(NSString *) urlParam fileName:(NSString *) fileName delegate:(id<BaseServiceDelegate>) delegate message:(int) msgid
{
    dispatch_queue_t pool = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(pool, ^{
        NSData * data=[[self class] downloadSync:urlParam];
        dispatch_async(dispatch_get_main_queue(), ^{
            if(delegate!=nil){
                [delegate callDataFinish:data message:msgid];
            }
        });
    });
}

/** 判断远程文件是否存在 */
+ (BOOL) isExistsRemoteFile:(NSString *)url
{
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:url]];
    [request startSynchronous];
    int statusCode = [request responseStatusCode];
    if(statusCode==200){
        return YES;
    }
    return NO;
}

/** 下载图片---定义缓存策略 需要在AppDelegate中定义缓存策略 */
+ (ASIHTTPRequest *) downloadSyncData:(NSURL *)urlParam
{
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:urlParam];
//    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    //[request setDownloadCache:appDelegate.customCache];//使用时这里需要打开---需要在AppDelegate中定义缓存策略
    [request setCacheStoragePolicy:ASICachePermanentlyCacheStoragePolicy];
    [request startSynchronous];
    
    NSError * error=[request error];
    if(!error){
        return request;
    }else{
        //NSLog(@"down fail:%@",[error localizedDescription]);
    }
    return nil;
}

//=========================================辅助方法===============================================

#pragma mark private 提取webservice(SOAP协议)结果集XML中的内容 去掉不需要的内容
+ (NSMutableDictionary *) extractXML:(NSMutableDictionary *)xmlDictionary {
    
    for (NSString *key in [xmlDictionary allKeys]) {
        // get the current object for this key
        id object = [xmlDictionary objectForKey:key];
        
        if ([object isKindOfClass:[NSDictionary class]]) {
            if ([[object allKeys] count] == 1 &&
                [[[object allKeys] objectAtIndex:0] isEqualToString:KEY] &&
                ![[object objectForKey:KEY] isKindOfClass:[NSDictionary class]]) {
                // this means the object has the key "text" and has no node
                // or array (for multiple values) attached to it.
                [xmlDictionary setObject:[object objectForKey:KEY] forKey:key];
            }else {
                // go deeper
                [self extractXML:object];
            }
        }else if ([object isKindOfClass:[NSArray class]]) {
            // this is an array of dictionaries, iterate
            for (id inArrayObject in (NSArray *)object) {
                if ([inArrayObject isKindOfClass:[NSDictionary class]]) {
                    // if this is a dictionary, go deeper
                    [self extractXML:inArrayObject];
                }
            }
        }
    }
    
    return xmlDictionary;
}

/** 模拟表单提交 可带图片 返回服务器结果 */
+ (NSString *)postRequestWithURL: (NSString *)url postParams: (NSMutableDictionary *)postParams picFilePath: (NSString *)picFilePath {
    
    NSString *TWITTERFON_FORM_BOUNDARY = @"line";
    //根据url初始化request
    NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]
                                                           cachePolicy:NSURLRequestReloadIgnoringLocalCacheData
                                                       timeoutInterval:100];
    //分界线 --AaB03x
    NSString *MPboundary=[[NSString alloc]initWithFormat:@"--%@",TWITTERFON_FORM_BOUNDARY];
    //结束符 AaB03x--
    NSString *endMPboundary=[[NSString alloc]initWithFormat:@"%@--",MPboundary];
    //得到图片的data
    NSData* data;
    if(picFilePath){
        UIImage *image=[UIImage imageWithContentsOfFile:picFilePath];
        //判断图片是不是png格式的文件
        if (UIImagePNGRepresentation(image)) {
            //返回为png图像。
            data = UIImagePNGRepresentation(image);
        }else {
            //返回为JPEG图像。
            data = UIImageJPEGRepresentation(image, 1.0);
        }
    }
    //http body的字符串
    NSMutableString *body=[[NSMutableString alloc]init];
    //参数的集合的所有key的集合
    NSArray *keys= [postParams allKeys];
    //遍历keys
    for(int i=0;i<[keys count];i++) {
        //得到当前key
        NSString *key=[keys objectAtIndex:i];
        //添加分界线，换行
        [body appendFormat:@"%@\r\n",MPboundary];
        //添加字段名称，换2行
        [body appendFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n",key];
        //添加字段的值
        [body appendFormat:@"%@\r\n",[postParams objectForKey:key]];
    }
    
    if(picFilePath){
        ////添加分界线，换行
        [body appendFormat:@"%@\r\n",MPboundary];
        //这里name为文件类型 filename为本地文件路径
        [body appendFormat:@"Content-Disposition: form-data; name=\"file\"; filename=\"%@\"\r\n",picFilePath];
        //声明上传文件的格式
        [body appendFormat:@"Content-Type: image/png,image/gif, image/jpeg, image/pjpeg, image/jpg\r\n\r\n"];
    }else{//如果没有图片路径去除最后的换行符
        body=[NSMutableString stringWithFormat:@"%@",body.trim];
    }
    
    //声明结束符：--AaB03x--
    NSString *end=[[NSString alloc]initWithFormat:@"\r\n%@",endMPboundary];
    //声明myRequestData，用来放入http body
    NSMutableData *myRequestData=[NSMutableData data];
    //将body字符串转化为UTF8格式的二进制
    [myRequestData appendData:[body dataUsingEncoding:NSUTF8StringEncoding]];
    if(picFilePath){
        //将image的data加入
        [myRequestData appendData:data];
    }
    //加入结束符--AaB03x--
    [myRequestData appendData:[end dataUsingEncoding:NSUTF8StringEncoding]];
    
    //设置HTTPHeader中Content-Type的值
    NSString *content=[[NSString alloc]initWithFormat:@"multipart/form-data; boundary=%@",TWITTERFON_FORM_BOUNDARY];
    //设置HTTPHeader
    [request setValue:content forHTTPHeaderField:@"Content-Type"];
    //设置Content-Length
    [request setValue:[NSString stringWithFormat:@"%lu", (unsigned long)[myRequestData length]] forHTTPHeaderField:@"Content-Length"];
    //设置http body
    [request setHTTPBody:myRequestData];
    //http method
    [request setHTTPMethod:@"POST"];
    
    NSHTTPURLResponse *urlResponese = nil;
    NSError *error = [[NSError alloc]init];
    NSData* resultData = [NSURLConnection sendSynchronousRequest:request   returningResponse:&urlResponese error:&error];
    NSString* result= [[NSString alloc] initWithData:resultData encoding:NSUTF8StringEncoding];
    if([urlResponese statusCode] >=200&&[urlResponese statusCode]<300){
        return result;
    }
    return nil;
}

@end
