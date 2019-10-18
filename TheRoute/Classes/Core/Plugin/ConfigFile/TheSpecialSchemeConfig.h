//
//  TheSpecialSchemeConfig.h
//  TheRoute
//
//  Created by TheMe on 8/30/16.
//  Copyright © 2016 sdqvsqiu@gmail.com. All rights reserved.
//

#import "TheConfigFileProtocol.h"

@interface TheSpecialSchemeConfig : NSObject<TheConfigFileProtocol>

@property (nonatomic,strong) NSDictionary *specialUrls;

@end
