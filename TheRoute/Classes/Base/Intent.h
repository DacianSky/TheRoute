//
//  Intent.h
//  TheRoute
//
//  Created by TheMe on 7/7/16.
//  Copyright © 2016 sdqvsqiu@gmail.com. All rights reserved.
//

#import "IntentCategory.h"

@interface Intent : NSObject <NSCopying>

@property (nonatomic,copy) NSString *routeName;

+ (Intent *)intentWithExtras:(NSDictionary *)extras;
+ (Intent *)intentWithCategory:(IntentCategory)intentCategory;
+ (Intent *)intentWithRouteName:(NSString *)routeName;

@property (nonatomic,assign) IntentParamOccasion paramOccasion;
@property (nonatomic) IntentCategory category;

- (NSString *)absoluteRoute;

@property (nonatomic,strong,readonly) NSDictionary *extras;

- (BOOL)existExtra:(NSString *)key;
- (id)getExtra:(NSString *)key;
- (void)removeExtra:(NSString *)key;
- (void)removeExtras:(NSArray *)keys;
- (void)putExtra:(NSString *)key value:(id)value;
- (void)putExtras:(NSDictionary *)extras;

@end
