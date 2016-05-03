//
//  JZAssetsCollectionOverlayView.h
//  jiangzhi
//
//  Created by Cobb on 15/9/16.
//  Copyright (c) 2015年 kingly. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface JZAssetsCollectionOverlayView : UIView

/**
 * 是否开启计数模式
 */
@property (nonatomic,assign) BOOL onOrder;

@property (nonatomic, strong) UILabel *labIndex;

- (void)setIndex:(int)_index;

@end
