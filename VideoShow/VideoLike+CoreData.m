//
//  VideoLike+CoreData.m
//  VideoShow
//
//  Created by chengkai.gan on 14-9-25.
//  Copyright (c) 2014年 energy. All rights reserved.
//

#import "VideoLike+CoreData.h"
#import "AppDelegate.h"

#define MODEL @"VideoLike"
#define SORT @"userId"

@implementation VideoLike (CoreData)


/** 查询所有点赞记录 */
+(NSArray*)queryAll:(int)count
{
    NSManagedObjectContext * context  = [[AppDelegate shareInstance] managedObjectContext];
    NSManagedObjectModel   * model    = [[AppDelegate shareInstance] managedObjectModel];
    NSDictionary           * entities = [model entitiesByName];
    NSEntityDescription    * entity   = [entities valueForKey:MODEL];
    
    NSSortDescriptor * sort = [[NSSortDescriptor alloc] initWithKey:SORT ascending:NO];
    NSArray * sortDescriptors = [NSArray arrayWithObject: sort];
    
    NSFetchRequest * req = [[NSFetchRequest alloc] init];
    [req setEntity: entity];
    [req setSortDescriptors: sortDescriptors];
    if (count>0) {
        [req setFetchLimit:count];
    }
    
    NSArray * results = [context executeFetchRequest:req error:nil];
    
    return results;
}

/** 查询该媒体是否已经点赞 */
+(VideoLike*) queryLiked:(NSString*)userId mediaid:(NSString*)mediaId
{
    NSManagedObjectContext * context=[[AppDelegate shareInstance] managedObjectContext];
    NSManagedObjectModel * model=[[AppDelegate shareInstance] managedObjectModel];
    NSDictionary * entities=[model entitiesByName];
    NSEntityDescription *entity=[entities valueForKey:MODEL];
    
    NSSortDescriptor * sort=[[NSSortDescriptor alloc] initWithKey:SORT ascending:NO];
    NSArray * sortDescriptors=[NSArray arrayWithObject:sort];
    
    NSFetchRequest * req=[[NSFetchRequest alloc] init];
    NSString *sql=[NSString stringWithFormat:@"(userId == '%@' and videoUrl=='%@' and likeState==1)",userId,mediaId];
    //NSLog(@"查询条件--->%@",sql);
    NSPredicate *predicate=[NSPredicate predicateWithFormat:sql];
    [req setEntity:entity];
    [req setSortDescriptors:sortDescriptors];
    [req setPredicate:predicate];
    
    NSArray * results=[context executeFetchRequest:req error:nil];
    if (results.count>0) {
        return [results objectAtIndex:0];
    }
    return nil;
}

/** 保存点赞记录 */
+(BOOL) insertLiked:(NSString*)userId mediaid:(NSString*)mediaId mediaowner:(NSString*)owner state:(int)likeState
{
    VideoLike * like=[NSEntityDescription insertNewObjectForEntityForName:MODEL
                    inManagedObjectContext:[AppDelegate shareInstance].managedObjectContext];
    like.id=[NSNumber numberWithInt:0];;//该字段基本没有用
    like.videoUrl=mediaId;
    like.likeState=[NSNumber numberWithInt:likeState];
    like.userId=userId;
    like.videoOwner=owner;
    
    [[AppDelegate shareInstance].managedObjectContext performSelectorOnMainThread:@selector(save:) withObject:nil waitUntilDone:YES];
    return YES;
}

/** 标记点赞状态 */
+(BOOL) remarkLiked:(NSString*)userId mediaid:(NSString*)mediaId mediaowner:(NSString*)owner state:(int)likeState
{
    VideoLike* like=[VideoLike queryLiked:userId mediaid:mediaId];
    if (like==nil) {//首先检查是否有保存记录---如果没有就插入记录
        [VideoLike insertLiked:userId mediaid:mediaId mediaowner:owner state:likeState];
        return YES;
    }
    @try {
        like.likeState=[NSNumber numberWithInt:likeState];//标记已经点赞
        return YES;
    }
    @catch (NSException *exception) {
    }
    @finally {
        [[AppDelegate shareInstance].managedObjectContext performSelectorOnMainThread:@selector(save:) withObject:nil waitUntilDone:YES];
    }
    
    return NO;
}

