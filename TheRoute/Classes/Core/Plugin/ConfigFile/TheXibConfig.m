//
//  TheXibConfig.m
//  TheRoute
//
//  Created by TheMe on 7/11/16.
//  Copyright © 2016 sdqvsqiu@gmail.com. All rights reserved.
//

#import "TheXibConfig.h"
#import "TheRouter.h"

@implementation TheXibConfig

- (NSDictionary *)buildConfig:(id)manifest
{
    [self configRoute_xib_module:manifest];
    return nil;
}

- (void)configRoute_xib_module:(NSDictionary *)manifest
{
    NSDictionary *vc = manifest[@"xib"];
    [vc enumerateKeysAndObjectsUsingBlock:^(NSString *key, NSArray *value, BOOL * _Nonnull stop) {
        [value enumerateObjectsUsingBlock:^(NSString *name, NSUInteger idx, BOOL * _Nonnull stop) {
            [_theRoute.core registerKey:name action:^UIViewController *{
                return [[NSClassFromString(name) alloc] initWithNibName:name bundle:nil];
            }];
        }];
    }];
}

@end
