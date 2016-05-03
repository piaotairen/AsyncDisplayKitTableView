//
//  JZAssetsCollectionViewController.m
//  jiangzhi
//
//  Created by Cobb on 15/9/16.
//  Copyright (c) 2015年 kingly. All rights reserved.
//

#import "JZAssetsCollectionViewController.h"
#import "CmdCollect.pch"
// Views
#import "JZAssetsCollectionViewCell.h"
#import "JZAssetsCollectionFooterView.h"
#import "CmdCollect.pch"
#import "JZConsole.h"
#import "CollectDownView.h"
#import "CacheImageNode.h"

#define kItemMargin 2.0f

@interface JZAssetsCollectionViewController () <selectedDoneDelegate,ASCollectionViewDataSource, ASCollectionViewDelegateFlowLayout>

@property (nonatomic, strong) NSMutableArray *assets;
@property (nonatomic, strong) NSMutableArray *groups;

@property (nonatomic, assign) NSInteger numberOfPhotos;
@property (nonatomic, assign) NSInteger numberOfVideos;

@end

@implementation JZAssetsCollectionViewController
{
    CollectDownView *collectPictureView;
}
- (instancetype)init
{
    if (!(self = [super init]))
        return nil;
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.headerReferenceSize = CGSizeMake(0.0, 0.0);
    layout.footerReferenceSize = CGSizeMake(50.0, 50.0);
    
    // View settings
    self.collectionView = [[ASCollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout asyncDataFetching:YES];
    self.collectionView.asyncDataSource = self;
    self.collectionView.asyncDelegate = self;

    self.collectionView.backgroundColor = [UIColor whiteColor];
    self.collectionView.frame = CGRectMake(0, 0, kScreenWidth, kScreenHeight-kCeilScreenPx(168.0f));
    
    [self.collectionView registerSupplementaryNodeOfKind:UICollectionElementKindSectionFooter];
    
    return self;
}

-(void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.view addSubview:self.collectionView];
    
    [self loadCollecPictureView];
}

- (void)viewWillLayoutSubviews
{
    _collectionView.frame = self.view.bounds;
}

/**
 * 加载图片拾取视图
 */
-(void)loadCollecPictureView
{
    collectPictureView = [[CollectDownView alloc]initWithFrame:CGRectMake(0, kScreenHeight-kCeilScreenPx(168.0f), kScreenWidth, kCeilScreenPx(168.0f))];
    collectPictureView.myDelegate = self;
    [self.view addSubview:collectPictureView];
    
    [collectPictureView layoutIfNeeded];
    [collectPictureView updateMarkText];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    // Scroll to bottom
    CGFloat topInset = ((self.edgesForExtendedLayout && UIRectEdgeTop) && (self.collectionView.contentInset.top == 0)) ? (20.0 + 44.0) : 0.0;
    
    [self.collectionView setContentOffset:CGPointMake(0, self.collectionView.collectionViewLayout.collectionViewContentSize.height - self.collectionView.frame.size.height + topInset)
                                 animated:NO];
    self.collectionView.bounces = YES;
    
    // Validation
    if (self.allowsMultipleSelection) {
        //        self.navigationItem.rightBarButtonItem.enabled = [self validateNumberOfSelections:self.imagePickerController.selectedAssetURLs.count];
    }
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

#pragma mark - Accessors

- (void)setFilterType:(JZImagePickerControllerFilterType)filterType
{
    _filterType = filterType;
    
    // Set assets filter
    [self.assetsGroup setAssetsFilter:ALAssetsFilterFromJZImagePickerControllerFilterType(self.filterType)];
}

- (void)setAssetsGroup:(ALAssetsGroup *)assetsGroup
{
    _assetsGroup = assetsGroup;
    
    // Set title
    self.title = [self.assetsGroup valueForProperty:ALAssetsGroupPropertyName];
    
    // Get the number of photos and videos
    [self.assetsGroup setAssetsFilter:[ALAssetsFilter allPhotos]];
    self.numberOfPhotos = self.assetsGroup.numberOfAssets;
    
    [self.assetsGroup setAssetsFilter:[ALAssetsFilter allVideos]];
    self.numberOfVideos = self.assetsGroup.numberOfAssets;
    
    // Set assets filter
    [self.assetsGroup setAssetsFilter:ALAssetsFilterFromJZImagePickerControllerFilterType(self.filterType)];
    
    // Load assets
    self.assets = [NSMutableArray array];
    
    __weak typeof(self) weakSelf = self;
    [self.assetsGroup enumerateAssetsUsingBlock:^(ALAsset *result, NSUInteger index, BOOL *stop) {
        if (result) {
            [weakSelf.assets addObject:result];
        }
    }];
    
    // Update view
    [self.collectionView reloadData];
}

- (void)setAllowsMultipleSelection:(BOOL)allowsMultipleSelection
{
    self.collectionView.allowsMultipleSelection = allowsMultipleSelection;
    
    // Show/hide done button
    if (allowsMultipleSelection) {
        UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelClick:)];
        [self.navigationItem setRightBarButtonItem:cancelButton animated:NO];
    } else {
        [self.navigationItem setRightBarButtonItem:nil animated:NO];
    }
}

