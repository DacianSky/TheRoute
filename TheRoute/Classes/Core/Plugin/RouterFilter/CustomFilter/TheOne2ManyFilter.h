//
//  TheOne2ManyFilter.h
//  TheRoute
//
//  Created by TheMe on 2017/9/14.
//  Copyright © 2017年 sdqvsqiu@gmail.com. All rights reserved.
//

#import "TheBaseRouterFilter.h"
#import "TheOne2ManyConfig.h"

/**
 *  会对请求进行重定向，重新执行请求，配置中匹配规则和替换规则相同时将造成循环。
 */
@interface TheOne2ManyFilter : TheBaseRouterFilter

@property (nonatomic,strong,readwrite) TheOne2ManyConfig *configFile;

@end
