//
//  JZAssetsCollectionOverlayView.m
//  jiangzhi
//
//  Created by Cobb on 15/9/16.
//  Copyright (c) 2015年 kingly. All rights reserved.
//

#import "JZAssetsCollectionOverlayView.h"
#import <QuartzCore/QuartzCore.h>

// Views
#import "JZAssetsCollectionCheckmarkView.h"

@interface JZAssetsCollectionOverlayView ()

@property (nonatomic, strong) JZAssetsCollectionCheckmarkView *checkmarkView;

@end

@implementation JZAssetsCollectionOverlayView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self) {
        // View settings
        self.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.4];
        self.onOrder = NO;//默认计数打开
        
        // Create a checkmark view
        JZAssetsCollectionCheckmarkView *checkmarkView = [[JZAssetsCollectionCheckmarkView alloc] initWithFrame:CGRectMake(self.bounds.size.width - (4.0 + 24.0), self.bounds.size.height - (4.0 + 24.0), 24.0, 24.0)];
        checkmarkView.autoresizingMask = UIViewAutoresizingNone;
        
        checkmarkView.layer.shadowColor = [[UIColor grayColor] CGColor];
        checkmarkView.layer.shadowOffset = CGSizeMake(0, 0);
        checkmarkView.layer.shadowOpacity = 0.6;
        checkmarkView.layer.shadowRadius = 2.0;
        
        [self addSubview:checkmarkView];
        self.checkmarkView = checkmarkView;
        
        //添加计数lable
        if (self.onOrder) {
            self.labIndex = [[UILabel alloc] initWithFrame:CGRectMake(5, 5, 16, 16)];
            self.labIndex.backgroundColor = [UIColor redColor];
            self.labIndex.clipsToBounds = YES;
            self.labIndex.textAlignment = NSTextAlignmentCenter;
            self.labIndex.textColor = [UIColor whiteColor];
            self.labIndex.layer.cornerRadius = 8;
            self.labIndex.layer.shouldRasterize = YES;
            //        self.labIndex.layer.borderWidth = 1;
            //        self.labIndex.layer.borderColor = [UIColor greenColor].CGColor;
            self.labIndex.font = [UIFont boldSystemFontOfSize:13];
            [self addSubview:self.labIndex];
        }
    }
    
    return self;
}

- (void)dealloc
{
    self.labIndex = nil;
}

- (void)setIndex:(int)_index
{
    self.labIndex.text = [NSString stringWithFormat:@"%d",_index];
}

@end
