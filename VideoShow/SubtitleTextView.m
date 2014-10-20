//
//  SubtitleTextView.m
//  VideoShow
//
//  Created by Jerry Chen  on 14-8-11.
//  Copyright (c) 2014年 energy. All rights reserved.
//

#import "SubtitleTextView.h"
#import "qxMediaObject.h"



@implementation SubtitleTextView
{
    UILabel *textLabel;
    UIView *foreground;
    UIImageView *positionView;
    UIImageView *scaleView;
    CGRect scaleArea;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

- (void)layoutSubviews
{
    CGRect rect = self.frame;
    if(!textLabel){
        textLabel = [[UILabel alloc] initWithFrame:CGRectMake(12, 12, rect.size.width - 24, rect.size.height - 24)];
        textLabel.layer.borderWidth = 2;
        textLabel.layer.borderColor = [[UIColor whiteColor] CGColor];
        textLabel.backgroundColor = [UIColor clearColor];
        textLabel.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);
        textLabel.adjustsFontSizeToFitWidth = YES;
        textLabel.numberOfLines = 0;//many lines
        textLabel.lineBreakMode = NSLineBreakByClipping;
        textLabel.textAlignment = NSTextAlignmentLeft;
        textLabel.font = [UIFont systemFontOfSize:20];
        textLabel.textColor = [UIColor whiteColor];
        [self addSubview:textLabel];
    }
    if(!foreground){
        foreground = [[UIView alloc] initWithFrame:textLabel.frame];
        foreground.backgroundColor = [UIColor clearColor];
        foreground.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);
        foreground.userInteractionEnabled = YES;
        [self addSubview:foreground];
        UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSubtitleViewForegroundTap:)];
        [foreground addGestureRecognizer:tapGestureRecognizer];
    }
    if(!positionView){
        positionView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 24, 24)];
        positionView.image = [UIImage imageNamed:@"subtitle_position.png"];
        positionView.userInteractionEnabled = YES;
        UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handlePositionViewTap:)];
        [positionView addGestureRecognizer:tapGestureRecognizer];
        [self addSubview:positionView];
    }
    positionView.center = CGPointMake(textLabel.frame.origin.x, textLabel.frame.origin.y);
    if(!scaleView){
        scaleView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 24, 24)];
        scaleView.image = [UIImage imageNamed:@"subtitle_scale.png"];
        scaleView.userInteractionEnabled = YES;
        UIPanGestureRecognizer *panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handleScaleViewPan:)];
        [scaleView addGestureRecognizer:panGestureRecognizer];
        [self addSubview:scaleView];
    }
    scaleView.center = CGPointMake(textLabel.frame.size.width + 12, textLabel.frame.size.height + 12);
    scaleArea = self.superview.frame;
}

- (void)handlePositionViewTap:(UITapGestureRecognizer*)gesture
{
    if([self.delegate respondsToSelector:@selector(subtitlePositionViewTapped)]){
        [self.delegate subtitlePositionViewTapped];
    }
}

- (void)handleScaleViewPan:(UIPanGestureRecognizer*)gesture
{
    if(gesture.state == UIGestureRecognizerStateChanged){
        CGPoint translation = [gesture translationInView:gesture.view.superview];
        if(textLabel.text == nil || [textLabel.text isEqualToString:@""]){
            CGRect rect = self.frame;
            rect.size.width += translation.x;
            rect.size.height += translation.y;
            rect.size.width = fminf(rect.size.width, scaleArea.size.width - rect.origin.x);
            rect.size.height = fminf(rect.size.height, scaleArea.size.height - rect.origin.y);
            self.frame = rect;
            [self setNeedsLayout];
        }else if(translation.x < 0 || translation.y < 0 ||[self scaleAvailable]){
            CGFloat ref = ABS(translation.x) > ABS(translation.y) ? translation.x : translation.y;
            CGFloat size = textLabel.font.pointSize + ref/4;
            textLabel.font = [UIFont fontWithName:textLabel.font.familyName size:size];
            [self updateTextRectByFont];
        }
        [gesture setTranslation:CGPointMake(0, 0) inView:gesture.view.superview];
    }else if(gesture.state == UIGestureRecognizerStateEnded){
        if([self.delegate respondsToSelector:@selector(subtitleTextSizeChanged:)]){
            [self.delegate subtitleTextSizeChanged:textLabel.font];
        }
    }
}

- (BOOL)scaleAvailable
{
    return self.frame.size.width < scaleArea.size.width && self.frame.size.height < scaleArea.size.height;
}

- (void)triggerSubtitleViewTapped
{
    textLabel.text = nil;
    [self handleSubtitleViewForegroundTap:nil];
}

- (void)handleSubtitleViewForegroundTap:(UITapGestureRecognizer*)gesture
{
    self.hidden = YES;
    if([self.delegate respondsToSelector:@selector(subtitleTextViewTapped)]){
        [self.delegate subtitleTextViewTapped];
    }
}

-(void)updateTextRectByFont
{
    if(textLabel.text != nil && ![textLabel.text isEqualToString:@""]){
        CGRect textViewRect = textLabel.frame;
        textViewRect.size = [textLabel.text sizeWithFont:textLabel.font constrainedToSize:CGSizeMake(260, 350) lineBreakMode:NSLineBreakByClipping];
        [self setFrame:CGRectMake(self.frame.origin.x, self.frame.origin.y, textViewRect.size.width + 24, textViewRect.size.height + 24)];
        [self setNeedsLayout];
    }
}

- (void)setTextWithOverlayObj:(qxMediaObject*)overlayObj
{
    if(overlayObj && overlayObj.overlayCustomObj){
        if(!textLabel){
            [self layoutIfNeeded];
        }
        qxMediaObject *textObj = overlayObj.overlayCustomObj;
        textLabel.text = textObj.text;
        textLabel.font = textObj.textFont;
        textLabel.textColor = textObj.textColor;
        [self updateTextRectByFont];
    }else{
        textLabel.text = nil;
    }
}

-(void)updateText:(NSString*)text
{
    if(text != nil && ![text isEqualToString:@""]){
        self.hidden = NO;
        textLabel.text = text;
        [self updateTextRectByFont];
    }
}

- (NSString*)text
{
    return  textLabel.text;
}

- (void)setTextColor:(UIColor*)color
{
    textLabel.textColor = color;
}

- (UIFont*)setTextFont:(NSString*)fontName
{
    UIFont *font = nil;
    if([fontName isEqualToString:@"default"]){
        font = [UIFont systemFontOfSize:textLabel.font.pointSize];
    }else{
        font = [UIFont fontWithName:fontName size:textLabel.font.pointSize];
    }
    if(font){
        textLabel.font = font;
    }
    return font;
}

- (void)resetTextSize
{
    textLabel.font = [UIFont fontWithName:textLabel.font.fontName size:20];
}

- (CGRect)subtitleRect
{
    CGRect rect = self.frame;
    rect.origin.x += 12;
    rect.origin.y += 12;
    rect.size = [textLabel.text sizeWithFont:textLabel.font constrainedToSize:CGSizeMake(260, 350) lineBreakMode:NSLineBreakByClipping];
    return rect;
}

- (CGRect)calTextViewRectFromSubtitleRect:(CGRect)subtitleRect
{
    CGRect rect = subtitleRect;
    rect.origin.x -= 12;
    rect.origin.y -= 12;
    rect.size.width += 24;
    rect.size.height += 24;
    return rect;
}
@end
