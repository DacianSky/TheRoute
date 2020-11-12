//
//  TheLoginPermissionFilter.m
//  TheRoute
//
//  Created by TheMe on 7/10/16.
//  Copyright © 2016 sdqvsqiu@gmail.com. All rights reserved.
//

#import "TheLoginPermissionFilter.h"
#import "TheRouter.h"

typedef NS_ENUM(NSInteger,LoginRefreshType) {
    LoginRefreshTypeNone,
    LoginRefreshTypeQueryUrl,
    LoginRefreshTypeRedirect
};

@interface TheLoginPermissionFilter()

@property (nonatomic,assign) LoginRefreshType updateType;

// 对应一个配置类，读取配置信息
@property (nonatomic,strong,readwrite) ThePermissionConfig *configFile;

@end

@implementation TheLoginPermissionFilter
@synthesize ENVIRONMENT = __ENVIRONMENT__;

- (NSDictionary *)withUpdateEnvironment
{
    if (self.needRefreshEnv) {
        if (self.updateType == LoginRefreshTypeRedirect) {
            return @{envRedirect:@(YES)};
        }else if (self.updateType == LoginRefreshTypeQueryUrl){
            return @{envQueryUrl:@(YES)};
        }
    }
    return nil;
}

#pragma mark - 代理方法登录权限过滤
- (NSString *)routerFilterUrl:(NSString *)url
{
    self.needRefreshEnv = NO;
    self.updateType = LoginRefreshTypeNone;
    
    if (self.disable) {
        return url;
    }
    BOOL loginFilter = _loginFilterBlock?_loginFilterBlock():NO;
    if (loginFilter) {
        // 登录用户不需要查看黑白名单过滤。如果block为空或返回结果为nil则需要过滤。
        return url;
    }
    
    NSMutableDictionary *__base_route__ = __ENVIRONMENT__[@"__base_route__"];
    NSString *loginVCName = __base_route__[@"login"];
    
    UINavigationController *nav = [self getAppCurrentNavigation];
    if ([nav.topViewController isKindOfClass:NSClassFromString(loginVCName)] && ([url isEqualToString:loginVCName] ||  [url isEqualToString:@"login"]) ) {
        self.updateType = LoginRefreshTypeQueryUrl;
        self.needRefreshEnv = YES;
        return @"";
    }
    
    // 是否需要被过滤
    BOOL filterFlag;
    if (!self.configFile.isWhitelistEnable) {
        filterFlag = [self checkBlackList:url];
    }else{
        filterFlag = ![self checkWhiteList:url];
    }
    
    NSString *filterUrl = url;
    if(filterFlag){
        NSString *filterActionUrl = _filterAction?_filterAction(filterUrl):filterUrl;
        self.needRefreshEnv = YES;
        if (!filterActionUrl) {
            self.updateType = LoginRefreshTypeQueryUrl;
            filterUrl = @"";
        }else{
            self.updateType = LoginRefreshTypeRedirect;
            filterUrl = filterActionUrl;
        }
    }
    
    return filterUrl;
}

/**
 *  @author thou, 16-07-04 20:07:48
 *
 *  @brief 判断url中是否含有被过滤字段
 *
 *  @return url中含有被过滤字段则返回true
 *
 *  @since 1.0
 */
- (BOOL)checkWhiteList:(NSString *)url
{
    BOOL filterFlag = false;
    for (NSString *key in self.configFile.whitelist) {
        NSArray *fragmentUrls = [url componentsSeparatedByString:@"/"];
        for (NSString *fragmentUrl in fragmentUrls) {
            if ([fragmentUrl rangeOfString:key].location != NSNotFound) {
                filterFlag = true;
            }
        }
    }
    return filterFlag;
}

- (BOOL)checkBlackList:(NSString *)url
{
    BOOL filterFlag = false;
    
    for (NSString *key in self.configFile.blacklist) {
        
        if ([url rangeOfString:key].location != NSNotFound) {
            filterFlag = true;
        }
        
    }
    return filterFlag;
}

- (UINavigationController *)getAppCurrentNavigation
{
    UIViewController *vc = [UIApplication sharedApplication].keyWindow.rootViewController;
    UINavigationController *nav;
    if ([vc isKindOfClass:[UITabBarController class]]) {
        UITabBarController *tabbarVC = (UITabBarController *)vc;
        nav = tabbarVC.selectedViewController;
    }else if ([vc isKindOfClass:[UINavigationController class]]){
        nav = (UINavigationController *)vc;
    }
    return nav;
}

@end
