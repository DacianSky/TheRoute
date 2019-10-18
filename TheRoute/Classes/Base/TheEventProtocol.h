//
//  TheEventProtocol.h
//  TheRoute
//
//  Created by TheMe on 6/15/16.
//  Copyright © 2016 sdqvsqiu@gmail.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol TheEventBaseProtocol <NSObject>

+ (id)startEventWithName:(NSString *)name;
+ (id)startEventWithName:(NSString *)name withParam:(NSDictionary *)param;

+ (void)addEvent:(NSString *)name withAction:(id(^)(NSDictionary *param))actionBlock;
+ (void)addEventPerformOnce:(NSString *)name withAction:(id(^)(NSDictionary *param))actionBlock;

@end

@protocol TheEventProtocol <TheEventBaseProtocol>

@optional

- (id)startEventWithName:(NSString *)name;
- (id)startEventWithName:(NSString *)name withParam:(NSDictionary *)param;

- (void)addEvent:(NSString *)name withAction:(id(^)(NSDictionary *param))actionBlock;
- (void)addEventPerformOnce:(NSString *)name withAction:(id(^)(NSDictionary *param))actionBlock;

- (void)removeEvent:(NSString *)name;

- (void)addParameter:(NSDictionary *)parameter forEvent:(NSString *)name;

- (void)bindEvent:(NSString *)name withAction:(id(^)(NSDictionary *param))actionBlock;
- (void)bindEventPerformOnce:(NSString *)name withAction:(id(^)(NSDictionary *param))actionBlock;
- (id)fireEventWithName:(NSString *)name;
- (id)fireEvent:(NSString *)name withParam:(NSDictionary *)param;
- (void)unbindEvent:(NSString *)name;

@end
