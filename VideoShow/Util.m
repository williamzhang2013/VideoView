//
//  Util.m
//  VideoShow
//
//  Created by Jerry Chen  on 14-7-23.
//  Copyright (c) 2014年 energy. All rights reserved.
//

#import "Util.h"
#import "qxTimeline.h"
#import "VideoDraft.h"
#import <Social/Social.h>
#import <Accounts/Accounts.h>
#import "SVProgressHUD.h"
#import "FileHandle.h"

@implementation Util

+ (NSString*)instagramAccessToken
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    return [defaults stringForKey:@"InstagramAccessToken"];
}

+ (void)saveInstagramAccessToken:(NSString*)accessToken
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:accessToken forKey:@"InstagramAccessToken"];
}
+ (NSString*)stringWithSeconds:(long)duration
{
    NSString *res = @"00 : 00";
    if(0 < duration && duration < 60){
        
        res = [NSString stringWithFormat:@"00 : %@",[self formatSingleTimeValue:duration]];
        
    }else if(60 <= duration && duration < 3600){
        
        res = [NSString stringWithFormat:@"%@ : %@",[self formatSingleTimeValue:duration/60],[self formatSingleTimeValue:duration%60]];
        
    }else if (duration >= 3600){
        
        int hour = (int)(duration/3600);
        int other = duration%3600;
        res = [NSString stringWithFormat:@"%d : %@ : %@",hour,[self formatSingleTimeValue:other/60],[self formatSingleTimeValue:other%60]];
        
    }
    return res;
}

+ (NSString*)formatSingleTimeValue:(long)value
{
    NSString *res = [NSString stringWithFormat:@"%ld",value];
    if(0 <= value && value < 10){
        res = [NSString stringWithFormat:@"0%ld",value];
    }
    return res;
}

+(void)showErrorAlertWithMessage:(NSString*)message
{
    UIAlertView *alertView =[[UIAlertView alloc] initWithTitle:nil message:message delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil];
    [alertView show];
}

+(void)deleteFile:(NSString*)filepath
{
    if(filepath){
        NSFileManager *fileManager = [NSFileManager defaultManager];
        if([fileManager fileExistsAtPath:filepath]){
            NSError *error;
            [fileManager removeItemAtPath:filepath error:&error];
            if(error){
                NSLog(@"delete file error :: %@ , %@",filepath,error);
            }else{
                NSLog(@"delete file success :: %@",filepath);
            }
        }
    }
}

+(void)saveVideo:(NSURL *)videoURL  toAlbum:(NSString *)customAlbumName  completionBlock:(void (^)(NSURL *videoUrl))completionBlock  failureBlock:(void (^)(NSError *error))failureBlock
{
    ALAssetsLibrary *assetsLibrary = [self defaultAssetsLibrary];
    __weak ALAssetsLibrary *assetsLibraryWeakRef = assetsLibrary;
    
    void (^addAsset)(ALAssetsLibrary *, NSURL *) = ^(ALAssetsLibrary *assetsLibrary, NSURL *assetURL) {
        [assetsLibrary assetForURL:assetURL resultBlock:^(ALAsset *asset) {
            [assetsLibrary enumerateGroupsWithTypes:ALAssetsGroupAll usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
                if ([[group valueForProperty:ALAssetsGroupPropertyName] isEqualToString:customAlbumName]) {
                    [group addAsset:asset];
                    if (completionBlock) {
                        completionBlock(assetURL);
                    }
                }
            } failureBlock:^(NSError *error) {
                if (failureBlock) {
                    failureBlock(error);
                }
            }];
        } failureBlock:^(NSError *error) {
            if (failureBlock) {
                failureBlock(error);
            }
        }];
    };
    
    [assetsLibrary writeVideoAtPathToSavedPhotosAlbum:videoURL completionBlock:^(NSURL *assetURL, NSError *error){
        if(customAlbumName){
            [assetsLibraryWeakRef addAssetsGroupAlbumWithName:customAlbumName resultBlock:^(ALAssetsGroup *group){
                if(group){
                    [assetsLibraryWeakRef assetForURL:assetURL resultBlock:^(ALAsset *asset){
                        [group addAsset:asset];
                        if(completionBlock){
                            completionBlock(assetURL);
                        }
                    } failureBlock:^(NSError *error){
                        if(failureBlock){
                            failureBlock(error);
                        }
                    }];
                    
                }else{
                    addAsset(assetsLibraryWeakRef, assetURL);
                }
            } failureBlock:^(NSError *error){
                addAsset(assetsLibraryWeakRef, assetURL);
            }];
        }else{
            if(completionBlock){
                completionBlock(assetURL);
            }
        }
    }];
}

