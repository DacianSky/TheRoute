//
//  TheHistoryDirFilter.m
//  TheRoute
//
//  Created by TheMe on 7/11/16.
//  Copyright © 2016 sdqvsqiu@gmail.com. All rights reserved.
//

#import "TheHistoryDirFilter.h"
#import "NSString+Route.h"
#import "TheRouter.h"

extern NSString * const kTheMeRouteScheme;
extern NSString * const kExtraRouteScheme;

@interface TheHistoryDirFilter()

@property (nonatomic,strong) NSMutableArray *historicRecord;

@end

@implementation TheHistoryDirFilter
@synthesize ENVIRONMENT = __ENVIRONMENT__;

- (NSDictionary *)withNewEnvironment
{
    return @{@"historicRecords":[@[@"/"] mutableCopy]};
}

- (NSString *)routerFilterUrl:(NSString *)urlString
{
    if (self.disable) {
        return urlString;
    }
    if ([self.ENVIRONMENT[envQueryUrl] boolValue]) {
        return urlString;
    }
    
    NSString *url = urlString;
    if ([self specialHandle:&url]) {
        return [url copy];
    }
    
    if (![urlString hasPrefix:@"/"] ) {
        urlString = [self handle:urlString];
    }else{
        [self handleAbsoluteForward:urlString];
    }
    
    [self addHistoryRecord:urlString];
    
    return urlString;
}

- (void)addHistoryRecord:(NSString *)url
{
    NSString *resultUrl = url;
    if ([resultUrl hasContainString:@"#"]) {
        resultUrl = [resultUrl removeUrlArg];
    }
    if ([resultUrl hasContainString:@"?"]) {
        resultUrl = [resultUrl deleteAllParameter];
    }
    if (![[self.historicRecord lastObject] isEqualToString:resultUrl]) {
        [self.historicRecord addObject:resultUrl];
    }
}

- (NSString *)handle:(NSString *)URLString
{
    NSString *handleUrl = [[[self currentUrl] stringByAppendingPathComponent:URLString] stringByStandardizingPath];
    
    return handleUrl;
}

/**
 *  @author thou, 16-08-08 16:08:50
 *
 *  @brief 对URL特殊处理
 *
 *  @param purl 传入需要处理的URL
 *
 *  @return 是否处理过URL
 *
 *  @since 1.0
 */
- (BOOL)specialHandle:(NSString **)purl
{
    NSString *backUrl = *purl;
    NSString *recordUrl = nil;
    
    if([backUrl isEqualToString:@"-"]){
        backUrl =  [self shiftLastUrl];
    }else if([backUrl isEqualToString:@"[..]"]){
        recordUrl = [self handleSystemBack];
        backUrl = @"";
    }else if([backUrl hasPrefix:kTheMeRouteScheme]){
        NSString *schemePrefix = [NSString stringWithFormat:@"%@://",kTheMeRouteScheme];
        NSRange schemePrefixRange = [backUrl rangeOfString:schemePrefix];
        backUrl = [backUrl substringFromIndex:NSMaxRange(schemePrefixRange)];
        
        if (![backUrl hasPrefix:@"/"] ) {
            backUrl = [self handle:backUrl];
        }
        
        NSRange paramSeparateRange = [backUrl rangeOfString:@"?"];
        if (paramSeparateRange.location != NSNotFound) {
            recordUrl = [backUrl substringToIndex:paramSeparateRange.location];
        }
    }else if(![self isBreakRuleUrl:backUrl]){
        return NO;
    }
    
    if (!recordUrl) {
        recordUrl = backUrl;
    }
    
    [self addHistoryRecord:[recordUrl copy]];
    
    *purl = backUrl;
    return YES;
}

- (void)handleAbsoluteForward:(NSString *)urlString
{
    UIViewController *rootVC = [UIApplication sharedApplication].keyWindow.rootViewController;
    if (![rootVC isKindOfClass:[UITabBarController class]]) {
        return;
    }
    
    UITabBarController *tabbarVC = (UITabBarController *)rootVC;
    UINavigationController *selectedNav = tabbarVC.selectedViewController;
    UIViewController *stackBottomVC = selectedNav.viewControllers[0];
    NSString *stackBottomRouteName = [NSString stringWithFormat:@"%@%@",@"/",NSStringFromClass([stackBottomVC class]) ];
    if (![urlString hasPrefix:stackBottomRouteName]) {
        if ([selectedNav.topViewController isKindOfClass:NSClassFromString(@"YWWebViewController")]) {
            [selectedNav popViewControllerAnimated:YES];
        }else{
            [selectedNav popToRootViewControllerAnimated:NO];
        }
        [self addHistoryRecord:@"/"];
    }else if(![urlString hasPrefix:[self.historicRecord lastObject]]){
        [tabbarVC.selectedViewController popToRootViewControllerAnimated:NO];
    }
}

- (NSString *)handleSystemBack
{
    NSString *handleUrl = [[[self currentUrl] stringByAppendingPathComponent:@".."] stringByStandardizingPath];
    return handleUrl;
}

- (NSString *)shiftLastUrl
{
    if (self.historicRecord.count<2) {
        return @"";
    }
    NSString *shiftLastUrl = self.historicRecord[self.historicRecord.count-2];
    return shiftLastUrl;
}

- (NSString *)currentUrl
{
    NSString *lastUrl;
    for (NSInteger i = self.historicRecord.count - 1; i >=0 ; i--) {
        lastUrl = self.historicRecord[i];
        if (![self isBreakRuleUrl:lastUrl]) {
            break;
        }
    }
    
    if (!lastUrl || [lastUrl isEqualToString:@"/"]) {
        UINavigationController *nav = [self getAppCurrentNavigation];
        lastUrl = [NSString stringWithFormat:@"/%@",NSStringFromClass([nav.topViewController class])];
    }
    return lastUrl;
}

#pragma mark - lazy load
- (NSMutableArray *)historicRecord
{
    if (!_historicRecord) {
        _historicRecord = __ENVIRONMENT__[@"historicRecords"];
    }
    if (_historicRecord.count>200) {
        // TODO：最多纪录100条历史纪录,之后清空50%写入到文件中。
        [_historicRecord removeObjectAtIndex:0];
    }
    return _historicRecord;
}

#pragma mark - private

- (BOOL)isBreakRuleUrl:(NSString *)url
{
    if([url isEqualToString:@"dismiss"]){
        return YES;
    }else if([url hasPrefix:@"modal://"]){
        return YES;
    }else if([url hasPrefix:@"#"]){
        return YES;
    }
    return NO;
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
