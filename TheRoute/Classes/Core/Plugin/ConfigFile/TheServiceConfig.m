//
//  TheServiceConfig.m
//  TheRoute
//
//  Created by TheMe on 7/24/16.
//  Copyright © 2016 sdqvsqiu@gmail.com. All rights reserved.
//

#import "TheServiceConfig.h"
#import "TheServerProtocol.h"
#import "TheRouter.h"

@implementation TheServiceConfig

- (NSDictionary *)buildConfig:(id)manifest
{
    NSArray *services = manifest[@"service"];
    [self configService:services];
    return nil;
}

- (void)configService:(NSArray *)services
{
    for (NSString *serviceName in services) {
        Class clz = NSClassFromString(serviceName);
        id<TheServerProtocol> service = [[clz alloc] init];
        [_theRoute addProperty:serviceName toValue:service];
    }
}

@end
