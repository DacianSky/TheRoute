//
//  Intent.m
//  TheRoute
//
//  Created by TheMe on 7/7/16.
//  Copyright © 2016 sdqvsqiu@gmail.com. All rights reserved.
//

#import "Intent.h"
#import "NSString+Route.h"

@interface Intent()

@property (nonatomic,strong,readwrite) NSMutableDictionary *extras;

@end

@implementation Intent

- (instancetype)init
{
    if (self = [super init]) {
        _paramOccasion = IntentParamOccasionBoth;
        _category = IntentCategoryDefault;
        _routeName = @".";  //默认是当前目录
        _extras = [@{} mutableCopy];
    }
    return self;
}

// 不能同时支持参数和锚点符号,如果有锚点，需要手动将参数添加到intent中
- (void)setRouteName:(NSString *)routeName
{
    if ([routeName isHttpUrl]) {
        routeName = [routeName theRouteDecode];
    }else{
        NSDictionary *params = [routeName paramsToDict];
        [self putExtras:params];
    }
    _routeName = routeName;
}

+ (Intent *)intentWithExtras:(NSDictionary *)extras
{
    Intent *intent = [[Intent alloc] init];
    [intent putExtras:extras];
    return intent;
}

+ (Intent *)intentWithCategory:(IntentCategory)intentCategory
{
    Intent *intent = [[Intent alloc] init];
    intent.category = intentCategory;
    return intent;
}

+ (Intent *)intentWithRouteName:(NSString *)routeName
{
    Intent *intent = [[Intent alloc] init];
    intent.routeName = routeName;
    return intent;
}

- (NSString *)absoluteRoute
{
    return self.routeName;
}

- (BOOL)existExtra:(NSString *)key
{
    if ([self.extras.allKeys containsObject:key]) {
        return YES;
    }
    return NO;
}

- (id)getExtra:(NSString *)key
{
    return _extras[key];
}

- (void)removeExtra:(NSString *)key
{
    if (_extras.count) {
        [_extras removeObjectForKey:key];
    }
}

- (void)removeExtras:(NSArray *)keys
{
    for (NSString *key in keys) {
        [_extras removeObjectForKey:key];
    }
}

- (void)putExtra:(NSString *)key value:(id)value
{
    _extras[key] = value;
}

- (void)putExtras:(NSDictionary *)extras
{
    if (extras) {
        for (NSString *key in extras.allKeys) {
            [self putExtra:key value:extras[key]];
        }
    }
}

- (id)copyWithZone:(nullable NSZone *)zone
{
    Intent *intent = [[Intent alloc] init];
    intent.routeName = [self.routeName copy];
    intent.extras = [self.extras mutableCopy];
    intent.category = self.category;
    intent.paramOccasion = self.paramOccasion;
    
    return intent;
}

@end
