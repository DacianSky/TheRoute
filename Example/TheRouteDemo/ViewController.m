//
//  ViewController.m
//  TheRouteDemo
//
//  Created by TheMe on 2019/1/20.
//  Copyright © 2019 sdqvsqiu@gmail.com. All rights reserved.
//

#import "ViewController.h"
#import <TheRoute/TheRoute.h>

@interface ViewController () <TheRoute>

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [UIViewController startEventWithName:@"123"];
}


@end