- (BOOL)allowsMultipleSelection
{
    return self.collectionView.allowsMultipleSelection;
}


#pragma mark - Actions

- (void)cancelClick:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:^{}];
    
    [[JZConsole mainConsole]removeAllIndex];
}


#pragma mark - Managing Selection

- (void)selectAssetHavingURL:(NSURL *)URL
{
    for (NSInteger i = 0; i < self.assets.count; i++) {
        ALAsset *asset = [self.assets objectAtIndex:i];
        NSURL *assetURL = [asset valueForProperty:ALAssetPropertyAssetURL];
        
        if ([assetURL isEqual:URL]) {
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:i inSection:0];
            [self.collectionView selectItemAtIndexPath:indexPath animated:NO scrollPosition:UICollectionViewScrollPositionNone];
            
            return;
        }
    }
}


#pragma mark - Validating Selections

- (BOOL)validateNumberOfSelections:(NSUInteger)numberOfSelections
{
    NSUInteger minimumNumberOfSelection = MAX(1, self.minimumNumberOfSelection);
    BOOL qualifiesMinimumNumberOfSelection = (numberOfSelections >= minimumNumberOfSelection);
    
    BOOL qualifiesMaximumNumberOfSelection = YES;
    if (minimumNumberOfSelection <= self.maximumNumberOfSelection) {
        qualifiesMaximumNumberOfSelection = (numberOfSelections <= self.maximumNumberOfSelection);
    }
    
    return (qualifiesMinimumNumberOfSelection && qualifiesMaximumNumberOfSelection);
}

- (BOOL)validateMaximumNumberOfSelections:(NSUInteger)numberOfSelections
{
    NSUInteger minimumNumberOfSelection = MAX(1, self.minimumNumberOfSelection);
    
    if (minimumNumberOfSelection <= self.maximumNumberOfSelection) {
        return (numberOfSelections <= self.maximumNumberOfSelection);
    }
    
    return YES;
}


#pragma mark - UICollectionViewDataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.assetsGroup.numberOfAssets;
}

- (void)collectionViewLockDataSource:(ASCollectionView *)collectionView
{
    // lock the data source
    // The data source should not be change until it is unlocked.
}

- (void)collectionViewUnlockDataSource:(ASCollectionView *)collectionView
{
    // unlock the data source to enable data source updating.
}

- (ASSizeRange)collectionView:(ASCollectionView *)collectionView constrainedSizeForNodeAtIndexPath:(NSIndexPath *)indexPath
{
    ASSizeRange range = {CGSizeMake(kScreenWidth, 180),CGSizeMake(kScreenWidth, 180)};
    return range;
}

