//
//  TheServiceProtocol.h
//  TheRoute
//
//  Created by TheMe on 7/24/16.
//  Copyright © 2016 sdqvsqiu@gmail.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TheServerProtocol.h"

#import "TheBaseBinder.h"
#import "TheBaseService.h"
#import "TheTimerService.h"

@protocol TheServiceBaseProtocol <NSObject>

+ (id<TheServerProtocol>)queryService:(NSString *)name;
+ (__kindof id<TheBinderProtocol>)bindService:(NSString *)name intent:(Intent *)intent callback:(void(^)(Intent *intent))lisner;
+ (__kindof id<TheBinderProtocol>)bindFireService:(NSString *)name intent:(Intent *)intent callback:(void(^)(Intent *intent))lisner;
+ (void)stopService:(NSString *)name intent:(Intent *)intent;
+ (void)startService:(NSString *)name intent:(Intent *)intent;

@end

@protocol TheServiceProtocol <TheServiceBaseProtocol>

@optional

- (id<TheServerProtocol>)queryService:(NSString *)name;
- (__kindof id<TheBinderProtocol>)bindService:(NSString *)name intent:(Intent *)intent callback:(void(^)(Intent *intent))lisner;
- (__kindof id<TheBinderProtocol>)bindFireService:(NSString *)name intent:(Intent *)intent callback:(void(^)(Intent *intent))lisner;
- (void)startService:(NSString *)name intent:(Intent *)intent;
- (void)stopService:(NSString *)name intent:(Intent *)intent;

@end
