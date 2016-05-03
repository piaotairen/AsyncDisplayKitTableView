//
//  CollectDownView.m
//  jiangzhi
//
//  Created by Cobb on 15/9/22.
//  Copyright © 2015年 kingly. All rights reserved.
//

#import "CollectDownView.h"
#import "UIColor+CustomColor.h"
#import "UIFont+CustomPS.h"
#import "CmdCollect.pch"
#import "JZConsole.h"

#define kMarkLabelHeight kCeilScreenPx(72.0f) //标记label的高度

@interface CollectDownView ()

@property (nonatomic, strong, readwrite) UILabel *textLabel;

@property (nonatomic, strong, readwrite) UIButton *doneButton;

@end

@implementation CollectDownView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        
        //已选择的个数
        UILabel *markLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        markLabel.backgroundColor = [UIColor colorWithHex:0x403836 alpha:0.3];
        markLabel.clipsToBounds = YES;
        markLabel.textAlignment = NSTextAlignmentCenter;
        markLabel.text = @"0";
        markLabel.textColor = [UIColor colorWithHex:0x403836];
        markLabel.font = [UIFont systemFontOfPx:40.0f];
        
        markLabel.layer.cornerRadius = kMarkLabelHeight/2;
        markLabel.layer.shouldRasterize = YES;
        markLabel.layer.borderWidth = 1;
        markLabel.layer.borderColor = [UIColor colorWithHex:0xffffff].CGColor;
        markLabel.backgroundColor = [UIColor colorWithHex:0xffd41b];
        markLabel.layer.borderColor = [UIColor colorWithHex:0xffbf27].CGColor;
        [self addSubview:markLabel];
        self.textLabel = markLabel;
        
        //完成的button按钮
        UIButton *doneBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [doneBtn setTitle:@"完成" forState:UIControlStateNormal];
        [doneBtn setTitleColor:[UIColor colorWithHex:0x403836] forState:UIControlStateNormal];
        [doneBtn addTarget:self action:@selector(doneButtonClick) forControlEvents:UIControlEventTouchUpInside];
        doneBtn.frame = CGRectZero;
        [self addSubview:doneBtn];
        self.doneButton = doneBtn;
    }
    
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGSize btnSize = [self.doneButton.titleLabel sizeThatFits:CGSizeMake(kScreenWidth, 20)];
    
    
    
    self.doneButton.frame = CGRectMake(kScreenWidth - btnSize.width - kScreenPx(40.0f),
                                       (self.bounds.size.height - kMarkLabelHeight) / 2.0,
                                       btnSize.width,
                                       kMarkLabelHeight);
    
    // Layout text label
    self.textLabel.frame = CGRectMake(kScreenWidth - btnSize.width - kScreenPx(40.0f)-kScreenPx(20.0f)-kMarkLabelHeight,
                                      (self.bounds.size.height - kMarkLabelHeight) / 2.0,
                                      kMarkLabelHeight,
                                      kMarkLabelHeight);
    
}

/**
 * 更新标记数
 */
-(void)updateMarkText
{
    int allIndex = [[JZConsole mainConsole]numOfSelectedElements];
    self.textLabel.text = [NSString stringWithFormat:@"%d",allIndex];
}

/**
 * 设置按钮点击
 */
-(void)doneButtonClick
{
    if (_myDelegate && [_myDelegate respondsToSelector:@selector(clickSelectedDone)]) {
        [_myDelegate clickSelectedDone];
    }
}

@end