+ (ALAssetsLibrary *)defaultAssetsLibrary
{
    static ALAssetsLibrary *assetsLibrary = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        assetsLibrary = [[ALAssetsLibrary alloc] init];
        
        // Workaround for triggering ALAssetsLibraryChangedNotification
        [assetsLibrary writeImageToSavedPhotosAlbum:nil metadata:nil completionBlock:^(NSURL *assetURL, NSError *error) { }];
    });
    
    return assetsLibrary;
}

+(NSString*)overlayImgDir
{
    NSArray *documents= NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentPath=[documents objectAtIndex:0];
    NSString *dir = [documentPath stringByAppendingPathComponent:@"Overlays"];
    if(![self fileExists:dir]){
        NSFileManager *fileManager = [NSFileManager defaultManager];
        BOOL ret = [fileManager createDirectoryAtPath:dir withIntermediateDirectories:YES attributes:nil error:nil];
        if(!ret){
            dir = nil;
        }
    }
    return dir;
}

+(NSString*)draftDir
{
    NSArray *documents= NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentPath=[documents objectAtIndex:0];
    return [documentPath stringByAppendingPathComponent:@"Dratfs"];
}

+(NSString*)createDraftDirIfNotExists
{
    NSString *draftPath = [self draftDir];
    if(![self fileExists:draftPath]){
        NSFileManager *fileManager = [NSFileManager defaultManager];
        BOOL ret = [fileManager createDirectoryAtPath:draftPath withIntermediateDirectories:YES attributes:nil error:nil];
        if(!ret){
            draftPath = nil;
        }
    }
    return draftPath;
}

+(BOOL)archiveDraft:(VideoDraft*)draft
{
    BOOL success = NO;
    if(draft && draft.timeline){
        NSString *draftDir = [self createDraftDirIfNotExists];
        if(draftDir){//Draft dir exists
            long long time = [[NSDate date] timeIntervalSince1970] * 1000;
            NSString *draftFile = [draftDir stringByAppendingPathComponent:[NSString stringWithFormat:@"%lld%@",time,@".archive"]];
            NSFileManager *fileManager = [NSFileManager defaultManager];
            if(![fileManager fileExistsAtPath:draftFile]){
                BOOL ret = [fileManager createFileAtPath:draftFile contents:nil attributes:nil];
                if(!ret){
                    draftFile = nil;
                }
            }
            if(draftFile){//Draft file exists
                success = [NSKeyedArchiver archiveRootObject:draft toFile:draftFile];
            }
        }
    }
    return success;
}

