//
//  CollectDownView.h
//  jiangzhi
//
//  Created by Cobb on 15/9/22.
//  Copyright © 2015年 kingly. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol selectedDoneDelegate;

@interface CollectDownView : UIView

/**
 * 更新标记数
 */
-(void)updateMarkText;

@property (nonatomic,weak) id <selectedDoneDelegate> myDelegate;

@end


/**
 * 图片选择完成的协议
 */
@protocol selectedDoneDelegate <NSObject>

/**
 * 点击了完成按钮
 */
-(void)clickSelectedDone;

@end
