//
//  JZAssetsCollectionFooterView.m
//  jiangzhi
//
//  Created by Cobb on 15/9/16.
//  Copyright (c) 2015年 kingly. All rights reserved.
//

#import "JZAssetsCollectionFooterView.h"

@interface JZAssetsCollectionFooterView ()

@property (nonatomic, strong, readwrite) ASTextNode *textLabel;

@end

@implementation JZAssetsCollectionFooterView

- (instancetype)init
{
    self = [super init];
    
    if (self) {
        // Create a label
        ASTextNode *textLabel = [[ASTextNode alloc] init];
//        textLabel.font = [UIFont systemFontOfSize:17];
//        textLabel.textColor = [UIColor blackColor];
//        textLabel.textAlignment = NSTextAlignmentCenter;
        
        [self addSubnode:textLabel];
        self.textLabel = textLabel;
    }
    
    return self;
}

- (ASLayoutSpec *)layoutSpecThatFits:(ASSizeRange)constrainedSize
{
    // Layout text label
    self.textLabel.frame = CGRectMake(0,
                                      (self.bounds.size.height - 21.0) / 2.0,
                                      self.bounds.size.width,
                                      21.0);
    
    ASCenterLayoutSpec *center = [[ASCenterLayoutSpec alloc] init];
    center.centeringOptions = ASCenterLayoutSpecCenteringXY;
    center.child = _textLabel;
    UIEdgeInsets insets = UIEdgeInsetsMake(15.0, 15.0, 15.0, 15.0);
    return [ASInsetLayoutSpec insetLayoutSpecWithInsets:insets child:center];
}

@end
