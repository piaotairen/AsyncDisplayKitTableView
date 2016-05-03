//
//  ALAssetImageLoader.h
//  AsyncDisplayKitTableView
//
//  Created by Zihai on 15/11/23.
//  Copyright © 2015年 Zihai. All rights reserved.
//

#import <SDWebImage/SDWebImageManager.h>
#import <AssetsLibrary/AssetsLibrary.h>

typedef void(^SDAssetImageCompletionWithFinishedBlock)(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, ALAsset *asset);

@interface ALAssetImageLoader : SDWebImageManager

+ (id)sharedManager;

- (id <SDWebImageOperation>)loadImageWithALAsset:(ALAsset *)asset
                                         options:(SDWebImageOptions)options
                                        progress:(SDWebImageDownloaderProgressBlock)progressBlock
                                       completed:(SDAssetImageCompletionWithFinishedBlock)completedBlock;

@end
