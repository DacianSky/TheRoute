//
//  TheAliasConfig.h
//  TheRoute
//
//  Created by TheMe on 7/11/16.
//  Copyright © 2016 sdqvsqiu@gmail.com. All rights reserved.
//

#import "TheConfigFileProtocol.h"

@interface TheAliasConfig : NSObject<TheConfigFileProtocol>

@property (nonatomic,strong) NSMutableDictionary *baseRouters;
@property (nonatomic,strong) NSMutableDictionary *aliasRouters;

@end
