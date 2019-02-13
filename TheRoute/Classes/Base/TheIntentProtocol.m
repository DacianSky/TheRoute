//
//  TheIntentProtocol.m
//  TheRoute
//
//  Created by TheMe on 6/15/16.
//  Copyright © 2016 sdqvsqiu@gmail.com. All rights reserved.
//

#import "TheIntentProtocol.h"
#import "MethodInjecting.h"
#import "NSString+Route.h"

#import "TheRouter.h"
#import "TheRouteHelper.h"

static BOOL _the_delayRightTime = NO;
void theDelayRightTime(BOOL flag)
{
    _the_delayRightTime = YES;
}

#define theContainer the_class_name(TheIntentProtocol)
@the_interface_concrete(TheIntentProtocol)

@property (nonatomic,strong) Intent *returnIntent;
@property (nonatomic,strong) Intent *parameterIntent;

@end

/*
 在~/.lldbinit中配置以下命令即可在终端中使用路由：
 command regex route 's/(.+)/expr (void)[[TheRouter sharedTheRouter] run:@"%1"]/'
 or:
 command regex route 's/(.+)/expr (void)__executeRoute(@"%1")/'
 */
void __executeRoute(NSString *url)
{
    NSLog(@"url:%@",url);
    Intent *intent = [Intent intentWithRouteName:url];
    [theContainer startViewController:intent];
}

#define kEventNeedDelayRoute @"kEventNeedDelayRoute"
@the_implementatione_concrete(TheIntentProtocol)

#pragma mark - 短路由自动生成
+ (void)loaded
{
    if(![self isSubclassOfClass:[UIViewController class]]){
        return;
    }
    if([self theNeedAliasAutoRegister]){
        NSString *alias = [self theAliasName];
        if(alias){
            [self registeRoute:alias object:NSStringFromClass([self class])];
        }
    }
}

+ (BOOL)theNeedAliasAutoRegister
{
    return NO;
}

+ (BOOL)theIsSwift
{
    return NO;
}

+ (NSString *)theAliasName
{
    NSString *vcName = NSStringFromClass([self class]);
    if([self theIsSwift]){
        vcName = [vcName nameSwift2OC];
    }
    return [[vcName regexReplce:[self theAliasRegex] handle:[self theHandleRegex]] lowercaseString];
}

+ (NSString *)theAliasRegex
{
    NSString *prefix = [self theClassPrefix];
    NSString *suffix = [self theClassSuffix];
    if(!prefix){
        prefix = @"";
    }
    if(!suffix){
        prefix = @"";
    }
    return [NSString stringWithFormat:@"%@(.*?)%@",prefix,suffix];
}

+ (NSString *)theHandleRegex
{
    return @"$1";
}

+ (NSString *)theClassPrefix
{
    return nil;
}

+ (NSString *)theClassSuffix
{
    return @"ViewController";
}

#pragma mark - 无路由环境路由延迟，通常用在通知进入app打开的第一个页面是广告页而不是主页面
+ (BOOL)canRoute
{
    return (BOOL)[TheRouteHelper getAppCurrentNavigation];
}

+ (BOOL)needDelayRoute
{
    return _the_delayRightTime && [self canRoute];
}

- (void)paramAppear
{
    if([[self class] needDelayRoute]){
        [_theRoute executeEvent:kEventNeedDelayRoute];
    }
    if (self.paramOccasion & IntentParamOccasionAppear) {
        [self setupParameterIntent];
    }
    [self setupResultIntent];
}

- (void)paramInit
{
    if (self.paramOccasion & IntentParamOccasionInit) {
        [self setupParameterIntent];
    }
    [self setupResultIntent];
}

- (void)setupInit
{
    self.paramOccasion = IntentParamOccasionInit;
}

- (void)setupParameterIntent
{
    //有值说明跳转过来的界面有传递参数
    if ([self conformsToProtocol:@protocol(TheIntentProtocol)]) {
        Intent *parameterIntent = [_theRoute propertyValueForKey:theParameterKey];
        if (self.paramOccasion & IntentParamOccasionRefuse || (parameterIntent.paramOccasion && parameterIntent.paramOccasion != self.paramOccasion) || parameterIntent.paramOccasion & IntentParamOccasionResult || !parameterIntent.extras || parameterIntent.extras == NULL || [parameterIntent.extras isKindOfClass:[NSNull class] ]) {
            return;
        }
        [self buildParameterIntent:parameterIntent];
    }
}

