//
//  MediaFrameView.m
//  VideoShow
//
//  Created by Jerry Chen  on 14-8-9.
//  Copyright (c) 2014年 energy. All rights reserved.
//

#import "MediaFrameView.h"
#import "qxMediaObject.h"
#import "qxTimeline.h"
#import "NMRangeSlider.h"
#import <AssetsLibrary/AssetsLibrary.h>

typedef void (^GenerateFrameComplementionHandler)(NSMutableArray *frames, float spi, Float64 duraion);

@implementation MediaFrameView
{
    //0 : video track,  1 : music track,  2 : audio track,  3 : overlay track
    qxTimeline *timeLine;
    UIView *pView;
    UIView *contentView;
    UIView *frameMark;
    UIImageView *sliderLeftHandle;
    UIImageView *sliderRightHandle;
    SubtitleRangeSlider *subtitleSlider;
    SubtitleRectView *currentEditingSubtitleView;
    SubtitleRectView *currentSubtitleView;
    
    NSMutableArray *subtitleViewArray;
    __block Float64 framesTotalWidth;
}

- (id)initWithMedias:(qxTimeline*)tl frame:(CGRect)rect
{
    if(self = [super initWithFrame:rect]){
        timeLine = tl;
        pView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, rect.size.width, rect.size.height)];
        [self addSubview:pView];
        frameMark = [[UIView alloc] initWithFrame:CGRectMake(rect.size.width/2, 0, 3, rect.size.height)];
        frameMark.backgroundColor = [UIColor whiteColor];
        [self addSubview:frameMark];
        UIPanGestureRecognizer *gestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanGesture:)];
        [pView addGestureRecognizer:gestureRecognizer];
        self.scrollEnabled = YES;
        
        [self loadFrames];
    }
    return self;
}


- (CGRect)calSliderRectWithSubtitleView:(SubtitleRectView*)view
{
    NSUInteger index = [subtitleViewArray indexOfObject:view];
    if(index != NSNotFound){
        float x,w;
        SubtitleRectView *tmpRectView;
        if(index == 0){
            x = self.frame.size.width/2;
            if(subtitleViewArray.count == 1){
                w = framesTotalWidth;
            }else{
                tmpRectView = (SubtitleRectView*)subtitleViewArray[1];
                w = tmpRectView.frame.origin.x - self.frame.size.width/2;
            }
        }else if(index == subtitleViewArray.count -1){
            tmpRectView = (SubtitleRectView*)subtitleViewArray[subtitleViewArray.count - 2];
            x = tmpRectView.frame.origin.x + tmpRectView.frame.size.width;
            w = framesTotalWidth - (x - self.frame.size.width/2);
        }else{
            tmpRectView = (SubtitleRectView*)subtitleViewArray[index - 1];
            x = tmpRectView.frame.origin.x + tmpRectView.frame.size.width;
            tmpRectView = (SubtitleRectView*)subtitleViewArray[index + 1];
            w = tmpRectView.frame.origin.x - x;
        }
        return CGRectMake(x, 0, w, self.frame.size.height);
    }
    return view.frame;
}

- (void)fillSubtitleView
{
    [self updateSubtitleRect];
    for(SubtitleRectView *view in subtitleViewArray){
        if(view){
            [contentView addSubview:view];
        }
    }
}

- (void)updateSubtitleRect
{   if(!subtitleViewArray){
        subtitleViewArray = [[NSMutableArray alloc] init];
    }
    for(SubtitleRectView *view in subtitleViewArray){
        if(view){
            [view removeFromSuperview];
        }
    }
    [subtitleViewArray removeAllObjects];
    //
    if(subtitleSlider && subtitleSlider.superview){
        [subtitleSlider removeFromSuperview];
    }
    subtitleSlider = nil;
    //----------------------
    NSMutableArray *overlayObjArray = [timeLine getTrackFromTimeline:3].mpMediaObjArray;
    qxMediaObject *obj = nil;
    for(int i = 0; i < overlayObjArray.count; i++){
        obj = overlayObjArray[i];
        if(obj && obj.eType == eMT_Overlay && obj.overlayCustomObj && ((qxMediaObject*)obj.overlayCustomObj).eType == eMT_Text){
            SubtitleRectView *subtitleView = [self newSubtitleRectViewWithMediaObj:obj pending:NO indexOnTrack:i];
            [subtitleViewArray addObject:subtitleView];
        }
    }
    [self sortSubtitleViewArray];
}

