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

static NSString *eventGroupPrefix = @"_event_group_";
- (void)storeGroup:(NSString *)group event:(NSString *)name
{
    if (!group.length || !name.length) {
        return;
    }
    
    NSString *groupName = [NSString stringWithFormat:@"%@%@",eventGroupPrefix,group];
    NSMutableArray *groupList = self.group[groupName];
    if (![groupList isKindOfClass:NSMutableArray.class]) {
        groupList = [@[] mutableCopy];
        self.group[groupName] = groupList;
    }
    [groupList addObject:name];
}

- (void)addEvent:(NSString *)name group:(NSString *)group forAction:(TheRouterActionBlock)action
{
    if (!group.length || !name.length) {
        return;
    }
    
    [self storeGroup:group event:name];
    [self addEvent:name forAction:action];
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

- (void)addEvent:(NSString *)name group:(NSString *)group forOnceAction:(TheRouterActionBlock)action
{
    if (!group.length || !name.length) {
        return;
    }
    
    [self storeGroup:group event:name];
    [self addEvent:name forOnceAction:action];
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

- (void)removeGroupEvent:(NSString *)group
{
    if (!group.length) {
        return;
    }
    
    NSString *groupName = [NSString stringWithFormat:@"%@%@",eventGroupPrefix,group];
    NSArray *groupList = [self.group[groupName] copy];
    for (NSString *name in groupList) {
        [self removeEvent:name];
    }
    [self.group removeObjectForKey:groupName];
}

- (id)executeEvent:(NSString *)name
{
    return [self executeEvent:name withParameter:@{}];
}

- (id)executeGroupEvent:(NSString *)group
{
    return [self executeGroupEvent:group withParameter:@{}];
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

- (void)addParameter:(NSDictionary *)parameter forGroup:(NSString *)group
{
    if (!group.length) {
        return;
    }
    
    NSString *groupName = [NSString stringWithFormat:@"%@%@",eventGroupPrefix,group];
    NSArray *groupList = [self.group[groupName] copy];
    for (NSString *name in groupList) {
        [self addParameter:parameter forEvent:name];
    }
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

- (id)executeGroupEvent:(NSString *)group withParameter:(id)param
{
    if (!group.length) {
        return nil;
    }
    NSMutableArray *resultList = [@[] mutableCopy];
    
    NSString *groupName = [NSString stringWithFormat:@"%@%@",eventGroupPrefix,group];
    NSArray *groupList = [self.group[groupName] copy];
    for (NSString *name in groupList) {
        id result = [self executeEvent:name withParameter:param];
        if (result) {
            [resultList addObject:result];
        }
    }
    
    return resultList;
}

@end
