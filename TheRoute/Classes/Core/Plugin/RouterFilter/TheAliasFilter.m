//
//  TheAliasFilter.m
//  TheRoute
//
//  Created by TheMe on 7/15/16.
//  Copyright © 2016 sdqvsqiu@gmail.com. All rights reserved.
//

#import "TheAliasFilter.h"
#import "NSString+Route.h"

@interface TheAliasFilter()

@property (nonatomic,strong,readwrite) TheAliasConfig *configFile;

@end

@implementation TheAliasFilter
@synthesize ENVIRONMENT = __ENVIRONMENT__;

- (NSDictionary *)withNewEnvironment
{
    return @{@"__base_route__": self.configFile.baseRouters };
}

- (NSString *)routerFilterUrl:(NSString *)url
{
    if (self.disable) {
        return url;
    }
    NSString *filterUrl = [self handleUrl:url];
    return filterUrl;
}

- (NSString *)handleUrl:(NSString *)urlString
{
    NSString *filterUrl = urlString;
    
    NSDictionary *alias = self.configFile.aliasRouters;
    
    for(NSString *key in alias.allKeys){
        // 替换字符串由起始结束标志字符串  如"/"开始，"/","#"或"空白字符"结束
        filterUrl = [filterUrl replaceUrlComponent:key value:alias[key]];
    }
    
    return filterUrl;
}

@end
