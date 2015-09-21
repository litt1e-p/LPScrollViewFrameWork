//
//  LPMainViewController.m
//
//  Created by litt1e-p on 15/8/22.
//  Copyright (c) 2015年 litt1e-p. All rights reserved.
//

#import "LPMainViewController.h"
#import "UIView+Extension.h"
#import "NSString+Extension.h"
#import "LPListViewController.h"
#import "LPMenuBtn.h"

#define KeyWindow [UIApplication sharedApplication].keyWindow
#define ScreenWidth [UIScreen mainScreen].bounds.size.width
#define ScreenHeight [UIScreen mainScreen].bounds.size.height

@interface LPMainViewController ()<UIScrollViewDelegate, LPMenuViewDelegate, NSCacheDelegate, UIGestureRecognizerDelegate>

@property (nonatomic, weak) LPMenuView *navMenuView;
@property (nonatomic, strong) UIScrollView *detailScrollView;
@property (nonatomic, copy) NSArray *subviewControllers;
@property (nonatomic, strong) NSMutableArray *controllerFrames;
@property (nonatomic, weak) LPListViewController *selectedViewController;
@property (nonatomic, strong) NSMutableArray *titles;
@property (nonatomic, assign) int selectedIndex;
@property (nonatomic, strong) NSCache *controllerCache;
@property (nonatomic, assign) NSInteger countLimit;



@end

@implementation LPMainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"LPScrollView";
    
}

- (void)loadVc:(NSArray *)viewControllers selectIndex:(int)index andCategories:(NSArray *)categories
{
    self.countLimit = categories.count;
    self.selectedIndex = index;
    self.subviewControllers = viewControllers;
    for (NSString *cate in categories) {
        [self.titles addObject:cate];
    }
    LPMenuView *navMenuView = [[LPMenuView alloc] initWithMenuViewTitles:self.titles];
    [self.view addSubview:navMenuView];
    navMenuView.delegate = self;
    self.navMenuView = navMenuView;
}

- (void)viewWillLayoutSubviews
{
    CGFloat navMenuHeight = 25;
    CGFloat height = self.view.height - navMenuHeight;
    [super viewWillLayoutSubviews];
    for (int i = 0; i < self.subviewControllers.count; i++) {
        CGFloat x = i * ScreenWidth;
        CGRect frame = CGRectMake(x, 0, ScreenWidth, height);
        [self.controllerFrames addObject:[NSValue valueWithCGRect:frame]];
    }
    self.navMenuView.frame = CGRectMake(0, 64, ScreenWidth, navMenuHeight);
    CGFloat detailScrollViewY = CGRectGetMaxY(self.navMenuView.frame);
    self.detailScrollView.frame = CGRectMake(0, detailScrollViewY, ScreenWidth, ScreenHeight - detailScrollViewY);
    self.detailScrollView.contentSize = CGSizeMake(self.subviewControllers.count * self.detailScrollView.width, 0);
    self.detailScrollView.bounces = NO;
    
    [self postNofi2NavMenuView:self.selectedIndex];
    self.detailScrollView.contentOffset = CGPointMake(ScreenWidth * self.selectedIndex, detailScrollViewY);
    
    [self.navMenuView resetSelectedBtn:self.selectedIndex];
    
    [self addViewControllerViewAtIndex:self.selectedIndex];
}

- (void)addViewControllerViewAtIndex:(NSUInteger)index
{
    LPListViewController *listVc = [self getCacheListVcAtIndex:index];
    if (!listVc) {
        Class vClass = self.subviewControllers[index];
        listVc = [[vClass alloc] init];
        listVc.view.frame = [self.controllerFrames[index] CGRectValue];
        [self addChildViewController:listVc];
        [self.detailScrollView addSubview:listVc.view];
        [self cacheListVc:listVc AtIndex:index];
        [self doSelectListVc:listVc AtIndex:index];
    }
}

- (void)cacheListVc:(LPListViewController *)listVc AtIndex:(NSUInteger)index
{
    LPListViewController *cachelistVc = [self getCacheListVcAtIndex:index];
    if (cachelistVc == listVc) {
        return;
    }
    [self.controllerCache setObject:listVc forKey:@(index)];
}