- (void)buildParameterIntent:(Intent *)parameterIntent
{
    self.parameterIntent = [self shouldViewControllerParam:parameterIntent];
    if (self.parameterIntent) {
        [self onViewControllerParam:self.parameterIntent];
    }
    [self didViewControllerParam:self.parameterIntent];
}

- (void)setupResultIntent
{
    //上个界面关闭时传递返回值
    Intent *intent = [_theRoute queryPropertyValueForKey:theReturnKey];
    
    if (IntentCategoryNextViewController == intent.category) {
        [self setupResult];
        return;
    }
    
    if (self.needResult_) {
        // 即self.needResult_ != IntentCategoryDefault
        
        if(intent.category != self.needResult_ && self.needResult_ != IntentCategoryAll){
            // 假如不是自己期待的返回值，可能不是返回给自己的。
            return;
        }
        
        [self setupResult];
    }
}

#pragma mark - 路由方法
+ (void)registeRoute:(NSString *)name object:(id)object
{
    if ([NSString isEmptyOrNull:name]) {
        return;
    }
    if ([object isKindOfClass:[NSString class]]) {
        [_theRoute.core registerKey:name class:object];
    }else if ([object isKindOfClass:[UIViewController class]]){
        [_theRoute.core registerKey:name instance:object];
    }else if ([TheRouteHelper isBlock:object]){
        [_theRoute.core registerKey:name action:object];
    }
}

+ (void)unregisterRoute:(NSString *)name
{
    [_theRoute.core unregisterKey:name];
}

+ (id)queryRoute:(id)object
{
    NSString *url = [_theRoute queryRoute:object];
    if (!url) {
        NSString *value = NSStringFromClass([object class]);
        url = [_theRoute queryRoute:value];
    }
    return url;
}

+ (NSString *)queryViewControllerName:(NSString *)url
{
    id value = [_theRoute pureUrl:url];
    if (![value isKindOfClass:[NSString class]] || ![NSClassFromString(value) isKindOfClass:[UIViewController class]]) {
        value = nil;
    }
    return value;
}

+ (__kindof UIViewController *)queryViewController:(NSString *)url
{
    id value = [_theRoute queryUrlValue:url];
    if (![value isKindOfClass:[UIViewController class]]) {
        value = nil;
    }
    return value;
}

+ (void)startViewController:(Intent *)intent
{
    [self startViewController:intent finish:nil];
}

+ (void)startViewController:(Intent *)intent finish:(IntentReusltCallBack)finish
{
    NSString *url = intent.routeName;
    if ([NSString isEmptyOrNull:url]) {
        return;
    }
    
    [_theRoute addEvent:kEventNeedDelayRoute forOnceAction:^id(id  _Nonnull param) {
        [self shouldStartViewController:intent];
        [_theRoute addProperty:theParameterKey toValue:intent];
        [_theRoute run:intent.absoluteRoute done:finish];
        [self didStartViewController:intent];
        return nil;
    }];
    if([self canRoute]){
        [_theRoute executeEvent:kEventNeedDelayRoute];
    }
}

- (void)registeRoute:(NSString *)name object:(id)object
{
    [[self class] registeRoute:name object:object];
}

- (void)unregisterRoute:(NSString *)name
{
    [[self class] unregisterRoute:name];
}

- (id)queryRoute:(id)object
{
    return [[self class] queryRoute:object];
}

- (NSString *)queryViewControllerName:(NSString *)url
{
    return [[self class] queryViewControllerName:url];
}

- (__kindof UIViewController *)queryViewController:(NSString *)url
{
    return [[self class] queryViewController:url];
}

- (void)startViewControllerForResult:(Intent *)intent
{
    if (intent.category == IntentCategoryDefault) {
        self.needResult_ = IntentCategoryAll;
    }else{
        self.needResult_ = intent.category;
    }
    
    [self startViewController:intent];
}

- (void)startViewController:(Intent *)intent
{
    [self startViewController:intent finish:nil];
}

