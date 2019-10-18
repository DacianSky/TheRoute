//
//  TheRouteCore.m
//  TheRoute
//
//  Created by TheMe on 7/4/16.
//  Copyright © 2016 sdqvsqiu@gmail.com. All rights reserved.
//

#import "TheRouteCore.h"
#import "TheRouteHelper.h"
#import "NSString+Route.h"
#import "TheRouteConst.h"
#import "TheEventProtocol.h"

#define dispatch_async_main_safe(block)\
if ([NSThread isMainThread]) {\
    block();\
} else {\
    dispatch_async(dispatch_get_main_queue(), block);\
}

@implementation TheRouteCore

- (instancetype)init
{
    if (self = [super init]){
    }
    return self;
}

#pragma mark - register key
- (void)registerKey:(NSString *)key action:(TheRouteMapAction)action
{
    if ([NSString isNotEmptyAndNull:key]) {
        self.map[key] = action;
    }
}

- (void)registerKey:(NSString *)key class:(NSString *)name
{
    if ([NSString isNotEmptyAndNull:key]) {
        self.map[key] = name;
    }
}

- (void)registerKey:(NSString *)key instance:(UIViewController *)vc
{
    if ([NSString isNotEmptyAndNull:key]) {
        self.map[key] = vc;
    }
}

- (void)unregisterKey:(NSString *)key
{
    if ([NSString isNotEmptyAndNull:key]) {
        [self.map removeObjectForKey:key];
    }
}

#pragma mark - query & execute
- (NSString *)keyForObject:(id)object
{
    NSString *swiftName = nil;  // 有值代表object是字符串
    if ([object isKindOfClass:[NSString class]]) {
        swiftName = [object nameOC2Swift];
    }
    for (NSString *key in self.map) {
        NSString *value = self.map[key];
        if (value == object){
            return key;
        }else if (swiftName && [value isKindOfClass:[NSString class]] && [value isEqualToString:object]){
            return key;
        }else if (swiftName && [value isKindOfClass:[NSString class]] && [value isEqualToString:swiftName]){
            return key;
        }else if (swiftName && [key isEqualToString:object]){
            return key;
        }else if (swiftName && [key isEqualToString:swiftName]){
            return key;
        }
    }
    return nil;
}

- (id)instanceForKey:(NSString *)key
{
    id value = self.map[key];
    
    UIViewController *vc = nil;
    if ([value isKindOfClass:[NSString class]]){
        vc = [[NSClassFromString((NSString *)value) alloc] init];
    }else if([TheRouteHelper isBlock:value]){
        vc = ((TheRouteMapAction)value)();
    }else if ([value isKindOfClass:[UIViewController class]]){
        vc = (UIViewController *)value;
    }else{
        vc = [[NSClassFromString(key) alloc] init];
        if (!vc) {
            vc = [[NSClassFromString([key nameOC2Swift]) alloc] init];
        }
    }
    return vc;
}

- (NSString *)parse:(NSString *)parse
{
    if (![parse hasPrefix:@"/"]) {
        parse = [[[self currentPath] stringByAppendingPathComponent:parse] stringByStandardizingPath];
    }
    return parse;
}

- (void)consume:(NSString *)url
{
    if ([NSString isEmptyOrNull:url] || [self executeException:url]) {
        return;
    }
    NSDictionary *param = [url getAllParameterDict];
    NSString *parse = [self parse:[url getUrlBody]];
    
    UIViewController *fromVC = [TheRouteHelper getAppCurrentNavigation].topViewController;
    [self prepareSelectTabbar:parse];
    
    
    NSString *path = [self currentPath];
    NSString *samePath = subSameComponent(path, parse, '/');
    BOOL done = [samePath isEqualToString:parse];
    NSMutableArray *components = [TheRouteHelper removeWhiteElement:[samePath componentsSeparatedByString:@"/"]];
    
    UINavigationController *nav = [TheRouteHelper getAppCurrentNavigation];
    
    NSInteger index = components.count;
    NSArray *bottomvcs = [nav.viewControllers subarrayWithRange:NSMakeRange(0, index>1?index:1)];
    if (done){
        // pop
        UIViewController *toVC = bottomvcs.lastObject;
        
        BOOL animation = YES;
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
        if ([toVC respondsToSelector:@selector(dismissAnimation)]) { animation = (BOOL)[toVC performSelector:@selector(dismissAnimation)];}
#pragma clang diagnostic pop
        
        dispatch_async_main_safe(^{
            [self willRoute:fromVC to:toVC];
            [self onRoute:toVC param:param];
            [nav popToViewController:toVC animated:animation];
            [self didRoute:toVC to:toVC];
        });
    }else {
        // push
        parse = [parse substringFromIndex:samePath.length];
        components = [TheRouteHelper removeWhiteElement:[parse componentsSeparatedByString:@"/"]];
        
        UIViewController *toVC = nil;
        do{
            NSString *key = [components lastObject];
            [components removeLastObject];
            toVC = [self lastViewControllerForKey:key];
            if (!toVC || [bottomvcs containsObject:toVC]) {
                toVC = [self instanceForKey:key];
            }
        }while (!toVC && components.count);
        toVC.hidesBottomBarWhenPushed = YES;
        
        BOOL animation = YES;
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
        if ([toVC respondsToSelector:@selector(showAnimation)]) { animation = (BOOL)[toVC performSelector:@selector(showAnimation)];}
        if ([toVC respondsToSelector:@selector(transition)]) {nav.delegate = [toVC performSelector:@selector(transition)];}else{nav.delegate = nil;}
#pragma clang diagnostic pop
        
        NSMutableArray *vcs = [bottomvcs mutableCopy];
        for (int i = 0 ; i < components.count; i++) {
            NSString *key = components[i];
            UIViewController *vc = [self instanceForKey:key];
            if (!vc) {
                continue;
            }
            vc.hidesBottomBarWhenPushed = YES;
            [vcs addObject:vc];
        }
        
        dispatch_async_main_safe(^{
            [self willRoute:fromVC to:toVC];
            [self onRoute:toVC param:param]; //这里的设置参数才会直接初始化；TheIntentProtocol里面的初始化时机在loadView和viewWillAppear:，避免参数提前被消化
            [nav setViewControllers:vcs animated:NO];
            [nav pushViewController:toVC animated:animation];
            [self didRoute:toVC to:toVC];
        });
    }
}

