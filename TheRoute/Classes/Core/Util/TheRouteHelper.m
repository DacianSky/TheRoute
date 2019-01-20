//
//  TheRouteHelper.m
//  TheRoute
//
//  Created by TheMe on 15/8/11.
//  Copyright (c) 2015年 sdqvsqiu@gmail.com. All rights reserved.
//

#import "TheRouteHelper.h"
#import <objc/runtime.h>
#import <CommonCrypto/CommonCrypto.h>
#import "NSString+Route.h"

@implementation TheRouteHelper

+ (void)map:(id)object params:(NSDictionary *)params
{
    NSMutableDictionary *ps = [params mutableCopy];
    Class clz = [object class];
    
    while(clz){
        unsigned int count;
        
        objc_property_t *properties = class_copyPropertyList(clz, &count);
        for (NSString *key in params.allKeys) {
            for(int i = 0; i < count; i++)
            {
                objc_property_t property = *(properties+i);
                const char *name = property_getName(property);
                NSString *propertyName = [NSString stringWithCString:name encoding:NSUTF8StringEncoding];
                
                if ([key isEqualToString:propertyName]) {
                    id value = ps[key];
                    if (value) {
                        [object setValue:value forKey:key];
                        [ps removeObjectForKey:key];
                    }
                    break;
                }
            }
        }
        free(properties);
        if (!ps.allKeys.count) {
            return;
        }
        clz = clz.superclass;
    }
}

+ (NSMutableArray *)removeWhiteElement:(NSArray *)array
{
    NSMutableArray *components = [array mutableCopy];
    for (NSString *com in array.copy) {
        if ([NSString isEmptyOrNull:com]) {
            [components removeObject:com];
        }
    }
    return components;
}

+ (UITabBarController *)getAppTabbar
{
    UIViewController *vc = [UIApplication sharedApplication].keyWindow.rootViewController;
    if ([vc isKindOfClass:[UITabBarController class]]) {
        return (UITabBarController *)vc;
    }
    return nil;
}

+ (UINavigationController *)getAppCurrentNavigation
{
    UIViewController *vc = [UIApplication sharedApplication].keyWindow.rootViewController;
    UINavigationController *nav;
    if ([vc isKindOfClass:[UITabBarController class]]) {
        UITabBarController *tabbarVC = (UITabBarController *)vc;
        nav = tabbarVC.selectedViewController;
    }else if ([vc isKindOfClass:[UINavigationController class]]){
        nav = (UINavigationController *)vc;
    }
    return nav;
}

+ (BOOL)isBlock:(id)value
{
    BOOL flag = NO;
    if ([value isKindOfClass:NSClassFromString(@"__NSGlobalBlock__")]) {
        flag = YES;
    }else if ([value isKindOfClass:NSClassFromString(@"__NSMallocBlock__")]) {
        flag = YES;
    }else if ([value isKindOfClass:NSClassFromString(@"__NSStackBlock__")]) {
        flag = YES;
    }
    return flag;
}

@end
