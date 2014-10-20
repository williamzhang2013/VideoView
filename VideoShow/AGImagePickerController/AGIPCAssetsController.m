//
//  AGIPCAssetsController.m
//  AGImagePickerController
//
//  Created by Artur Grigor on 17.02.2012.
//  Copyright (c) 2012 - 2013 Artur Grigor. All rights reserved.
//  
//  For the full copyright and license information, please view the LICENSE
//  file that was distributed with this source code.
//  

#import "AGIPCAssetsController.h"

#import "AGImagePickerController+Helper.h"

#import "AGIPCGridCell.h"
#import "AGIPCToolbarItem.h"
#import "ToolBarView.h"


@interface AGIPCAssetsController ()
{
    ALAssetsGroup *_assetsGroup;
    NSMutableArray *_assets;
    AGImagePickerController *_imagePickerController;
}

@property (nonatomic, strong) NSMutableArray *assets;

@end

@interface AGIPCAssetsController (Private)

- (void)changeSelectionInformation;

- (void)registerForNotifications;
- (void)unregisterFromNotifications;

- (void)didChangeLibrary:(NSNotification *)notification;
- (void)didChangeToolbarItemsForManagingTheSelection:(NSNotification *)notification;

- (BOOL)toolbarHidden;

- (void)loadAssets;
- (void)reloadData;

- (void)setupToolbarItems;

- (NSArray *)itemsForRowAtIndexPath:(NSIndexPath *)indexPath;

- (void)doneAction:(id)sender;
- (void)selectAllAction:(id)sender;
- (void)deselectAllAction:(id)sender;
- (void)customBarButtonItemAction:(id)sender;

@end

@implementation AGIPCAssetsController

#pragma mark - Properties

@synthesize assetsGroup = _assetsGroup, assets = _assets;

- (BOOL)toolbarHidden
{
//    if (! self.imagePickerController.shouldShowToolbarForManagingTheSelection)
//        return YES;
//    else
//    {
//        if (self.imagePickerController.toolbarItemsForManagingTheSelection != nil) {
//            return !(self.imagePickerController.toolbarItemsForManagingTheSelection.count > 0);
//        } else {
//            return NO;
//        }
//    }
    return YES;
}

- (void)setAssetsGroup:(ALAssetsGroup *)theAssetsGroup
{
    @synchronized (self)
    {
        if (_assetsGroup != theAssetsGroup)
        {
            _assetsGroup = theAssetsGroup;
            [self reloadData];
        }
    }
}

- (ALAssetsGroup *)assetsGroup
{
    ALAssetsGroup *ret = nil;
    
    @synchronized (self)
    {
        ret = _assetsGroup;
    }
    
    return ret;
}

- (NSArray *)selectedAssets
{
    NSMutableArray *selectedAssets = [NSMutableArray array];
    
	for (AGIPCGridItem *gridItem in self.assets) 
    {		
		if (gridItem.selected)
        {	
			[selectedAssets addObject:gridItem.asset];
		}
	}
    
    return selectedAssets;
}

#pragma mark - Object Lifecycle

- (id)initWithAssetsGroup:(ALAssetsGroup *)assetsGroup
{
    self = [super initWithStyle:UITableViewStylePlain];
    if (self)
    {
        _assets = [[NSMutableArray alloc] init];
        self.assetsGroup = assetsGroup;
        
        //title
        UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 80, 30)];
        titleLabel.backgroundColor = [UIColor clearColor];
        titleLabel.text = [self.assetsGroup valueForProperty:ALAssetsGroupPropertyName];
        titleLabel.textAlignment = NSTextAlignmentCenter;
        titleLabel.font = [UIFont boldSystemFontOfSize:17];
        titleLabel.textColor = [UIColor whiteColor];
        [titleLabel sizeToFit];
        self.navigationItem.titleView = titleLabel;
        
        //left bar button
        UIView *leftBtnView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 50, 44)];
        leftBtnView.userInteractionEnabled = YES;
        UITapGestureRecognizer *backBtnTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(backViewTap:)];
        [leftBtnView addGestureRecognizer:backBtnTapGesture];
        UIImageView *leftArrow = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"back.png"]];
        leftArrow.frame = CGRectMake(0, 0, 11, 19);
        [leftBtnView addSubview:leftArrow];
        UILabel *leftLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 0, 45, 44)];
        leftLabel.backgroundColor = [UIColor clearColor];
        leftLabel.text = NSLocalizedString(@"Back", nil);
        leftLabel.font = [UIFont boldSystemFontOfSize:17];
        leftLabel.textColor = [UIColor colorWithRed:221/255.0 green:107/255.0 blue:111/255.0 alpha:1.0];
        [leftBtnView addSubview:leftLabel];
        UIBarButtonItem *leftBarButton = [[UIBarButtonItem alloc] initWithCustomView:leftBtnView];
        leftBarButton.style = UIBarButtonItemStylePlain;
        leftArrow.center = CGPointMake(5.5, leftLabel.center.y);
        self.navigationItem.leftBarButtonItem = leftBarButton;
        
        //right bar button
        UILabel *rightLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 80, 44)];
        rightLabel.userInteractionEnabled = YES;
        UITapGestureRecognizer *nextBtnTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(nextAction:)];
        [rightLabel addGestureRecognizer:nextBtnTapGesture];
        rightLabel.backgroundColor = [UIColor clearColor];
        rightLabel.textAlignment = NSTextAlignmentRight;
        rightLabel.text = NSLocalizedString(@"Next", nil);
        rightLabel.font = [UIFont boldSystemFontOfSize:17];
        rightLabel.textColor = [UIColor colorWithRed:221/255.0 green:107/255.0 blue:111/255.0 alpha:1.0];
        UIBarButtonItem *nextButton = [[UIBarButtonItem alloc] initWithCustomView:rightLabel];
        self.navigationItem.rightBarButtonItem = nextButton;
        
        
        self.tableView.allowsMultipleSelection = NO;
        self.tableView.allowsSelection = NO;
        self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        
        // Start loading the assets
        [self loadAssets];
    }
    
    return self;
}

