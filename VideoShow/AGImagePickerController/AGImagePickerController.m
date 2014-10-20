//
//  AGImagePickerController.m
//  AGImagePickerController
//
//  Created by Artur Grigor on 2/16/12.
//  Copyright (c) 2012 - 2013 Artur Grigor. All rights reserved.
//
//  For the full copyright and license information, please view the LICENSE
//  file that was distributed with this source code.
//

#import "AGImagePickerController.h"

#import "AGIPCAlbumsController.h"
#import "AGIPCGridItem.h"
#import "ToolBarView.h"
#import "Util.h"

@interface AGImagePickerController ()
{
    
}

- (void)didFinishPickingAssets:(NSArray *)selectedAssets;
- (void)didCancelPickingAssets;
- (void)didFail:(NSError *)error;

@end

@implementation AGImagePickerController

#pragma mark - Properties

@synthesize
delegate = _pickerDelegate,
maximumNumberOfPhotosToBeSelected = _maximumNumberOfPhotosToBeSelected,
shouldChangeStatusBarStyle = _shouldChangeStatusBarStyle,
shouldShowSavedPhotosOnTop = _shouldShowSavedPhotosOnTop;

@synthesize
toolbarItemsForManagingTheSelection = _toolbarItemsForManagingTheSelection,
selection = _selection;

- (AGImagePickerControllerSelectionMode)selectionMode
{
    return (self.maximumNumberOfPhotosToBeSelected == 1 ? AGImagePickerControllerSelectionModeSingle : AGImagePickerControllerSelectionModeMultiple);
}

//- (void)setDelegate:(id)delegate
//{
//    _pickerDelegate = delegate;
//    
//    _pickerFlags.delegateSelectionBehaviorInSingleSelectionMode = _pickerDelegate && [_pickerDelegate respondsToSelector:@selector(selectionBehaviorInSingleSelectionModeForAGImagePickerController:)];
//    _pickerFlags.delegateNumberOfItemsPerRowForDevice = _pickerDelegate && [_pickerDelegate respondsToSelector:@selector(agImagePickerController:numberOfItemsPerRowForDevice:andInterfaceOrientation:)];
//    _pickerFlags.delegateShouldDisplaySelectionInformationInSelectionMode = _pickerDelegate && [_pickerDelegate respondsToSelector:@selector(agImagePickerController:shouldDisplaySelectionInformationInSelectionMode:)];
//    _pickerFlags.delegateShouldShowToolbarForManagingTheSelectionInSelectionMode = _pickerDelegate && [_pickerDelegate respondsToSelector:@selector(agImagePickerController:shouldShowToolbarForManagingTheSelectionInSelectionMode:)];
//    _pickerFlags.delegateDidFinishPickingMediaWithInfo = _pickerDelegate && [_pickerDelegate respondsToSelector:@selector(agImagePickerController:didFinishPickingMediaWithInfo:)];
//    _pickerFlags.delegateDidFail = _pickerDelegate && [_pickerDelegate respondsToSelector:@selector(agImagePickerController:didFail:)];
//}

- (void)setShouldChangeStatusBarStyle:(BOOL)shouldChangeStatusBarStyle
{
    if (_shouldChangeStatusBarStyle != shouldChangeStatusBarStyle)
    {
        _shouldChangeStatusBarStyle = shouldChangeStatusBarStyle;
        
        if (_shouldChangeStatusBarStyle)
            if (IS_IPAD())
                [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleBlackOpaque animated:YES];
            else
                [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleBlackTranslucent animated:YES];
            else
                [[UIApplication sharedApplication] setStatusBarStyle:_oldStatusBarStyle animated:YES];
    }
}

+ (ALAssetsLibrary *)defaultAssetsLibrary
{
    return [Util defaultAssetsLibrary];
}

#pragma mark - Object Lifecycle

