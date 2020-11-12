//
//  TheLoginPermissionFilter.h
//  TheRoute
//
//  Created by TheMe on 7/10/16.
//  Copyright © 2016 sdqvsqiu@gmail.com. All rights reserved.
//

#import "TheBaseRouterFilter.h"
#import "ThePermissionConfig.h"

typedef BOOL(^ LoginFilter)(void);
typedef NSString *(^ FilterAction)(NSString *filterUrl);

@interface TheLoginPermissionFilter : TheBaseRouterFilter

/**
 *  @author thou, 16-07-05 11:07:43
 *
 *  @brief 存放判定用户是否登录成功的block，用于黑白名单过滤。block返回YES代表是登录状态。
 *
 *  @since 1.0
 */
@property (nonatomic,copy) LoginFilter loginFilterBlock;

/**
 *  @author TheMe, 20-11-06 18:16:06
 *
 *  @brief 确定过滤之后的行为处理
 *
 *  @since 1.0
 */
@property (nonatomic,copy) FilterAction filterAction;

@end