- (LPListViewController *)getCacheListVcAtIndex:(NSUInteger)index
{
    LPListViewController *listVc = [self.controllerCache objectForKey:@(index)];
    if (listVc) {
        [self doSelectListVc:listVc AtIndex:index];
    }
    return listVc;
}

- (void)doSelectListVc:(LPListViewController *)listVc AtIndex:(NSUInteger)index
{
    self.selectedIndex = (int)index;
    self.selectedViewController = listVc;
    self.selectedViewController.categoryName = self.titles[index];
}

#pragma mark - scrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    CGFloat rate = scrollView.contentOffset.x / self.view.width;
    int index = (int)rate;
    [self.navMenuView selectedBtnMoveToCenterWithIndex:index withRate:rate];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    if (scrollView.contentOffset.x < 0 || scrollView.contentOffset.x > scrollView.contentSize.width) {
        return;
    }
    int page = (int)(scrollView.contentOffset.x / self.view.width);
    LPListViewController *listVc = [self getCacheListVcAtIndex:page];
    if (!listVc) {
        [self addViewControllerViewAtIndex:page];
    }
    [self postNofi2NavMenuView:page];
}

- (void)postNofi2NavMenuView:(int)index
{
    NSString *notiName = [NSString stringWithFormat:@"scrollViewDidFinished%@", self.navMenuView];
    NSDictionary *info = @{@"index" : @(index)};
    [[NSNotificationCenter defaultCenter] postNotificationName:notiName object:nil userInfo:info];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if (scrollView.contentOffset.x < 0 || scrollView.contentOffset.x > scrollView.contentSize.width) {
        return;
    }
    if (!decelerate) {
        int page = (int)(scrollView.contentOffset.x / ScreenWidth);
        [self.navMenuView resetSelectedBtn:page];
    }
}

#pragma mark - nav menuView click Delegate
- (void)menuViewBtnDidClickAtIndex:(NSUInteger)index
{
    self.detailScrollView.contentOffset = CGPointMake(index * ScreenWidth, 0);
    
    self.selectedIndex = (int)index;
    LPListViewController *listVc = [self getCacheListVcAtIndex:index];
    if (!listVc) {
        [self addViewControllerViewAtIndex:index];
    }
}

#pragma mark - Recognize gestureRecognizer Simultaneously
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    if ([gestureRecognizer isKindOfClass:[UIScreenEdgePanGestureRecognizer class]]) {
        return YES;
    }
    return NO;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldBeRequiredToFailByGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    return [gestureRecognizer isKindOfClass:[UIScreenEdgePanGestureRecognizer class]];
}

- (BOOL)isInScreen:(CGRect)frame
{
    CGFloat x = frame.origin.x;
    CGFloat scrollerViewWidth = self.detailScrollView.width;
    CGFloat contentOffsetX = self.detailScrollView.contentOffset.x;
    return CGRectGetMaxX(frame) > contentOffsetX && x - contentOffsetX < scrollerViewWidth ? YES : NO;
}

- (NSArray *)titles
{
    if (!_titles) {
        self.titles = [NSMutableArray array];
    }
    return _titles;
}

- (NSArray *)subviewControllers
{
    if (!_subviewControllers) {
        self.subviewControllers = [NSMutableArray array];
    }
    return _subviewControllers;
}

- (UIScrollView *)detailScrollView
{
    if (!_detailScrollView) {
        self.detailScrollView = [[UIScrollView alloc] init];
        self.detailScrollView.backgroundColor = [UIColor whiteColor];
        self.detailScrollView.pagingEnabled = YES;
        self.detailScrollView.delegate = self;
        [self.view addSubview:self.detailScrollView];
    }
    return _detailScrollView;
}

- (NSMutableArray *)controllerFrames
{
    if (!_controllerFrames) {
        self.controllerFrames = [NSMutableArray array];
    }
    return _controllerFrames;
}

- (NSCache *)controllerCache
{
    if (!_controllerCache) {
        self.controllerCache = [[NSCache alloc] init];
        self.controllerCache.countLimit = self.countLimit ? : 4;
        self.controllerCache.totalCostLimit = self.titles.count ? : 4;
    }
    return _controllerCache;
}


@end