//
//  TheEventProtocol.m
//  TheRoute
//
//  Created by TheMe on 6/15/16.
//  Copyright © 2016 sdqvsqiu@gmail.com. All rights reserved.
//

#import "TheEventProtocol.h"
#import "MethodInjecting.h"
#import "TheRouter.h"

#define theContainer the_class_name(TheEventProtocol)

@the_concreteprotocol(TheEventProtocol)

+ (id)startEventWithName:(NSString *)name
{
    return [_theRoute executeEvent:name];
}

+ (id)startEventWithName:(NSString *)name withParam:(NSDictionary *)param
{
    return [_theRoute executeEvent:name withParameter:param];
}

+ (void)addEvent:(NSString *)name withAction:(id(^)(NSDictionary *param))actionBlock
{
    [_theRoute addEvent:name forAction:actionBlock];
}

+ (void)addEventPerformOnce:(NSString *)name withAction:(id(^)(NSDictionary *param))actionBlock
{
    [_theRoute addEvent:name forOnceAction:actionBlock]; // 模拟未启动
}

- (id)startEventWithName:(NSString *)name
{
    return [[self class] startEventWithName:name];
}

- (id)startEventWithName:(NSString *)name withParam:(NSDictionary *)param
{
    return [[self class] startEventWithName:name withParam:param];
}

- (void)addEvent:(NSString *)name withAction:(id(^)(NSDictionary *param))actionBlock
{
    [[self class] addEvent:name withAction:actionBlock];
}

- (void)addEventPerformOnce:(NSString *)name withAction:(id(^)(NSDictionary *param))actionBlock
{
    [[self class] addEventPerformOnce:name withAction:actionBlock]; // 模拟未启动
}

- (void)removeEvent:(NSString *)name
{
    [_theRoute removeEvent:name];
}

- (void)addParameter:(NSDictionary *)parameter forEvent:(NSString *)name
{
    [_theRoute addParameter:parameter forEvent:name];
}

#pragma mark - event
#define kBindEventName [NSString stringWithFormat:@"%@%lu",name,(unsigned long)self.hash]
// 界面复用会引起相同的event覆盖，绑定最好是加上指针地址或对象hash值等唯一标识
- (void)bindEvent:(NSString *)name withAction:(id(^)(NSDictionary *param))actionBlock
{
    [self addEvent:kBindEventName withAction:actionBlock];
}

- (void)bindEventPerformOnce:(NSString *)name withAction:(id(^)(NSDictionary *param))actionBlock
{
    [_theRoute addEvent:kBindEventName forOnceAction:actionBlock];
}

- (id)fireEventWithName:(NSString *)name
{
    return [self startEventWithName:kBindEventName];
}

- (id)fireEvent:(NSString *)name withParam:(NSDictionary *)param
{
    return [self startEventWithName:kBindEventName withParam:param];
}

- (void)unbindEvent:(NSString *)name
{
    [_theRoute removeEvent:kBindEventName];
}

@end

@implementation UIViewController (Event)

+ (id)startEventWithName:(NSString *)name
{
    return [theContainer startEventWithName:name];
}

+ (id)startEventWithName:(NSString *)name withParam:(NSDictionary *)param
{
    return [theContainer startEventWithName:name withParam:param];
}

+ (void)addEvent:(NSString *)name withAction:(id(^)(NSDictionary *param))actionBlock
{
    [theContainer addEvent:name withAction:actionBlock];
}

+ (void)addEventPerformOnce:(NSString *)name withAction:(id(^)(NSDictionary *param))actionBlock
{
    [theContainer addEventPerformOnce:name withAction:actionBlock];
}

@end
