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
#import "TheForceViewController.h"

#define kRouteEventExecName(name) [NSString stringWithFormat:@"event://%@",name]

#define kRouteEventTest @"testEventRoute"
#define kBlockRoute @"kBlockRoute"

@interface ViewController () <TheRoute>

@end

@implementation ViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    
    routeAliasRegister; // 自动注册该macho文件内所有实现TheIntentProtocol协议类的短路由，初始化时调用；短路由使用方法见@selector(aliasRouteUrl)
    
    [TheForceViewController registeToIntentProtocol];   // 给TheForceViewController类添加协议TheIntentProtocol，配合IntentParamOccasionForce以用于传递参数。只需要添加一次。
    
    __weak typeof(self) _self = self;
    [self addEvent:kRouteEventTest withAction:^id(NSDictionary *param) {
        NSLog(@"route event success");
        
        TheShowViewController *vc = [[TheShowViewController alloc] init];
        vc.age = 100;
        vc.name = param[@"name"];
        [_self.navigationController pushViewController:vc animated:YES];
        return nil;
    }];
    
    [UIViewController registeRoute:kBlockRoute object:^id(){
        NSLog(@"route block success");
        return [TheShowViewController new];
    }];
}

- (IBAction)routeUrl:(id)sender
{
    [self normalRouteUrl];
}

- (IBAction)routeEvent:(id)sender
{
    [self routeEvent];
}

- (IBAction)routeForce:(id)sender
{
    [self forceRouteUrl];
}

- (IBAction)routeAlias:(id)sender
{
    [self aliasRouteUrl];
}

- (IBAction)routeBlock:(id)sender
{
    [self blockRouteUrl];
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

- (void)normalRouteUrl
{
    Intent *intent = [Intent intentWithRouteName:@"TheShowViewController?urlParam=TheMeUrlParam"];
    [intent putExtra:@"name" value:@"Name: routeUrl"];
    [intent putExtra:@"age" value:@(18)];
    [self startViewControllerForResult:intent];
}

- (void)routeEvent
{
    NSString *eventRouteName = kRouteEventExecName(kRouteEventTest);
    Intent *intent = [Intent intentWithRouteName:eventRouteName];
    [intent putExtra:@"name" value:@"Name: routeEvent"];
    [self startViewController:intent];
}

- (void)forceRouteUrl
{
    Intent *intent = [Intent intentWithRouteName:@"TheForceViewController?urlParam=TheMeUrlParam"];
    intent.paramOccasion = IntentParamOccasionForce;
    [intent putExtra:@"name" value:@"Name: TheForceViewController->forceRouteUrl"];
    [self startViewControllerForResult:intent];
}

- (void)aliasRouteUrl
{
    Intent *intent = [Intent intentWithRouteName:@"alias"];
    [intent putExtra:@"name" value:@"Name: TheAliasViewController->aliasRouteUrl"];
    [self startViewControllerForResult:intent];
}

- (void)blockRouteUrl
{
    Intent *intent = [Intent intentWithRouteName:kBlockRoute];
    [intent putExtra:@"name" value:@"Name: routeBlock"];
    [intent putExtra:@"age" value:@(123456)];
    [self startViewControllerForResult:intent];
}

@end
