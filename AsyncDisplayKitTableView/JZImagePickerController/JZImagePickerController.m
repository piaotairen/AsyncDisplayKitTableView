//
//  JZImagePickerController.m
//  jiangzhi
//
//  Created by Cobb on 15/9/16.
//  Copyright (c) 2015年 kingly. All rights reserved.
//

#import "JZImagePickerController.h"
#import <AssetsLibrary/AssetsLibrary.h>

#import <AsyncDisplayKit/AsyncDisplayKit.h>

// Views
#import "JZImagePickerGroupCell.h"
#import "JZAssetsCollectionViewLayout.h"

// ViewControllers
#import "JZAssetsCollectionViewController.h"
#import "JZConsole.h"
#import <CoreLocation/CoreLocation.h>
#import "CmdCollect.pch"
#import "NSData+ImageContentType.h"
#import "UIImage+GIF.h"

#define UIImagePickerControllerOriginalImageData @"UIImagePickerControllerOriginalImageData"  // a UIImage NSData

ALAssetsFilter * ALAssetsFilterFromJZImagePickerControllerFilterType(JZImagePickerControllerFilterType type) {
    switch (type) {
        case JZImagePickerControllerFilterTypeNone:
            return [ALAssetsFilter allAssets];
            break;
            
        case JZImagePickerControllerFilterTypePhotos:
            return [ALAssetsFilter allPhotos];
            break;
            
        case JZImagePickerControllerFilterTypeVideos:
            return [ALAssetsFilter allVideos];
            break;
    }
}

@interface JZImagePickerController () <JZAssetsCollectionViewControllerDelegate,ASTableViewDataSource, ASTableViewDelegate>

@property (nonatomic,strong) ASTableView *tableView;

@property (nonatomic, strong, readwrite) ALAssetsLibrary *assetsLibrary;
@property (nonatomic, copy, readwrite) NSArray *assetsGroups;
@property (nonatomic, strong, readwrite) NSMutableSet *selectedAssetURLs;

@end

@implementation JZImagePickerController
{
    BOOL isFirstPush;//第一次进入push标记
}
+ (BOOL)isAccessible
{
    return ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary] &&
            [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeSavedPhotosAlbum]);
}

- (instancetype)init
{
    if (!(self = [super init])){
        return nil;
    }
    
    _tableView = [[ASTableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain asyncDataFetching:YES];
    _tableView.asyncDataSource = self;
    _tableView.asyncDelegate = self;
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    // Property settings
    self.selectedAssetURLs = [NSMutableSet set];
    
    self.groupTypes = @[
                        @(ALAssetsGroupSavedPhotos),
                        @(ALAssetsGroupPhotoStream),
                        @(ALAssetsGroupAlbum)
                        ];
    self.filterType = JZImagePickerControllerFilterTypeNone;
    self.showsCancelButton = YES;
    
    // Create assets library instance
    ALAssetsLibrary *assetsLibrary = [[ALAssetsLibrary alloc] init];
    self.assetsLibrary = assetsLibrary;
    
    isFirstPush = YES;
    
    return self;
}

-(void)loadView
{
    [super loadView];
    // View controller settings
    self.title = @"相簿";
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.view addSubview:_tableView];
    
    [self thrashTableView];
}

- (void)viewWillLayoutSubviews
{
    _tableView.frame = self.view.bounds;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)thrashTableView
{
    [_tableView reloadData];
    
    // Load assets groups
    [self loadAssetsGroupsWithTypes:self.groupTypes
                         completion:^(NSArray *assetsGroups) {
                             self.assetsGroups = assetsGroups;
                             
                             [self.tableView reloadData];
                             
                             [self pushToChildVc];
                         }];
    
    // Validation
    self.navigationItem.leftBarButtonItem.enabled = [self validateNumberOfSelections:self.selectedAssetURLs.count];
}


/**
 * 第一次进入直接push下级页面
 */
