//
//  ViewController.m
//  TheRouteDemo
//
//  Created by TheMe on 2019/1/20.
//  Copyright © 2019 sdqvsqiu@gmail.com. All rights reserved.
//

#import "ViewController.h"
#import <TheRoute/TheRoute.h>
#import "TheShowViewController.h"

#define kRouteEventExecName(name) [NSString stringWithFormat:@"event://%@",name]

#define kRouteEventTest @"testEventRoute"

@interface ViewController () <TheRoute>

@end

@implementation ViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    
    __weak typeof(self) _self = self;
    [self addEvent:kRouteEventTest withAction:^id(NSDictionary *param) {
        NSLog(@"route success");
        
        TheShowViewController *vc = [[TheShowViewController alloc] init];
        vc.age = 100;
        vc.name = param[@"name"];
        [_self.navigationController pushViewController:vc animated:YES];
        return nil;
    }];
}

- (IBAction)routeUrl:(id)sender
{
    Intent *intent = [Intent intentWithRouteName:@"TheShowViewController?urlParam=TheMeUrlParam"];
    [intent putExtra:@"name" value:@"Name: routeUrl"];
    [intent putExtra:@"age" value:@(18)];
    [self startViewControllerForResult:intent];
}

- (IBAction)routeEvent:(id)sender
{
    NSString *eventName = kRouteEventExecName(kRouteEventTest);
    Intent *intent = [Intent intentWithRouteName:eventName];
    [intent putExtra:@"name" value:@"Name: routeEvent"];
    [self startViewController:intent];
}

- (void)onViewControllerResult:(Intent *)intent
{
    NSLog(@"result:%@",[intent extras]);
}

- (void)dealloc
{
    [self removeEvent:@"testEventRoute"];
}

#pragma mark - action
- (void)testEvent
{
    // 事件
    [UIViewController addEvent:@"testEvent" withAction:^id(NSDictionary *param) {
        NSLog(@"event success");
        return nil;
    }];
    [UIViewController startEventWithName:@"testEvent"];
    [UIViewController removeEvent:@"testEvent"];
}

@end
