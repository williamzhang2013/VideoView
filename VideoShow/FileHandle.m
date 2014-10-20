//
//  FileHandle.m
//  Wallinter
//
//  Created by lance on 14-2-22.
//  Copyright (c) 2014年 lance. All rights reserved.
//

#import "FileHandle.h"
#import "NetService.h"
#import "NSString+Util.h"

@implementation FileHandle

//判断文件是否存在
+ (BOOL) existFile:(NSString *) dir fileName:(NSString *) fileName;
{
    NSString * filePath=[NSString stringWithFormat:@"%@/%@",dir,fileName];
    if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
        return YES;
    }
    return NO;
}
//写入图片数据到文件系统
+ (BOOL) writeImage:(NSData *) data toDir:(NSString *) dir fileName:(NSString *) fileName
{
    if(data==nil){
        return NO;
    }
    //文件保存路径
    NSString *savePath = [NSString stringWithFormat:@"%@/%@",dir,fileName];
    if (![[NSFileManager defaultManager] fileExistsAtPath:dir]) {//判断目录是否存在
        NSError * error;
        [[NSFileManager defaultManager] createDirectoryAtPath:dir withIntermediateDirectories:YES attributes:nil error:&error];
        if(error){//创建失败返回false
            return NO;
        }
    }
    return [data writeToFile:savePath atomically:YES];
}

//根据文件路径获取图片
+ (UIImage *) getImageWithDir:(NSString *)dir fileName:(NSString *) fileName
{
    NSString * filePath=[NSString stringWithFormat:@"%@/%@",dir,fileName];
    return [FileHandle getImageWithDirWithAbsolutePath:filePath];
}

//根据文件绝对路径获取图片
+ (UIImage *) getImageWithDirWithAbsolutePath:(NSString *)filePath
{
    if([[NSFileManager defaultManager] fileExistsAtPath:filePath]){
        NSData * data=[[NSFileManager defaultManager] contentsAtPath:filePath];
        return [UIImage imageWithData:data];
    }
    return nil;
}

+ (NSArray *) contentOfDir:(NSString *) dir
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *error = nil;
    //fileList便是包含有该文件夹下所有文件的文件名及文件夹名的数组
    NSArray *fileList = [fileManager contentsOfDirectoryAtPath:dir error:&error];
    if (!error) {
    }
    return fileList;
}

+ (BOOL) deleteFile:(NSString *) filePath
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if([fileManager fileExistsAtPath:filePath]){
        NSError * error;
        [fileManager removeItemAtPath:filePath error:&error];
        if(error){
            return NO;
        }
    }
    return YES;
}

/* 获取程序的Home目录 */
+ (NSString *) getHomeDirectory
{
    return NSHomeDirectory();
}

+ (NSString *) getDocumentDir
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    return [paths objectAtIndex:0];
}

+ (NSString *) getCacheDirectory
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    return [paths objectAtIndex:0];
}

//获取Library目录
+ (NSString *) getLibraryDirectory
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
    return [paths objectAtIndex:0];
}

//获取Tmp目录
+ (NSString *) getTempDirectory
{
    return NSTemporaryDirectory();
}

//单个文件的大小
+ (long long) fileSizeAtPath:(NSString*) filePath{
    NSFileManager* manager = [NSFileManager defaultManager];
    if ([manager fileExistsAtPath:filePath]){
        return [[manager attributesOfItemAtPath:filePath error:nil] fileSize];
    }
    return 0;
}

//遍历文件夹获得文件夹大小，返回多少M
+ (float ) folderSizeAtPath:(NSString*) folderPath{
    NSFileManager* manager = [NSFileManager defaultManager];
    if (![manager fileExistsAtPath:folderPath]) {
        return 0;
    }
    NSEnumerator *childFilesEnumerator = [[manager subpathsAtPath:folderPath] objectEnumerator];
    NSString* fileName;
    long long folderSize = 0;
    while ((fileName = [childFilesEnumerator nextObject]) != nil){
        NSString* fileAbsolutePath = [folderPath stringByAppendingPathComponent:fileName];
        folderSize += [self fileSizeAtPath:fileAbsolutePath];
    }
    return folderSize/(1024.0*1024.0);
}


@end