+(VideoDraft*)unArchiveDraft:(NSString*)draftFile
{
    VideoDraft *draft = nil;
    if(draftFile){
        draft = [NSKeyedUnarchiver unarchiveObjectWithFile:draftFile];
        if(draft){
            //0 : video track,  1 : music track,  2 : audio track,  3 : text track
            qxTimeline *tmpTimeline = draft.timeline;
            //rebuild track and mediaObject
            if(tmpTimeline && [tmpTimeline getTrackCount] >= 4){
                qxTrack *track = nil;
                qxTimeline *timeline = [[qxTimeline alloc] init];
                //video track
                track = [self rebuildVideoTrack:[tmpTimeline getTrackFromTimeline:0]];
                if(!track){
                    return nil;
                }
                [timeline addTrack:track];
                
                //music track
                track = [self rebuildMusicTrack:[tmpTimeline getTrackFromTimeline:1]];
                if(!track){
                    return nil;
                }
                [timeline addTrack:track];
                
                //audio track
                track = [self rebuildAudioTrack:[tmpTimeline getTrackFromTimeline:2]];
                if(!track){
                    return nil;
                }
                [timeline addTrack:track];
                
                //overlay track
                track = [self rebuildOverlayTrack:[tmpTimeline getTrackFromTimeline:3]];
                if(!track){
                    return nil;
                }
                [timeline addTrack:track];
                draft.timeline = timeline;
            }
        }
    }
    return draft;
}

+(BOOL)fileExists:(NSString*)file
{
    BOOL exists = NO;
    if(file && ![file isEqualToString:@""]){
        NSFileManager *fileManager = [NSFileManager defaultManager];
        exists = [fileManager fileExistsAtPath:file];
    }
    return exists;
}

+(qxTrack*)rebuildVideoTrack:(qxTrack*)srcTrack
{
    __block qxTrack *track = nil;
    qxMediaObject *medObj = nil;
    if(srcTrack && srcTrack.mpMediaObjArray.count > 0){//video track exists
        track = [[qxTrack alloc] initWithTrackType:eMT_Video];
        ALAssetsLibrary *library = [self defaultAssetsLibrary];
        dispatch_semaphore_t semapthore = dispatch_semaphore_create(0);
        for(qxMediaObject *obj in srcTrack.mpMediaObjArray){
            if(!track){
                break;
            }
            if(obj){
                medObj = [[qxMediaObject alloc] init];
                [library assetForURL:[NSURL URLWithString:obj.strFilePath] resultBlock:^(ALAsset *asset){
                    [medObj setFilePath:obj.strFilePath withType:obj.eType fromAssetLibrary:YES];
                    if(obj.eType == eMT_Photo){
                        [medObj setDuration:CMTimeGetSeconds(obj.mediaOriginalDuration) * 1000];
                    }else if(obj.eType == eMT_Video){
                        [medObj setTrim:CMTimeGetSeconds(obj.actualTimeRange.start) * 1000 withRight:(CMTimeGetSeconds(obj.mediaOriginalDuration) - CMTimeGetSeconds(obj.actualTimeRange.start) - CMTimeGetSeconds(obj.actualTimeRange.duration)) * 1000];
                    }
                    [track addMediaObject:medObj];
                    dispatch_semaphore_signal(semapthore);
                } failureBlock:^(NSError *error){
                    track = nil;
                    dispatch_semaphore_signal(semapthore);
                }];
            }
            dispatch_semaphore_wait(semapthore, DISPATCH_TIME_FOREVER);
        }
    }
    return track;
}

+(qxTrack*)rebuildMusicTrack:(qxTrack*)srcTrack
{
    __block qxTrack *track = [[qxTrack alloc] initWithTrackType:eMT_Audio];
    qxMediaObject *medObj = nil;
    //music track
    if(srcTrack && srcTrack.mpMediaObjArray.count > 0){
        ALAssetsLibrary *library = [self defaultAssetsLibrary];
        dispatch_semaphore_t semapthore = dispatch_semaphore_create(0);
        for(qxMediaObject *obj in srcTrack.mpMediaObjArray){
            if(!track){
                break;
            }
            if(obj){
                medObj = [[qxMediaObject alloc] init];
                [library assetForURL:[NSURL URLWithString:obj.strFilePath] resultBlock:^(ALAsset *asset){
                    [medObj setFilePath:obj.strFilePath withType:eMT_Audio fromAssetLibrary:YES];
                    [medObj setTrim:CMTimeGetSeconds(obj.actualTimeRange.start) * 1000 withRight:(CMTimeGetSeconds(obj.mediaOriginalDuration) - CMTimeGetSeconds(obj.actualTimeRange.start) - CMTimeGetSeconds(obj.actualTimeRange.duration)) * 1000];
                    [track addMediaObject:medObj];
                    dispatch_semaphore_signal(semapthore);
                } failureBlock:^(NSError *error){
                    track = nil;
                    dispatch_semaphore_signal(semapthore);
                }];
            }
            dispatch_semaphore_wait(semapthore, DISPATCH_TIME_FOREVER);
        }
    }
    return track;
}

