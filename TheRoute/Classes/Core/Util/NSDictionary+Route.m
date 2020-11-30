//
//  NSDictionary+Route.m
//  TestRoute
//
//  Created by TheMe on 2018/12/4.
//  Copyright © 2018 sdqvsqiu@gmail.com. All rights reserved.
//

#import "NSDictionary+Route.h"

@implementation NSDictionary (Route)

- (NSMutableDictionary *)mergeDictionary:(NSDictionary *)dict
{
    NSMutableDictionary *result = [self mutableCopy];
    if (![dict isKindOfClass:[NSDictionary class]]) {
        return result;
    }
    
    NSDictionary *origin = [self mutableCopy];
    NSDictionary *patch = [dict mutableCopy];
    
    NSArray *keys = patch.allKeys;
    for (NSString *key in keys) {
        id vOrigin = origin[key];
        id vPatch = patch[key];
        if ([vOrigin isKindOfClass:[NSDictionary class]] && [vPatch isKindOfClass:[NSDictionary class]]) {
            result[key] = [vOrigin mergeDictionary:vPatch];
        }else{
            result[key] = vPatch;
        }
    }
    
    return result;
}

+ (NSMutableDictionary *)merge:(NSDictionary *)unmerged withDictionary:(NSDictionary *)other
{
    NSMutableDictionary *result = nil;
    if (unmerged) {
        result = [unmerged mergeDictionary:other];
    }else{
        result = [other mergeDictionary:unmerged];
    }
    return result;
}

- (BOOL)judgeDictEqaulStringValue:(NSDictionary *)dict
{
    if (self.allKeys.count != dict.allKeys.count) {
        return NO;
    }
    
    BOOL equalFlag = YES;
    
    NSArray *allKeys = self.allKeys;
    for (NSString *key in allKeys) {
        NSString *value = self[key];
        if (![dict[key] isEqualToString:value]) {
            equalFlag = NO;
            break;
        }
    }
    
    return equalFlag;
}

- (BOOL)judgeDictEqaulValue:(NSDictionary *)dict
{
    if (self.allKeys.count != dict.allKeys.count) {
        return NO;
    }
    
    BOOL equalFlag = YES;
    
    NSArray *allKeys = self.allKeys;
    for (NSString *key in allKeys) {
        NSString *value = self[key];
        if ([value isKindOfClass:[NSString class]]) {
            if (![dict[key] isEqualToString:value]) {
                equalFlag = NO;
                break;
            }
        }else if([value isKindOfClass:[NSNumber class]]){
            if ([dict[key] compare:value] != NSOrderedSame) {
                equalFlag = NO;
                break;
            }
        }else{
            if ( dict[key] != value) {
                equalFlag = NO;
                break;
            }
        }
    }
    
    return equalFlag;
}

@end


@implementation NSMutableDictionary(Route)

- (NSMutableDictionary *)mergeDictionary:(NSDictionary *)dict
{
    NSMutableDictionary *result = self;
    if (![dict isKindOfClass:[NSDictionary class]]) {
        return result;
    }
    
    NSDictionary *origin = [self mutableCopy];
    NSDictionary *patch = [dict mutableCopy];
    
    NSArray *keys = patch.allKeys;
    for (NSString *key in keys) {
        id vOrigin = origin[key];
        id vPatch = patch[key];
        if ([vOrigin isKindOfClass:[NSDictionary class]] && [vPatch isKindOfClass:[NSDictionary class]]) {
            result[key] = [vOrigin mergeDictionary:vPatch];
        }else{
            result[key] = vPatch;
        }
    }
    
    return result;
}

@end
