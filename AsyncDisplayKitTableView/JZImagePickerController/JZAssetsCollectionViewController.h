//
//  JZAssetsCollectionViewController.h
//  jiangzhi
//
//  Created by Cobb on 15/9/16.
//  Copyright (c) 2015年 kingly. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import <AsyncDisplayKit/AsyncDisplayKit.h>

// ViewControllers
#import "JZImagePickerController.h"

@class JZAssetsCollectionViewController;

@protocol JZAssetsCollectionViewControllerDelegate <NSObject>

@optional
- (void)assetsCollectionViewController:(JZAssetsCollectionViewController *)assetsCollectionViewController didSelectAsset:(ALAsset *)asset;
- (void)assetsCollectionViewController:(JZAssetsCollectionViewController *)assetsCollectionViewController didDeselectAsset:(ALAsset *)asset;
- (void)assetsCollectionViewControllerDidFinishSelection:(JZAssetsCollectionViewController *)assetsCollectionViewController;

@end

@interface JZAssetsCollectionViewController : UIViewController <ASCollectionViewDataSource, ASCollectionViewDelegateFlowLayout>

@property (nonatomic,strong) ASCollectionView *collectionView;

@property (nonatomic, weak) JZImagePickerController *imagePickerController;

@property (nonatomic, weak) id<JZAssetsCollectionViewControllerDelegate> delegate;
@property (nonatomic, strong) ALAssetsGroup *assetsGroup;
@property (nonatomic, assign) JZImagePickerControllerFilterType filterType;
@property (nonatomic, assign) BOOL allowsMultipleSelection;
@property (nonatomic, assign) NSUInteger minimumNumberOfSelection;
@property (nonatomic, assign) NSUInteger maximumNumberOfSelection;

- (void)selectAssetHavingURL:(NSURL *)URL;

@end
