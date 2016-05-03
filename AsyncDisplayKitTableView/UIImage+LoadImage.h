//
//  UIImage+LoadImage.h
//  jiangzhi
//
//  Created by Cobb on 15/5/13.
//  Copyright (c) 2015年 Hu Zhiyuan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <ImageIO/CGImageSource.h>
#import <AssetsLibrary/ALAsset.h>
#import "SDWebImageOperation.h"

@interface UIImage (LoadImage)

/**
 *————————————————————————————————————————————————————————————————————————————————————————
 * 1、[UIImage imageNamed:@""]在图片使用完成后，不会直接被释放掉，
 *    具体释放时间由系统决定，适用于图片小，常用的图像处理
 * 2、如果要释放快速释放图片，可以使用[UIImage imageWithContentsOfFile:path]实例化图像
 *————————————————————————————————————————————————————————————————————————————————————————
 */

/**
 * +方法，从[NSBundle mainBundle]加载图片
 * rName 项目中的图片文件名
 *
 */
+(UIImage *)imageResourceName:(NSString *)rName;

/**
 * 通过颜色值构造UIImage
 */
+(UIImage *)imageWithColor:(NSInteger)color;

/**
 * 重绘图片已解决图片大小变更的问题
 */
+ (UIImage *)reSizeImage:(UIImage *)image toSize:(CGSize)reSize;
/**
 * UIButton 控制UIImage自由改变大小
 */
- (UIImage* )transformWidth:(CGFloat)width withHeight:(CGFloat)height;

/**
 * @brief 按比例缩放,size 是你要把图显示到 多大区域 CGSizeMake(300, 140)
 */
-(UIImage *) imageCompressForSize:(CGSize)size;

/**
 * @brief 指定宽度按比例缩放
 */
-(UIImage *) imageCompressForWidth:(CGFloat)defineWidth;

/**
 * @brief ALAsset获取指定像素的图片
 */
+ (UIImage *)thumbnailForAsset:(ALAsset *)asset maxPixelSize:(NSUInteger)size;

@end
