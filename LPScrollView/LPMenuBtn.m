//
//  LPMenuBtn.m
//  LPScrollView
//
//  Created by litt1e-p on 15/8/25.
//  Copyright (c) 2015年 litt1e-p. All rights reserved.
//

#import "LPMenuBtn.h"
#define DefaultRate 1.5

@implementation LPMenuBtn

- (UIColor *)selectedColor
{
    if (!_selectedColor) {
        _selectedColor = [UIColor redColor];
    }
    return _selectedColor;
}

- (UIColor *)normalColor
{
    if (!_normalColor) {
        _normalColor = [UIColor darkGrayColor];
    }
    return _normalColor;
}

- (void)setSelected:(BOOL)selected
{
    [super setSelected:selected];
    if (selected) {
        [self setTitleColor:self.selectedColor forState:UIControlStateNormal];
    } else {
        [self setTitleColor:self.normalColor forState:UIControlStateNormal];
    }
}

- (CGFloat)normalSize
{
    if (!_normalSize) {
        _normalSize = 13;
    }
    return _normalSize;
}

- (CGFloat)rate
{
    if (!_rate) {
        _rate = DefaultRate;
    }
    return _rate;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self.titleLabel setFont:[UIFont systemFontOfSize:self.normalSize]];
        [self setTitleColor:self.normalColor forState:UIControlStateNormal];
    }
    return self;
}

- (instancetype)initWithTitle:(NSString *)title andIndex:(NSInteger)index
{
    if (self = [super init]) {
        [self setTitle:title forState:UIControlStateNormal];
    }
    return self;
}

- (void)selectedItemWithoutAnimation
{
    self.selected = YES;
    [UIView animateWithDuration:0.3 animations:^{
        self.transform = CGAffineTransformMakeScale(self.rate, self.rate);
    }];
}

- (void)deselectedItemWithoutAnimation
{
    self.selected = NO;
    [UIView animateWithDuration:0.3 animations:^{
        self.transform = CGAffineTransformIdentity;
    }];
}

-(void)changeSelectedColorWithRate:(CGFloat)rate
{
    
}

- (void)changeSelectedColorAndScaleWithRate:(CGFloat)rate
{
    [self changeSelectedColorWithRate:rate];
    CGFloat scaleRate = self.rate - rate * (self.rate - 1);
    self.transform = CGAffineTransformMakeScale(scaleRate, scaleRate);
}

@end
