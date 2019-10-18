//
//  TheAliasConfig.m
//  TheRoute
//
//  Created by TheMe on 7/11/16.
//  Copyright © 2016 sdqvsqiu@gmail.com. All rights reserved.
//

#import "TheAliasConfig.h"
#import "NSDictionary+Route.h"

@interface TheAliasConfig()


@end

@implementation TheAliasConfig

- (NSDictionary *)buildConfig:(id)manifest
{
    [self configRoute_routes:manifest];
    return nil;
}

- (void)configRoute_routes:(NSDictionary *)manifest
{
    NSDictionary *base = manifest[@"base"];
    self.baseRouters = [base mutableCopy];
    
    NSMutableDictionary *alias = [manifest[@"alias"] mergeDictionary:base];
    self.aliasRouters = alias;
}

@end