-(void)pushToChildVc
{
    if (isFirstPush) {
        isFirstPush = !isFirstPush;
        
        JZAssetsCollectionViewController *assetsCollectionViewController = [[JZAssetsCollectionViewController alloc] init];
        assetsCollectionViewController.imagePickerController = self;
        assetsCollectionViewController.filterType = self.filterType;
        assetsCollectionViewController.allowsMultipleSelection = self.allowsMultipleSelection;
        assetsCollectionViewController.minimumNumberOfSelection = self.minimumNumberOfSelection;
        assetsCollectionViewController.maximumNumberOfSelection = self.maximumNumberOfSelection;
        
        ALAssetsGroup *assetsGroup = [self.assetsGroups firstObject];
        assetsCollectionViewController.delegate = self;
        assetsCollectionViewController.assetsGroup = assetsGroup;
        
        for (NSURL *assetURL in self.selectedAssetURLs) {
            [assetsCollectionViewController selectAssetHavingURL:assetURL];
        }
        
        [self.navigationController pushViewController:assetsCollectionViewController animated:NO];
    }
}

#pragma mark - Accessors

- (void)setShowsCancelButton:(BOOL)showsCancelButton
{
    _showsCancelButton = showsCancelButton;
    
    // Show/hide cancel button
    if (showsCancelButton) {
        UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancel:)];
        [self.navigationItem setRightBarButtonItem:cancelButton animated:NO];
    } else {
        [self.navigationItem setRightBarButtonItem:nil animated:NO];
    }
}

- (void)setAllowsMultipleSelection:(BOOL)allowsMultipleSelection
{
    _allowsMultipleSelection = allowsMultipleSelection;
    
    // Show/hide done button
    if (allowsMultipleSelection) {
        UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(done:)];
        [self.navigationItem setLeftBarButtonItem:doneButton animated:NO];
    } else {
        [self.navigationItem setLeftBarButtonItem:nil animated:NO];
    }
}


#pragma mark - Actions

- (void)done:(id)sender
{
    [self passSelectedAssetsToDelegate];
}

- (void)cancel:(id)sender
{
    [[JZConsole mainConsole] removeAllIndex];
    
    // Delegate
    if (self.delegate && [self.delegate respondsToSelector:@selector(imagePickerControllerDidCancel:)]) {
        [self.delegate imagePickerDidCancel:self];
    }
}


#pragma mark - Validating Selections

- (BOOL)validateNumberOfSelections:(NSUInteger)numberOfSelections
{
    // Check the number of selected assets
    NSUInteger minimumNumberOfSelection = MAX(1, self.minimumNumberOfSelection);
    BOOL qualifiesMinimumNumberOfSelection = (numberOfSelections >= minimumNumberOfSelection);
    
    BOOL qualifiesMaximumNumberOfSelection = YES;
    if (minimumNumberOfSelection <= self.maximumNumberOfSelection) {
        qualifiesMaximumNumberOfSelection = (numberOfSelections <= self.maximumNumberOfSelection);
    }
    
    return (qualifiesMinimumNumberOfSelection && qualifiesMaximumNumberOfSelection);
}


#pragma mark - Managing Assets

- (void)loadAssetsGroupsWithTypes:(NSArray *)types completion:(void (^)(NSArray *assetsGroups))completion
{
    __block NSMutableArray *assetsGroups = [NSMutableArray array];
    __block NSUInteger numberOfFinishedTypes = 0;
    
    for (NSNumber *type in types) {
        __weak typeof(self) weakSelf = self;
        
        [self.assetsLibrary enumerateGroupsWithTypes:[type unsignedIntegerValue]
                                          usingBlock:^(ALAssetsGroup *assetsGroup, BOOL *stop) {
                                              if (assetsGroup) {
                                                  // Filter the assets group
                                                  [assetsGroup setAssetsFilter:ALAssetsFilterFromJZImagePickerControllerFilterType(weakSelf.filterType)];
                                                  
                                                  if (assetsGroup.numberOfAssets > 0) {
                                                      // Add assets group
                                                      [assetsGroups addObject:assetsGroup];
                                                  }
                                              } else {
                                                  numberOfFinishedTypes++;
                                              }
                                              
                                              // Check if the loading finished
                                              if (numberOfFinishedTypes == types.count) {
                                                  // Sort assets groups
                                                  NSArray *sortedAssetsGroups = [self sortAssetsGroups:(NSArray *)assetsGroups typesOrder:types];
                                                  
                                                  // Call completion block
                                                  if (completion) {
                                                      completion(sortedAssetsGroups);
                                                  }
                                              }
                                          } failureBlock:^(NSError *error) {
                                              NSLog(@"Error: %@", [error localizedDescription]);
                                          }];
    }
}

