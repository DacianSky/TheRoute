//
//  ThePermissionConfig.m
//  TheRoute
//
//  Created by TheMe on 7/10/16.
//  Copyright © 2016 sdqvsqiu@gmail.com. All rights reserved.
//

#import "ThePermissionConfig.h"

@interface ThePermissionConfig()

@end

@implementation ThePermissionConfig

// TODO: 最好返回一个可以添加到总路由中的字典
- (NSDictionary *)buildConfig:(id)manifest
{
    [self configRoute_permissions:manifest];
    return nil;
}

- (void)configRoute_permissions:(NSDictionary *)manifest
{
    NSString *protocol = @"permissions";
    NSDictionary *permissions = manifest[protocol];
    
    [self.whitelist addObjectsFromArray: permissions[@"whitelist"]];
    [self.blacklist addObjectsFromArray: permissions[@"blacklist"]];
    
    _whitelist?:(void)(_whitelist = [@[] mutableCopy]);
    _blacklist?:(void)(_blacklist = [@[] mutableCopy]);
    _whitelistEnable?:(void)(_whitelistEnable = [permissions[@"whitelistEnable"] boolValue]);
}

- (NSMutableArray *)whitelist
{
    if (!_whitelist) {
        _whitelist = [@[] mutableCopy];
    }
    return _whitelist;
}

- (NSMutableArray *)blacklist
{
    if (!_blacklist) {
        _blacklist = [@[] mutableCopy];
    }
    return _blacklist;
}

@end
