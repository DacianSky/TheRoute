//
//  TheHttpSchemeFilter.m
//  TheRoute
//
//  Created by TheMe on 7/14/16.
//  Copyright © 2016 sdqvsqiu@gmail.com. All rights reserved.
//

#import "TheHttpSchemeFilter.h"
#import "NSString+Route.h"
#import "Intent.h"

@interface TheHttpSchemeFilter()

@property (nonatomic,copy) NSString *urlParam;

@end

@implementation TheHttpSchemeFilter

- (BOOL)standProcessing
{
    return YES;
}

- (BOOL)couldStandProcessingUrl:(NSString *)url
{
    if (self.disable) {
        return NO;
    }
    if ([url isHttpUrl]) {
        self.urlParam = url;
        return YES;
    }
    return NO;
}

- (NSString *)routerFilterUrl:(NSString *)url
{
    if (self.disable) {
        return url;
    }
    if ([self couldStandProcessingUrl:url]) {
        return @"_http_";
    }
    return url;
}

- (NSArray *)nextFilter
{
    return @[@"TheAliasFilter",@"TheBaseTabbarFilter"];
}

- (Intent *)routerFilterParam:(Intent *)paramIntent
{
    Intent *intent = paramIntent;
    if (!intent) {
        intent = [[Intent alloc] init];
    }
    [intent putExtra:@"url" value:[self.urlParam routeencode]];
    return intent;
}

@end
