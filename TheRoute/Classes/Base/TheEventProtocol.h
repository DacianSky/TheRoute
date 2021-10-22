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

+ (id)startGroupEvent:(NSString *)group;
+ (id)startGroupEvent:(NSString *)group withParam:(NSDictionary *)param;
+ (id)startGroupEvent:(NSString *)group identifier:(NSString *)aspectIdentifier type:(NSString *)actionType withParam:(NSDictionary *)param;

+ (void)addEvent:(NSString *)name withAction:(id(^)(NSDictionary *param))actionBlock;
+ (void)addEventPerformOnce:(NSString *)name withAction:(id(^)(NSDictionary *param))actionBlock;

+ (void)addEvent:(NSString *)name group:group withAction:(id(^)(NSDictionary *param))actionBlock;
+ (void)addEventPerformOnce:(NSString *)name group:group withAction:(id(^)(NSDictionary *param))actionBlock;

+ (void)removeEvent:(NSString *)name;
+ (void)removeGroupEvent:(NSString *)group;

+ (void)addParameter:(NSDictionary *)parameter forEvent:(NSString *)name;
+ (void)addParameter:(NSDictionary *)parameter forGroup:(NSString *)name;

@end

@protocol TheEventProtocol <TheEventBaseProtocol>

@optional

- (id)startEventWithName:(NSString *)name;
- (id)startEventWithName:(NSString *)name withParam:(NSDictionary *)param;

- (id)startGroupEvent:(NSString *)group;
- (id)startGroupEvent:(NSString *)group withParam:(NSDictionary *)param;
- (id)startGroupEvent:(NSString *)group identifier:(NSString *)aspectIdentifier type:(NSString *)actionType withParam:(NSDictionary *)param;

- (void)addEvent:(NSString *)name withAction:(id(^)(NSDictionary *param))actionBlock;
- (void)addEventPerformOnce:(NSString *)name withAction:(id(^)(NSDictionary *param))actionBlock;

- (void)addEvent:(NSString *)name group:group withAction:(id(^)(NSDictionary *param))actionBlock;
- (void)addEventPerformOnce:(NSString *)name group:(NSString *)group withAction:(id(^)(NSDictionary *param))actionBlock;

- (void)addGroup:(NSString *)group prepareAction:(id(^)(NSDictionary *param))actionBlock;
- (void)addGroup:(NSString *)group afterAction:(id(^)(NSDictionary *param))actionBlock;
- (void)addGroup:(NSString *)group identifier:(NSString *)identifier type:(NSString *)actionType action:(id(^)(NSDictionary *param))actionBlock;

- (void)removeEvent:(NSString *)name;
- (void)removeGroupEvent:(NSString *)group;     // 批量移除事件

- (void)addParameter:(NSDictionary *)parameter forEvent:(NSString *)name;
- (void)addParameter:(NSDictionary *)parameter forGroup:(NSString *)name;

- (void)bindEvent:(NSString *)name withAction:(id(^)(NSDictionary *param))actionBlock;
- (void)bindEventPerformOnce:(NSString *)name withAction:(id(^)(NSDictionary *param))actionBlock;
- (id)fireEventWithName:(NSString *)name;
- (id)fireEvent:(NSString *)name withParam:(NSDictionary *)param;
- (void)unbindEvent:(NSString *)name;

@end
