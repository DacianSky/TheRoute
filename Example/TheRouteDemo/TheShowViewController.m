//
//  TheShowViewController.m
//  TheRouteDemo
//
//  Created by TheMe on 2021/5/13.
//  Copyright © 2021 sdqvsqiu@gmail.com. All rights reserved.
//

#import "TheShowViewController.h"

@interface TheShowViewController ()

@property (nonatomic,strong) UILabel *nameLabel;
@property (nonatomic,strong) UILabel *ageLabel;

@end

@implementation TheShowViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self onStart];
}

- (void)the_configParams
{
    if (!self.name) {
        self.name = @"未传名称参数";
    }
    if (self.age<=0) {
        self.age = MAXFLOAT;
    }
    NSLog(@"param-------->:%@",[[self getIntent] getExtra:@"urlParam"]);
    
    self.view.backgroundColor = UIColor.blackColor;
}

- (void)the_configViews
{
    [self.view addSubview:self.nameLabel];
    [self.view addSubview:self.ageLabel];
}

- (void)the_configConstraints
{
    self.nameLabel.frame = CGRectMake(70, 100, 180, 40);
    self.ageLabel.frame = CGRectMake(70, 200, 180, 40);
}

- (void)the_configDatas
{
    self.nameLabel.text = self.name;
    self.ageLabel.text = [NSString stringWithFormat:@"%ld",(long)self.age];
}

#pragma mark - action
- (UILabel *)nameLabel
{
    if (!_nameLabel) {
        _nameLabel = [[UILabel alloc] init];
        _nameLabel.backgroundColor = UIColor.redColor;
    }
    return _nameLabel;
}

- (UILabel *)ageLabel
{
    if (!_ageLabel) {
        _ageLabel = [[UILabel alloc] init];
        _ageLabel.backgroundColor = UIColor.blueColor;
    }
    return _ageLabel;
}

@end
