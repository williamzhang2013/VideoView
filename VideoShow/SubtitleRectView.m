//
//  SubtitleRectView.m
//  X-VideoShow
//
//  Created by Jerry Chen  on 14-7-9.
//  Copyright (c) 2014年 energy. All rights reserved.
//

#import "SubtitleRectView.h"

@implementation SubtitleRectView
{
    UITapGestureRecognizer *tapGestureRecoginizer;
}

- (id)initWithFrame:(CGRect)frame Pending:(BOOL)pending IndexOnTrack:(NSUInteger)index
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor colorWithRed:221/255.0 green:107/255.0 blue:111/255.0 alpha:0.8];
        [self addObserver:self forKeyPath:@"editing" options:NSKeyValueObservingOptionNew context:NULL];
        tapGestureRecoginizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap:)];
        tapGestureRecoginizer.numberOfTapsRequired = 1;
        tapGestureRecoginizer.numberOfTouchesRequired = 1;
        [self addGestureRecognizer:tapGestureRecoginizer];
        self.userInteractionEnabled = YES;
        _editing = NO;
        if(pending){
            _indexOnTrack = -1;
        }else{
            _indexOnTrack = index;
        }
    }
    return self;
}

-(void)tap:(UIGestureRecognizer*)sender
{
    if([self.delegate respondsToSelector:@selector(subtitleRectViewTaped:)]){
        [self.delegate subtitleRectViewTaped:self];
    }
}

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if([keyPath isEqualToString:@"editing"]){
        if ([(NSNumber*)change[NSKeyValueChangeNewKey] boolValue]) {
            self.backgroundColor = [UIColor clearColor];
        }else{
            self.backgroundColor = [UIColor colorWithRed:221/255.0 green:107/255.0 blue:111/255.0 alpha:0.8];
        }
    }
}

-(void)dealloc
{
    [self removeObserver:self forKeyPath:@"editing"];
    [self removeGestureRecognizer:tapGestureRecoginizer];
}

-(NSString *)description
{
    return [NSString stringWithFormat:@"x = %f , y = %f, h = %f, w = %f",self.frame.origin.x , self.frame.origin.y, self.frame.size.height, self.frame.size.width];
}
@end
