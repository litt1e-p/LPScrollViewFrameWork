//
//  LPListViewController.m
//  LPScrollView
//
//  Created by litt1e-p on 15/9/5.
//  Copyright (c) 2015年 litt1e-p. All rights reserved.
//

#import "LPListViewController.h"

@interface LPListViewController ()

@end

@implementation LPListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)setCategoryName:(NSString *)categoryName
{
    _categoryName = categoryName;
    UILabel *nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(150, 200, 320, 44)];
    nameLabel.text = categoryName;
    nameLabel.font = [UIFont systemFontOfSize:18];
    nameLabel.textColor = [UIColor blackColor];
    [self.view addSubview:nameLabel];
}

@end