- (NSArray *)sortAssetsGroups:(NSArray *)assetsGroups typesOrder:(NSArray *)typesOrder
{
    NSMutableArray *sortedAssetsGroups = [NSMutableArray array];
    
    for (ALAssetsGroup *assetsGroup in assetsGroups) {
        if (sortedAssetsGroups.count == 0) {
            [sortedAssetsGroups addObject:assetsGroup];
            continue;
        }
        
        ALAssetsGroupType assetsGroupType = [[assetsGroup valueForProperty:ALAssetsGroupPropertyType] unsignedIntegerValue];
        NSUInteger indexOfAssetsGroupType = [typesOrder indexOfObject:@(assetsGroupType)];
        
        for (NSInteger i = 0; i <= sortedAssetsGroups.count; i++) {
            if (i == sortedAssetsGroups.count) {
                [sortedAssetsGroups addObject:assetsGroup];
                break;
            }
            
            ALAssetsGroup *sortedAssetsGroup = [sortedAssetsGroups objectAtIndex:i];
            ALAssetsGroupType sortedAssetsGroupType = [[sortedAssetsGroup valueForProperty:ALAssetsGroupPropertyType] unsignedIntegerValue];
            NSUInteger indexOfSortedAssetsGroupType = [typesOrder indexOfObject:@(sortedAssetsGroupType)];
            
            if (indexOfAssetsGroupType < indexOfSortedAssetsGroupType) {
                [sortedAssetsGroups insertObject:assetsGroup atIndex:i];
                break;
            }
        }
    }
    
    return [sortedAssetsGroups copy];
}

- (void)passSelectedAssetsToDelegate
{
    // Load assets from URLs
    __block NSMutableArray *assets = [NSMutableArray array];
    
    for (NSURL *selectedAssetURL in self.selectedAssetURLs) {
        __weak typeof(self) weakSelf = self;
        [self.assetsLibrary assetForURL:selectedAssetURL
                            resultBlock:^(ALAsset *asset) {
                                
                                // Add asset
                                [assets addObject:asset];
                                
                                // Check if the loading finished
                                if (assets.count == weakSelf.selectedAssetURLs.count) {
                                    NSArray *sortArray = [self sortWithIndex:assets];
                                    NSArray *imageArray = [self imageArrayWithInfo:[self selectedAssets:sortArray]];
                                    //                                    NSLog(@"imageArray is %@",imageArray);
                                    
                                    // Delegate
                                    if (self.delegate && [self.delegate respondsToSelector:@selector(imagePickerController:didSelectImgs:)]) {
                                        [self.delegate imagePickerController:self didSelectImgs:[imageArray copy]];
                                    }
                                    
                                    [[JZConsole mainConsole] removeAllIndex];
                                }
                            } failureBlock:^(NSError *error) {
                                NSLog(@"Error: %@", [error localizedDescription]);
                            }];
    }
}

#pragma mark - 根据字典中标记排序
/**
 * 根据字典中顺序排列
 */
-(NSArray *)sortWithIndex:(NSArray *)assets
{
    return [assets sortedArrayUsingComparator:^NSComparisonResult(id obj1,id obj2){
        NSString *assetUrls1 = [(ALAsset *)obj1 valueForProperty:ALAssetPropertyURLs];
        NSNumber *index1 = [[JZConsole mainConsole].assetUrlDic objectForKey:assetUrls1];
        NSLog(@"assetUrls1 is ********** is %@ index1 is %@",assetUrls1,index1);
        
        NSString *assetUrls2 = [(ALAsset *)obj2 valueForProperty:ALAssetPropertyURLs];
        NSNumber *index2 = [[JZConsole mainConsole].assetUrlDic objectForKey:assetUrls2];
        NSLog(@"assetUrls2 is ********** is %@ index2 is %@",assetUrls2,index2);
        
        if (index1 >= index2) {
            return NSOrderedDescending;
        }else{
            return NSOrderedAscending;
        }
    }];
}

