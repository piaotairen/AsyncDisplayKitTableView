//
//  JZImagePickerGroupCell.h
//  jiangzhi
//
//  Created by Cobb on 15/9/16.
//  Copyright (c) 2015年 kingly. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import <AsyncDisplayKit/ASCellNode.h>

@interface JZImagePickerGroupCell : ASCellNode

@property (nonatomic, strong) ALAssetsGroup *assetsGroup;

@end
