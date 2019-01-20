//
//  NSDictionary+Route.h
//  TestRoute
//
//  Created by TheMe on 2018/12/4.
//  Copyright © 2018 sdqvsqiu@gmail.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDictionary (Route)

- (NSMutableDictionary *)mergeDictionary:(NSDictionary *)dict;
+ (NSMutableDictionary *)merge:(NSDictionary *)unmerged withDictionary:(NSDictionary *)other;

- (BOOL)judgeDictEqaulStringValue:(NSDictionary *)dict;
- (BOOL)judgeDictEqaulValue:(NSDictionary *)dict;

@end