- (void)nextAction:(UITapGestureRecognizer*)gesture
{
    if([self.delegate respondsToSelector:@selector(selectDoneAndNextStep)]){
        [self.delegate selectDoneAndNextStep];
    }
}

- (void)backViewTap:(UITapGestureRecognizer*)gesture
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)dealloc
{
    NSLog(@"AGIPCAssetsController dealloc ****");
    [self unregisterFromNotifications];
}

#pragma mark - UITableViewDataSource Methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (! self.navigationController) return 0;
    
    double numberOfAssets = (double)self.assetsGroup.numberOfAssets;
    NSInteger nr = ceil(numberOfAssets / ((AGImagePickerController*)self.navigationController).numberOfItemsPerRow);
    
    return nr;
}

- (NSArray *)itemsForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSMutableArray *items = [NSMutableArray arrayWithCapacity:((AGImagePickerController*)self.navigationController).numberOfItemsPerRow];
    
    NSUInteger startIndex = indexPath.row * ((AGImagePickerController*)self.navigationController).numberOfItemsPerRow,
                 endIndex = startIndex + ((AGImagePickerController*)self.navigationController).numberOfItemsPerRow - 1;
    if (startIndex < self.assets.count)
    {
        if (endIndex > self.assets.count - 1)
            endIndex = self.assets.count - 1;
        
        for (NSUInteger i = startIndex; i <= endIndex; i++)
        {
            [items addObject:(self.assets)[i]];
        }
    }
    
    return items;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    AGIPCGridCell *cell = (AGIPCGridCell *)[self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) 
    {		        
        cell = [[AGIPCGridCell alloc] initWithImagePickerController:(AGImagePickerController*)self.navigationController items:[self itemsForRowAtIndexPath:indexPath] andReuseIdentifier:CellIdentifier];
    }	
	else 
    {		
		cell.items = [self itemsForRowAtIndexPath:indexPath];
	}
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGRect itemRect = ((AGImagePickerController*)self.navigationController).itemRect;
    return itemRect.size.height + itemRect.origin.y;
}

#pragma mark - View Lifecycle

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
    
    [self reloadData];
}

- (void)viewWillAppear:(BOOL)animated
{
    [self.navigationController.navigationBar setBackgroundImage:nil forBarMetrics:UIBarMetricsDefault];
    if([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0){
        self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:40/255.0 green:35/255.0 blue:35/255.0 alpha:1.0];
    }else{
        self.navigationController.navigationBar.tintColor = [UIColor colorWithRed:40/255.0 green:35/255.0 blue:35/255.0 alpha:1.0];
    }
    self.navigationController.navigationBar.barStyle = UIBarStyleDefault;
    
    ToolBarView *toolbar = ((AGImagePickerController*)self.navigationController).toolBar;
    if(toolbar && ![toolbar superview]){
        [((AGImagePickerController*)self.navigationController).view addSubview:toolbar];
    }
    
    // Reset the number of selections
    [AGIPCGridItem performSelector:@selector(resetNumberOfSelections)];
    
    [super viewWillAppear:animated];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.navigationController.navigationBar setBackgroundImage:nil forBarMetrics:UIBarMetricsDefault];
    if([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0){
        self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:40/255.0 green:35/255.0 blue:35/255.0 alpha:1.0];
    }else{
        self.navigationController.navigationBar.tintColor = [UIColor colorWithRed:40/255.0 green:35/255.0 blue:35/255.0 alpha:1.0];
    }
    self.navigationController.navigationBar.barStyle = UIBarStyleDefault;
    
    // Fullscreen
    if (((AGImagePickerController*)self.navigationController).shouldChangeStatusBarStyle) {
        self.wantsFullScreenLayout = YES;
    }
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    // Setup Notifications
    [self registerForNotifications];
    
    UIView *view = ((AGImagePickerController*)self.navigationController).toolBar;
    float tableViewTopInset = 0;
    if([[[UIDevice currentDevice] systemVersion] floatValue] < 7.0){
        tableViewTopInset = 44;
    }else{
        tableViewTopInset = 64;
    }
    self.tableView.contentInset = UIEdgeInsetsMake(tableViewTopInset, 0, view.frame.size.height, 0);
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    // Destroy Notifications
    [self unregisterFromNotifications];
}

