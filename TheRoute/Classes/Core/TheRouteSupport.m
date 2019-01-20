//
//  TheRouteSupport.m
//  TheRoute
//
//  Created by TheMe on 7/4/16.
//  Copyright © 2016 sdqvsqiu@gmail.com. All rights reserved.
//

#import "TheRouteSupport.h"

@implementation TheRouteSupport

static NSString *valuePrefix = @"_value_";
- (void)addProperty:(NSString *)key toValue:(id)value
{
    if (!key.length) {
        return;
    }
    NSString *eventName = [NSString stringWithFormat:@"%@%@",valuePrefix,key];
    self.map[eventName] = value;
}

- (id)propertyValueForKey:(NSString *)key
{
    NSString *eventName = [NSString stringWithFormat:@"%@%@",valuePrefix,key];
    NSObject *value = key.length > 0 ? self.map[eventName] : nil;
    [self.map removeObjectForKey:eventName];
    return value;
}

- (id)queryPropertyValueForKey:(NSString *)key
{
    NSString *eventName = [NSString stringWithFormat:@"%@%@",valuePrefix,key];
    NSObject *value = key.length > 0 ? self.map[eventName] : nil;
    return value;
}

static NSString *eventPrefix = @"_event_";
- (void)addEvent:(NSString *)name forAction:(TheRouterActionBlock)action
{
    if (!name.length) {
        return;
    }
    NSString *eventName = [NSString stringWithFormat:@"%@%@",eventPrefix,name];
    self.map[eventName] = action;
}

static NSString *eventOncePrefix = @"_event_once_";
- (void)addEvent:(NSString *)name forOnceAction:(TheRouterActionBlock)action
{
    if (!name.length) {
        return;
    }
    NSString *eventName = [NSString stringWithFormat:@"%@%@",eventOncePrefix,name];
    self.map[eventName] = action;
}

- (void)removeEvent:(NSString *)name
{
    NSString *eventParameterName = [NSString stringWithFormat:@"%@%@",eventParameterPrefix,name];
    NSMutableDictionary *parameterDict =  self.map[eventParameterName];
    if (parameterDict) {
        [self.map removeObjectForKey:eventParameterName];
    }
    
    NSString *eventName = [NSString stringWithFormat:@"%@%@",eventPrefix,name];
    TheRouterActionBlock block = self.map[eventName];
    if (!block) {
        eventName = [NSString stringWithFormat:@"%@%@",eventOncePrefix,name];
        block = self.map[eventName];
    }
    if (block) {
        [self.map removeObjectForKey:eventName];
    }
}

- (id)executeEvent:(NSString *)name
{
    return [self executeEvent:name withParameter:@{}];
}

static NSString *eventParameterPrefix = @"_event_parameter_";
- (void)addParameter:(NSDictionary *)parameter forEvent:(NSString *)name
{
    if (!parameter || !name.length) {
        return;
    }
    NSString *eventName = [NSString stringWithFormat:@"%@%@",eventParameterPrefix,name];
    NSMutableDictionary *parameterDict =  self.map[eventName];
    if (!parameterDict) {
        parameterDict = [@{} mutableCopy];
    }
    [parameterDict addEntriesFromDictionary:parameter];
    
    self.map[eventName] = parameterDict;
}

- (id)executeEvent:(NSString *)name withParameter:(NSDictionary *)param
{
    [self addParameter:param forEvent:name];
    if (!name.length) {
        return nil;
    }
    NSString *eventName = [NSString stringWithFormat:@"%@%@",eventPrefix,name];
    TheRouterActionBlock block = self.map[eventName];
    if (!block || block == NULL) {
        NSString *onceEventName = [NSString stringWithFormat:@"%@%@",eventOncePrefix,name];
        block = self.map[onceEventName];
        [self.map removeObjectForKey:onceEventName];
    }
    
    NSString *eventParameterName = [NSString stringWithFormat:@"%@%@",eventParameterPrefix,name];
    NSMutableDictionary *parameterDict =  self.map[eventParameterName];
    if (parameterDict) {
        [self.map removeObjectForKey:eventParameterName];
    }
    
    return !block?nil:block(parameterDict);
}

@end
