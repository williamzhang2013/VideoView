//
//  SubtitleRectView.h
//  X-VideoShow
//
//  Created by Jerry Chen  on 14-7-9.
//  Copyright (c) 2014年 energy. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SubtitleRectView;
@protocol SubtitleRectViewDelegate <NSObject>
@optional
-(void)subtitleRectViewTaped:(SubtitleRectView*)view;

@end

@interface SubtitleRectView : UIView

@property (nonatomic,assign) BOOL editing;
//only for non-pending obj, it will be -1 forever for pending obj.
@property (nonatomic,assign,readonly) NSUInteger indexOnTrack;
@property (nonatomic,weak) id<SubtitleRectViewDelegate> delegate;

- (id)initWithFrame:(CGRect)frame Pending:(BOOL)pending IndexOnTrack:(NSUInteger)index;

@end
