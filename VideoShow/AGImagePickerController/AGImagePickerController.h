//
//  AGImagePickerController.h
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

#import "AGImagePickerControllerDefines.h"

#define TOOLBAR_HEGITH 85

typedef enum{
    FilterTypeNone,
    FilterTypePhoto,
    FilterTypeVideo
}FilterType;

@class AGImagePickerController;
@class ToolBarView;
@protocol AGImagePickerControllerDelegate

@optional

#pragma mark - Configuring Rows
- (NSUInteger)agImagePickerController:(AGImagePickerController *)picker
   numberOfItemsPerRowForDevice:(AGDeviceType)deviceType
        andInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation;

#pragma mark - Configuring Selections
- (AGImagePickerControllerSelectionBehaviorType)selectionBehaviorInSingleSelectionModeForAGImagePickerController:(AGImagePickerController *)picker;

#pragma mark - Appearance Configuration
- (BOOL)agImagePickerController:(AGImagePickerController *)picker
shouldDisplaySelectionInformationInSelectionMode:(AGImagePickerControllerSelectionMode)selectionMode;
- (BOOL)agImagePickerController:(AGImagePickerController *)picker
shouldShowToolbarForManagingTheSelectionInSelectionMode:(AGImagePickerControllerSelectionMode)selectionMode;

#pragma mark - Managing Selections
- (void)agImagePickerController:(AGImagePickerController *)picker didFinishPickingMediaWithInfo:(NSArray *)info;
- (void)agImagePickerController:(AGImagePickerController *)picker didFail:(NSError *)error;

@end

@class qxTimeline;
@interface AGImagePickerController : UINavigationController
{
    struct {
        unsigned int delegateSelectionBehaviorInSingleSelectionMode:1;
        unsigned int delegateNumberOfItemsPerRowForDevice:1;
        unsigned int delegateShouldDisplaySelectionInformationInSelectionMode:1;
        unsigned int delegateShouldShowToolbarForManagingTheSelectionInSelectionMode:1;
        unsigned int delegateDidFinishPickingMediaWithInfo:1;
        unsigned int delegateDidFail:1;
    } _pickerFlags;
    
    BOOL _shouldChangeStatusBarStyle;
    BOOL _shouldShowSavedPhotosOnTop;
    UIStatusBarStyle _oldStatusBarStyle;
    
    AGIPCDidFinish _didFinishBlock;
    AGIPCDidFail _didFailBlock;
    
    NSUInteger _maximumNumberOfPhotosToBeSelected;
    
    NSArray *_toolbarItemsForManagingTheSelection;
    NSArray *_selection;
}

@property (nonatomic) BOOL shouldChangeStatusBarStyle;
@property (nonatomic) BOOL shouldShowSavedPhotosOnTop;
@property (nonatomic) BOOL shouldShowPhotosWithLocationOnly;
@property (nonatomic) NSUInteger maximumNumberOfPhotosToBeSelected;

@property (nonatomic, strong) NSArray *toolbarItemsForManagingTheSelection;
@property (nonatomic, strong) NSArray *selection;

@property (nonatomic, readonly) AGImagePickerControllerSelectionMode selectionMode;
@property (atomic,strong) ToolBarView *toolBar;
@property (nonatomic,assign) BOOL isEditWithTimeline;
@property (nonatomic,strong) qxTimeline *reeditTimeline;


+ (ALAssetsLibrary *)defaultAssetsLibrary;

- (id)initWithFilterType:(FilterType)filter;
- (id)initWithFilterType:(FilterType)filter
maximumNumberOfPhotosToBeSelected:(NSUInteger)maximumNumberOfPhotosToBeSelected
shouldChangeStatusBarStyle:(BOOL)shouldChangeStatusBarStyle
toolbarItemsForManagingTheSelection:(NSArray *)toolbarItemsForManagingTheSelection
andShouldShowSavedPhotosOnTop:(BOOL)shouldShowSavedPhotosOnTop;

- (void)resetToolBar;

@end


