//
//  ThePermissionConfig.h
//  TheRoute
//
//  Created by TheMe on 7/10/16.
//  Copyright © 2016 sdqvsqiu@gmail.com. All rights reserved.
//

#import "TheConfigFileProtocol.h"

@interface ThePermissionConfig : NSObject <TheConfigFileProtocol>

/**
 *  @author thou, 16-07-04 20:07:29
 *
 *  @brief 是否开启白名单，开启白名单仅仅不过滤白名单；否则只过滤黑名单
 *
 *  @since 1.0
 */
@property (nonatomic) BOOL white_list_enable;
@property (nonatomic,strong) NSMutableArray *whitelist;
@property (nonatomic,strong) NSMutableArray *blacklist;

@end
