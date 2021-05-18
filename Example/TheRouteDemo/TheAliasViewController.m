//
//  TheAliasViewController.m
//  TheRouteDemo
//
//  Created by TheMe on 2021/5/18.
//  Copyright © 2021 sdqvsqiu@gmail.com. All rights reserved.
//

#import "TheAliasViewController.h"

@interface TheAliasViewController ()

@property (nonatomic,strong) UILabel *nameLabel;

@end

@implementation TheAliasViewController

+ (BOOL)theNeedAliasAutoRegister
{
    return YES;
}

+ (NSString *)theClassPrefix
{
    return @"The";
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = UIColor.darkGrayColor;
    NSLog(@"name:-->%@",self.name);
    [self onStart];
}

- (void)the_configParams
{
    if (!self.name) {
        self.name = @"未传名称参数";
    }
    NSLog(@"param-------->:%@",[[self getIntent] getExtra:@"urlParam"]);
    
    self.view.backgroundColor = UIColor.blackColor;
}


- (void)the_configViews
{
    [self.view addSubview:self.nameLabel];
}

- (void)the_configConstraints
{
    self.nameLabel.frame = CGRectMake(70, 100, 300, 40);
}

- (void)the_configDatas
{
    self.nameLabel.text = self.name;
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

@end