#pragma mark - Private

- (void)setupToolbarItems
{
    if (((AGImagePickerController*)self.navigationController).toolbarItemsForManagingTheSelection != nil)
    {
        NSMutableArray *items = [NSMutableArray array];
        
        // Custom Toolbar Items
        for (id item in ((AGImagePickerController*)self.navigationController).toolbarItemsForManagingTheSelection)
        {
            NSAssert([item isKindOfClass:[AGIPCToolbarItem class]], @"Item is not a instance of AGIPCToolbarItem.");
            
            ((AGIPCToolbarItem *)item).barButtonItem.target = self;
            ((AGIPCToolbarItem *)item).barButtonItem.action = @selector(customBarButtonItemAction:);
            
            [items addObject:((AGIPCToolbarItem *)item).barButtonItem];
        }
        
        self.toolbarItems = items;
    } else {
        // Standard Toolbar Items
        UIBarButtonItem *selectAll = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedStringWithDefaultValue(@"AGIPC.SelectAll", nil, [NSBundle mainBundle], @"Select All", nil) style:UIBarButtonItemStyleBordered target:self action:@selector(selectAllAction:)];
        UIBarButtonItem *flexibleSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
        UIBarButtonItem *deselectAll = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedStringWithDefaultValue(@"AGIPC.DeselectAll", nil, [NSBundle mainBundle], @"Deselect All", nil) style:UIBarButtonItemStyleBordered target:self action:@selector(deselectAllAction:)];
        
        NSArray *toolbarItemsForManagingTheSelection = @[selectAll, flexibleSpace, deselectAll];
        self.toolbarItems = toolbarItemsForManagingTheSelection;
    }
}

- (void)loadAssets
{
    [self.assets removeAllObjects];
    __ag_weak AGIPCAssetsController *weakSelf = self;
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        
        __strong AGIPCAssetsController *strongSelf = weakSelf;
        
        @autoreleasepool {
            [strongSelf.assetsGroup enumerateAssetsUsingBlock:^(ALAsset *result, NSUInteger index, BOOL *stop) {
                
                if (result == nil) 
                {
                    return;
                }
                if (((AGImagePickerController*)strongSelf.navigationController).shouldShowPhotosWithLocationOnly) {
                    CLLocation *assetLocation = [result valueForProperty:ALAssetPropertyLocation];
                    if (!assetLocation || !CLLocationCoordinate2DIsValid([assetLocation coordinate])) {
                        return;
                    }
                }
                
                AGIPCGridItem *gridItem = [[AGIPCGridItem alloc] initWithImagePickerController:(AGImagePickerController*)strongSelf.navigationController asset:result andDelegate:strongSelf];
                [strongSelf.assets addObject:gridItem];

            }];
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [strongSelf reloadData];
        });
    
    });
}

- (void)reloadData
{
    // Don't display the select button until all the assets are loaded.
    [self.navigationController setToolbarHidden:[self toolbarHidden] animated:YES];
    
    [self.tableView reloadData];
    
    //[self setTitle:[self.assetsGroup valueForProperty:ALAssetsGroupPropertyName]];
    [self changeSelectionInformation];
    
    /*
    NSInteger totalRows = [self.tableView numberOfRowsInSection:0];
    //Prevents crash if totalRows = 0 (when the album is empty).
    if (totalRows > 0) {
        [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:totalRows-1 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:NO];
    }
     */
}

- (void)doneAction:(id)sender
{
    [(AGImagePickerController*)self.navigationController performSelector:@selector(didFinishPickingAssets:) withObject:self.selectedAssets];
}

- (void)selectAllAction:(id)sender
{
    for (AGIPCGridItem *gridItem in self.assets) {
        gridItem.selected = YES;
    }
}

- (void)deselectAllAction:(id)sender
{
    for (AGIPCGridItem *gridItem in self.assets) {
        gridItem.selected = NO;
    }
}

