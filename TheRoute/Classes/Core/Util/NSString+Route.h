//
//  NSString+Route.h
//  TheRoute
//
//  Created by TheMe on 2018/12/4.
//  Copyright © 2018 sdqvsqiu@gmail.com. All rights reserved.
//

#import <Foundation/Foundation.h>

#define ThemeJson(filename) [NSString jsonWithFileName:(filename)]
#define ThemeAppJson(filename,themename) [NSString jsonWithAppFileName:(filename) andThemeName:(themename)]

NS_ASSUME_NONNULL_BEGIN

NSString * subSameComponent(NSString *str1,NSString *str2, char separate);

@interface NSString (Route)

- (BOOL)isHttpUrl;
- (BOOL)isTheRouteUrl;
- (BOOL)supportScheme:(NSString *)scheme;

- (NSString *)routeDecode;
- (NSString *)routeencode;

/**
 *  解析一个url，将url中参数转换为字典
 *
 *  @return 以字典形式存放的参数
 */
- (NSDictionary *)paramsToDict;

/**
 *  将占位符替换为字典中对应的值。
 *
 *  @param dict 如果是可变字典会移除所有已被替换的键值对。
 *
 *  @return 返回值为替换后的url。
 */
- (NSString *)parseURLPlacehold:(NSDictionary *)dict;
- (NSString *)replaceUrlComponent:(NSString *)componenyKey value:(NSString *)componentValue;

- (NSString *)getParameter:(NSString *)parameter;
- (NSDictionary *)getAllParameterDict;
- (NSArray<NSString *> *)getAllParameter;

- (NSString *)deleteScheme;
- (NSString *)deleteParameter:(NSString *)parameter;
- (NSString *)deleteEnsureParameter:(NSString *)parameter;
- (NSString *)deleteAllParameter;

- (NSString *)addParameter:(NSString *)parameter;
- (NSString *)addParameter:(NSString *)parameter withValue:(NSString *)value;

- (NSString *)getUrlArg;
- (NSString *)addUrlArg:(NSString *)urlArg;
- (NSString *)removeUrlArg;

- (NSString *)getUrlBody;

- (BOOL)hasContainString:(NSString *)string;
+ (BOOL)isEmptyOrNull: (NSString *)string;
+ (BOOL)isNotEmptyAndNull: (NSString *)string;

- (NSString *)nameOC2Swift;
- (NSString *)nameSwift2OC;

// 替换匹配的字符串为指定规则
- (NSString *)regexReplce:(NSString *)regular handle:(NSString *)handle;

#pragma mark - json
+ (id)jsonWithFileName:(NSString *)filename;
+ (id)jsonWithAppFileName:(NSString *)filename andThemeName:(NSString *)themeName;

@end

NS_ASSUME_NONNULL_END