#pragma mark - 将assets数组设为image数组
/**
 * 获取媒体数组
 */
- (NSMutableArray *)selectedAssets:(NSArray *)assets
{
    NSMutableArray *returnArray = [[NSMutableArray alloc] init];
    
    for(int i = 0; i < assets.count; i++) {
        
        ALAsset *eachAsset  = [assets objectAtIndex:i];
        
        id obj = [eachAsset valueForProperty:ALAssetPropertyType];
        if (!obj) {
            continue;
        }
        NSMutableDictionary *workingDictionary = [[NSMutableDictionary alloc] init];
        
        CLLocation* wgs84Location = [eachAsset valueForProperty:ALAssetPropertyLocation];
        if (wgs84Location) {
            [workingDictionary setObject:wgs84Location forKey:ALAssetPropertyLocation];
        }
        
        [workingDictionary setObject:obj forKey:UIImagePickerControllerMediaType];
        
        //This method returns nil for assets from a shared photo stream that are not yet available locally. If the asset becomes available in the future, an ALAssetsLibraryChangedNotification notification is posted.
        ALAssetRepresentation *assetRep = [eachAsset defaultRepresentation];
        
        if(assetRep != nil) {
            //gif格式的图片需保存NSData
            Byte *imageBuffer = (Byte*)malloc((unsigned long)assetRep.size);
            NSUInteger bufferSize = [assetRep getBytes:imageBuffer fromOffset:0.0 length:(NSUInteger)assetRep.size error:nil];
            NSData *imageData = [NSData dataWithBytesNoCopy:imageBuffer length:bufferSize freeWhenDone:YES];
            [workingDictionary setObject:imageData forKey:UIImagePickerControllerOriginalImageData];
            
            CGImageRef imgRef = nil;
            //defaultRepresentation returns image as it appears in photo picker, rotated and sized,
            //so use UIImageOrientationUp when creating our image below.
            UIImageOrientation orientation = UIImageOrientationUp;
            
            //原图
            imgRef = [assetRep fullResolutionImage];
            orientation = (UIImageOrientation)[assetRep orientation];
            //全屏
            //imgRef = [assetRep fullScreenImage];
            UIImage *img = [UIImage imageWithCGImage:imgRef
                                               scale:1.0f
                                         orientation:orientation];
            [workingDictionary setObject:img forKey:UIImagePickerControllerOriginalImage];
        }
        
        [workingDictionary setObject:[[eachAsset valueForProperty:ALAssetPropertyURLs] valueForKey:[[[eachAsset valueForProperty:ALAssetPropertyURLs] allKeys] objectAtIndex:0]] forKey:UIImagePickerControllerReferenceURL];
        
        [returnArray addObject:workingDictionary];
    }
    return returnArray;
}



/**
 * 获取图片数组
 */
-(NSArray *)imageArrayWithInfo:(NSArray *)assets
{
    NSMutableArray *images = [NSMutableArray arrayWithCapacity:[assets count]];
    for (NSDictionary *dict in assets) {
        if ([dict objectForKey:UIImagePickerControllerMediaType] == ALAssetTypePhoto){
            if ([dict objectForKey:UIImagePickerControllerOriginalImage]){
                UIImage* image=[dict objectForKey:UIImagePickerControllerOriginalImage];
                NSData *selImageData = [dict objectForKey:UIImagePickerControllerOriginalImageData];
                
                if (![[NSData sd_contentTypeForImageData:selImageData] isEqualToString:@"image/gif"]) {
                    //普通图压缩
                    [images addObject:UIImageJPEGRepresentation(image,0.3f)];
                }else{
                    //gif图不压缩
                    [images addObject:selImageData];
                }
            } else {
                NSLog(@"UIImagePickerControllerReferenceURL = %@", dict);
            }
        } else if ([dict objectForKey:UIImagePickerControllerMediaType] == ALAssetTypeVideo){
            if ([dict objectForKey:UIImagePickerControllerOriginalImage]){
                UIImage* image=[dict objectForKey:UIImagePickerControllerOriginalImage];
                [images addObject:UIImageJPEGRepresentation(image,0.3f)];
            } else {
                NSLog(@"UIImagePickerControllerReferenceURL = %@", dict);
            }
        } else {
            NSLog(@"Uknown asset type");
        }
    }
    return images;
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.assetsGroups.count;
}

