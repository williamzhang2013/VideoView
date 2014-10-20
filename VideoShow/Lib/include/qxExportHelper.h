//
//  qxExportHelper.h
//  videoeditor
//
//  Created by MingweiShen on 14-3-5.
//  Copyright (c) 2014年 quxun. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "qxTimeline.h"

@protocol qxExportDelegate <NSObject>
@optional
//status=0, fail; status=1, success
-(void)exportStatus:(int)status;
-(void)exportProgress:(float)fPercent;
@end

@interface qxExportHelper : NSObject

@property(nonatomic, assign) qxTimeline * mpTimeline;
@property(nonatomic, copy) NSString * strOutput;
@property(nonatomic, assign) id<qxExportDelegate> delegate;

//quality=1, FHD; quality=2, 720p; quality=3, VGA
-(void)doSave:(int)quality;

-(void)doSaveForSingleFile:(int)quality;

-(void)cancelSave;

@end