+(qxTrack*)rebuildAudioTrack:(qxTrack*)srcTrack
{
    __block qxTrack *track = [[qxTrack alloc] initWithTrackType:eMT_Audio];
    qxMediaObject *medObj = nil;
    if(srcTrack && srcTrack.mpMediaObjArray.count > 0){
        ALAssetsLibrary *library = [self defaultAssetsLibrary];
        dispatch_semaphore_t semapthore = dispatch_semaphore_create(0);
        for(qxMediaObject *obj in srcTrack.mpMediaObjArray){
            if(!track){
                break;
            }
            if(obj){
                medObj = [[qxMediaObject alloc] init];
                [library assetForURL:[NSURL URLWithString:obj.strFilePath] resultBlock:^(ALAsset *asset){
                    [medObj setFilePath:obj.strFilePath withType:eMT_Audio fromAssetLibrary:YES];
                    [medObj setTrim:CMTimeGetSeconds(obj.actualTimeRange.start) * 1000 withRight:(CMTimeGetSeconds(obj.mediaOriginalDuration) - CMTimeGetSeconds(obj.actualTimeRange.start) - CMTimeGetSeconds(obj.actualTimeRange.duration)) * 1000];
                    [track addMediaObject:medObj];
                    dispatch_semaphore_signal(semapthore);
                } failureBlock:^(NSError *error){
                    track = nil;
                    dispatch_semaphore_signal(semapthore);
                }];
            }
            dispatch_semaphore_wait(semapthore, DISPATCH_TIME_FOREVER);
        }
    }
    return track;
}

+(qxTrack*)rebuildOverlayTrack:(qxTrack*)srcTrack
{
    qxTrack *track = [[qxTrack alloc] initWithTrackType:eMT_Overlay];
    qxMediaObject *medObj = nil;
    qxMediaObject *textObj = nil;
    if(srcTrack && srcTrack.mpMediaObjArray.count > 0){
        for(qxMediaObject *obj in srcTrack.mpMediaObjArray){
            if(obj){
                medObj = [[qxMediaObject alloc] init];
                [medObj setFilePath:obj.strFilePath withType:eMT_Overlay fromAssetLibrary:NO];
                textObj = [[qxMediaObject alloc] init];
                [textObj setFilePath:nil withType:eMT_Text fromAssetLibrary:NO];
                [textObj setText:((qxMediaObject*)obj.overlayCustomObj).text];
                [textObj setTextColor:((qxMediaObject*)obj.overlayCustomObj).textColor];
                [textObj setTextFont:((qxMediaObject*)obj.overlayCustomObj).textFont.fontName size:((qxMediaObject*)obj.overlayCustomObj).textFontSize];
                [textObj setDisplayRect:obj.textDisplayRect];
                medObj.overlayCustomObj = textObj;
                [medObj setDisplayRect:obj.textDisplayRect];
                [track addMediaObject:medObj];
                [track updateTimeAtIndex:(int)track.mpMediaObjArray.count - 1 startTime:obj.startTimeOfTrack duration:obj.mediaOriginalDuration];
            }
        }
    }
    return track;
}

+(void)clearPhotoTrack:(qxTrack*)track
{
    if(track && track.mpMediaObjArray.count > 0){
        for(qxMediaObject *obj in track.mpMediaObjArray){
            if(obj && (obj.eType == eMT_Photo || obj.eType == eMT_Overlay)){
                [obj clearPhoto];
            }
        }
    }
}


