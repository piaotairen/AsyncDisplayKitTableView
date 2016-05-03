//
//  JZAssetsCollectionViewLayout.m
//  jiangzhi
//
//  Created by Cobb on 15/9/16.
//  Copyright (c) 2015年 kingly. All rights reserved.
//

#import "JZAssetsCollectionViewLayout.h"

@implementation JZAssetsCollectionViewLayout

+ (instancetype)layout
{
    return [[self alloc] init];
}

- (instancetype)init
{
    self = [super init];
    
    if (self) {
        self.minimumLineSpacing = 2.0;
        self.minimumInteritemSpacing = 2.0;
    }
    
    return self;
}

@end
