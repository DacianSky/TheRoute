//
//  TheOpenApplicationFilter.m
//  TheRoute
//
//  Created by TheMe on 8/30/16.
//  Copyright © 2016 sdqvsqiu@gmail.com. All rights reserved.
//

#import "TheOpenApplicationFilter.h"
#import <UIKit/UIKit.h>
#import "NSString+Route.h"

@implementation TheOpenApplicationFilter

- (BOOL)standProcessing
{
    return YES;
}

- (BOOL)couldStandProcessingUrl:(NSString *)url
{
    if (self.disable) {
        return NO;
    }
    if ([url supportScheme:@"open"]) {
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
        NSRange range = [url rangeOfString:@"open://"];
        NSString *unpackUrl = [url substringFromIndex:range.location + range.length];
        
        url = [self handleUrl:unpackUrl];
    }
    return url;
}

- (NSString *)handleUrl:(NSString *)url
{
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
    return nil;
}

@end
