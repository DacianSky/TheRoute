//
//  TheRouteCore.h
//  TheRoute
//
//  Created by TheMe on 7/4/16.
//  Copyright © 2016 sdqvsqiu@gmail.com. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef id(^ TheRouteMapAction)(void);

@protocol TheRouteCoreDelegate <NSObject>

@optional
- (UIViewController *)lastViewControllerForKey:(NSString *)key;

- (void)willRoute:(UIViewController *)from to:(UIViewController *)to;
- (void)didRoute:(UIViewController *)from to:(UIViewController *)to;

- (void)willSelectTabbar;
- (void)didSelectTabbar;

@end

@interface TheRouteCore : NSObject

@property (nonatomic, strong) NSMutableDictionary *map;
@property (nonatomic, weak) id<TheRouteCoreDelegate> delegate;

- (NSString *)keyForObject:(id)object;
- (id)instanceForKey:(NSString *)key;

- (NSString *)parse:(NSString *)url;
- (void)consume:(NSString *)url;

- (void)registerKey:(NSString *)key action:(TheRouteMapAction)action;
- (void)registerKey:(NSString *)key class:(NSString *)name;
- (void)registerKey:(NSString *)key instance:(UIViewController *)vc;
- (void)unregisterKey:(NSString *)key;

@end

NS_ASSUME_NONNULL_END
