//
//  TheRouter.h
//  TheRoute
//
//  Created by TheMe on 7/4/16.
//  Copyright © 2016 sdqvsqiu@gmail.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TheSupportProtocol.h"
#import "TheRouteCore.h"

extern NSString *const theRetainKey;
extern NSString * const theParameterKey;
extern NSString * const theReturnKey;
extern NSString * const envRedirect;
extern NSString * const envQueryUrl;


@protocol TheRouterFilterProtocol;


#define _theRoute [TheRouter sharedTheRouter]
@interface TheRouter : NSObject <TheSupportProtocol>
+ (instancetype)sharedTheRouter;

@property (nonatomic,strong,readonly) TheRouteCore *core;

@property (nonatomic,strong,readonly) NSMutableDictionary *ENVIRONMENT;

// 过滤器集合
@property (nonatomic,readonly,strong) NSArray<id<TheRouterFilterProtocol>> *standProcessingFilters;
@property (nonatomic,readonly,strong) NSArray<id<TheRouterFilterProtocol>> *filters;

- (void)registerFilter:(id<TheRouterFilterProtocol>)filter;
- (__kindof id<TheRouterFilterProtocol>)searchFilter:(NSString *)filterName;

- (NSString *)queryRoute:(id)object;
- (NSString *)pureUrl:(NSString *)url;
- (NSString *)queryUrl:(NSString *)urlString;
- (id)queryUrlValue:(NSString *)url;
- (void)run:(NSString *)url done:(TheRouterCallBack)callBack;
- (void)run:(NSString *)url;

@end
