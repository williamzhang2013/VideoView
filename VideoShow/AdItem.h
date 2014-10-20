//
//  AdItem.h
//  VideoShow
//
//  Created by Jerry Chen  on 14-7-17.
//  Copyright (c) 2014年 energy. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AdItem : NSObject

@property (nonatomic,strong) NSNumber *id;
@property (nonatomic,strong) NSNumber *type;
@property (nonatomic,strong) NSString *advertActivity;
@property (nonatomic,strong) NSString *advertUrl;
@property (nonatomic,strong) NSString *name;
@property (nonatomic,strong) NSString *picUrl;

@end
