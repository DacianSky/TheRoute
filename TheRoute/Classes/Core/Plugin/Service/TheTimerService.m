//
//  TheTimerService.m
//  TheRoute
//
//  Created by TheMe on 7/23/16.
//  Copyright © 2016 sdqvsqiu@gmail.com. All rights reserved.
//

#import "TheTimerService.h"
#import "TheRouteHelper.h"

@interface TheWeakTimer : NSObject
@property (nonatomic, weak) id target;
@property (nonatomic, assign) SEL sel;
@property (nonatomic, weak) NSTimer *timer;
+ (TheWeakTimer *)scheduledTimerWithTimeInterval:(NSTimeInterval)interval target:(id)target selector:(SEL)sel userInfo:(id)userInfo repeats:(BOOL)repeats;
- (void)action;
@end

@interface TheTimerService()

@property (nonatomic,strong) NSMutableDictionary *binderMap;

@property (nonatomic,strong) NSMutableDictionary *timers;
@property (nonatomic,strong) NSMutableDictionary *timersDuration;
@property (nonatomic,strong) NSMutableDictionary *timerTrigerCounts;

@end

@implementation TheTimerService

// onBind服务时调用该方法
- (id<TheBinderProtocol>)makeBinder:(Intent *)intent
{
    id<TheBinderProtocol> binder = [super makeBinder:intent];
    
    NSString *name = [intent getExtra:@"name"];
    if (!name || [name isEqualToString:@""]) {
        name = @"_default_timer_";
    }
    
    NSPointerArray *map = self.binderMap[name];
    if (!map) {
        map = [NSPointerArray weakObjectsPointerArray];
        self.binderMap[name] = map;
    }
    [map addPointer:(__bridge void *)binder];
    
    return binder;
}

- (void)onFinishCommand:(Intent *)commandIntent
{
    NSString *name = [commandIntent getExtra:@"name"];
    NSPointerArray *map = self.binderMap[name];
    
    [map compact];
    NSArray *binders = map.allObjects;
    for (id<TheBinderProtocol> binder in binders) {
        if ([binder respondsToSelector:@selector(isPause)] && [binder isPause]) {
            continue;
        }
        [TheRouteHelper map:binder params:commandIntent.extras];
        !binder.lisner?:binder.lisner(commandIntent);
    }
}

- (void)stopService:(Intent *)intent
{
    NSString *name = [intent getExtra:@"name"];
    NSString *timerName = [NSString stringWithFormat:@"%@%@",timerPrefix, name];
    [self removeTimer:timerName];
    [super stopService:intent];
}

- (Intent *)onStartCommand:(Intent *)intent
{
    NSString *name = [intent getExtra:@"name"];
    NSInteger duration = [[intent getExtra:@"duration"] integerValue];
    NSInteger interval = [[intent getExtra:@"interval"] integerValue];
    BOOL fire = ![[intent getExtra:@"notFire"] boolValue];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        // 定时器需要放在主线程中触发
         NSInteger result = interval?interval:1;
        [self startTimerWithName:name andDuration:duration interval:result fire:fire];
    });
    
    return nil;
}

static NSString *timerPrefix = @"_timer_";
- (TheWeakTimer *)startTimerWithName:(NSString *)name andDuration:(NSInteger)duration interval:(NSInteger)interval fire:(BOOL)fire

{
    NSString *timerName = [NSString stringWithFormat:@"%@%@",timerPrefix, name];
    TheWeakTimer *timer = self.timers[timerName];
    if (!timer) {
        timer = [self makeTimer:timerName duration:duration interval:interval fire:fire];
    }
    return timer;
}

- (TheWeakTimer *)makeTimer:(NSString *)timerName duration:(NSInteger)duration interval:(NSInteger)interval fire:(BOOL)fire
{
    TheWeakTimer * timer = [TheWeakTimer scheduledTimerWithTimeInterval:interval target:self selector:@selector(timerTriger:) userInfo:timerName repeats:YES];

    self.timers[timerName] = timer;
    self.timersDuration[timerName] = @(duration);
    self.timerTrigerCounts[timerName] = @(0);
    
    if (fire) {
        [timer.timer fire];
    }
    return timer;
}

- (TheWeakTimer *)makeTimer:(NSString *)timerName duration:(NSInteger)duration
{
    return [self makeTimer:timerName duration:duration interval:1 fire:YES];
}

- (void)removeTimer:(NSString *)timerName
{
    TheWeakTimer *timer = self.timers[timerName];
    if (timer) {
        [self.timers removeObjectForKey:timerName];
        [timer.timer invalidate];
    }
}

- (void)timerTriger:(NSTimer *)sender
{
    NSString *timerName = sender.userInfo;
    
    NSInteger totalDuration = [self.timersDuration[timerName] integerValue];
    NSInteger timerTrigerCount = [self.timerTrigerCounts[timerName] integerValue];
    self.timerTrigerCounts[timerName] = @(timerTrigerCount+1);
    
    NSInteger remainTime = totalDuration - timerTrigerCount;
    NSString *name = [timerName stringByReplacingOccurrencesOfString:timerPrefix withString:@""];
    
    Intent *intent = [[Intent alloc] init];
    [intent putExtra:@"name" value:name];
    [intent putExtra:@"remainTime" value:@(remainTime)];
    
    [self finishCommand: intent];
    
    if (remainTime <= 0) {
        [self removeTimer:timerName];
    }
}

#pragma mark - getter & setter
- (NSMutableDictionary *)timers
{
    if (!_timers) {
        _timers = [@{} mutableCopy];
    }
    return _timers;
}

- (NSMutableDictionary *)timersDuration
{
    if (!_timersDuration) {
        _timersDuration = [@{} mutableCopy];
    }
    return _timersDuration;
}

- (NSMutableDictionary *)timerTrigerCounts
{
    if (!_timerTrigerCounts) {
        _timerTrigerCounts = [@{} mutableCopy];
    }
    return _timerTrigerCounts;
}

- (NSMutableDictionary *)binderMap
{
    if (!_binderMap) {
        _binderMap = [@{} mutableCopy];
    }
    return _binderMap;
}

#pragma mark - private function

@end


@implementation TheWeakTimer

+ (TheWeakTimer *)scheduledTimerWithTimeInterval:(NSTimeInterval)interval target:(id)target selector:(SEL)sel userInfo:(id)userInfo repeats:(BOOL)repeats
{
    TheWeakTimer *weak = [[TheWeakTimer alloc] init];
    weak.target = target;
    weak.sel = sel;
    weak.timer = [NSTimer scheduledTimerWithTimeInterval:interval target:weak selector:@selector(action) userInfo:userInfo repeats:repeats];
    
    return weak;
}

- (void)action
{
    if (self.target) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        if ([self.target respondsToSelector:self.sel]) {
            [self.target performSelector:self.sel withObject:self.timer];
        }
#pragma clang diagnostic pop
    }
    else{
        [self.timer invalidate];
    }
}

@end