- (void)prepareSelectTabbar:(NSString *)url
{
    if ([NSString isEmptyOrNull:url]) {
        return;
    }
    
    UITabBarController *tbc = [TheRouteHelper getAppTabbar];
    if (!tbc) {
        return;
    }
    for (int i = 0; i < tbc.viewControllers.count; i++) {
        UINavigationController *nav = tbc.viewControllers[i];
        if (![nav isKindOfClass:[UINavigationController class]]) {
            continue;
        }
        UIViewController *bottomVC = nav.viewControllers[0];
        if (![url hasPrefix: [NSString stringWithFormat:@"/%@",NSStringFromClass(bottomVC.class)] ]) {
            continue;
        }
        if (tbc.selectedIndex != i) {
            [self willSelectTabbar];
            [(UINavigationController *)tbc.selectedViewController popToRootViewControllerAnimated:NO];
            tbc.selectedIndex = i;
            UINavigationController *nav = tbc.selectedViewController;
            [(id<UITabBarControllerDelegate>)tbc.delegate tabBarController:tbc didSelectViewController:nav.topViewController];
            [self didSelectTabbar];
        }
        break;
    }
}

#pragma mark - 处理例外
- (BOOL)executeException:(NSString *)url
{
    return [self executeExceptionModal:url] || [self executeExceptionDismiss:url];
}

- (BOOL)executeExceptionModal:(NSString *)url
{
    if (![url supportScheme:@"modal"]){
        return NO;
    }
    
    UIViewController *vc = [self instanceForKey:[url getUrlBody]];
    [TheRouteHelper map:vc params:[url getAllParameterDict]];
    
    UINavigationController *nav = [TheRouteHelper getAppCurrentNavigation];
    [nav presentViewController:vc animated:YES completion:nil];
    return YES;
}

- (BOOL)executeExceptionDismiss:(NSString *)url
{
    if (![url isEqualToString:@"dismiss"]){
        return NO;
    }
    
    UINavigationController *nav = [TheRouteHelper getAppCurrentNavigation];
    UIViewController *mvc = nav.presentedViewController;
    
    BOOL animation = YES;
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
    if ([mvc respondsToSelector:@selector(dismissAnimation)]) { animation = (BOOL)[mvc performSelector:@selector(dismissAnimation)];}
#pragma clang diagnostic pop
    UIViewController *vc = nav.visibleViewController;
    [mvc dismissViewControllerAnimated:animation completion:^{
        if (mvc.modalPresentationStyle == UIModalPresentationOverCurrentContext) {
            [vc viewWillAppear:animation];
        }
    }];
    
    return YES;
}

#pragma mark - private
- (NSString *)currentPath
{
    NSString *currentUrl = @"";
    UINavigationController *nav = [TheRouteHelper getAppCurrentNavigation];
    for (UIViewController *vc in nav.viewControllers) {
        currentUrl = [currentUrl stringByAppendingString:@"/"];
        currentUrl = [currentUrl stringByAppendingString:NSStringFromClass([vc class])];
    }
    return currentUrl;
}

#pragma mark - delegate
- (UIViewController *)lastViewControllerForKey:(NSString *)key
{
    if ([self.delegate respondsToSelector:@selector(lastViewControllerForKey:)]) {
        return [self.delegate lastViewControllerForKey:key];
    }
    return nil;
}

- (void)willRoute:(UIViewController *)from to:(UIViewController *)to
{
    if ([self.delegate respondsToSelector:@selector(willRoute:to:)]) {
        [self.delegate willRoute:from to:to];
    }
}

- (void)onRoute:(UIViewController *)dest param:(NSDictionary *)param
{
    [TheRouteHelper map:dest params:param];
    if (dest.parentViewController) {
        theExecuteUndeclaredSelector(dest,@selector(paramAppear));
    }else{
        theExecuteUndeclaredSelector(dest,@selector(paramInit));
    }
    if ([self.delegate respondsToSelector:@selector(onRoute:param:)]) {
        [self.delegate onRoute:dest param:param];
    }
}

- (void)didRoute:(UIViewController *)from to:(UIViewController *)to
{
    if ([self.delegate respondsToSelector:@selector(didRoute:to:)]) {
        [self.delegate didRoute:from to:to];
    }
}

- (void)willSelectTabbar
{
    if ([self.delegate respondsToSelector:@selector(willSelectTabbar)]) {
        [self.delegate willSelectTabbar];
    }
}

- (void)didSelectTabbar
{
    if ([self.delegate respondsToSelector:@selector(didSelectTabbar)]) {
        [self.delegate didSelectTabbar];
    }
}

@end
