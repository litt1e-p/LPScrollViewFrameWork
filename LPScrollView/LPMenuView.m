//
//  LPMenuView.m
//  LPScrollView
//
//  Created by litt1e-p on 15/8/25.
//  Copyright (c) 2015年 litt1e-p. All rights reserved.
//

#import "LPMenuView.h"
#import "LPMenuBtn.h"
#import "NSString+Extension.h"
#import "UIView+Extension.h"

#define BtnMargin 8

@interface LPMenuView()<UIScrollViewDelegate>


@property (nonatomic, weak) LPMenuBtn *selectedBtn;
@property (nonatomic, assign) CGFloat sumWidth;

@end

@implementation LPMenuView

- (instancetype)initWithMenuViewTitles:(NSArray *)titles
{
    if (self = [super init]) {
        [self loadScrollViewAndBtnWithTitles:titles];
    }
    return self;
}

- (void)loadScrollViewAndBtnWithTitles:(NSArray *)titles
{
    UIScrollView *navMenuScrollView = [[UIScrollView alloc] init];
    navMenuScrollView.showsVerticalScrollIndicator = NO;
    navMenuScrollView.showsHorizontalScrollIndicator = NO;
    navMenuScrollView.backgroundColor = [UIColor whiteColor];
    navMenuScrollView.delegate = self;
    self.navMenuScrollView = navMenuScrollView;
    [self addSubview:self.navMenuScrollView];
    
    for (int i = 0; i < titles.count; i++) {
        LPMenuBtn *btn = [[LPMenuBtn alloc] initWithTitle:titles[i] andIndex:i];
        btn.tag = i;
        [btn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
        btn.titleLabel.textColor = [UIColor blackColor];
        [self.navMenuScrollView addSubview:btn];
    }
}

- (void)layoutSubviews
{
    for (NSInteger i = 0; i < self.navMenuScrollView.subviews.count; i++) {
        LPMenuBtn *currentBtn = self.navMenuScrollView.subviews[i];
        LPMenuBtn *prevBtn = i >= 1 ? (LPMenuBtn *)self.navMenuScrollView.subviews[i - 1] : [[LPMenuBtn alloc] init];
        currentBtn.width = [currentBtn.titleLabel.text sizeWithfont:currentBtn.titleLabel.font].width + 2 * BtnMargin;
        currentBtn.x = prevBtn.x + prevBtn.width + BtnMargin;
        currentBtn.y = 0;
        currentBtn.height = self.height - BtnMargin * 0.25;
        self.sumWidth += currentBtn.width;
    }
    self.navMenuScrollView.size = CGSizeMake(self.bounds.size.width, self.bounds.size.height);
    LPMenuBtn *lastBtn = [self.navMenuScrollView.subviews lastObject];
    self.navMenuScrollView.contentSize = CGSizeMake(CGRectGetMaxX(lastBtn.frame) + BtnMargin, 0);
    self.navMenuScrollView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0);
}

- (void)btnClick:(LPMenuBtn *)btn
{
    if (self.selectedBtn == btn) {
        return;
    }
    [self resetSelectedBtn:btn.tag];
    if ([self.delegate respondsToSelector:@selector(menuViewBtnDidClickAtIndex:)]) {
        [self.delegate menuViewBtnDidClickAtIndex:btn.tag];
    }
}

- (void)selectedBtnMoveToCenterWithIndex:(NSInteger)index withRate:(CGFloat)pageRate
{
    NSString *notiName = [NSString stringWithFormat:@"scrollViewDidFinished%@", self];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(move:) name:notiName object:nil];
    
    int page = (int)(pageRate + 0.5);
    CGFloat rate = pageRate - index;
    int count = (int)self.navMenuScrollView.subviews.count;
    if (pageRate < 0 || rate == 0 || index >= count - 1) {
        return;
    }
    self.selectedBtn.selected = NO;
    LPMenuBtn *currentBtn = self.navMenuScrollView.subviews[index];
    LPMenuBtn *nextBtn = self.navMenuScrollView.subviews[index + 1];
    [currentBtn changeSelectedColorAndScaleWithRate:rate];
    [nextBtn changeSelectedColorAndScaleWithRate:1 - rate];
    self.selectedBtn = self.navMenuScrollView.subviews[page];
    self.selectedBtn.selected = YES;
}

- (void)move:(NSNotification *)info
{
    NSNumber *index = info.userInfo[@"index"];
    [self moveViewWithIndex:[index intValue]];
}

- (void)moveViewWithIndex:(NSInteger)index
{
    LPMenuBtn *btn = self.navMenuScrollView.subviews[index];
    CGRect newFrame = [btn convertRect:self.bounds toView:nil];
    CGFloat distance = newFrame.origin.x - self.center.x;
    CGFloat scrollOffsetX = self.navMenuScrollView.contentOffset.x;
    int count = (int)self.navMenuScrollView.subviews.count;
    if (index > count - 1) {
        return;
    }
    CGFloat contentOffsetX = self.navMenuScrollView.contentOffset.x + btn.x > self.center.x ? scrollOffsetX + distance + btn.width - BtnMargin * 4 : 0;
    [self.navMenuScrollView setContentOffset:CGPointMake(contentOffsetX, 0) animated:YES];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (scrollView.contentOffset.x <= 0) {
        [scrollView setContentOffset:CGPointMake(0, 0)];
    } else if (scrollView.contentOffset.x + self.width >= scrollView.contentSize.width) {
        [scrollView setContentOffset:CGPointMake(scrollView.contentSize.width - self.width, 0)];
    }
}

- (void)resetSelectedBtn:(NSInteger)tag
{
    [self.selectedBtn deselectedItemWithoutAnimation];
    for (LPMenuBtn *btn in self.navMenuScrollView.subviews) {
        if (btn.tag == tag) {
            btn.selected = YES;
            self.selectedBtn = btn;
        } else {
            btn.selected = NO;
        }
    }
    [self moveViewWithIndex:self.selectedBtn.tag];
    [self.selectedBtn selectedItemWithoutAnimation];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
