//
//  TheRouter.m
//  TheRoute
//
//  Created by TheMe on 7/4/16.
//  Copyright © 2016 sdqvsqiu@gmail.com. All rights reserved.
//

#import "TheRouter.h"
#import "NSString+Route.h"
#import "NSDictionary+Route.h"

#import "TheRouteSupport.h"
#import "TheRouterFilterProtocol.h"
#import "Intent.h"

NSString *const theCallBackEvent = @"_the_route_callback_key_";

NSString *const theRetainKey = @"_retain_key_";

NSString *const theParameterKey = @"_parameter_key_";
NSString *const theReturnKey = @"_return_flag_";

NSString *const envRedirect = @"_envRedirect_";
NSString *const envQueryUrl = @"_queryUrl_";

@interface TheRouter() <TheRouteCoreDelegate>

@property (nonatomic,readwrite,strong) NSMutableArray<id<TheRouterFilterProtocol>> *standProcessingFilters;
@property (nonatomic,readwrite,strong) NSMutableArray<id<TheRouterFilterProtocol>> *filters;

@property (nonatomic,strong,readwrite) TheRouteCore *core;
@property (nonatomic,strong) TheRouteSupport *support;
@property (nonatomic,strong,readwrite) NSMutableDictionary *ENVIRONMENT;

@end

@implementation TheRouter
@synthesize ENVIRONMENT = __ENVIRONMENT__;

static TheRouter * _instance = nil;
+ (instancetype)sharedTheRouter
{
    if (!_instance) {
        _instance = [[TheRouter alloc] init];
    }
    return _instance;
    
}
+ (instancetype)allocWithZone:(struct _NSZone*)zone
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [super allocWithZone:zone];
    });
    return _instance;
}

- (instancetype)init
{
    if (self = [super init]) {
        _filters = [@[] mutableCopy];
        _standProcessingFilters = [@[] mutableCopy];
        
        _support = [[TheRouteSupport alloc] init];
        _core = [[TheRouteCore alloc] init];
        _core.map = _support.map = [@{} mutableCopy];
        _core.delegate = self;
    }
    return self;
}

+ (void)load
{
    [_theRoute configRoute];
}

/**
 *  @author thou, 16-07-04 20:07:14
 *
 *  @brief 可以配置多个json文件，键值不重复即可patchDict
 *
 *  @since 1.0
 */
- (void)configRoute
{
    NSDictionary *json = ThemeJson(@"manifest");
    if (json[@"apppath"]) {
        NSDictionary *patchDict = ThemeAppJson(json[@"apppath"][@"filename"], json[@"apppath"][@"themename"]);
        json = [NSDictionary merge:json withDictionary:patchDict];
    }
    
    [self buildFilters:json];
}

#pragma mark - Tool
- (NSString *)queryRoute:(id)object
{
    return [self.core keyForObject:object];
}

- (NSString *)pureUrl:(NSString *)url
{
    return [[self queryUrlValue:url] getUrlBody];
}

- (id)queryUrlValue:(NSString *)urlString
{
    [self setEnv:envQueryUrl value:@(YES)];
    urlString = [self translateUrl:urlString];
    [self setEnv:envQueryUrl value:@(NO)];
    
    return [self.core instanceForKey:urlString];
}

- (void)run:(NSString *)url done:(TheRouterCallBack)callBack
{
    if (callBack) {
        [self addEvent:theCallBackEvent forOnceAction:^id(id  _Nonnull param) {
            callBack(param[@"vc"],param[@"intent"]);
            return nil;
        }];
    }
    [self run:url];
}

- (void)run:(NSString *)url
{
    [self setEnv:envQueryUrl value:@(NO)];
    
    url = [self translateUrl:url];
    if ([NSString isNotEmptyAndNull:url]) {
        @synchronized (self) {
            [self.core consume:url];
        }
    }
}

- (NSString *)translateUrl:(NSString *)url
{
    NSString *urlString = url;
    for (id<TheRouterFilterProtocol> filter in self.standProcessingFilters) {
        if ([filter couldStandProcessingUrl:urlString]) {
            urlString = [self handleUrl:urlString stand:filter];
            if ([self checkRedirect]) {
                [self removeEnv:envRedirect];
                return [self translateUrl:urlString];
            }
        }
    }
    
    if ([url isEqualToString:urlString]) {
        for (id<TheRouterFilterProtocol> filter in self.filters) {
            urlString = [self handleUrl:urlString filter:filter];
            if ([self checkRedirect]) {
                [self removeEnv:envRedirect];
                return [self translateUrl:urlString];
            }
        }
    }
    return urlString;
}

