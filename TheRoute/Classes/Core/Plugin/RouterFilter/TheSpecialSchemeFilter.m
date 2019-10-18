//
//  TheSpecialSchemeFilter.m
//  TheRoute
//
//  Created by TheMe on 8/30/16.
//  Copyright © 2016 sdqvsqiu@gmail.com. All rights reserved.
//

#import "TheSpecialSchemeFilter.h"
#import "TheRouter.h"
#import "NSString+Route.h"

extern NSString * const kTheMeRouteScheme;
extern NSString * const kExtraRouteScheme;
@interface TheSpecialSchemeFilter()

@property (nonatomic,strong,readwrite) TheSpecialSchemeConfig *configFile;

@end

@implementation TheSpecialSchemeFilter
@synthesize ENVIRONMENT = __ENVIRONMENT__;

- (NSDictionary *)withUpdateEnvironment
{
    if (self.needRefreshEnv) {
        return @{envRedirect:@(YES)};
    }
    return nil;
}

- (BOOL)standProcessing
{
    return YES;
}

- (BOOL)couldStandProcessingUrl:(NSString *)url
{
    if (self.disable) {
        return NO;
    }
    if ([url supportScheme:kExtraRouteScheme]) {
        return YES;
    }
    return NO;
}

- (NSString *)routerFilterUrl:(NSString *)url
{
    self.needRefreshEnv = NO;
    if (self.disable) {
        return url;
    }
    if ([self couldStandProcessingUrl:url]) {
        self.needRefreshEnv = YES;
        
        NSRange range = [url rangeOfString:[NSString stringWithFormat:@"%@%@",kExtraRouteScheme, @"://"]];
        NSString *unpackUrl = [url substringFromIndex:range.location + range.length];
        
        url = [self handleUrl:unpackUrl];
    }
    return url;
}

- (NSString *)handleUrl:(NSString *)url
{
    NSString *convertUrl =  self.configFile.specialUrls[url];
    if ([NSString isEmptyOrNull:convertUrl]) {
        convertUrl = url;
    }
    return convertUrl;
}

@end
