//
//  TheServiceProtocol.m
//  TheRoute
//
//  Created by TheMe on 7/24/16.
//  Copyright © 2016 sdqvsqiu@gmail.com. All rights reserved.
//

#import "TheServiceProtocol.h"
#import "MethodInjecting.h"
#import "TheRouter.h"

#define theContainer the_class_name(TheServiceProtocol)

@the_concreteprotocol(TheServiceProtocol)

#pragma mark - service
+ (id<TheServiceProtocol>)queryService:(NSString *)name
{
    return [_theRoute queryPropertyValueForKey:name];
}

+ (__kindof id<TheBinderProtocol>)bindService:(NSString *)name intent:(Intent *)intent callback:(void(^)(Intent *intent))lisner
{
    id<TheServerProtocol> service = [self queryService:name];
    
    id<TheBinderProtocol> binder = [service onBind:intent];
    
    binder.lisner = lisner;
    return binder;
}

+ (__kindof id<TheBinderProtocol>)bindFireService:(NSString *)name intent:(Intent *)intent callback:(void(^)(Intent *intent))lisner
{
    id<TheServerProtocol> service = [self queryService:name];
    
    id<TheBinderProtocol> binder = [service onBind:intent];
    
    binder.lisner = lisner;
    
    [service startCommand:intent];
    return binder;
}

+ (void)startService:(NSString *)name intent:(Intent *)intent
{
    id<TheServerProtocol> service = [_theRoute queryPropertyValueForKey:name];;
    [service startCommand:intent];
}

+ (void)stopService:(NSString *)name intent:(Intent *)intent
{
    id<TheServerProtocol> service = [self queryService:name];
    [service stopService:intent];
}

- (id<TheServerProtocol>)queryService:(NSString *)name
{
    return [[self class] queryService:name];
}

- (__kindof id<TheBinderProtocol>)bindService:(NSString *)name intent:(Intent *)intent callback:(void(^)(Intent *intent))lisner
{
    return [[self class] bindService:name intent:intent callback:lisner];
}

- (__kindof id<TheBinderProtocol>)bindFireService:(NSString *)name intent:(Intent *)intent callback:(void(^)(Intent *intent))lisner
{
    return [[self class] bindFireService:name intent:intent callback:lisner];
}

- (void)startService:(NSString *)name intent:(Intent *)intent
{
    [[self class] startService:name intent:intent];
}

- (void)stopService:(NSString *)name intent:(Intent *)intent
{
    [[self class] stopService:name intent:intent];
}

@end



@implementation UIViewController (Service)

+ (id<TheServerProtocol>)queryService:(NSString *)name
{
    return [theContainer queryService:name];
}

+ (__kindof id<TheBinderProtocol>)bindService:(NSString *)name intent:(Intent *)intent callback:(void(^)(Intent *intent))lisner
{
    return [theContainer bindService:name intent:intent callback:lisner];
}

+ (__kindof id<TheBinderProtocol>)bindFireService:(NSString *)name intent:(Intent *)intent callback:(void(^)(Intent *intent))lisner
{
    return [theContainer bindFireService:name intent:intent callback:lisner];
}

+ (void)startService:(NSString *)name intent:(Intent *)intent
{
    [theContainer startService:name intent:intent];
}

+ (void)stopService:(NSString *)name intent:(Intent *)intent
{
    [theContainer stopService:name intent:intent];
}

@end