- (void)customBarButtonItemAction:(id)sender
{
    for (id item in ((AGImagePickerController*)self.navigationController).toolbarItemsForManagingTheSelection)
    {
        NSAssert([item isKindOfClass:[AGIPCToolbarItem class]], @"Item is not a instance of AGIPCToolbarItem.");
        
        if (((AGIPCToolbarItem *)item).barButtonItem == sender)
        {
            if (((AGIPCToolbarItem *)item).assetIsSelectedBlock) {
                
                NSUInteger idx = 0;
                for (AGIPCGridItem *obj in self.assets) {
                    obj.selected = ((AGIPCToolbarItem *)item).assetIsSelectedBlock(idx, ((AGIPCGridItem *)obj).asset);
                    idx++;
                }
                
            }
        }
    }
}

- (void)changeSelectionInformation
{
//    if (self.imagePickerController.shouldDisplaySelectionInformation ) {
//        if (0 == [AGIPCGridItem numberOfSelections] ) {
//            self.navigationController.navigationBar.topItem.prompt = nil;
//        } else {
//            //self.navigationController.navigationBar.topItem.prompt = [NSString stringWithFormat:@"(%d/%d)", [AGIPCGridItem numberOfSelections], self.assets.count];
//            // Display supports up to select several photos at the same time, springox(20131220)
//            NSInteger maxNumber = _imagePickerController.maximumNumberOfPhotosToBeSelected;
//            if (0 < maxNumber) {
//                self.navigationController.navigationBar.topItem.prompt = [NSString stringWithFormat:@"(%d/%d)", [AGIPCGridItem numberOfSelections], maxNumber];
//            } else {
//                self.navigationController.navigationBar.topItem.prompt = [NSString stringWithFormat:@"(%d/%d)", [AGIPCGridItem numberOfSelections], self.assets.count];
//            }
//        }
//    }
}

#pragma mark - AGGridItemDelegate Methods

//- (void)agGridItem:(AGIPCGridItem *)gridItem didChangeNumberOfSelections:(NSNumber *)numberOfSelections
//{
////    self.navigationItem.rightBarButtonItem.enabled = (numberOfSelections.unsignedIntegerValue > 0);
//    [self changeSelectionInformation];
//    
//    ToolBarView *bar = ((AGImagePickerController*)self.navigationController).toolBar;
//    if (gridItem.selected) {
//        BOOL found = NO;
//        for (BaseView *b in bar.itemArray) {
//            if ([b.item.asset isEqual:gridItem.asset]) {
//                found = YES;
//                break;
//            }
//        }
//        if (!found) {
//            [bar addBaseView:gridItem];
//        }
//    }else{
//        [bar removeBaseView:gridItem];
//    }
//}

- (void)agGridItem:(AGIPCGridItem *)gridItem didChangeNumberOfSelections:(NSNumber *)numberOfSelections
{
    ToolBarView *bar = ((AGImagePickerController*)self.navigationController).toolBar;
    if([self canAddItem:bar.itemArray.count + 1]){
        if(gridItem){
            [bar addBaseView:gridItem];
        }
    }else{
       UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"File Count Max", nil) message:nil delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil, nil];
        [alertView show];
    }
}

- (BOOL)agGridItemCanSelect:(AGIPCGridItem *)gridItem
{
    if (((AGImagePickerController*)self.navigationController).selectionMode == AGImagePickerControllerSelectionModeSingle &&
        ((AGImagePickerController*)self.navigationController).selectionBehaviorInSingleSelectionMode == AGImagePickerControllerSelectionBehaviorTypeRadio) {
        for (AGIPCGridItem *item in self.assets)
            if (item.selected)
                item.selected = NO;
        
        return YES;
    } else {
        if (((AGImagePickerController*)self.navigationController).maximumNumberOfPhotosToBeSelected > 0)
            return ([AGIPCGridItem numberOfSelections] < ((AGImagePickerController*)self.navigationController).maximumNumberOfPhotosToBeSelected);
        else
            return YES;
    }
}

- (BOOL)canAddItem:(NSUInteger)count
{
    NSUInteger max = 45;
    if([UIScreen mainScreen].bounds.size.height >= 568){
        max = 70;
    }
    return count <= max;
}

#pragma mark - Notifications

- (void)registerForNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(didChangeLibrary:) 
                                                 name:ALAssetsLibraryChangedNotification 
                                               object:[AGImagePickerController defaultAssetsLibrary]];
}

- (void)unregisterFromNotifications
{
    [[NSNotificationCenter defaultCenter] removeObserver:self 
                                                    name:ALAssetsLibraryChangedNotification 
                                                  object:[AGImagePickerController defaultAssetsLibrary]];
}

- (void)didChangeLibrary:(NSNotification *)notification
{
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (void)didChangeToolbarItemsForManagingTheSelection:(NSNotification *)notification
{
    NSLog(@"here.");
}
@end
