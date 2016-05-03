//
//  JZAssetsCollectionViewCell.m
//  jiangzhi
//
//  Created by Cobb on 15/9/16.
//  Copyright (c) 2015年 kingly. All rights reserved.
//

#import "JZAssetsCollectionViewCell.h"
#import "CmdCollect.pch"
#import <Photos/PHImageManager.h>
#import "SDWebImageCompat.h"
#import "UIImageView+WebCache.h"
#import "UIView+WebCacheOperation.h"
#import "UIColor+CustomColor.h"
#import "UIFont+CustomPS.h"

#import <AsyncDisplayKit/ASDisplayNode+Subclasses.h>
#import <AsyncDisplayKit/ASInsetLayoutSpec.h>
#import <AsyncDisplayKit/ASCenterLayoutSpec.h>
#import <AsyncDisplayKit/AsyncDisplayKit.h>


#define kMarkLabelHeight kCeilScreenPx(72.0f) //标记label的高度
#define kMarkLabelMargin 4.0f //标记label离右下边的间隙

@interface JZAssetsCollectionViewCell ()

@property (nonatomic, strong) ASImageNode *imageView;

@property (nonatomic,strong) ASTextNode *markLabel;

@end


@implementation JZAssetsCollectionViewCell

- (instancetype)init
{
    self = [super init];
    if (self != nil) {
        self.showsOverlayViewWhenSelected = YES;
        
        // Create a image view
        self.imageView = [[ASImageNode alloc] init];
        self.imageView.frame = CGRectMake(0, 0, 100, 30);
        self.imageView.backgroundColor = [UIColor yellowColor];
//        self.imageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
//        self.imageView.contentMode = UIViewContentModeScaleAspectFit;
        [self addSubnode:self.imageView];
        
        [self addMarkLabel];//添加标记圆圈
    }
    
    return self;
}

/**
 * 添加标记圆圈
 */
-(void)addMarkLabel
{
    // Create a checkmark view
    self.markLabel = [[ASTextNode alloc] init];
    self.markLabel.frame = CGRectMake(self.bounds.size.width - (kMarkLabelMargin + kMarkLabelHeight), self.bounds.size.height - (kMarkLabelMargin + kMarkLabelHeight), kMarkLabelHeight, kMarkLabelHeight);
    self.markLabel.backgroundColor = [UIColor colorWithHex:0x403836 alpha:0.3];
    self.markLabel.clipsToBounds = YES;
    //    self.markLabel.tex = NSTextAlignmentCenter;
    //    self.markLabel.textColor = [UIColor colorWithHex:0x403836];
    //    self.markLabel.font = [UIFont systemFontOfPx:40.0f];
    
    self.markLabel.layer.cornerRadius = kMarkLabelHeight/2;
    self.markLabel.layer.shouldRasterize = YES;
    self.markLabel.layer.borderWidth = 1;
    self.markLabel.layer.borderColor = [UIColor colorWithHex:0xffffff].CGColor;
    
    //    self.markLabel.layer.shadowColor = [[UIColor grayColor] CGColor];
    //    self.markLabel.layer.shadowOffset = CGSizeMake(0, 0);
    //    self.markLabel.layer.shadowOpacity = 0.6;
    //    self.markLabel.layer.shadowRadius = 2.0;
    
    [self addSubnode:self.markLabel];
}


/**
 * 更新标记label的位置
 */
-(void)updateMarkLabelIndex:(NSInteger)index
{
    self.markLabel.attributedString = [[NSMutableAttributedString alloc]initWithString:[NSString stringWithFormat:@"%ld",(long)index] attributes:@{NSFontAttributeName:[UIFont systemFontOfPx:40.0f],NSForegroundColorAttributeName:[UIColor colorWithHex:0x403836]}] ;
}


- (void)setSelected:(BOOL)selected
{
    [super setSelected:selected];
    
    // Show/hide overlay view
    if (selected && self.showsOverlayViewWhenSelected) {
        //        [self hideOverlayView];
        //        [self showOverlayView];
        
        self.markLabel.backgroundColor = [UIColor colorWithHex:0xffd41b];
        self.markLabel.layer.borderColor = [UIColor colorWithHex:0xffbf27].CGColor;
    } else {
        //        [self hideOverlayView];
        
        self.markLabel.backgroundColor = [UIColor colorWithHex:0x403836 alpha:0.3];
        self.markLabel.layer.borderColor = [UIColor colorWithHex:0xffffff].CGColor;
        self.markLabel.attributedString = nil;
    }
}


- (ASLayoutSpec *)layoutSpecThatFits:(ASSizeRange)constrainedSize
{
    ASCenterLayoutSpec *center = [[ASCenterLayoutSpec alloc] init];
    center.centeringOptions = ASCenterLayoutSpecCenteringY;
    center.child = _imageView;
    UIEdgeInsets insets = UIEdgeInsetsMake(0, 0, 0, 0);
    return [ASInsetLayoutSpec insetLayoutSpecWithInsets:insets child:center];
}


/**
 * 展示勾选标记
 */
- (void)showOverlayView
{
//    JZAssetsCollectionOverlayView *overlayView = [[JZAssetsCollectionOverlayView alloc] initWithFrame:self.contentView.bounds];
//    overlayView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
//    
//    [self addSubview:overlayView];
//    self.overlayView = overlayView;
}
/**
 * 去除勾选标记
 */
- (void)hideOverlayView
{
//    [self.overlayView removeFromSuperview];
//    self.overlayView = nil;
}


#pragma mark - Accessors

- (void)setAsset:(ALAsset *)asset
{
    _asset = asset;
    
    //全图
    //    UIImage *resolutionImage = [UIImage imageWithCGImage:[[asset defaultRepresentation]fullResolutionImage]];
    
    // 缩略图
    //        UIImage *thumbnailImage = [UIImage imageWithCGImage:[asset thumbnail]];
    
    // 合适比例缩略图
    //    UIImage *aspectImage = [UIImage imageWithCGImage:[asset aspectRatioThumbnail]];
    
    
    UIImage *thumbnailImage = [UIImage imageWithCGImage:[asset thumbnail]];
    self.imageView.image = thumbnailImage;
    
    [self setNeedsLayout];
}


/**
 * cell显示时切换为高清图片
 */
-(void)UpdatePicture
{
    if (_asset) {
        __weak __typeof(self)wself = self;
        UIImage *aspectImage = [UIImage imageWithCGImage:[_asset aspectRatioThumbnail]];
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
            
            UIImage *resizeImage = [aspectImage imageCompressForSize:CGSizeMake((kScreenWidth-2*5)/2, (kScreenWidth-2*5)/2)];
            
            wself.imageView.image = resizeImage;
        });
    }
}




/**
 * cell不显示时取消图片的切换
 */
-(void)cancelPictureLoad
{
    ;
}

@end