-(void)sortSubtitleViewArray
{
    NSArray *tmp = [subtitleViewArray sortedArrayUsingComparator:^(SubtitleRectView *v1, SubtitleRectView *v2){
        qxTrack *overlayTrack = [timeLine getTrackFromTimeline:3];
        double d1 = CMTimeGetSeconds([overlayTrack getMediaObjectFromTrack:(int)v1.indexOnTrack].startTimeOfTrack);
        double d2 = CMTimeGetSeconds([overlayTrack getMediaObjectFromTrack:(int)v2.indexOnTrack].startTimeOfTrack);
        NSComparisonResult result = NSOrderedSame;
        if(d1 > d2){
            result = NSOrderedDescending;
        }else if(d1 < d2){
            result = NSOrderedAscending;
        }
        return result;
    }];
    [subtitleViewArray removeAllObjects];
    [subtitleViewArray addObjectsFromArray:tmp];
}

-(SubtitleRectView*)newSubtitleRectViewWithMediaObj:(qxMediaObject*)obj pending:(BOOL)pending indexOnTrack:(NSUInteger)index
{
    SubtitleRectView *view = nil;
    CGRect rect = [self rectWithSubtitleStart:CMTimeGetSeconds(obj.startTimeOfTrack) Duration:CMTimeGetSeconds(obj.mediaOriginalDuration)];
    view = [[SubtitleRectView alloc] initWithFrame:rect Pending:(((qxMediaObject*)obj.overlayCustomObj).text == nil) IndexOnTrack:index];
    view.delegate = self;
    return view;
}

-(CGRect)rectWithSubtitleStart:(double)start  Duration:(double)duration
{
    return CGRectMake(start * FrameWidthPerSecond + self.frame.size.width/2, 0, duration * FrameWidthPerSecond, contentView.frame.size.height);
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
    pView.bounds = bounds;
    if([self.delegate respondsToSelector:@selector(mediaFrameView:didScrollTo:)]){
        [self.delegate mediaFrameView:self didScrollTo:pView.bounds.origin.x/FrameWidthPerSecond];
    }
    //
    SubtitleRectView *tmpSubtitleView = [self getSubtitleAt:frameMark.frame.origin.x + pView.bounds.origin.x];
    if(!tmpSubtitleView || ![tmpSubtitleView isEqual:currentSubtitleView]){
        currentSubtitleView = tmpSubtitleView;
    }
}

- (SubtitleRectView*)getSubtitleAt:(CGFloat)x
{
    SubtitleRectView *subView;
    for(SubtitleRectView *view in subtitleViewArray){
        if(x >= view.frame.origin.x && x <= view.frame.origin.x + view.frame.size.width){
            subView = view;
            break;
        }
    }
    return subView;
}

