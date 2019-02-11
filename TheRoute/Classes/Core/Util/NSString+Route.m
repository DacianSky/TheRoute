//
//  NSString+Route.m
//  TheRoute
//
//  Created by TheMe on 2018/12/4.
//  Copyright © 2018 sdqvsqiu@gmail.com. All rights reserved.
//

#import "NSString+Route.h"

#define kTheRouteBundleName @"TheRoute.bundle"
#define kThemeName @"theme.bundle"

// 为你的app定义一个kTheMeRouteScheme全局变量，用来区分路由的自定义前缀
NSString * kTheMeRouteScheme = @"route";
void theInitRouteScheme(NSString *scheme)
{
    kTheMeRouteScheme = scheme;
}

// 为你的app定义一个额外kExtraRouteScheme全局变量，用来区分路由的特殊情况下自定义前缀
NSString * kExtraRouteScheme = @"theme";
void theInitExtraScheme(NSString *scheme)
{
    kExtraRouteScheme = scheme;
}

@implementation NSString (Route)

- (BOOL)isHttpUrl
{
    NSString *url = [self lowercaseString];
    if ([url hasPrefix:@"http"] || [url hasPrefix:@"https"] || [url hasPrefix:@"http%3A%2F%2F"] || [url hasPrefix:@"https%3A%2F%2F"]) {
        return YES;
    }
    return NO;
}

- (BOOL)isTheRouteUrl
{
    if ([self supportScheme:kTheMeRouteScheme] || [self supportScheme:kExtraRouteScheme]) {
        return YES;
    }
    return NO;
}

- (BOOL)supportScheme:(NSString *)scheme
{
    NSString *schemePrefix = [NSString stringWithFormat:@"%@://",scheme];
    if ([self hasPrefix:schemePrefix]) {
        return YES;
    }
    return NO;
}

- (NSString *)theRouteDecode
{
    NSString *unencodedString = self;
    NSString *encodedString = (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault,(CFStringRef)unencodedString,NULL,(CFStringRef)@"!*'();:@&=+$,/?%#[]",kCFStringEncodingUTF8));
    
    return encodedString;
}

