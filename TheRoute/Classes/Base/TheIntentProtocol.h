//
//  TheIntentProtocol.h
//  TheRoute
//
//  Created by TheMe on 6/15/16.
//  Copyright © 2016 sdqvsqiu@gmail.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Intent.h"

#import "TheBaseRouterFilter.h"
#import "TheConfigFileProtocol.h"

// 不可路由条件下是否等待有路由执行条件后开始执行路由
void theDelayRightTime(BOOL flag);

typedef void(^ IntentReusltCallBack)(UIViewController *vc,Intent *intent);

@protocol TheAliasRegux <NSObject>

@optional
+ (BOOL)theNeedAliasAutoRegister;   // 如果需要开启自动生成短路由功能需要覆盖这个方法并返回YES
+ (BOOL)theIsSwift;                 // 如果是swift对象开启自动生成短路由功能需要覆盖这个方法并返回YES

+ (NSString *)theAliasName;         // 覆盖则自定义短路由名
+ (NSString *)theAliaRegex;         // 覆盖则自定义自动生成短路由的匹配规则
+ (NSString *)theHandleRegex;       // 覆盖则自定义自动生成短路由的匹配替换结果
+ (NSString *)theClassPrefix;       // 覆盖则自定义生成短路由的类名前缀，无则返回nil或@""，默认为nil
+ (NSString *)theClassSuffix;       // 覆盖则自定义生成短路由的类名后缀，无则返回nil或@""，默认为@“ViewController”

@end

@protocol TheIntentBaseProtocol <NSObject>

+ (void)startViewController:(Intent *)intent;
+ (void)startViewController:(Intent *)intent finish:(IntentReusltCallBack)finish;

+ (void)registeRoute:(NSString *)name object:(id)object;
+ (void)unregisterRoute:(NSString *)name;

+ (id)queryRoute:(id)object;
+ (NSString *)queryViewControllerName:(NSString *)url;
+ (__kindof UIViewController *)queryViewController:(NSString *)url;

@end

@protocol TheIntentProtocol <TheIntentBaseProtocol,TheAliasRegux>

@optional

@property (nonatomic,assign) IntentParamOccasion paramOccasion;
- (id<TheIntentProtocol>)judegeNeedResult:(IntentCategory)category;

- (void)startViewController:(Intent *)intent;
- (void)startViewControllerForResult:(Intent *)intent;
- (void)startViewController:(Intent *)intent finish:(IntentReusltCallBack)finish; // 路由完成将要push，在这里可以细微调整定制

+ (void)shouldStartViewController:(Intent *)intent;
- (void)shouldStartViewController:(Intent *)intent;
+ (void)didStartViewController:(Intent *)intent;
- (void)didStartViewController:(Intent *)intent;

- (void)retainViewController:(NSString *)key; // 当控制器被维持住时，startViewController碰到相同键值时将直接使用维持的这个控制器
- (void)releaseViewController:(NSString *)key;

#pragma mark - 参数传递与返回值
// 得到作为参数传递过来的intent
- (Intent *)getIntent;

- (id)queryRoute:(id)object;
- (NSString *)queryViewControllerName:(NSString *)url;
- (__kindof UIViewController *)queryViewController:(NSString *)url;
// 从跳转过来的界面拿到参数
- (void)buildParameterIntent:(Intent *)parameterIntent; // 用于手动设置子视图控制器参数
- (Intent *)shouldViewControllerParam:(Intent *)intent;
- (void)onViewControllerParam:(Intent *)intent; //有参数设置时才会被调用
- (void)didViewControllerParam:(Intent *)intent;
// 从上个界面拿到返回值后会回调该方法
- (void)onViewControllerResult:(Intent *)intent;
// 之后也可以手动调用该方法得到返回视图控制器的返回结果
- (Intent *)getResult;

// 关闭返回到上一个界面时设置返回结果
- (void)setResult:(Intent *)intent;
// 关闭返回到上一个界面时设置返回结果
- (void)appendResult:(NSDictionary *)extras;

// 返回到根界面
- (void)forwardRoot;
// 关闭并返回到上一个界面
+ (void)finish;
- (void)finish;
// 关闭并返回到指定界面
- (void)finishForward:(NSString *)forward;
- (BOOL)needReturn;
- (void)didReturn;

- (BOOL)navigationShouldPopOnBackButton;
- (BOOL)navigationShouldPopOnBackGesture;
- (void)navigationDidPopOnBackGesture;

@end
