//
//  AGIPCAlbumsController.h
//  AGImagePickerController
//
//  Created by Artur Grigor on 2/16/12.
//  Copyright (c) 2012 - 2013 Artur Grigor. All rights reserved.
//  
//  For the full copyright and license information, please view the LICENSE
//  file that was distributed with this source code.
//  

#import <UIKit/UIKit.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import "AGImagePickerController.h"
#import "AGIPCAssetsController.h"

@class qxTimeline;
@interface AGIPCAlbumsController : UITableViewController<UITableViewDataSource, UITableViewDelegate, AGIPCAssetsControllerDelegate>

//@property (strong) AGImagePickerController *imagePickerController;
@property (assign,nonatomic)FilterType filterType;

- (void)resetPikcerWithTimeline:(qxTimeline*)timeline;

@end
