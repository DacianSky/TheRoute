//
//  TheOne2ManyFilter.m
//  TheRoute
//
//  Created by TheMe on 2017/9/14.
//  Copyright © 2017年 sdqvsqiu@gmail.com. All rights reserved.
//

#import "TheOne2ManyFilter.h"
#import "NSString+Route.h"
#import "TheRouter.h"
#import "Intent.h"

extern NSString * const kTheMeRouteScheme;
extern NSString * const kProjectSpecialScheme;

@interface TheOne2ManyFilter()

@property (nonatomic,strong) NSDictionary *params;

@end

@implementation TheOne2ManyFilter
@synthesize ENVIRONMENT = __ENVIRONMENT__;

- (NSDictionary *)withUpdateEnvironment
{
    if (self.needRefreshEnv) {
        return @{envRedirect:@(YES)};
    }
    return nil;
}

- (NSString *)routerFilterUrl:(NSString *)url
{
    self.needRefreshEnv = NO;
    NSString *filterUrl = [self handleUrl:url];
    return filterUrl;
}

- (NSString *)handleUrl:(NSString *)urlString
{
    if (!urlString) {
        return urlString;
    }
    NSString *filterUrl = urlString;
    if([filterUrl hasPrefix:kTheMeRouteScheme]){
        NSString *schemePrefix = [NSString stringWithFormat:@"%@://",kTheMeRouteScheme];
        NSRange schemePrefixRange = [filterUrl rangeOfString:schemePrefix];
        filterUrl = [filterUrl substringFromIndex:NSMaxRange(schemePrefixRange)];
    }
    
    NSDictionary *one2ManyMap = self.configFile.one2ManyMap;
    
    for(NSString *outline in one2ManyMap.allKeys){
        NSRange range = [filterUrl rangeOfString:outline options:NSRegularExpressionSearch];
        if (range.location == NSNotFound) {
            continue;
        }
        // 正则替换
        NSArray *regualarMaps = one2ManyMap[outline];
        for (NSDictionary *regualarMap in regualarMaps) {
            if ([@"equal" isEqualToString:regualarMap[@"type"]]) {
                if ( [filterUrl isEqualToString:regualarMap[@"url"] ]) {
                    filterUrl = regualarMap[@"handle"];
                    break;
                }
            }else if ([@"replace" isEqualToString:regualarMap[@"type"]]) {
                NSString *text = [filterUrl regexReplce:regualarMap[@"url"] handle:regualarMap[@"handle"]];
                if(!text){
                    filterUrl = text;
                    self.needRefreshEnv = YES;
                    break;
                }
            }
        }
    }
    
    self.params = [filterUrl getAllParameterDict];
    
    return filterUrl;
}

- (Intent *)routerFilterParam:(Intent *)paramIntent
{
    if (!self.params.allKeys.count) {
        return paramIntent;
    }
    Intent *intent = paramIntent;
    if (!intent) {
        intent = [[Intent alloc] init];
    }
    [intent putExtras:self.params];
    self.params = nil;
    return intent;
}

@end