- (void)startViewController:(Intent *)intent finish:(IntentReusltCallBack)finish
{
    [self shouldStartViewController:intent];
    [[self class] startViewController:intent finish:finish];
    [self didStartViewController:intent];
}

- (void)retainViewController:(NSString *)key
{
    NSString *value = [[self getIntent] getExtra:key];
    NSString *routeName = [self queryRoute:self];
    if([NSString isEmptyOrNull:key] || [NSString isEmptyOrNull:value] || [NSString isEmptyOrNull:routeName]){
        return;
    }
    NSString *retainKey = [NSString stringWithFormat:@"%@%@_%@_",theRetainKey,routeName,key];
    [_theRoute addProperty:retainKey toValue:@{value:self}];
}

- (void)releaseViewController:(NSString *)key
{
    NSString *routeName = [self queryRoute:self];
    NSString *retainKey = [NSString stringWithFormat:@"%@%@_%@_",theRetainKey,routeName,key];
    [_theRoute propertyValueForKey:retainKey];
}

#pragma mark - 参数传递与返回值
// 得到作为参数传递过来的intent
- (Intent *)getIntent
{
    return self.parameterIntent;
}

// 得到返回视图控制器的返回值
- (Intent *)getResult
{
    return self.returnIntent;
}

// 设置返回值结果
- (void)setResult:(Intent *)intent
{
    @synchronized(self) {
        if (intent.category == IntentCategoryDefault) {
            intent.category = [self getIntent].category;
        }
        intent.paramOccasion = IntentParamOccasionResult;
        [_theRoute addProperty:theReturnKey toValue:intent];
    }
}

- (void)appendResult:(NSDictionary *)extras
{
    Intent *intent = [_theRoute queryPropertyValueForKey:theReturnKey];
    if(!intent){
        intent = [Intent intentWithExtras:extras];
        [self setResult:intent];
    }else{
        [intent putExtras:extras];
    }
}

- (void)forwardRoot
{
    [_theRoute run:@"/"];
}

- (void)finishForward:(NSString *)forward
{
    [_theRoute run:[NSString stringWithFormat:@"../%@",forward]];
}

+ (void)shouldStartViewController:(Intent *)intent{}
- (void)shouldStartViewController:(Intent *)intent{}
+ (void)didStartViewController:(Intent *)intent{}
- (void)didStartViewController:(Intent *)intent{}

- (BOOL)navigationShouldPopOnBackButton
{
    BOOL canReturn = NO;
    if ([self respondsToSelector:@selector(needReturn)] && [self performSelector:@selector(needReturn)]) {
        canReturn = YES;
    }
    if (canReturn) {
        [_theRoute run:@"[..]"];
    }
    return canReturn; // return YES;
}

- (BOOL)navigationShouldPopOnBackGesture
{
    BOOL canReturn = NO;
    if ([self respondsToSelector:@selector(needReturn)] && [self performSelector:@selector(needReturn)]) {
        canReturn = YES;
    }
    return canReturn;
}

- (void)navigationDidPopOnBackGesture
{
    [_theRoute run:@"[..]"];
}

+ (void)finish
{
    theContainer *vc = (theContainer *)[TheRouteHelper getAppCurrentNavigation].topViewController;
    [vc finish];
}

- (void)finish
{
    if (![self respondsToSelector:@selector(needReturn)] || ![self performSelector:@selector(needReturn)]) {
        return;
    }
    
    theExecuteUndeclaredSelector(self, @selector(onReturn));
    theExecuteUndeclaredSelector(self, @selector(didReturn));
}

- (BOOL)needReturn
{
    return YES;
}

- (void)didReturn{}

- (void)onViewControllerResult:(Intent *)intent{}

- (Intent *)shouldViewControllerParam:(Intent *)intent
{
    return intent;
}

- (void)onViewControllerParam:(Intent *)intent
{
    [TheRouteHelper map:self params:intent.extras];
}

- (void)didViewControllerParam:(Intent *)intent{}

#pragma mark - private

- (void)setupResult
{
    self.returnIntent = [_theRoute propertyValueForKey:theReturnKey];
    
    self.needResult_ = NO;
    if (self.returnIntent) {
        [self onViewControllerResult:self.returnIntent];
    }
}

