//
//  TheRouteHelper.h
//  TheRoute
//
//  Created by TheMe on 15/8/11.
//  Copyright (c) 2015年 sdqvsqiu@gmail.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TheRouteHelper : NSObject

/**
 *  @author thou, 16-07-15 14:07:47
 *
 *  @brief 将字典映射为对象参数.
 *
 *  @param object 需要被映射字典内容的对象
 *  @param params 字典对象
 *
 *  @since 1.0
 */
+ (void)map:(id)object params:(NSDictionary *)params;

+ (NSMutableArray *)removeWhiteElement:(NSArray *)array;

+ (UITabBarController *)getAppTabbar;
+ (UINavigationController *)getAppCurrentNavigation;

+ (BOOL)isBlock:(id)value;

@end
