//
//  TheSupportProtocol.h
//  TheRoute
//
//  Created by TheMe on 7/4/16.
//  Copyright © 2016 sdqvsqiu@gmail.com. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class Intent;

typedef id _Nullable (^ TheRouterActionBlock)(id param);
typedef void(^ TheRouterCallBack)(UIViewController *vc,Intent *intent);

@protocol TheSupportProtocol <NSObject>

@optional
- (void)addProperty:(NSString *)key toValue:(id)value;
- (id)propertyValueForKey:(NSString *)key;
- (id)queryPropertyValueForKey:(NSString *)key;

- (void)addEvent:(NSString *)name forAction:(TheRouterActionBlock)action;
- (void)addEvent:(NSString *)name group:(NSString *)group forAction:(TheRouterActionBlock)action;
- (void)addEvent:(NSString *)name forOnceAction:(TheRouterActionBlock)action;
- (void)addEvent:(NSString *)name group:(NSString *)group forOnceAction:(TheRouterActionBlock)action;
- (void)removeEvent:(NSString *)name;
- (void)removeGroupEvent:(NSString *)group;
- (id)executeEvent:(NSString *)name;
- (id)executeGroupEvent:(NSString *)group;
- (id)executeEvent:(NSString *)name withParameter:(id)param;
- (id)executeGroupEvent:(NSString *)group withParameter:(id)param;
- (void)addParameter:(NSDictionary *)parameter forEvent:(NSString *)name;
- (void)addParameter:(NSDictionary *)parameter forGroup:(NSString *)group;

@end

NS_ASSUME_NONNULL_END