- (id<TheIntentProtocol>)judegeNeedResult:(IntentCategory)category
{
    UIViewController<TheIntentProtocol> *svc = (UIViewController<TheIntentProtocol> *)self;
    UIViewController<TheIntentProtocol> *respondVC = nil;
    
    if(self.needResult_ == IntentCategoryAll || category == self.needResult_){
        respondVC = svc;
    }else if(svc.childViewControllers){
        for(UIViewController<TheIntentProtocol> *cvc in svc.childViewControllers){
            if([cvc conformsToProtocol:@protocol(TheIntentProtocol)]){
                // 假如不是自己期待的返回值，可能不是返回给自己的。
                if([cvc judegeNeedResult:category]){
                    respondVC = cvc;
                    break;
                }
            }
        }
    }
    
    return respondVC;
}

#pragma mark - associate

- (IntentCategory)needResult_
{
    NSNumber *needResult = objc_getAssociatedObject(self, @selector(needResult_));
    return [needResult integerValue];;
}

- (void)setNeedResult_:(IntentCategory)needResult_
{
    NSNumber *needResult = [NSNumber numberWithInteger:needResult_];
    objc_setAssociatedObject(self, @selector(needResult_), needResult, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (Intent *)parameterIntent
{
    Intent *intent = objc_getAssociatedObject(self, @selector(parameterIntent));
    return intent;
}

- (void)setParameterIntent:(Intent *)parameterIntent
{
    objc_setAssociatedObject(self, @selector(parameterIntent), parameterIntent, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (Intent *)returnIntent
{
    Intent *intent = objc_getAssociatedObject(self, @selector(returnIntent));
    return intent;
}

- (void)setReturnIntent:(Intent *)returnIntent
{
    objc_setAssociatedObject(self, @selector(returnIntent), returnIntent, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (IntentParamOccasion)paramOccasion
{
    NSNumber *paramOccasion_ = objc_getAssociatedObject(self, @selector(paramOccasion));
    return [paramOccasion_ integerValue];;
}

- (void)setParamOccasion:(IntentParamOccasion)paramOccasion_
{
    NSNumber *paramOccasion = [NSNumber numberWithInteger:paramOccasion_];
    objc_setAssociatedObject(self, @selector(paramOccasion), paramOccasion, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

/** 防御性编程 防止从userDefaults取空value 或者 以不存在的key去访问字典*/
- (void)setNilValueForKey:(NSString *)key{}
- (void)setValue:(nullable id)value forUndefinedKey:(NSString *)key{}
- (id)valueForUndefinedKey:(NSString *)key{return nil;}

@end

@implementation UIViewController (Intent)

+ (void)load
{
    theSwizzleMethod(self, @selector(viewWillAppear:), @selector(the_viewWillAppear:));
    theSwizzleMethod(self, @selector(loadView), @selector(the_loadView));
}

- (void)the_viewWillAppear:(BOOL)animated
{
    if(![self respondsToSelector:@selector(setupInit)]){
        [self the_viewWillAppear:animated];
        return;
    }
    [(theContainer *)self paramAppear];
    [self the_viewWillAppear:animated];
}

- (void)the_loadView
{
    if(![self respondsToSelector:@selector(setupInit)]){
        [self the_loadView];
        return;
    }
    [(theContainer *)self paramInit];
    [self the_loadView];
}

+ (void)finish
{
    [(theContainer *)self finish];
}

+ (void)registeRoute:(NSString *)name object:(id)object
{
    [theContainer registeRoute:name object:object];
}

+ (void)unregisterRoute:(NSString *)name
{
    [theContainer unregisterRoute:name];
}

+ (id)queryRoute:(id)object
{
    return [theContainer queryRoute:object];
}

+ (NSString *)queryViewControllerName:(NSString *)url
{
    return [theContainer queryViewControllerName:url];
}

+ (__kindof UIViewController *)queryViewController:(NSString *)url
{
    return [theContainer queryViewController:url];
}

+ (void)startViewController:(Intent *)intent finish:(IntentReusltCallBack)finish
{
    [theContainer startViewController:intent finish:finish];
}

+ (void)startViewController:(Intent *)intent
{
    [theContainer startViewController:intent];
}

@end
