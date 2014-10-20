//
//  MyStudioVideoCell.m
//  VideoShow
//
//  Created by Jerry Chen  on 14-8-23.
//  Copyright (c) 2014年 energy. All rights reserved.
//

#import "MyStudioVideoCell.h"


@implementation MyStudioVideoCell

- (void)awakeFromNib
{
    // Initialization code
}

- (IBAction)controlAction:(id)sender {
    if(self.isDraft){
        if([self.delegate respondsToSelector:@selector(editDraft:)]){
            [self.delegate editDraft:self.draft];
        }
    }else{
        if([self.delegate respondsToSelector:@selector(playVideo:)]){
            [self.delegate playVideo:self.videoURL];
        }
    }
}

- (IBAction)shareAction:(id)sender {
    if(!self.isDraft){
        if([self.delegate respondsToSelector:@selector(shareVideo:)]){
            [self.delegate shareVideo:self.videoURL];
        }
    }
    
}

- (IBAction)deleteAction:(id)sender {
    if(self.isDraft){
        if([self.delegate respondsToSelector:@selector(deleteDraft:)]){
            [self.delegate deleteDraft:self.videoURL];
        }
    }else{
        if([self.delegate respondsToSelector:@selector(deleteVideo:)]){
            [self.delegate deleteVideo:self.videoURL];
        }
    }
    
}
@end
