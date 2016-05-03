//
//  CacheImageNode.h
//  AsyncDisplayKitTableView
//
//  Created by Zihai on 15/11/23.
//  Copyright © 2015年 Zihai. All rights reserved.
//

#import <AsyncDisplayKit/AsyncDisplayKit.h>

#import "SDWebImageCompat.h"
#import "SDWebImageManager.h"
#import <AssetsLibrary/AssetsLibrary.h>

@interface CacheImageNode : ASImageNode

- (void)sd_setImageWithURL:(NSURL *)url placeholderImage:(UIImage *)placeholder;


- (void)sd_setImageWithAsset:(ALAsset *)asset placeholderImage:(UIImage *)placeholder;

@end