- (id)init
{
    return [self initWithFilterType:FilterTypeNone maximumNumberOfPhotosToBeSelected:0 shouldChangeStatusBarStyle:SHOULD_CHANGE_STATUS_BAR_STYLE toolbarItemsForManagingTheSelection:nil andShouldShowSavedPhotosOnTop:SHOULD_SHOW_SAVED_PHOTOS_ON_TOP];
}

- (id)initWithFilterType:(FilterType)filter
{
    return [self initWithFilterType:filter maximumNumberOfPhotosToBeSelected:0 shouldChangeStatusBarStyle:SHOULD_CHANGE_STATUS_BAR_STYLE toolbarItemsForManagingTheSelection:nil andShouldShowSavedPhotosOnTop:SHOULD_SHOW_SAVED_PHOTOS_ON_TOP];
}

- (id)initWithFilterType:(FilterType)filter maximumNumberOfPhotosToBeSelected:(NSUInteger)maximumNumberOfPhotosToBeSelected shouldChangeStatusBarStyle:(BOOL)shouldChangeStatusBarStyle toolbarItemsForManagingTheSelection:(NSArray *)toolbarItemsForManagingTheSelection andShouldShowSavedPhotosOnTop:(BOOL)shouldShowSavedPhotosOnTop
{
    self = [super init];
    if (self)
    {
        _oldStatusBarStyle = [UIApplication sharedApplication].statusBarStyle;
        
        self.shouldChangeStatusBarStyle = shouldChangeStatusBarStyle;
        self.shouldShowSavedPhotosOnTop = shouldShowSavedPhotosOnTop;
        
        UIBarStyle barStyle;
        
        if (floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_6_1)
        {
            // iOS 6.1 or earlier
            
            barStyle = UIBarStyleBlack;
        }
        else
        {
            // iOS 7 or later
            
            barStyle = UIBarStyleDefault;
        }
        self.navigationBar.barStyle = barStyle;
        self.navigationBar.translucent = YES;
        self.toolbar.barStyle = barStyle;
        self.toolbar.translucent = YES;
        
        self.toolbarItemsForManagingTheSelection = toolbarItemsForManagingTheSelection;
        self.selection = nil;
        self.maximumNumberOfPhotosToBeSelected = maximumNumberOfPhotosToBeSelected;
        
        AGIPCAlbumsController *albumController = [[AGIPCAlbumsController alloc] init];
        albumController.filterType = filter;
        self.viewControllers = @[albumController];
    }
    
    return self;
}

#pragma mark - View lifecycle

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

#pragma mark - Private

- (void)didFinishPickingAssets:(NSArray *)selectedAssets
{
    [self popToRootViewControllerAnimated:NO];
    
    // Reset the number of selections
    [AGIPCGridItem performSelector:@selector(resetNumberOfSelections)];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)didCancelPickingAssets
{
    [self popToRootViewControllerAnimated:NO];
    
    // Reset the number of selections
    [AGIPCGridItem performSelector:@selector(resetNumberOfSelections)];
    [self resetToolBar];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)resetToolBar
{
    for (BaseView *b in _toolBar.itemArray) {
        [b removeFromSuperview];
    }
    [_toolBar.itemArray removeAllObjects];
    _toolBar.scrollView.contentSize = CGSizeMake(0, 0);
}

- (void)didFail:(NSError *)error
{
    [self popToRootViewControllerAnimated:NO];
    
    // Reset the number of selections
    [AGIPCGridItem performSelector:@selector(resetNumberOfSelections)];
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)viewDidLoad
{
    [super viewDidLoad];
    _toolBar = [[ToolBarView alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height-TOOLBAR_HEGITH, self.view.frame.size.width, TOOLBAR_HEGITH)];
    //[self.view addSubview:_toolBar];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    //[self checkToolBar];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
}

-(void)checkToolBar
{
    CGRect toolRect=_toolBar.frame;
    if (_toolBar.itemArray.count>0) {
        toolRect.size.height=TOOLBAR_HEGITH;
    }else{
        toolRect.size.height=0;
    }
    _toolBar.frame=toolRect;
}

- (void)dealloc
{
    NSLog(@"AGImagePickerController dealloc *****");
}

@end
