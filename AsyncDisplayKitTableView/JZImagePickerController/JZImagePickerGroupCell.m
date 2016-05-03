//
//  JZImagePickerGroupCell.m
//  jiangzhi
//
//  Created by Cobb on 15/9/16.
//  Copyright (c) 2015年 kingly. All rights reserved.
//

#import "JZImagePickerGroupCell.h"

// Views
#import "JZImagePickerThumbnailView.h"
#import "UIColor+CustomColor.h"
#import "CmdCollect.pch"
#import "UIFont+CustomPS.h"

#import <AsyncDisplayKit/ASTextNode.h>
#import <AsyncDisplayKit/ASInsetLayoutSpec.h>
#import <AsyncDisplayKit/ASImageNode.h>

@interface JZImagePickerGroupCell ()

@property (nonatomic, strong) ASImageNode *thumbnailView;
@property (nonatomic, strong) ASTextNode *nameLabel;
@property (nonatomic, strong) ASTextNode *countLabel;

@end

@implementation JZImagePickerGroupCell

- (instancetype)init
{
    if (!(self = [super init]))
        return nil;
    
    self.selectionStyle = UITableViewCellSelectionStyleDefault;
    self.clipsToBounds = YES;
    
    // Create thumbnail view
    ASImageNode *thumbnailView = [[ASImageNode alloc]init];
    thumbnailView.backgroundColor = [UIColor redColor];
    thumbnailView.frame = CGRectMake(kScreenPx(40.0f), (kCeilScreenPx(222.0f)-(kCeilScreenPx(162.0)+4))/2, kCeilScreenPx(162.0), kCeilScreenPx(162.0)+4);
//    thumbnailView.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleBottomMargin;
    
    [self addSubnode:thumbnailView];
    self.thumbnailView = thumbnailView;
    
    // Create name label
    ASTextNode *nameLabel = [[ASTextNode alloc] init];
    nameLabel.frame = CGRectMake(2*kScreenPx(40.0f) + kCeilScreenPx(162.0), (kCeilScreenPx(222.0)-39)/2, 180, 21);
    nameLabel.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleWidth;
    
    [self addSubnode:nameLabel];
    self.nameLabel = nameLabel;
    
    // Create count label
    ASTextNode *countLabel = [[ASTextNode alloc] init];
    countLabel.frame = CGRectMake(2*kScreenPx(40.0f) + kCeilScreenPx(162.0), nameLabel.frame.origin.y+nameLabel.frame.size.height+3, 180, 15);
    countLabel.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleWidth;
    
    [self addSubnode:countLabel];
    self.countLabel = countLabel;
    
    //底线
    ASDisplayNode *downLine = [[ASDisplayNode alloc]init];
    downLine.frame = CGRectMake(0, kCeilScreenPx(222.0f) - kTableViewCellLineHeight, kScreenWidth, kTableViewCellLineHeight);
    downLine.backgroundColor = [UIColor colorWithHex:kCellLineColor];
    [self addSubnode:downLine];
    
    return self;
}


#pragma mark - Accessors

- (void)setAssetsGroup:(ALAssetsGroup *)assetsGroup
{
    _assetsGroup = assetsGroup;
    
    // Update thumbnail view
    [self loadImages];
    
    // Update label
    self.nameLabel.attributedString = [[NSMutableAttributedString alloc]initWithString:[self.assetsGroup valueForProperty:ALAssetsGroupPropertyName] attributes:@{NSFontAttributeName:[UIFont systemFontOfPx:46.0f],NSForegroundColorAttributeName:[UIColor colorWithHex:0x403836]}];
    self.countLabel.attributedString = [[NSMutableAttributedString alloc]initWithString:[NSString stringWithFormat:@"%ld", (long)self.assetsGroup.numberOfAssets] attributes:@{NSFontAttributeName:[UIFont systemFontOfPx:40.0f],NSForegroundColorAttributeName:[UIColor colorWithHex:0x403836]}];

    [self setNeedsLayout];
}
- (void)loadImages
{
    // Extract three thumbnail images
    NSIndexSet *indexes = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, MIN(3, _assetsGroup.numberOfAssets))];
    NSMutableArray *thumbnailImages = [NSMutableArray array];
    [_assetsGroup enumerateAssetsAtIndexes:indexes
                                  options:0
                               usingBlock:^(ALAsset *result, NSUInteger index, BOOL *stop) {
                                   if (result) {
                                       UIImage *thumbnailImage = [UIImage imageWithCGImage:[result thumbnail]];
                                       [thumbnailImages addObject:thumbnailImage];
                                   }
                               }];
    UIImage *firstImage = [thumbnailImages objectAtIndex:0];
    
    self.thumbnailView.image = firstImage;
}

- (ASLayoutSpec *)layoutSpecThatFits:(ASSizeRange)constrainedSize
{
    UIEdgeInsets insets = UIEdgeInsetsMake(0, kScreenPx(40.0f), 0, kScreenWidth - kCeilScreenPx(222.0));
    return [ASInsetLayoutSpec insetLayoutSpecWithInsets:insets child:_thumbnailView];
}

@end
