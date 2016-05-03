//
//  JZConsole.m
//  JZImagePickerDemo
//
//  Created by Seamus on 14-7-11.
//  Copyright (c) 2014年 JZ Technologies. All rights reserved.
//

#import "JZConsole.h"

static JZConsole *_mainconsole;

@implementation JZConsole
{
    NSMutableArray *myIndex;
}


+ (JZConsole *)mainConsole
{
    if (!_mainconsole) {
        _mainconsole = [[JZConsole alloc] init];
    }
    return _mainconsole;
}

- (id)init
{
    self = [super init];
    if (self) {
        myIndex = [[NSMutableArray alloc] init];
        self.assetUrlDic = [[NSMutableDictionary alloc]init];
    }
    return self;
}

- (void)dealloc
{
    myIndex = nil;
    _mainconsole = nil;
}

- (void)addIndex:(int)index
{
    if (![myIndex containsObject:@(index)]) {
        [myIndex addObject:@(index)];
    }
}

- (void)removeIndex:(int)index
{
    [myIndex removeObject:@(index)];
}

- (void)removeAllIndex
{
    [myIndex removeAllObjects];
    
    [self.assetUrlDic removeAllObjects];
}

- (int)currIndex
{
    [myIndex sortUsingSelector:@selector(compare:)];
    
    for (int i = 0; i < [myIndex count]; i++) {
        int c = [[myIndex objectAtIndex:i] intValue];
        if (c != i) {
            return i;
        }
    }
    return (int)[myIndex count];
}

/**
 * 通过collectionView的item得到当前标记
 */
-(NSUInteger)indexForItem:(NSInteger)item
{
    return [myIndex indexOfObject:@(item)];
}

- (int)numOfSelectedElements {
    
    return (int)[myIndex count];
}

@end
