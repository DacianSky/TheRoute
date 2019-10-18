//
//  TheOne2ManyConfig.h
//  TheRoute
//
//  Created by TheMe on 2017/9/14.
//  Copyright © 2017年 sdqvsqiu@gmail.com. All rights reserved.
//

#import "TheConfigFileProtocol.h"

@interface TheOne2ManyConfig : NSObject<TheConfigFileProtocol>

@property (nonatomic,strong) NSDictionary *one2ManyMap;

@end
