//
//  TheBaseRouterFilter.m
//  TheRoute
//
//  Created by TheMe on 2018/12/4.
//  Copyright © 2018 sdqvsqiu@gmail.com. All rights reserved.
//

#import "TheBaseRouterFilter.h"

@implementation TheBaseRouterFilter
@synthesize priorityOrder = _priorityOrder;
@synthesize standProcessing = _standProcessing;
@synthesize disable = _disable;
@synthesize needRefreshEnv = _needRefreshEnv;

- (BOOL)needRedirect{return NO;}

// 降序
- (NSComparisonResult)compare:(TheBaseRouterFilter *)filter
{
    if (self.priorityOrder > filter.priorityOrder){
        return NSOrderedAscending;
    }else if (self.priorityOrder == filter.priorityOrder){
        return NSOrderedSame;
    }else{
        return NSOrderedDescending;
    }
}

@end
