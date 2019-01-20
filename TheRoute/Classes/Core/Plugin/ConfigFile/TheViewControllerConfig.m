//
//  TheViewControllerConfig.m
//  TheRoute
//
//  Created by TheMe on 7/11/16.
//  Copyright © 2016 sdqvsqiu@gmail.com. All rights reserved.
//

#import "TheViewControllerConfig.h"
#import "TheRouter.h"

// 如果某些运行时动态生成的类无法路由，在这里通过配置文件注册
@implementation TheViewControllerConfig

- (NSDictionary *)buildConfig:(id)manifest
{
    [self configRoute_vc_module:manifest];
    return nil;
}

- (void)configRoute_vc_module:(NSDictionary *)manifest
{
    NSDictionary *vc = manifest[@"viewcontroller"];
    if ([manifest[@"usePackageName"] boolValue]) {
        // generate the full name of your class (take a look into your "appname-swift.h" file)
        // let classStringName = "_TtC\(appName!.utf16Count)\(appName!)\(count(className))\(className)"//xcode 6.1-6.2 beta
        //  method2
        //cls = NSClassFromString("\(appName!).\(className)")
        
        NSString *appName = [[NSBundle mainBundle] infoDictionary][@"CFBundleExecutable"];
        
        [vc enumerateKeysAndObjectsUsingBlock:^(NSString *key, NSArray *value, BOOL * _Nonnull stop) {
            [value enumerateObjectsUsingBlock:^(NSString *name, NSUInteger idx, BOOL * _Nonnull stop) {
                // 二选一
//                NSString *vcName = [NSString stringWithFormat:@"_TtC%ld%@%ld%@",appName.length,appName,name.length,name];
//                [_theRoute.core registerKey:name class:vcName];
                
                NSString *vcName = [NSString stringWithFormat:@"%@.%@",appName,name];
                [_theRoute.core registerKey:name class:vcName];
            }];
        }];
    }else{
        [vc enumerateKeysAndObjectsUsingBlock:^(NSString *key, NSArray *value, BOOL * _Nonnull stop) {
            [value enumerateObjectsUsingBlock:^(NSString *name, NSUInteger idx, BOOL * _Nonnull stop) {
                [_theRoute.core registerKey:name class:name];
            }];
        }];
    }
}

@end