- (ASCellNode *)tableView:(ASTableView *)tableView nodeForRowAtIndexPath:(NSIndexPath *)indexPath
{
    JZImagePickerGroupCell *cell = [[JZImagePickerGroupCell alloc]init];
    
    cell.backgroundColor = [UIColor yellowColor];
    
    ALAssetsGroup *assetsGroup = [self.assetsGroups objectAtIndex:indexPath.row];
    cell.assetsGroup = assetsGroup;
    
    return cell;
}


#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return kCeilScreenPx(222.0f);
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    JZAssetsCollectionViewController *assetsCollectionViewController = [[JZAssetsCollectionViewController alloc] init];
    assetsCollectionViewController.imagePickerController = self;
    assetsCollectionViewController.filterType = self.filterType;
    assetsCollectionViewController.allowsMultipleSelection = self.allowsMultipleSelection;
    assetsCollectionViewController.minimumNumberOfSelection = self.minimumNumberOfSelection;
    assetsCollectionViewController.maximumNumberOfSelection = self.maximumNumberOfSelection;
    
    ALAssetsGroup *assetsGroup = [self.assetsGroups objectAtIndex:indexPath.row];
    assetsCollectionViewController.delegate = self;
    assetsCollectionViewController.assetsGroup = assetsGroup;
    
    for (NSURL *assetURL in self.selectedAssetURLs) {
        [assetsCollectionViewController selectAssetHavingURL:assetURL];
    }
    
    [self.navigationController pushViewController:assetsCollectionViewController animated:YES];
}


#pragma mark - JZAssetsCollectionViewControllerDelegate

- (void)assetsCollectionViewController:(JZAssetsCollectionViewController *)assetsCollectionViewController didSelectAsset:(ALAsset *)asset
{
    if (self.allowsMultipleSelection) {
        // Add asset URL
        NSURL *assetURL = [asset valueForProperty:ALAssetPropertyAssetURL];
        [self.selectedAssetURLs addObject:assetURL];
        
        // Validation
        self.navigationItem.leftBarButtonItem.enabled = [self validateNumberOfSelections:self.selectedAssetURLs.count];
    } else {
        NSArray *imageArray = [self imageArrayWithInfo:[self selectedAssets:@[asset]]];
        NSLog(@"imageArray is %@",imageArray);
        // Delegate
        if (self.delegate && [self.delegate respondsToSelector:@selector(imagePickerController:didSelectImg:)]) {
            [self.delegate imagePickerController:self didSelectImg:[imageArray copy]];
        }
    }
}

- (void)assetsCollectionViewController:(JZAssetsCollectionViewController *)assetsCollectionViewController didDeselectAsset:(ALAsset *)asset
{
    if (self.allowsMultipleSelection) {
        // Remove asset URL
        NSURL *assetURL = [asset valueForProperty:ALAssetPropertyAssetURL];
        [self.selectedAssetURLs removeObject:assetURL];
        
        // Validation
        self.navigationItem.leftBarButtonItem.enabled = [self validateNumberOfSelections:self.selectedAssetURLs.count];
    }
}

- (void)assetsCollectionViewControllerDidFinishSelection:(JZAssetsCollectionViewController *)assetsCollectionViewController
{
    [self passSelectedAssetsToDelegate];
}

@end