- (NSString *)handleUrl:(NSString *)urlString filter:(id<TheRouterFilterProtocol>)filter
{
    if ([filter respondsToSelector:@selector(routerFilterUrl:)]) {
        urlString = [filter routerFilterUrl:urlString];
    }
    if (filter.needRefreshEnv && [filter respondsToSelector:@selector(withUpdateEnvironment)]) {
        [self addEnv:[filter withUpdateEnvironment]];
    }
    
    if ([filter respondsToSelector:@selector(routerFilterParam:)]){
        Intent *parameterIntent = [self propertyValueForKey:theParameterKey];
        Intent *intent = [filter routerFilterParam:parameterIntent];
        [self addProperty:theParameterKey toValue:intent];
    }
    return urlString;
}

- (NSString *)handleUrl:(NSString *)url stand:(id<TheRouterFilterProtocol>)filter
{
    url = [self handleUrl:url filter:filter];
    
    if ([filter respondsToSelector:@selector(nextFilter)]) {
        NSArray<NSString *> *nextFilterNames =  [filter nextFilter];
        
        for(NSString *filterName in nextFilterNames) {
            filter = [self searchFilter:filterName];
            url = [self handleUrl:url filter:filter];
        }
    }
    
    return url;
}

#pragma mark - env
- (BOOL)checkRedirect
{
    if ([self getEnv:envRedirect]) {
        return YES;
    }
    return NO;
}

- (NSMutableDictionary *)ENVIRONMENT
{
    if (!__ENVIRONMENT__) {
        __ENVIRONMENT__ = [@{} mutableCopy];
    }
    return __ENVIRONMENT__;
}

- (void)addEnv:(NSDictionary *)env
{
    [self environmentWillChange];
    [__ENVIRONMENT__ mergeDictionary:env];
    [self environmentDidChange];
}

- (void)removeEnv:(NSString *)envKey
{
    [self environmentWillChange];
    [__ENVIRONMENT__ removeObjectForKey:envRedirect];
    [self environmentDidChange];
}

- (void)setEnv:(NSString *)key value:(id)value
{
    [self environmentWillChange];
    __ENVIRONMENT__[key] = value;
    [self environmentDidChange];
}

- (id)getEnv:(NSString *)key
{
    return __ENVIRONMENT__[key];
}

- (void)environmentWillChange{}
- (void)environmentDidChange
{
    [self reloadEnvironment:self.filters];
    [self reloadEnvironment:self.standProcessingFilters];
}

- (void)reloadEnvironment:(NSArray<id<TheRouterFilterProtocol>> *)filters
{
    for (id<TheRouterFilterProtocol> filter in filters) {
        if ([filter respondsToSelector:@selector(setENVIRONMENT:)]) {
            [filter setENVIRONMENT:self.ENVIRONMENT];
        }
    }
}

#pragma mark - 增添路由

- (BOOL)respondsToSelector:(SEL)aSelector {
    if ([self.support respondsToSelector:aSelector]) {
        return YES;
    }
    return [super respondsToSelector:aSelector];
}

- (id)forwardingTargetForSelector:(SEL)aSelector {
    if ([self.support respondsToSelector:aSelector]){
        return self.support;
    }
    return [super forwardingTargetForSelector:aSelector];
}

#pragma mark - 配置过滤器

- (id<TheRouterFilterProtocol>)searchFilter:(NSString *)filterName
{
    id<TheRouterFilterProtocol> filter =  [self searchFilter:filterName withFilterList:self.standProcessingFilters];
    if (!filter) {
        filter = [self searchFilter:filterName withFilterList:self.filters];
    }
    return filter;
}

- (id<TheRouterFilterProtocol>)searchFilter:(NSString *)filterName withFilterList:(NSArray<id<TheRouterFilterProtocol>> *)filterList
{
    id<TheRouterFilterProtocol> filter;
    
    for (id<TheRouterFilterProtocol> f in filterList) {
        if ([NSStringFromClass([f class]) isEqualToString:filterName]) {
            filter = f;
        }
    }
    
    return filter;
}

