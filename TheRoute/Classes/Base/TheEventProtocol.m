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

+ (id)startGroupEvent:(NSString *)group
{
    return [_theRoute executeGroupEvent:group];
}

+ (id)startGroupEvent:(NSString *)group withParam:(NSDictionary *)param
{
    return [_theRoute executeGroupEvent:group withParameter:param];
}

+ (void)addEvent:(NSString *)name withAction:(id(^)(NSDictionary *param))actionBlock
{
    [_theRoute addEvent:name forAction:actionBlock];
}

+ (void)addEventPerformOnce:(NSString *)name withAction:(id(^)(NSDictionary *param))actionBlock
{
    [_theRoute addEvent:name forOnceAction:actionBlock]; // 模拟未启动
}

+ (void)addEvent:(NSString *)name group:group withAction:(id(^)(NSDictionary *param))actionBlock
{
    [_theRoute addEvent:name group:group forAction:actionBlock];
}

+ (void)addEventPerformOnce:(NSString *)name group:group withAction:(id(^)(NSDictionary *param))actionBlock
{
    [_theRoute addEvent:name group:group forOnceAction:actionBlock];
}

+ (void)removeEvent:(NSString *)name
{
    [_theRoute removeEvent:name];
}

+ (void)removeGroupEvent:(NSString *)group
{
    [_theRoute removeGroupEvent:group];
}

+ (void)addParameter:(NSDictionary *)parameter forEvent:(NSString *)name
{
    [_theRoute addParameter:parameter forEvent:name];
}

+ (void)addParameter:(NSDictionary *)parameter forGroup:(NSString *)group
{
    [_theRoute addParameter:parameter forGroup:group];
}

- (id)startEventWithName:(NSString *)name
{
    return [[self class] startEventWithName:name];
}

- (id)startEventWithName:(NSString *)name withParam:(NSDictionary *)param
{
    return [[self class] startEventWithName:name withParam:param];
}

- (id)startGroupEvent:(NSString *)group
{
    return [[self class] startGroupEvent:group];
}

- (id)startGroupEvent:(NSString *)group withParam:(NSDictionary *)param
{
    return [[self class] startGroupEvent:group withParam:(NSDictionary *)param];
}

- (void)addEvent:(NSString *)name withAction:(id(^)(NSDictionary *param))actionBlock
{
    [[self class] addEvent:name withAction:actionBlock];
}

- (void)addEventPerformOnce:(NSString *)name withAction:(id(^)(NSDictionary *param))actionBlock
{
    [[self class] addEventPerformOnce:name withAction:actionBlock]; // 模拟未启动
}

- (void)addEvent:(NSString *)name group:group withAction:(id(^)(NSDictionary *param))actionBlock
{
    [[self class] addEvent:name group:group withAction:actionBlock];
}

- (void)addEventPerformOnce:(NSString *)name group:group withAction:(id(^)(NSDictionary *param))actionBlock
{
    [[self class] addEventPerformOnce:name group:group withAction:actionBlock];
}

- (void)removeEvent:(NSString *)name
{
    [[self class] removeEvent:name];
}

- (void)removeGroupEvent:(NSString *)group
{
    [[self class] removeGroupEvent:group];
}

- (void)addParameter:(NSDictionary *)parameter forEvent:(NSString *)name
{
    [[self class] addParameter:parameter forEvent:name];
}

- (void)addParameter:(NSDictionary *)parameter forGroup:(NSString *)group
{
    [[self class] addParameter:parameter forGroup:group];
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
    [self addEventPerformOnce:kBindEventName withAction:actionBlock];
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
    [self removeEvent:kBindEventName];
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

+ (id)startGroupEvent:(NSString *)group
{
    return [theContainer startGroupEvent:group];
}

+ (id)startGroupEvent:(NSString *)group withParam:(NSDictionary *)param
{
    return [theContainer startGroupEvent:group withParam:param];
}

+ (void)addEvent:(NSString *)name withAction:(id(^)(NSDictionary *param))actionBlock
{
    [theContainer addEvent:name withAction:actionBlock];
}

+ (void)addEventPerformOnce:(NSString *)name withAction:(id(^)(NSDictionary *param))actionBlock
{
    [theContainer addEventPerformOnce:name withAction:actionBlock];
}

+ (void)addEvent:(NSString *)name group:group withAction:(id(^)(NSDictionary *param))actionBlock
{
    [theContainer addEvent:name group:group withAction:actionBlock];
}

+ (void)addEventPerformOnce:(NSString *)name group:group withAction:(id(^)(NSDictionary *param))actionBlock
{
    [theContainer addEventPerformOnce:name group:group withAction:actionBlock];
}

+ (void)removeEvent:(NSString *)name
{
    [theContainer removeEvent:name];
}

+ (void)removeGroupEvent:(NSString *)group
{
    [theContainer removeGroupEvent:group];
}

+ (void)addParameter:(NSDictionary *)parameter forEvent:(NSString *)name
{
    [theContainer addParameter:parameter forEvent:name];
}

+ (void)addParameter:(NSDictionary *)parameter forGroup:(NSString *)group
{
    [theContainer addParameter:parameter forGroup:group];
}

@end
