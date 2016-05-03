//
//  JZAssetsCollectionViewCell.h
//  jiangzhi
//
//  Created by Cobb on 15/9/16.
//  Copyright (c) 2015年 kingly. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AssetsLibrary/AssetsLibrary.h>
// Views
#import "JZAssetsCollectionOverlayView.h"
#import <AsyncDisplayKit/AsyncDisplayKit.h>
#import "UIImage+LoadImage.h"

@interface JZAssetsCollectionViewCell : ASCellNode

@property (nonatomic, strong) JZAssetsCollectionOverlayView *overlayView;//覆盖层视图

@property (nonatomic, strong) ALAsset *asset;
@property (nonatomic, assign) BOOL showsOverlayViewWhenSelected;


/**
 * 更新标记label的位置
 */
-(void)updateMarkLabelIndex:(NSInteger)index;

/**
 * cell显示时切换为高清图片
 */
-(void)UpdatePicture;

/**
 * cell不显示时取消图片的切换
 */
-(void)cancelPictureLoad;

@end