+ (void)uploadVideoALAssetToFacebook:(ALAsset*)asset
{
    [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeClear];
    ACAccountStore *accountStore = [[ACAccountStore alloc] init];
    ACAccountType *accountType = [accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierFacebook];
    NSDictionary *publishWritePermisson = @{
                                            ACFacebookAppIdKey : @"606029609517176",
                                            ACFacebookPermissionsKey : @[@"publish_actions"],
                                            ACFacebookAudienceKey : ACFacebookAudienceEveryone
                                            };
    
    
    [accountStore requestAccessToAccountsWithType:accountType options:publishWritePermisson completion:^(BOOL granted, NSError *error){
         if (granted){
             NSArray *counts = [accountStore accountsWithAccountType:accountType];
             if (counts && [counts count] > 0){
                 [self requestWithAccount:[counts objectAtIndex:0] andAsset:asset];
             }
             if(error){
                 dispatch_async(dispatch_get_main_queue(), ^{
                     [SVProgressHUD dismiss];
                     [SVProgressHUD showSuccessWithStatus:NSLocalizedString(@"Upload Failed", nil) duration:2.0];
                 });
             }
         }else{
             dispatch_async(dispatch_get_main_queue(), ^{
                 [SVProgressHUD dismiss];
                 [Util showErrorAlertWithMessage:NSLocalizedString(@"Set Facebook Account in Setting", nil)];
             });
         }
     }];
    
}

+ (void)requestWithAccount:(ACAccount*)account andAsset:(ALAsset*)asset
{
    NSString *file = [self generateTempFileFromALAsset:asset];
    if(!file){
        return;
    }
    NSURL *videourl = [NSURL URLWithString:@"https://graph.facebook.com/me/videos"];
    
    NSData *videoData = [NSData dataWithContentsOfFile:file];
    NSDictionary *params = @{
                             @"title": @"VideoShow",
                             @"description": @""
                             };
    
    SLRequest *uploadRequest = [SLRequest requestForServiceType:SLServiceTypeFacebook
                                                  requestMethod:SLRequestMethodPOST
                                                            URL:videourl
                                                     parameters:params];
    [uploadRequest addMultipartData:videoData
                           withName:@"source"
                               type:@"video/quicktime"
                           filename:[file lastPathComponent]];
    uploadRequest.account = account;
    
    [uploadRequest performRequestWithHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) {
        NSString *responseString = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
        dispatch_async(dispatch_get_main_queue(), ^{
            [SVProgressHUD dismiss];
        });
        if(error){
            dispatch_async(dispatch_get_main_queue(), ^{
                [SVProgressHUD showSuccessWithStatus:NSLocalizedString(@"Upload Failed", nil) duration:2.0];
            });
            NSLog(@"Error %@", error.localizedDescription);
        }else{
            dispatch_async(dispatch_get_main_queue(), ^{
                [SVProgressHUD showSuccessWithStatus:NSLocalizedString(@"Upload Success", nil) duration:2.0];
            });
            NSLog(@"%@", responseString);
        }
        [Util deleteFile:file];
    }];
}

+ (void)deleteDraft:(NSString*)filename
{
    VideoDraft *draft = [NSKeyedUnarchiver unarchiveObjectWithFile:filename];
    if(draft){
        qxTimeline *tmpTimeline = draft.timeline;
        if(tmpTimeline && tmpTimeline.getTrackCount == 4){
            //overlay
            qxTrack *subtitleTrack = [tmpTimeline getTrackFromTimeline:3];
            if(subtitleTrack && subtitleTrack.mpMediaObjArray){
                for(qxMediaObject *obj in subtitleTrack.mpMediaObjArray){
                    [Util deleteFile:obj.strFilePath];
                }
            }
            //audio
            qxTrack *audioTrack = [tmpTimeline getTrackFromTimeline:2];
            if(audioTrack && audioTrack.mpMediaObjArray){
                for(qxMediaObject *obj in audioTrack.mpMediaObjArray){
                    [Util deleteFile:obj.strFilePath];
                }
            }
        }
    }
    [Util deleteFile:filename];
}

