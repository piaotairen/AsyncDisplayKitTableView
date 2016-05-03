//
//  JZConsole.h
//  JZImagePickerDemo
//
//  Created by Seamus on 14-7-11.
//  Copyright (c) 2014年 JZ Technologies. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 * 设置所选图片的标记类
 */
@interface JZConsole : NSObject

@property (nonatomic,strong) NSMutableDictionary *assetUrlDic;//asseturl字典@{urls:index}

@property (nonatomic,assign) BOOL onOrder;
/**
 * 单例
 */
+ (JZConsole *)mainConsole;
/**
 * 添加标记item
 */
- (void)addIndex:(int)index;
/**
 * 删除标记item
 */
- (void)removeIndex:(int)index;
/**
 * 通过collectionView的item得到当前标记
 */
-(NSUInteger)indexForItem:(NSInteger)item;
/**
 * 标记总数
 */
- (int)numOfSelectedElements;
/**
 * 删除所有标记
 */
- (void)removeAllIndex;
@end
