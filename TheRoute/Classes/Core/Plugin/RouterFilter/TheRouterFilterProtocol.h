//
//  TheRouterFilterProtocol.h
//  TheRoute
//
//  Created by TheMe on 7/10/16.
//  Copyright © 2016 sdqvsqiu@gmail.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TheConfigFileProtocol.h"

@class Intent;
@protocol TheConfigFileProtocol;

@protocol TheRouterFilterProtocol <NSObject>

// 优先级默认为0，需要在配置文件中修改。
@property (nonatomic,assign) NSInteger priorityOrder;
@property (nonatomic,assign) BOOL disable;
@property (nonatomic) BOOL needRefreshEnv;

- (NSComparisonResult)compare:(id<TheRouterFilterProtocol>)filter;

@optional

@property (nonatomic) BOOL standProcessing;
- (BOOL)couldStandProcessingUrl:(NSString *)url;

@property (nonatomic,strong) NSMutableDictionary *ENVIRONMENT;
- (NSDictionary *)withNewEnvironment; // 初始化添加新环境变量
- (NSDictionary *)withUpdateEnvironment; // 更新环境变量

- (NSArray<NSString *> *)nextFilter;

- (NSString *)routerFilterUrl:(NSString *)url;
- (Intent *)routerFilterParam:(Intent *)paramIntent;

// 对应一个配置类，读取配置信息
- (void)setConfigFile:(id<TheConfigFileProtocol>)configFile;
- (id<TheConfigFileProtocol>)configFile;

@end
