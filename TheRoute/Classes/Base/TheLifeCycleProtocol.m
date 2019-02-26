//
//  TheLifeCycleProtocol.m
//  TheRoute
//
//  Created by TheMe on 2018/11/28.
//  Copyright © 2018 sdqvsqiu@gmail.com. All rights reserved.
//

#import "TheLifeCycleProtocol.h"
#import "MethodInjecting.h"

@the_concreteprotocol(TheLifeCycleProtocol)

- (instancetype)init
{
    if (self = [super init]) {
        [self anywayInit];
    }
    return self;
}

- (void)anywayInit
{
    theExecuteUndeclaredSelector(self,@selector(setupInit));
    [self onInit];
}

- (void)reloadVC
{
    if(![self needReloadVC]){
        return;
    }
    [self prepareReloadVC];
    [self didReloadVC];
}

- (BOOL)needReloadVC
{
    return YES;
}

- (void)prepareReloadVC{}
- (void)didReloadVC
{
    [self reloadView];
}

- (void)reloadView{}

# pragma mark - 自定义生命周期
- (void)the_configParams{}
- (void)the_configViews{}
- (void)the_configConstraints{}
- (void)the_configDatas{}

- (void)the_updateViews{};
- (void)the_updataConstraints{}
- (void)the_updateGlobalProperty{}

- (void)onInit{}

- (void)willCreate{}
- (void)onCreate
{
}

// 私有方法。不建议覆盖，覆盖onStart方法会导致“the_config*”系列方法失效。
- (void)onStart{
    self.extendedLayoutIncludesOpaqueBars = YES;
    self.automaticallyAdjustsScrollViewInsets = NO;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onSleep) name:UIApplicationWillEnterForegroundNotification object:nil];
    if(![self respondsToSelector:@selector(the_wouldConfig)] || [self the_wouldConfig]){
        [self the_config];
    }
}

- (void)the_config
{
    [self the_configParams];
    [self the_configViews];
    [self the_configConstraints];
    [self the_configDatas];
}

//进入后台或跳转到其他页面
- (void)onPause{}

// 私有方法。不建议覆盖，会导致`the_xx`系列方法不会被调用。
- (void)onRestart
{
    [self the_updateViews];
}

//进入前台或切换tabbar
- (void)onResume
{
    for (id<TheLifeCycleProtocol> vc in self.childViewControllers) {
        if ([vc respondsToSelector:@selector(onResume)]) {
            [vc onResume];
        }
    }
}

- (void)onSleep{}
- (void)onDestroy
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)onRotate:(UIDeviceOrientation)newOrientation{}
- (void)rotated:(UIDeviceOrientation)oldOrientation{}

- (void)onReturn
{
    BOOL animation = [self dismissAnimation];
    if ([self presentingViewController]) {
        [self dismissViewControllerAnimated:animation completion:^{}];
    }else{
        [self.navigationController popViewControllerAnimated:animation];
    }
}

- (void)returnClick
{
    theExecuteUndeclaredSelector(self,@selector(finish));
}

- (BOOL)showAnimation
{
    return YES;
}

- (BOOL)dismissAnimation
{
    return YES;
}

@end
