//
//  TheBaseService.m
//  TheRoute
//
//  Created by TheMe on 7/24/16.
//  Copyright © 2016 sdqvsqiu@gmail.com. All rights reserved.
//

#import "TheBaseService.h"
#import "TheBaseBinder.h"
#import "TheRouteHelper.h"

@interface TheBaseService()
{
    NSUInteger _bind_count_;
}

@property (nonatomic,strong) NSPointerArray *binderObjects;

@end

@implementation TheBaseService

- (instancetype)init
{
    if (self = [super init]) {
        [self onCreate];
    }
    return self;
}

- (void)startService:(Intent *)intent
{
    [self startCommand:intent];
}

// TODO:内含一个计数器，绑定的对象都移除了才会彻底移除。
- (void)stopService:(Intent *)intent
{
    @synchronized (self) {
        _bind_count_ --;
    }
    if (!_bind_count_) {
        // TODO: 从寄存者中申请移除服务
        [self onDestroy];
    }
}

- (__kindof id<TheBinderProtocol>)onBind:(Intent *)intent
{
    @synchronized (self) {
        _bind_count_ ++;
    }
    
    id<TheBinderProtocol> binder = [self makeBinder:intent];
    [self.binderObjects addPointer:(__bridge void *)binder];
    return binder;
}

- (void)startCommand:(Intent *)intent
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        Intent * finish = [self onStartCommand:intent];
        if (finish) {
            [self finishCommand:finish];
        }
    });
}

- (Intent *)onStartCommand:(Intent *)intent
{
    return intent;
}

- (void)finishCommand:(Intent *)commandIntent
{
    if (![NSThread isMainThread]) {
        dispatch_sync(dispatch_get_main_queue(), ^{
            [self onFinishCommand:commandIntent];
        });
    }else{
        [self onFinishCommand:commandIntent];
    }
}

- (void)onFinishCommand:(Intent *)commandIntent
{
    [self.binderObjects compact];
    NSArray *binders = self.binderObjects.allObjects;
    for (id<TheBinderProtocol> binder in binders) {
        if ([binder respondsToSelector:@selector(isPause)] && [binder isPause]) {
            continue;
        }
        [TheRouteHelper map:binder params:commandIntent.extras];
        !binder.lisner?:binder.lisner(commandIntent);
    }
}

- (void)onCreate{}

- (void)onDestroy{}

- (id)queryState:(Intent *)intent
{
    return nil;
}

// onBind服务时调用该方法
- (id<TheBinderProtocol>)makeBinder:(Intent *)intent
{
    return [[TheBaseBinder alloc] init];
}

- (NSPointerArray *)binderObjects
{
    if (!_binderObjects) {
        _binderObjects = [NSPointerArray weakObjectsPointerArray];
    }
    return _binderObjects;
}

@end
