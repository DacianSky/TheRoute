//
//  TheEventFilter.m
//  TheRoute
//
//  Created by TheMe on 4/29/21.
//  Copyright © 2016 sdqvsqiu@gmail.com. All rights reserved.
//

#import "TheEventFilter.h"
#import "NSString+Route.h"
#import "TheRouter.h"

@implementation TheEventFilter

- (BOOL)couldStandProcessingUrl:(NSString *)url
{
    if (self.disable) {
        return NO;
    }
    if ([url supportScheme:@"event"]) {
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
        url = [url deleteScheme];
        NSString *event = [url getUrlBody];
        NSDictionary *params = [[_theRoute queryPropertyValueForKey:theParameterKey] valueForKey:@"extras"];
        [UIViewController startEventWithName:event withParam:params];
        return @"";
    }
    return url;
}
@end
