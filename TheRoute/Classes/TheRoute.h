//  TheRoute.h
//  TheRoute
//
//  Created by TheMe on 6/15/16.
//  Copyright © 2016 sdqvsqiu@gmail.com. All rights reserved.
//

#if __has_include(<TheRoute/TheRoute.h>)

    #import <TheRoute/TheLifeCycleProtocol.h>
    #import <TheRoute/TheIntentProtocol.h>
    #import <TheRoute/TheEventProtocol.h>
    #import <TheRoute/TheServiceProtocol.h>

#else

    #import "TheLifeCycleProtocol.h"
    #import "TheIntentProtocol.h"
    #import "TheEventProtocol.h"
    #import "TheServiceProtocol.h"

#endif

@protocol TheRoute <TheLifeCycleProtocol,TheIntentProtocol,TheEventProtocol,TheServiceProtocol>
@end

@interface UIViewController () <TheIntentBaseProtocol,TheEventBaseProtocol,TheServiceBaseProtocol>
@end


void callLibLoaded(const void * addr);

// 在组件初始化时调用，用于自动注册短路由
#define routeAliasRegister callLibLoaded(&@selector(load))
