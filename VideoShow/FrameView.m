//
//  FrameView.m
//  VideoShow
//
//  Created by Jerry Chen  on 14-8-6.
//  Copyright (c) 2014年 energy. All rights reserved.
//

#import "FrameView.h"
#import "qxMediaObject.h"
#import <AssetsLibrary/AssetsLibrary.h>

@implementation FrameView
{
    NSMutableArray *mediaArray;
    UIView *contentView;
    UIView *selectView;
    __block Float64 framesTotalWidth;
}

- (id)initWithMedias:(NSMutableArray*)medias frame:(CGRect)rect
{
    if(self = [super initWithFrame:rect]){
        mediaArray = [[NSMutableArray alloc] initWithArray:medias];
        [self loadFrames];
        UIPanGestureRecognizer *gestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanGesture:)];
        [self addGestureRecognizer:gestureRecognizer];
        self.scrollEnabled = YES;
    }
    return self;
}

- (void)updateSelectView:(CGRect)frame
{
    if(frame.origin.x + frame.size.width > framesTotalWidth){
        frame.size.width = framesTotalWidth - frame.origin.x;
    }
    if(!selectView){
        selectView = [[UIView alloc] initWithFrame:frame];
        selectView.backgroundColor = [UIColor colorWithRed:221/255.0 green:107/255.0 blue:111/255.0 alpha:0.6];
        [contentView addSubview:selectView];
    }else{
        selectView.frame = frame;
    }
}

- (void)scrollTo:(CGPoint)point
{
    CGRect bounds = self.bounds;
    CGFloat newBoundsOriginX = point.x;
    CGFloat minBoundsOriginX = 0.0;
    CGFloat maxBoundsOriginX = contentView.frame.size.width - bounds.size.width;
    bounds.origin.x = fmax(minBoundsOriginX, fmin(newBoundsOriginX, maxBoundsOriginX));
    //
    CGFloat newBoundsOriginY = point.y;
    CGFloat minBoundsOriginY = 0.0;
    CGFloat maxBoundsOriginY = contentView.frame.size.height - bounds.size.height;
    bounds.origin.y = fmax(minBoundsOriginY, fmin(newBoundsOriginY, maxBoundsOriginY));
    self.bounds = bounds;
    [self delegateNotificationWithScrollPoint:bounds.origin];
}

- (void)delegateNotificationWithScrollPoint:(CGPoint)point
{
    if(point.x < 0 || point.x > contentView.frame.size.width){
        return;
    }
    if([self.delegate respondsToSelector:@selector(scrollToSecond:)]){
        [self.delegate scrollToSecond:3*point.x/45];
    }
}

- (void)handlePanGesture:(UIPanGestureRecognizer *)gestureRecognizer
{
    if(!self.scrollEnabled){
        return;
    }
    CGPoint translation = [gestureRecognizer translationInView:self];
    CGRect bounds = self.bounds;

    CGFloat newBoundsOriginX = bounds.origin.x - translation.x;
    CGFloat newBoundsOriginY = bounds.origin.y - translation.y;
    [self scrollTo:CGPointMake(newBoundsOriginX, newBoundsOriginY)];
    [gestureRecognizer setTranslation:CGPointZero inView:self];
}

- (void)generateFramesWithCompletionHanlder:(GenerateFrameComplementionHandler)complementionHandler
{
    NSMutableArray *destArray = [[NSMutableArray alloc] init];
    
    int spi = 3;//seconds per image
    __block CGFloat delta = 0;
    __block CGFloat totalDuration = 0;
    ALAssetsLibrary *alLibrary = [[ALAssetsLibrary alloc] init];
    dispatch_semaphore_t semapthore = dispatch_semaphore_create(0);
    dispatch_async(dispatch_queue_create("serial_queue", NULL), ^{
        if(mediaArray){
            int frameCount;
            qxMediaObject *mediaObj = nil;
            NSArray *temp = nil;
            
            CGSize size = CGSizeMake(45, 45);
            for (int i = 0; i < mediaArray.count; i++) {
                delta = destArray.count * spi - totalDuration;
                mediaObj = mediaArray[i];
                if(mediaObj.eType == eMT_Video){
                    frameCount = ceil(((long long)CMTimeGetSeconds(mediaObj.actualTimeRange.duration) - delta)/spi);
                    temp = [self getCountFrame:frameCount andPictureSize:size fromVideo:mediaObj];
                    if(temp){
                        [destArray addObjectsFromArray:temp];
                    }
                    dispatch_semaphore_signal(semapthore);
                    
                }else if(mediaObj.eType == eMT_Photo){
                    if(delta < CMTimeGetSeconds(mediaObj.actualTimeRange.duration)){
                        [alLibrary assetForURL:[NSURL URLWithString:mediaObj.strFilePath] resultBlock:^(ALAsset *asset){
                            
                            UIImage *img = [UIImage imageWithCGImage:asset.thumbnail];
                            if(img){
                                int count = ceil((CMTimeGetSeconds(mediaObj.actualTimeRange.duration) - delta)/3);
                                while (count) {
                                    [destArray addObject:img];
                                    count --;
                                }
                                
                            }
                            dispatch_semaphore_signal(semapthore);
                        } failureBlock:^(NSError *error){
                            dispatch_semaphore_signal(semapthore);
                            
                        }];
                    }else{
                        dispatch_semaphore_signal(semapthore);
                    }
                }
                dispatch_semaphore_wait(semapthore, DISPATCH_TIME_FOREVER);
                totalDuration += CMTimeGetSeconds(mediaObj.actualTimeRange.duration);
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                
                if(complementionHandler){
                    complementionHandler(destArray,spi,totalDuration);
                }
            });
        }
    });
}

