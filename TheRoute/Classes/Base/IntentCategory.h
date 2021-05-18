//
//  IntentCategory.h
//  TheRoute
//
//  Created by TheMe on 7/22/16.
//  Copyright © 2016 sdqvsqiu@gmail.com. All rights reserved.
//

#ifndef IntentCategory_h
#define IntentCategory_h

#import <Foundation/Foundation.h>

typedef NS_OPTIONS(NSUInteger, IntentParamOccasion) {
    IntentParamOccasionNone  = 0,
    IntentParamOccasionInit = 1 << 1,
    IntentParamOccasionAppear = 1 << 2,
    IntentParamOccasionException = 1 << 3,
    IntentParamOccasionResult = 1 << 4,
    IntentParamOccasionRefuse = 1 << 5, // 不接受参数，通常用于避免子视图控制器提前消化参数
    IntentParamOccasionForce = 1 << 6, // 强制接受参数，通常用于路由到未遵循TheIntentProtocol协议又想传递参数的对象
    IntentParamOccasionBoth = IntentParamOccasionInit | IntentParamOccasionAppear,
    IntentParamOccasionAll = IntentParamOccasionInit | IntentParamOccasionAppear | IntentParamOccasionResult | IntentParamOccasionException | IntentParamOccasionForce
};

typedef NS_ENUM(NSUInteger,IntentCategory){
    // 默认不接受所有返回值
    IntentCategoryDefault = 0,
    // 接受所有
    IntentCategoryAll = 1,
    // 返回值给下一个跳转到的界面
    IntentCategoryNextViewController,
    // 接受含图片类型
    IntentCategoryImage,
    // 接受含文本类型
    IntentCategoryText,
    // 日期
    IntentCategoryDate,
    // 联系人
    IntentCategoryContact,
    // 网页
    IntentCategoryWeb,
    // 返回
    IntentCategoryReturn
};

typedef NS_ENUM(NSUInteger,CustomIntentCategory){
    CustomIntentCategoryAccountSettingNick = 10000,
    CustomIntentCategoryAccountSettingName,
    CustomIntentCategoryAccountSettingPhone,
    CustomIntentCategoryAccountSettingEmail,
    CustomIntentCategoryAccountSettingBirthday
};

#endif /* IntentCategory_h */