+ (NSString*)generateTempFileFromALAsset:(ALAsset*)asset
{
    NSString *file = nil;
    if(asset){
        file = [NSTemporaryDirectory() stringByAppendingPathComponent:@"tempVideo.mp4"];
        NSFileManager *fileManager = [NSFileManager defaultManager];
        if(![fileManager fileExistsAtPath:file]){
            [fileManager createFileAtPath:file contents:nil attributes:nil];
        }
        NSFileHandle *fileHandle = [NSFileHandle fileHandleForWritingAtPath:file];
        [fileHandle seekToFileOffset:0];
        ALAssetRepresentation *rep = [asset defaultRepresentation];
        NSUInteger size = 1024 * 1024;
        Byte *buffer = (Byte*)malloc((long)size);
        NSUInteger buffered = 0;
        NSData *data = nil;
        long long totalSize = 0;
        do {
            buffered = [rep getBytes:buffer fromOffset:totalSize length:size error:nil];
            data = [NSData dataWithBytesNoCopy:buffer length:buffered freeWhenDone:NO];
            [fileHandle writeData:data];
            totalSize += buffered;
            bzero(buffer, size);
            if(data){
                
            }
        } while (buffered > 0);
        free(buffer);
        [fileHandle closeFile];
    }
    return file;
}

+(NSMutableArray*)rgbValueFromColor:(UIColor*)color
{
    NSMutableArray *rgbValueArr = [[NSMutableArray alloc] init];
    NSString *rgbValue = [NSString stringWithFormat:@"%@",color];
    NSArray *rgbArr = [rgbValue componentsSeparatedByString:@" "];
    float r = [rgbArr[1] floatValue] * 255;
    [rgbValueArr addObject:[NSNumber numberWithFloat:r]];
    float g = [rgbArr[2] floatValue] * 255;
    [rgbValueArr addObject:[NSNumber numberWithFloat:g]];
    float b = [rgbArr[3] floatValue] * 255;
    [rgbValueArr addObject:[NSNumber numberWithFloat:b]];
    float a = [rgbArr[4] floatValue];
    [rgbValueArr addObject:[NSNumber numberWithFloat:a]];
    return rgbValueArr;
}

//生成临时的igo格式文件
+ (NSString*)generateTempIGOFileFromALAsset:(ALAsset*)asset
{
    NSString *file = nil;
    if(asset){
        file = [[FileHandle getDocumentDir] stringByAppendingPathComponent:@"tempVideo.mp4.igo"];
        NSFileManager *fileManager = [NSFileManager defaultManager];
        if(![fileManager fileExistsAtPath:file]){
            [fileManager createFileAtPath:file contents:nil attributes:nil];
        }
        NSFileHandle *fileHandle = [NSFileHandle fileHandleForWritingAtPath:file];
        [fileHandle seekToFileOffset:0];
        ALAssetRepresentation *rep = [asset defaultRepresentation];
        NSUInteger size = 1024 * 1024;
        Byte *buffer = (Byte*)malloc((long)size);
        NSUInteger buffered = 0;
        NSData *data = nil;
        long long totalSize = 0;
        do {
            buffered = [rep getBytes:buffer fromOffset:totalSize length:size error:nil];
            data = [NSData dataWithBytesNoCopy:buffer length:buffered freeWhenDone:NO];
            [fileHandle writeData:data];
            totalSize += buffered;
            bzero(buffer, size);
            if(data){
                
            }
        } while (buffered > 0);
        free(buffer);
        [fileHandle closeFile];
    }
    return file;
}

@end