- (ASCellNode *)collectionView:(ASCollectionView *)collectionView nodeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    ASCellNode *cellNode = [[ASCellNode alloc]init];
    cellNode.backgroundColor = [UIColor whiteColor];
    [cellNode setNeedsLayout];
    
    ASTextNode *node = [[ASTextNode alloc] init];
    NSMutableParagraphStyle *textStyle = [[NSMutableParagraphStyle alloc]init];
    textStyle.alignment = NSTextAlignmentCenter;
    node.attributedString = [[NSMutableAttributedString alloc]initWithString:[NSString stringWithFormat:@"[%zd.%zd] says hi", indexPath.section, indexPath.item] attributes:@{NSForegroundColorAttributeName:[UIColor purpleColor],NSFontAttributeName:[UIFont systemFontOfSize:15],NSParagraphStyleAttributeName:textStyle}];
    node.frame = CGRectMake(0, 160, kScreenWidth, 20);
    [cellNode addSubnode:node];
    
    CacheImageNode *image = [[CacheImageNode alloc]init];
    image.frame = CGRectMake(0, 0, kScreenWidth, 160);
    image.backgroundColor = [UIColor whiteColor];
    [cellNode addSubnode:image];
    
    //method1 采用网络加载图片SDWebImage方案
    NSArray *urlList = @[@"http://www.mengchongzhi.com/uploads/allimg/150408/1-15040Q1544A24.jpg",
                         @"http://img5.duitang.com/uploads/item/201401/21/20140121143628_At8F3.thumb.700_0.jpeg",
                         @"http://img.boqiicdn.com/Data/BK/A/1410/20/img52511413791120_y.jpg",
                         @"http://img4.duitang.com/uploads/item/201411/01/20141101093253_WNnEd.thumb.700_0.jpeg",
                         @"http://img4.duitang.com/uploads/item/201211/16/20121116191117_NP2YC.jpeg",
                         @"http://imgsrc.baidu.com/baike/pic/item/241f95cad1c8a7861dde9b3e6509c93d70cf500e.jpg",
                         @"http://img5.duitang.com/uploads/item/201411/13/20141113050159_SeAhV.jpeg",
                         @"http://imgsrc.baidu.com/forum/w%3D580/sign=66eda867dbf9d72a17641015e42b282a/eab7370828381f30958541f1ab014c086f06f067.jpg",
                         @"http://pic.baike.soso.com/p/20130608/20130608201656-2138559459.jpg",
                         @"http://cdn.duitang.com/uploads/item/201405/20/20140520235647_RVHwy.thumb.700_0.jpeg",
                         @"http://www.honghuowang.com/data/attachment/forum/pw/1307/thread/24_257_58f9c6eee087de6.jpg"
                         ];
    [image sd_setImageWithURL:[NSURL URLWithString:[urlList objectAtIndex:indexPath.item%11]] placeholderImage:[UIImage imageNamed:@"feed"]];
    
    //method2 采用本地相册资源加载图片
//        ALAsset *asset = [self.assets objectAtIndex:indexPath.row];
//        [image sd_setImageWithAsset:asset placeholderImage:[UIImage imageNamed:@"feed"]];
    
    return cellNode;
}

-(ASCellNode *)collectionView:(ASCollectionView *)collectionView nodeForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    if (kind == UICollectionElementKindSectionFooter) {
        JZAssetsCollectionFooterView *footerView = [[JZAssetsCollectionFooterView alloc]init];
        
        switch (self.filterType) {
            case JZImagePickerControllerFilterTypeNone:
                footerView.textLabel.attributedString = [[NSMutableAttributedString alloc]initWithString:[NSString stringWithFormat:MLString(@"格式化_照片_视频"),
                                                                                                          self.numberOfPhotos,
                                                                                                          self.numberOfVideos]];
                break;
                
            case JZImagePickerControllerFilterTypePhotos:
                footerView.textLabel.attributedString = [[NSMutableAttributedString alloc]initWithString:[NSString stringWithFormat:MLString(@"格式化_照片"),
                                                                                                          self.numberOfPhotos,
                                                                                                          self.numberOfVideos]];
                
                break;
                
            case JZImagePickerControllerFilterTypeVideos:
                footerView.textLabel.attributedString = [[NSMutableAttributedString alloc]initWithString:[NSString stringWithFormat:MLString(@"格式化_视频"),
                                                                                                          self.numberOfPhotos,
                                                                                                          self.numberOfVideos]];
                break;
        }
        
        return footerView;
    }
    
    return nil;
}
#pragma mark - selectedDoneDelegate
/**
 * 点击了完成按钮
 */
-(void)clickSelectedDone
{
    // Delegate
    if (self.delegate && [self.delegate respondsToSelector:@selector(assetsCollectionViewControllerDidFinishSelection:)]) {
        [self.delegate assetsCollectionViewControllerDidFinishSelection:self];
    }
}

@end
