//
//  TheSpecialSchemeConfig.m
//  TheRoute
//
//  Created by TheMe on 8/30/16.
//  Copyright © 2016 sdqvsqiu@gmail.com. All rights reserved.
//

#import "TheSpecialSchemeConfig.h"

extern NSString * const kTheMeRouteScheme;
extern NSString * const kExtraRouteScheme;

@implementation TheSpecialSchemeConfig

- (NSDictionary *)buildConfig:(id)manifest
{
    NSDictionary *urls = manifest[kExtraRouteScheme];
    [self configSepcialUrls:urls];
    return nil;
}

- (void)configSepcialUrls:(NSDictionary *)specialUrls
{
    self.specialUrls = specialUrls;
}

@end
