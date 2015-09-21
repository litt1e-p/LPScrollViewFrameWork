//
//  LPMenuBtn.h
//  LPScrollView
//
//  Created by litt1e-p on 15/8/25.
//  Copyright (c) 2015年 litt1e-p. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LPMenuBtn : UIButton

@property (nonatomic, copy) NSString *fontName;
@property (nonatomic, assign) CGFloat fontSize;
@property (nonatomic, assign) CGFloat normalSize;
@property (nonatomic, assign) CGFloat rate;
@property (nonatomic, weak) UIColor *normalColor;
@property (nonatomic, weak) UIColor *selectedColor;
@property (nonatomic, weak) UIColor *titleColor;

- (instancetype)initWithTitle:(NSString *)title andIndex:(NSInteger)index;
- (void)selectedItemWithoutAnimation;
- (void)deselectedItemWithoutAnimation;
- (void)changeSelectedColorWithRate:(CGFloat)rate;
- (void)changeSelectedColorAndScaleWithRate:(CGFloat)rate;

@end
