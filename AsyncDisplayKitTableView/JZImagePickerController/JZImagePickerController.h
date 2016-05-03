//
//  JZImagePickerController.h
//  jiangzhi
//
//  Created by Cobb on 15/9/16.
//  Copyright (c) 2015年 kingly. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AssetsLibrary/AssetsLibrary.h>

/**
 * 资源类型
 */
typedef NS_ENUM(NSUInteger, JZImagePickerControllerFilterType) {
    JZImagePickerControllerFilterTypeNone,
    JZImagePickerControllerFilterTypePhotos,
    JZImagePickerControllerFilterTypeVideos
};

UIKIT_EXTERN ALAssetsFilter * ALAssetsFilterFromJZImagePickerControllerFilterType(JZImagePickerControllerFilterType type);

@class JZImagePickerController;

@protocol JZImagePickerControllerDelegate <NSObject>

@optional
- (void)imagePickerController:(JZImagePickerController *)imagePickerController didSelectImg:(ALAsset *)image;
- (void)imagePickerController:(JZImagePickerController *)imagePickerController didSelectImgs:(NSArray *)images;
- (void)imagePickerDidCancel:(JZImagePickerController *)imagePickerController;

@end

@interface JZImagePickerController : UIViewController

@property (nonatomic, strong, readonly) ALAssetsLibrary *assetsLibrary;
@property (nonatomic, copy, readonly) NSArray *assetsGroups;
@property (nonatomic, strong, readonly) NSMutableSet *selectedAssetURLs;

@property (nonatomic, weak) id<JZImagePickerControllerDelegate> delegate;
@property (nonatomic, copy) NSArray *groupTypes;
@property (nonatomic, assign) JZImagePickerControllerFilterType filterType;
@property (nonatomic, assign) BOOL showsCancelButton;
@property (nonatomic, assign) BOOL allowsMultipleSelection;
@property (nonatomic, assign) NSUInteger minimumNumberOfSelection;
@property (nonatomic, assign) NSUInteger maximumNumberOfSelection;

+ (BOOL)isAccessible;

@end