- (NSString *)theRouteEncode
{
    NSString *result = [(NSString *)self stringByReplacingOccurrencesOfString:@"+" withString:@" "];
    result = [result stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    return result;
}

- (NSDictionary *)paramsToDict
{
    //获取问号到锚点的位置，问号后是参数列表
    NSString *regular = @"\\?-?[^#]+";
    NSRange range = [self rangeOfString:regular options:NSRegularExpressionSearch];
    //    thouLog(@"参数列表开始的位置：%d", (int)range.location);
    if (range.location == NSNotFound) {
        return @{};
    }
    
    //获取参数列表
    range.location++;
    range.length--;
    NSString *propertys = [self substringWithRange:range];
    //    thouLog(@"截取的参数列表：%@", propertys);
    
    //进行字符串的拆分，通过&来拆分，把每个参数分开
    NSArray *subArray = [propertys componentsSeparatedByString:@"&"];
    //    thouLog(@"把每个参数列表进行拆分，返回为数组：n%@", subArray);
    
    //把subArray转换为字典
    //tempDic中存放一个URL中转换的键值对
    NSMutableDictionary *paramDict = [NSMutableDictionary dictionaryWithCapacity:4];
    
    for (int j = 0 ; j < subArray.count; j++){
        //在通过=拆分键和值
        NSArray *dicArray = [subArray[j] componentsSeparatedByString:@"="];
        //        thouLog(@"再把每个参数通过=号进行拆分：n%@", dicArray);
        //给字典加入元素
        if(dicArray.count>=2){
            NSString *key = dicArray[0];
            NSString *value = [dicArray[1] theRouteEncode];
            
            id dictValue = paramDict[key];
            if ([dictValue isKindOfClass:[NSString class]]) {
                NSMutableArray *list = [@[] mutableCopy];
                [list addObject:dictValue];
                [list addObject:value];
                paramDict[key] = list;
            }else if ([dictValue isKindOfClass:[NSMutableArray class]]) {
                NSMutableArray *list = (NSMutableArray *)dictValue;
                [list addObject:value];
                paramDict[key] = list;
            }else{
                paramDict[key] = value;
            }
        }
    }
    //    thouLog(@"打印参数列表生成的字典：n%@", tempDic);
    
    return paramDict;
}

- (NSString *)parseURLPlacehold:(NSDictionary *)dict
{
    NSMutableString *resultUrl = [self mutableCopy];
    
    for (NSString *key in dict.allKeys) {
        NSString *value = dict[key];
        BOOL replaceResult = [self replaceEL:resultUrl key:key withValue:value];
        
        if (replaceResult && [dict isKindOfClass:[NSMutableDictionary class]]) {
            [((NSMutableDictionary *)dict) removeObjectForKey:key];
        }
    }
    
    return resultUrl;
}

/**
 *  单次替换url中占位符为实际参数
 *
 *  @param resultUrl 被替换的url地址可变字符串
 *  @param key       被替换占位名
 *  @param value     被替换占位值
 *
 *  @return          替换是否成功
 */
- (BOOL)replaceColon:(NSMutableString *)resultUrl key:(NSString *)key withValue:(NSString *)value
{
    BOOL result = NO;
    
    NSString *searchKey = [NSString stringWithFormat:@":%@/",key];
    
    NSRange patternRange = [resultUrl rangeOfString:searchKey];
    
    if(patternRange.location != NSNotFound && patternRange.length > 2){
        patternRange.length = patternRange.length - 1;
        [resultUrl replaceCharactersInRange:patternRange withString:value];
        result = YES;
    }
    
    return result;
}

/**
 *  单次替换url中占位符为实际参数
 *
 *  @param resultUrl 被替换的url地址可变字符串
 *  @param key       被替换占位名
 *  @param value     被替换占位值
 *
 *  @return          替换是否成功
 */
- (BOOL)replaceEL:(NSMutableString *)resultUrl key:(NSString *)key withValue:(id)value
{
    BOOL result = NO;
    
    NSString *searchKey = [NSString stringWithFormat:@"{%@}",key];
    
    NSRange patternRange = [resultUrl rangeOfString:searchKey];
    
    if(patternRange.location != NSNotFound && patternRange.length > 2){
        result = YES;
        if ([value isKindOfClass:[NSString class]]) {
            [resultUrl replaceCharactersInRange:patternRange withString:[value theRouteDecode]];
        }else if ([value isKindOfClass:[NSNumber class]]) {
            NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
            NSString *numberStr = [formatter stringFromNumber:value];
            [resultUrl replaceCharactersInRange:patternRange withString:numberStr];
        }else{
            result = NO;
        }
    }
    
    return result;
}

- (NSString *)replaceUrlComponent:(NSString *)componenyKey value:(NSString *)componentValue
{
    NSString *resultUrl = [self copy];
    NSString *pattern = [NSString stringWithFormat:@"(^|/?)(%@)($|/|#|\\?)",componenyKey]; // /?[(%@)/|(%@)$]
    NSRegularExpression *regular = [[NSRegularExpression alloc] initWithPattern:pattern options:0  error:nil];
    if (regular != nil) {
        NSArray *matchs = [regular matchesInString:resultUrl options:0 range:NSMakeRange(0, [resultUrl length])];
        NSEnumerator *enume = [matchs reverseObjectEnumerator];
        
        NSTextCheckingResult *match;
        while (match = [enume nextObject]) {
            NSRange resultRange = [match rangeAtIndex:2];
            if (resultRange.location != NSNotFound) {
                resultUrl = [resultUrl stringByReplacingCharactersInRange:resultRange withString:componentValue];
            }
        }
    }
    
    return resultUrl;
}

// 获取URL中的某个参数(不能获取到数组参数)
- (NSString *)getParameter:(NSString *)parameter
{
    NSError *error;
    
    NSString *regTags = [[NSString alloc] initWithFormat:@"(^|&|\\?)+%@=+([^&]*)(&|$)",parameter];
    NSRegularExpression *regex =
    [NSRegularExpression regularExpressionWithPattern:regTags options:NSRegularExpressionCaseInsensitive error:&error];
    
    NSArray *matches =
    [regex matchesInString:self options:0 range:NSMakeRange(0, [self length])];
    
    for (NSTextCheckingResult *match in matches){
        NSString *tagValue = [self substringWithRange:[match rangeAtIndex:2]]; //分组2所对应的串
        return tagValue;
    }
    return @"";
}

- (NSDictionary *)getAllParameterDict
{
    NSString *url = [self copy];
    NSArray *paramStrs = [url getAllParameter];
    
    NSMutableDictionary *paramDict = [@{} mutableCopy];
    for (NSString *paramStr in paramStrs) {
        NSArray *paramKV = [paramStr componentsSeparatedByString:@"="];
        if (paramKV.count == 2) {
            NSString *key = [paramKV firstObject];
            NSString *value = [[paramKV lastObject] theRouteEncode];
            if ([NSString isNotEmptyAndNull:key] && [NSString isNotEmptyAndNull:value]) {
                id dictValue = paramDict[key];
                if ([dictValue isKindOfClass:[NSString class]]) {
                    NSMutableArray *list = [@[] mutableCopy];
                    [list addObject:dictValue];
                    [list addObject:value];
                    paramDict[key] = list;
                }else if ([dictValue isKindOfClass:[NSMutableArray class]]) {
                    NSMutableArray *list = (NSMutableArray *)dictValue;
                    [list addObject:value];
                    paramDict[key] = list;
                }else{
                    paramDict[key] = value;
                }
            }
        }
    }
    
    return paramDict;
}

- (NSArray<NSString *> *)getAllParameter
{
    NSString *url = [self copy];
    url = [url removeUrlArg];
    if ([url containsString:@"?"]) {
        //        NSRange range = [url rangeOfString:@"?"];
        //        url = [url substringFromIndex:range.location + range.length];
        url = [[url componentsSeparatedByString:@"?"] lastObject];
        NSArray *paramStrs = [url componentsSeparatedByString:@"&"];
        return paramStrs;
    }
    return @[];
}

- (NSString *)deleteScheme
{
    NSString *url = [self copy];
    NSArray *uls = [url componentsSeparatedByString:@"://"];
    if (uls.count <= 1) {
        return url;
    }
    return uls[1];
}

//删除URL中的某个参数：
- (NSString *)deleteParameter:(NSString *)parameter
{
    NSString *url = [self copy];
    
    NSArray *allParam = [url getAllParameter];
    NSMutableArray *params = [allParam mutableCopy];
    for (NSString *param in allParam) {
        if ([param hasPrefix:[NSString stringWithFormat:@"%@=",parameter]]) {
            [params removeObject:param];
            break;
        }
    }
    
    NSString *finalStr = [url deleteAllParameter];
    for (NSString *param in params) {
        finalStr = [finalStr addParameter:param];
    }
    return finalStr;
}

- (NSString *)deleteEnsureParameter:(NSString *)parameter
{
    NSString *url = [self copy];
    
    NSArray *allParam = [url getAllParameter];
    NSMutableArray *params = [allParam mutableCopy];
    for (NSString *param in allParam) {
        if ([param isEqualToString:parameter]) {
            [params removeObject:param];
            break;
        }
    }
    
    NSString *finalStr = [url deleteAllParameter];
    for (NSString *param in params) {
        finalStr = [finalStr addParameter:param];
    }
    return finalStr;
}

- (NSString *)deleteAllParameter
{
    NSString *result = self;
    
    NSRange range = [result rangeOfString:@"\\?[a-zA-Z=_&{,}0-9:/%\\-.\u4e00-\u9fa5]+#?" options:NSRegularExpressionSearch];
    
    if (range.location != NSNotFound) {
        NSString *subStr = [result substringWithRange:range];
        if ([subStr hasSuffix:@"#"]) {
            range.length--;
        }
        result = [result stringByReplacingCharactersInRange:range withString:@""];
    }
    return result;
}

- (NSString *)addParameter:(NSString *)parameter
{
    NSString *url = [self copy];
    NSString *arg = [url getUrlArg];
    url = [url removeUrlArg];
    if ([url hasContainString:@"?"]) {
        url = [NSString stringWithFormat:@"%@&%@",url, parameter];
    }else{
        url = [NSString stringWithFormat:@"%@?%@",url, parameter];
    }
    url = [url addUrlArg:arg];
    return url;
}

- (NSString *)addParameter:(NSString *)parameter withValue:(NSString *)value
{
    NSString *param = [NSString stringWithFormat:@"%@=%@",parameter,value];
    return [self addParameter:param];
}

- (NSString *)getUrlArg
{
    NSString *url = [self copy];
    NSRange range = [url rangeOfString:@"#[a-zA-Z,:0-9]+\\/?" options:NSRegularExpressionSearch];
    
    NSString *result = nil;
    if (range.location != NSNotFound) {
        result = [url substringWithRange:range];
    }
    
    return result;
}

- (NSString *)addUrlArg:(NSString *)urlArg
{
    NSString *url = [self copy];
    if ([NSString isEmptyOrNull:urlArg]) {
        return url;
    }
    return [NSString stringWithFormat:@"%@%@",url,urlArg];
}

- (NSString *)removeUrlArg
{
    NSString *result = self;
    
    NSRange range = [result rangeOfString:@"#[a-zA-Z,:0-9]+\\/?" options:NSRegularExpressionSearch];
    
    if (range.location != NSNotFound) {
        NSString *subStr = [result substringWithRange:range];
        if ([subStr hasSuffix:@"/"]) {
            range.length--;
        }
        result = [result stringByReplacingCharactersInRange:range withString:@""];
    }
    
    return result;
}

- (NSString *)getUrlBody
{
    NSString *url = [self copy];
    url = [url removeUrlArg];
    url = [url deleteAllParameter];
    return url;
}

- (BOOL)hasContainString:(NSString *)string
{
    if([self rangeOfString:string].location != NSNotFound)
    {
        return YES;
    }
    return NO;
}

+ (BOOL)isEmptyOrNull: (NSString *)string
{
    if (![string isKindOfClass:[NSString class]] || [string isKindOfClass:[NSNull class]] || string == nil || [string isEqualToString:@""] || [string isEqualToString:@"undefined"] || [string isEqualToString:@"null"])
        return true;
    return false;
}

+ (BOOL)isNotEmptyAndNull: (NSString *)string
{
    if (![self isEmptyOrNull:string])
        return  true;
    return false;
}

- (NSString *)nameOC2Swift
{
    NSString *name = self;
    NSString *appName = [[NSBundle mainBundle] infoDictionary][@"CFBundleExecutable"];
    NSString *vcName = [NSString stringWithFormat:@"%@.%@",appName,name];
    //    NSString *vcName = [NSString stringWithFormat:@"_TtC%ld%@%ld%@",appName.length,appName,name.length,name];
    return vcName;
}

- (NSString *)nameSwift2OC
{
    NSString *name = self;
    NSString *appName = [[NSBundle mainBundle] infoDictionary][@"CFBundleExecutable"];
    NSString *swiftName = [name stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"%@.",appName] withString:@""];
//      NSString *swiftName = [name regexReplce:[NSString stringWithFormat:@"_TtC%ld%@\\d+(.*)",appName.length,appName] handle:@"$1"];
    return swiftName;
}

