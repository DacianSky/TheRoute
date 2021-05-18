//
//  TheForceViewController.m
//  TheRouteDemo
//
//  Created by TheMe on 2021/5/18.
//  Copyright © 2021 sdqvsqiu@gmail.com. All rights reserved.
//

#import "TheForceViewController.h"

@interface TheForceViewController()


@property (nonatomic,strong) UILabel *nameLabel;

@end

@implementation TheForceViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = UIColor.grayColor;
    
    if (!self.name) {
        self.name = @"未传名称参数";
    }
    [self.view addSubview:self.nameLabel];
    self.nameLabel.frame = CGRectMake(70, 100, 300, 40);
    self.nameLabel.text = self.name;
    
    NSLog(@"name:-->%@",self.name);
}

- (UILabel *)nameLabel
{
    if (!_nameLabel) {
        _nameLabel = [[UILabel alloc] init];
        _nameLabel.backgroundColor = UIColor.redColor;
    }
    return _nameLabel;
}

@end
