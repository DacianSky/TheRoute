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

#define kTestGroupEvent @"TestGroupEvent"

@interface ViewController () <TheRoute>

@property (weak, nonatomic) IBOutlet UIButton *groupEventBtn;

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
    
    [self addGroupEvent];
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

- (IBAction)groupEvent:(id)sender
{   // 批量处理事件
    [self startEventWithName:@"GroupEvent"];    // 单条执行组事件中某事件
    [self startGroupEvent:kTestGroupEvent];     // 执行组事件
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self startGroupEvent:kTestGroupEvent withParam:@{@"title":@"批量事件"}];     // 执行带参数组事件
    });
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(10 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self startEventWithName:@"GroupEvent" withParam:@{@"title":@"单条事件"}];    // 执行单参数事件
        [self removeGroupEvent:kTestGroupEvent];    // 执行组事件
        [self startGroupEvent:kTestGroupEvent];     // 移除组事件后无法再次执行
    });
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

#pragma mark -
- (void)addGroupEvent
{
    __weak typeof(self) _self = self;
    [self addEvent:@"GroupEvent" group:kTestGroupEvent withAction:^id(NSDictionary *param) {
        NSString *title = param[@"title"];
        if (!title) {
            title = @"GroupEvent";
        }
        [_self.groupEventBtn setTitle:title forState:UIControlStateNormal];
        return nil;
    }];
    [self addEvent:@"GroupEvent1" group:kTestGroupEvent withAction:^id(NSDictionary *param) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [_self.groupEventBtn setTitle:@"group1" forState:UIControlStateNormal];
        });
        return nil;
    }];
    [self addEvent:@"GroupEvent2" group:kTestGroupEvent withAction:^id(NSDictionary *param) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [_self.groupEventBtn setTitle:@"group2" forState:UIControlStateNormal];
        });
        return nil;
    }];
    [self addEvent:@"GroupEvent3" group:kTestGroupEvent withAction:^id(NSDictionary *param) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [_self.groupEventBtn setTitle:@"group3" forState:UIControlStateNormal];
        });
        return nil;
    }];
    [self addEvent:@"GroupEvent4" group:kTestGroupEvent withAction:^id(NSDictionary *param) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(4 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [_self.groupEventBtn setTitle:@"group4" forState:UIControlStateNormal];
        });
        return nil;
    }];
}

@end
