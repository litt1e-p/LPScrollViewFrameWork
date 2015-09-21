//
//  LPMainViewController.h
//
//  Created by litt1e-p on 15/8/22.
//  Copyright (c) 2015年 litt1e-p. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LPMenuView.h"

@interface LPMainViewController : UIViewController

- (void)loadVc:(NSArray *)viewControllers selectIndex:(int)index andCategories:(NSArray *)categories;

@end
