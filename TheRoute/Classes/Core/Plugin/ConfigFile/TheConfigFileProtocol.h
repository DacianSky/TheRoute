//
//  TheConfigFileProtocol.h
//  TheRoute
//
//  Created by TheMe on 7/10/16.
//  Copyright © 2016 sdqvsqiu@gmail.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol TheConfigFileProtocol <NSObject>

/**
 *  @author thou, 16-07-11 15:07:26
 *
 *  @brief 根据路由配置文件处理路由
 *
 *  @param manifest 读取的路由配置文件
 *
 *  @return 返回自己对环境变量的更改
 *
 *  @since 1.0
 */
- (NSDictionary *)buildConfig:(id)manifest;

@end