- (BOOL)isRetinaScreen
{
    return [UIScreen mainScreen].scale == 2.0;
}

- (NSArray*)getCountFrame:(NSInteger)count andPictureSize:(CGSize)size fromVideo:(qxMediaObject*)videoObj
{
    NSMutableArray *frames = [[NSMutableArray alloc] init];
    AVAsset *myAsset = [[AVURLAsset alloc] initWithURL:[NSURL URLWithString:videoObj.strFilePath] options:nil];
    AVAssetImageGenerator *imageGenerator = [AVAssetImageGenerator assetImageGeneratorWithAsset:myAsset];
    if ([self isRetinaScreen]){
        imageGenerator.maximumSize = CGSizeMake(size.width*2, size.height*2);
    } else {
        imageGenerator.maximumSize = CGSizeMake(size.width, size.height);
    }

    NSError *error;
    CMTime actualTime;
    Float64 durationSeconds = CMTimeGetSeconds(videoObj.actualTimeRange.duration);
    Float64 timeUnit = durationSeconds/count;
    
    for (int i=0; i < count; i++){
        
        CMTime timeFrame = CMTimeMakeWithSeconds(i * timeUnit + CMTimeGetSeconds(videoObj.actualTimeRange.start), 600);
        
        CGImageRef halfWayImage = [imageGenerator copyCGImageAtTime:timeFrame actualTime:&actualTime error:&error];
        UIImage *videoScreen;
        if ([self isRetinaScreen]){
            videoScreen = [[UIImage alloc] initWithCGImage:halfWayImage scale:2.0 orientation:UIImageOrientationUp];
        } else {
            videoScreen = [[UIImage alloc] initWithCGImage:halfWayImage];
        }
        [frames addObject:videoScreen];
        CGImageRelease(halfWayImage);
    }
    return frames;
}

- (void)loadFrames
{
    [self generateFramesWithCompletionHanlder:^(NSMutableArray *frames, float spi, Float64 totalDuration){
        CGRect imgRect;
        UIImage *image;
        UIImageView *tmpImgView;
        if(contentView){
            [contentView removeFromSuperview];
            contentView = nil;
        }
        if(selectView && [selectView superview]){
            [selectView removeFromSuperview];
        }
        selectView = nil;
        framesTotalWidth = totalDuration * FrameWidthPerSecond;
        contentView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, framesTotalWidth + self.frame.size.width, 45)];
        
        [self addSubview:contentView];
        for(int i = 0; i < frames.count; i++){
            image = frames[i];
            tmpImgView = [[UIImageView alloc] initWithImage:image];
            
            if(i != frames.count - 1){
                imgRect = CGRectMake(i * 45, 0, 45, 45);
            }else{
                if(frames.count * spi > totalDuration){
                    float delta = frames.count *spi - totalDuration;
                    imgRect = CGRectMake(i *45, 0, (spi - delta)*45/spi, 45);
                }else{
                    imgRect = CGRectMake(i * 45, 0, 45, 45);
                }
            }
            tmpImgView.frame = imgRect;
            [contentView addSubview:tmpImgView];
        }
        [self scrollTo:CGPointMake(0, 0)];
    }];
}

- (void)reloadFrames
{
    [self loadFrames];
}

@end