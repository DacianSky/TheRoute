//
//  TheHttpSchemeFilter.h
//  TheRoute
//
//  Created by TheMe on 7/14/16.
//  Copyright © 2016 sdqvsqiu@gmail.com. All rights reserved.
//

#import "TheBaseRouterFilter.h"

/**
 *  @author thou, 16-07-15 14:07:18
 *
 *  @brief 这个过滤器仅仅用来演示自定义协议是如何使用的。
    如下用来拦截http或https类型的url在web页面显示。
 
    如果使用这种类型的独立协议，使用如下方式打开一个web页面用来显示内容详情。
    Intent *intent = [Intent intentWithRouteName:@"http://www.baidu.com"];
    [self startViewController:intent];
 
    但实际如下用法更为符合设计原意:
     Intent *intent = [Intent intentWithRouteName:@"_http_"];
     [intent putExtra:@"url" value:@"http://www.baidu.com"];
     [self startViewController:intent];
 *
 *  @since 1.0
 */
@interface TheHttpSchemeFilter : TheBaseRouterFilter

@end
