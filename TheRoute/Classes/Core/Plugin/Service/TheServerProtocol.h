//
//  TheServiceProtocol.h
//  TheRoute
//
//  Created by TheMe on 7/23/16.
//  Copyright © 2016 sdqvsqiu@gmail.com. All rights reserved.
//

#import "Intent.h"
#import "TheBinderProtocol.h"

@protocol TheServerProtocol <NSObject>
//
//// 初始化和绑定的时候才会赋值全局intent
//@property (nonatomic,strong,readonly) Intent *intent;

- (void)startCommand:(Intent *)intent;
// 子类中确认完成请求调用该方法。
- (void)finishCommand:(Intent *)commandIntent;

// TODO:内含一个计数器，绑定的对象都移除了才会彻底移除。
- (void)stopService:(Intent *)intent;

//int mStartMode; // indicates how to behave if the service is killed
//boolean mAllowRebind; // indicates whether onRebind should be used lifeCycle. The service is being created
- (void)onCreate;

// lifeCycle. The service is starting, due to a call to startCommand
- (Intent *)onStartCommand:(Intent *)intent;
// override point.lifeCycle.
- (void)onFinishCommand:(Intent *)commandIntent;

// lifeCycle. 
- (void)onDestroy;

- (id)queryState:(NSString *)query;

@optional

// override point.
- (id<TheBinderProtocol>)makeBinder:(Intent *)intent;

// A client is binding to the service with bindService()
- (__kindof id<TheBinderProtocol>)onBind:(Intent *)intent;

// All clients have unbound with unbindService()
- (BOOL)onUnbind:(Intent *)intent;

// A client is binding to the service with bindService(),
// after onUnbind() has already been called
- (void)onRebind:(Intent *)intent;

@end
