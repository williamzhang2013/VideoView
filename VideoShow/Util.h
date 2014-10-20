//
//  Util.h
//  VideoShow
//
//  Created by Jerry Chen  on 14-7-23.
//  Copyright (c) 2014年 energy. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AssetsLibrary/AssetsLibrary.h>

#define VideoShowAlbum  @"VideoShow"

typedef void (^GenerateFrameComplementionHandler)(NSMutableArray *frames, float spi, Float64 duraion);

@class VideoDraft;
@class qxTimeline;
@class qxTrack;
@interface Util : NSObject

+ (NSString*)instagramAccessToken;
+ (void)saveInstagramAccessToken:(NSString*)accessToken;
+ (NSString*)stringWithSeconds:(long)duration;
+(void)showErrorAlertWithMessage:(NSString*)message;
+(void)saveVideo:(NSURL *)videoURL  toAlbum:(NSString *)customAlbumName  completionBlock:(void (^)(NSURL *videoUrl))completionBlock  failureBlock:(void (^)(NSError *error))failureBlock;
+(void)deleteFile:(NSString*)filepath;
+(ALAssetsLibrary *)defaultAssetsLibrary;
+(BOOL)archiveDraft:(VideoDraft*)draft;
+(VideoDraft*)unArchiveDraft:(NSString*)draftFile;
+(NSString*)draftDir;
+ (void)uploadVideoALAssetToFacebook:(ALAsset*)asset;
+(void)clearPhotoTrack:(qxTrack*)track;
+ (void)deleteDraft:(NSString*)filename;
+ (NSString*)generateTempFileFromALAsset:(ALAsset*)asset;
+(NSString*)overlayImgDir;
+(NSMutableArray*)rgbValueFromColor:(UIColor*)color;
+ (NSString*)generateTempIGOFileFromALAsset:(ALAsset*)asset;
@end
