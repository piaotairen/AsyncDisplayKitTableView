//
//  JZImagePickerThumbnailView.m
//  jiangzhi
//
//  Created by Cobb on 15/9/16.
//  Copyright (c) 2015年 kingly. All rights reserved.
//

#import "JZImagePickerThumbnailView.h"
#import "CmdCollect.pch"

@interface JZImagePickerThumbnailView ()

@property (nonatomic, copy) NSArray *thumbnailImages;
@end

@implementation JZImagePickerThumbnailView

- (instancetype)init
{
    self = [super init];
    
    if (self) {
        self.backgroundColor = [UIColor redColor];
    }
    
    return self;
}


//-(void)drawLayer:(CALayer *)layer inContext:(CGContextRef)ctx
//{
//    CGContextRef context = ctx;
//    CGContextSetRGBFillColor(context, 1.0, 1.0, 1.0, 1.0);
//    
//    if (self.thumbnailImages.count == 3) {
//        UIImage *thumbnailImage = [self.thumbnailImages objectAtIndex:2];
//        
//        CGRect thumbnailImageRect = CGRectMake(4.0, 0, kCeilScreenPx(162.0)-8, kCeilScreenPx(162.0)-8);
//        CGContextFillRect(context, thumbnailImageRect);
//        [thumbnailImage drawInRect:CGRectInset(thumbnailImageRect, 0.5, 0.5)];
//    }
//    
//    if (self.thumbnailImages.count >= 2) {
//        UIImage *thumbnailImage = [self.thumbnailImages objectAtIndex:1];
//        
//        CGRect thumbnailImageRect = CGRectMake(2.0, 2.0, kCeilScreenPx(162.0)-4, kCeilScreenPx(162.0)-4);
//        CGContextFillRect(context, thumbnailImageRect);
//        [thumbnailImage drawInRect:CGRectInset(thumbnailImageRect, 0.5, 0.5)];
//    }
//    
//    UIImage *thumbnailImage = [self.thumbnailImages objectAtIndex:0];
//    
//    CGRect thumbnailImageRect = CGRectMake(0, 4.0, kCeilScreenPx(162.0), kCeilScreenPx(162.0));
//    CGContextFillRect(context, thumbnailImageRect);
//    [thumbnailImage drawInRect:CGRectInset(thumbnailImageRect, 0.5, 0.5)];
//}

- (void)thumbnailImagesConfig
{
    NSLog(@"self view frame is %@",NSStringFromCGRect(self.view.frame));
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetRGBFillColor(context, 1.0, 1.0, 1.0, 1.0);
    
    if (self.thumbnailImages.count == 3) {
        UIImage *thumbnailImage = [self.thumbnailImages objectAtIndex:2];
        
        CGRect thumbnailImageRect = CGRectMake(4.0, 0, kCeilScreenPx(162.0)-8, kCeilScreenPx(162.0)-8);
        CGContextFillRect(context, thumbnailImageRect);
        [thumbnailImage drawInRect:CGRectInset(thumbnailImageRect, 0.5, 0.5)];
    }
    
    if (self.thumbnailImages.count >= 2) {
        UIImage *thumbnailImage = [self.thumbnailImages objectAtIndex:1];
        
        CGRect thumbnailImageRect = CGRectMake(2.0, 2.0, kCeilScreenPx(162.0)-4, kCeilScreenPx(162.0)-4);
        CGContextFillRect(context, thumbnailImageRect);
        [thumbnailImage drawInRect:CGRectInset(thumbnailImageRect, 0.5, 0.5)];
    }
    
    UIImage *thumbnailImage = [self.thumbnailImages objectAtIndex:0];
    
    CGRect thumbnailImageRect = CGRectMake(0, 4.0, kCeilScreenPx(162.0), kCeilScreenPx(162.0));
    CGContextFillRect(context, thumbnailImageRect);
    [thumbnailImage drawInRect:CGRectInset(thumbnailImageRect, 0.5, 0.5)];
}


#pragma mark - Accessors

- (void)setAssetsGroup:(ALAssetsGroup *)assetsGroup
{
    _assetsGroup = assetsGroup;
    
    // Extract three thumbnail images
    NSIndexSet *indexes = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, MIN(3, assetsGroup.numberOfAssets))];
    NSMutableArray *thumbnailImages = [NSMutableArray array];
    [assetsGroup enumerateAssetsAtIndexes:indexes
                                  options:0
                               usingBlock:^(ALAsset *result, NSUInteger index, BOOL *stop) {
                                   if (result) {
                                       UIImage *thumbnailImage = [UIImage imageWithCGImage:[result thumbnail]];
                                       [thumbnailImages addObject:thumbnailImage];
                                   }
                               }];
    self.thumbnailImages = [thumbnailImages copy];
}

@end
