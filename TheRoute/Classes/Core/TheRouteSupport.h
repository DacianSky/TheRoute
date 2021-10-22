//
//  TheRouteSupport.h
//  TheRoute
//
//  Created by TheMe on 7/4/16.
//  Copyright © 2016 sdqvsqiu@gmail.com. All rights reserved.
//

#import "TheSupportProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@interface TheRouteSupport : NSObject <TheSupportProtocol>

@property (nonatomic, strong) NSMutableDictionary *map;
@property (nonatomic, strong) NSMutableDictionary *group;

@end

NS_ASSUME_NONNULL_END
