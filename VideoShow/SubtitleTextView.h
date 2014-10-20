//
//  SubtitleTextView.h
//  VideoShow
//
//  Created by Jerry Chen  on 14-8-11.
//  Copyright (c) 2014年 energy. All rights reserved.
//

#import <UIKit/UIKit.h>

@class qxMediaObject;
@protocol SubtitleTextViewDelegate <NSObject>
@optional
- (void)subtitlePositionViewTapped;
- (void)subtitleTextViewTapped;
- (void)subtitleTextSizeChanged:(UIFont*)font;
@end

@interface SubtitleTextView : UIView<UITextViewDelegate>

@property (nonatomic,weak) id<SubtitleTextViewDelegate> delegate;

- (void)setTextWithOverlayObj:(qxMediaObject*)overlayObj;
- (NSString*)text;
- (void)updateText:(NSString*)text;
- (void)setTextColor:(UIColor*)color;
- (UIFont*)setTextFont:(NSString*)fontName;
- (void)resetTextSize;
- (CGRect)subtitleRect;
- (CGRect)calTextViewRectFromSubtitleRect:(CGRect)subtitleRect;
- (void)triggerSubtitleViewTapped;

@end