- (NSString *)regexReplce:(NSString *)regular handle:(NSString *)handle
{
    NSString *text = self;
    NSRange range = [text rangeOfString:regular options:NSRegularExpressionSearch];
    if (range.location == NSNotFound) {
        return nil;
    }
    if ([NSString isEmptyOrNull:handle]) {
        handle = @"$1";
    }
    NSRegularExpression *regExp = [[NSRegularExpression alloc] initWithPattern:regular options:NSRegularExpressionCaseInsensitive error:nil];
    text = [regExp stringByReplacingMatchesInString:text options:NSMatchingReportProgress range:NSMakeRange(0, text.length) withTemplate:handle];
    
    return text;
}

#pragma mark - json
+ (id)theRouteJsonWithFileName:(NSString *)filename
{
    NSString *directory = [NSString stringWithFormat:@"%@/%@/json", kTheRouteBundleName,kThemeName];
    NSString *jsonPath = [[NSBundle bundleForClass:NSClassFromString(@"TheRouter")] pathForResource:filename ofType:@".json" inDirectory:directory];
    NSString *jsonstr = [NSString stringWithContentsOfFile:jsonPath encoding:NSUTF8StringEncoding error:nil];
    
    return [self theRouteJsonObject:jsonstr];
}

+ (id)theRouteJsonWithAppFileName:(NSString *)filename andThemeName:(NSString *)themeName
{
    if ([NSString isEmptyOrNull:themeName]) {
        themeName = kThemeName;
    }
    NSString *directory = [NSString stringWithFormat:@"%@/json", kThemeName];
    NSString *jsonPath = [[NSBundle mainBundle] pathForResource:filename ofType:@".json" inDirectory:directory];
    NSString *jsonstr = [NSString stringWithContentsOfFile:jsonPath encoding:NSUTF8StringEncoding error:nil];
    
    return [self theRouteJsonObject:jsonstr];
}

+ (id)theRouteJsonObject:(NSString *)jsonstr
{
    NSData *jsonData = [jsonstr dataUsingEncoding:NSUTF8StringEncoding];
    
    NSDictionary *json;
    NSError *error;
    if (jsonData) {
        json = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:&error];
    }
    NSAssert(!error, @"json解析失败：%@",jsonstr);
    return json;
}

@end

NSString * subSameComponent(NSString *str1,NSString *str2, char c)
{
    const char * s1 =[str1 UTF8String];
    const char * s2 =[str2 UTF8String];
    
    size_t length = MIN(strlen(s1),strlen(s2));
    size_t count = 0;
    size_t pause = 0;
    for (size_t i = 0; i < length ; i++) {
        if (*(s1+i) == *(s2+i)) {
            count++;
            if (*(s1+i) == c) {
                pause = count;
            }
        }else{
            break;
        }
    }
    if (length == count) {
        pause = length;
    }
    return [str1 substringToIndex:pause];
};