- (void)registerFilter:(id<TheRouterFilterProtocol>)filter
{
    // 设置全局环境变量
    if([filter respondsToSelector:@selector(withNewEnvironment)] )
    {
        [self addEnv:[filter withNewEnvironment]];
    }
    
    // 同步环境变量到过滤器
    if ([filter respondsToSelector:@selector(setENVIRONMENT:)]) {
        [filter setENVIRONMENT:self.ENVIRONMENT];
    }
    
    // 分辨过滤器类型
    if ([filter respondsToSelector:@selector(standProcessing)] && [filter standProcessing]) {
        [_standProcessingFilters addObject:filter];
    }else{
        [_filters addObject:filter];
    }
}

- (void)sortFilters
{
    [_standProcessingFilters sortUsingSelector:@selector(compare:)];
    [_filters sortUsingSelector:@selector(compare:)];
}

- (void)buildFilters:(NSDictionary *)json
{
    NSDictionary *filters = json[@"filters"];
    NSDictionary *disableFilters = json[@"disables"];
    NSDictionary *prioritys = json[@"prioritys"];
    NSDictionary *configFiles = [self buildConfigFiles:json];
    
    for (NSString *routerClassName in filters.allKeys) {
        id<TheRouterFilterProtocol> filter = [[NSClassFromString(routerClassName) alloc] init];
        
        // 设置优先级
        filter.priorityOrder = [prioritys[routerClassName] integerValue];
        
        // 设置禁用项
        if ([disableFilters.allKeys containsObject:routerClassName]) {
            filter.disable = [disableFilters[routerClassName] boolValue];
        }
        
        // 设置配置文件
        NSString *configFileName = filters[routerClassName];
        if (configFileName.length && [configFiles.allKeys containsObject:configFileName]) {
            filter.configFile = configFiles[configFileName];
        }
        
        // 添加过滤器到路由器中
        [self registerFilter:filter];
    }
    [self sortFilters];
}

- (NSMutableDictionary *)buildConfigFiles:(NSDictionary *)json
{
    NSMutableDictionary *configFiles = [@{} mutableCopy];
    NSDictionary *configs = json[@"config"];
    for (NSString *className in configs.allKeys) {
        Class clz = NSClassFromString(className);
        id<TheConfigFileProtocol> configFile = [[clz alloc] init];
        configFiles[className] = configFile;
        
        id jsons = configs[className];
        NSMutableArray *jsonFileNames = [@[] mutableCopy];
        if ([jsons isKindOfClass:[NSString class]]) {
            [jsonFileNames addObject:jsons];
        }else if ([jsons isKindOfClass:[NSArray class]]) {
            for (NSString *jsonFileName in jsons) {
                [jsonFileNames addObject:jsonFileName];
            }
        }
        
        for (NSString *jsonFileName in jsonFileNames) {
            NSDictionary *confDict = ThemeJson(jsonFileName);
            if (json[@"apppath"]) {
                NSDictionary *patchDict = ThemeAppJson(jsonFileName, json[@"apppath"][@"themename"]);
                confDict = [NSDictionary merge:confDict withDictionary:patchDict];
            }
            
            NSDictionary *dict = [configFile buildConfig:confDict];
            !dict?:[self.ENVIRONMENT addEntriesFromDictionary:dict];
        }
    }
    return configFiles;
}

#pragma mark - delegate
- (void)willRoute:(UIViewController *)from to:(UIViewController *)to
{
    NSMutableDictionary *params = [@{} mutableCopy];
    params[@"intent"] = [self queryPropertyValueForKey:theParameterKey];;
    params[@"vc"] = to;
    [self executeEvent:theCallBackEvent withParameter:params];
}

- (UIViewController *)lastViewControllerForKey:(NSString *)routeName
{
    UIViewController *lastvc = nil;
    
    Intent *intent = [self queryPropertyValueForKey:theParameterKey];
    for (NSString *key in intent.extras.allKeys) {
        NSString *retainKey = [NSString stringWithFormat:@"%@%@_%@_",theRetainKey,routeName,key];
        NSDictionary *retainObject = [self queryPropertyValueForKey:retainKey];
        if (retainObject.allKeys) {
            NSString *anyKey = [retainObject.allKeys lastObject];
            NSString *value = [intent getExtra:key];
            if ([value isEqualToString:anyKey]) {
                lastvc = retainObject[anyKey];
                break;
            }
        }
    }
    
    return lastvc;
}

@end