/** 根据属性和值查询 */
+(NSArray*)queryWithAttr:(NSString*)attr value:(NSString*)value limit:(int)count
{
    NSManagedObjectContext * context=[[AppDelegate shareInstance] managedObjectContext];
    NSManagedObjectModel * model=[[AppDelegate shareInstance] managedObjectModel];
    NSDictionary * entities=[model entitiesByName];
    NSEntityDescription *entity=[entities valueForKey:MODEL];
    
    NSSortDescriptor * sort=[[NSSortDescriptor alloc] initWithKey:SORT ascending:NO];
    NSArray * sortDescriptors=[NSArray arrayWithObject:sort];
    
    NSFetchRequest * req=[[NSFetchRequest alloc] init];
    NSPredicate *predicate=[NSPredicate predicateWithFormat:[NSString stringWithFormat:@"%@=='%@'",attr,value]];
    [req setEntity:entity];
    [req setSortDescriptors:sortDescriptors];
    [req setPredicate:predicate];
    if (count>0) {
        [req setFetchLimit:count];
    }
    
    NSArray * results=[context executeFetchRequest:req error:nil];
    
    return results;
}

/** 根据属性值模糊查询 */
+(NSArray*)queryObscureWithAttr:(NSString*)attr value:(NSString*)value limit:(int)count
{
    NSManagedObjectContext * context  = [[AppDelegate shareInstance] managedObjectContext];
    NSManagedObjectModel   * model    = [[AppDelegate shareInstance] managedObjectModel];
    NSDictionary           * entities = [model entitiesByName];
    NSEntityDescription    * entity   = [entities valueForKey:MODEL];
    
    
    NSSortDescriptor * sort = [[NSSortDescriptor alloc] initWithKey:SORT ascending:YES];
    NSArray * sortDescriptors = [NSArray arrayWithObject: sort];
    NSLog(@"%@ LIKE[c] '*%@*'",attr, value);
    NSFetchRequest * req = [[NSFetchRequest alloc] init];
    NSPredicate * predicate=[NSPredicate predicateWithFormat:[NSString stringWithFormat:@"%@ LIKE[c] '%@*'", attr, value]];
    
    [req setEntity: entity];
    [req setSortDescriptors: sortDescriptors];
    [req setPredicate:predicate];
    if (count>0) {
        [req setFetchLimit:count];
    }
    
    NSArray * results = [context executeFetchRequest:req error:nil];
    
    return results;
}

/** 删除所有记录 */
+(BOOL)deleteAll
{
    NSManagedObjectContext * context  = [[AppDelegate shareInstance] managedObjectContext];
    NSManagedObjectModel   * model    = [[AppDelegate shareInstance] managedObjectModel];
    NSDictionary           * entities = [model entitiesByName];
    NSEntityDescription    * entity   = [entities valueForKey:MODEL];
    
    
    NSSortDescriptor * sort = [[NSSortDescriptor alloc] initWithKey:SORT ascending:YES];
    NSArray * sortDescriptors = [NSArray arrayWithObject: sort];
    
    NSFetchRequest * req = [[NSFetchRequest alloc] init];
    [req setEntity: entity];
    [req setSortDescriptors: sortDescriptors];
    NSError * error;
    NSArray * results = [context executeFetchRequest:req error:&error];
    if(!error && results){
        for (NSManagedObject *obj in results)
        {
            [context deleteObject:obj];
        }
        if (![context save:&error])
        {
            NSLog(@"error:%@",error);
        }
    }else{
        return NO;
    }
    
    return YES;
}


@end