- (void)handlePanGesture:(UIPanGestureRecognizer *)gestureRecognizer
{
    if(!self.scrollEnabled){
        return;
    }
    CGPoint translation = [gestureRecognizer translationInView:pView];
    CGRect bounds = pView.bounds;
    
    CGFloat newBoundsOriginX = bounds.origin.x - translation.x;
    CGFloat newBoundsOriginY = bounds.origin.y - translation.y;
    [self scrollTo:CGPointMake(newBoundsOriginX, newBoundsOriginY)];
    [gestureRecognizer setTranslation:CGPointZero inView:pView];
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
        NSMutableArray *mediaArray = [timeLine getTrackFromTimeline:0].mpMediaObjArray;
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
            videoScreen = [[UIImage alloc] initWithCGImage:halfWayImage scale:2.0 orientation:UIImageOrientationDown];
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
        CGFloat half = self.frame.size.width/2;
        framesTotalWidth = totalDuration * FrameWidthPerSecond;
        contentView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, framesTotalWidth + self.frame.size.width, 45)];
        [pView addSubview:contentView];
        for(int i = 0; i < frames.count; i++){
            image = frames[i];
            tmpImgView = [[UIImageView alloc] initWithImage:image];
            
            if(i != frames.count - 1){
                imgRect = CGRectMake(i * 45 + half, 0, 45, 45);
            }else{
                if(frames.count * spi > totalDuration){
                    float delta = frames.count *spi - totalDuration;
                    imgRect = CGRectMake(i *45 + half, 0, (spi - delta)*45/spi, 45);
                }else{
                    imgRect = CGRectMake(i * 45 + half, 0, 45, 45);
                }
            }
            tmpImgView.frame = imgRect;
            [contentView addSubview:tmpImgView];
        }
        
        [self fillSubtitleView];
        //
        [self scrollTo:CGPointMake(0, 0)];
        [self bringSubviewToFront:frameMark];
        if([self.delegate respondsToSelector:@selector(framesLoadDone)]){
            [self.delegate framesLoadDone];
        }
    }];
}

- (void)reloadFrames
{
    [self loadFrames];
}

- (void)refreshSubtitleView
{
    [self fillSubtitleView];
}

- (void)updateSubtitleViewEditingStatus:(SubtitleRectView*)view
{
    if(!view.editing){
        view.editing = YES;
        for(SubtitleRectView *tmp in subtitleViewArray){
            if(![tmp isEqual:view]){
                tmp.editing = NO;
            }
        }
    }
}

- (void)showSliderWithSubtitleView:(SubtitleRectView*)view
{
    if(!subtitleSlider){
        subtitleSlider = [[SubtitleRangeSlider alloc] initWithFrame:CGRectMake(0, 0, 0, self.frame.size.height)];
        subtitleSlider.delegate = self;
        [contentView addSubview:subtitleSlider];
    }
    CGRect availableRect = [self calSliderRectWithSubtitleView:view];
    [subtitleSlider showWithFrame:view.frame maxRect:availableRect];
    currentEditingSubtitleView = view;
}

#pragma mark - SubtitleRectViewDelegate
- (void)subtitleRectViewTaped:(SubtitleRectView *)view
{
    [self updateSubtitleViewEditingStatus:view];
    [self showSliderWithSubtitleView:view];
    SubtitleRectView *tmpSubtitleView = [self getSubtitleAt:frameMark.frame.origin.x + pView.bounds.origin.x];
    if(tmpSubtitleView != view){
        [self scrollTo:CGPointMake(view.frame.origin.x - self.frame.size.width/2 + 2, 0)];
    }
}

#pragma mark - SubtitleRangeSliderDelegate
- (void)subtitleRangeSliderValueChange:(SubtitleRangeSlider *)slider
{
    if(currentEditingSubtitleView){
        qxTrack *overlayTrack = [timeLine getTrackFromTimeline:3];
        int timeScale = [overlayTrack getMediaObjectFromTrack:(int)currentEditingSubtitleView.indexOnTrack].mediaOriginalDuration.timescale;
        Float64 start = (slider.frame.origin.x - self.frame.size.width/2)/FrameWidthPerSecond;
        Float64 duration = slider.frame.size.width/FrameWidthPerSecond;
        [overlayTrack updateTimeAtIndex:(int)currentEditingSubtitleView.indexOnTrack startTime:CMTimeMakeWithSeconds(start, timeScale) duration:CMTimeMakeWithSeconds(duration, timeScale)];
        if([self.delegate respondsToSelector:@selector(needRefreshVideo)]){
            [self.delegate needRefreshVideo];
        }
    }
}

@end
