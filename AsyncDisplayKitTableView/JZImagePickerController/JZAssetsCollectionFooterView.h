//
//  JZAssetsCollectionFooterView.h
//  jiangzhi
//
//  Created by Cobb on 15/9/16.
//  Copyright (c) 2015年 kingly. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AsyncDisplayKit/AsyncDisplayKit.h>

@protocol selectedDoneDelegate;

@interface JZAssetsCollectionFooterView : ASCellNode

/**
 * 图片和视频个数
 */
@property (nonatomic, strong, readonly) ASTextNode *textLabel;


@end