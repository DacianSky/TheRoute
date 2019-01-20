//
//  TheViewControlProtocol.h
//  TheRoute
//
//  Created by TheMe on 7/24/16.
//  Copyright © 2016 sdqvsqiu@gmail.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol TheViewControlProtocol <NSObject>

@optional
@property(null_resettable, nonatomic,strong) UIView *view;
@property(nullable, nonatomic,readonly,strong) UINavigationController *navigationController;
@property(nonatomic,readonly) NSArray<__kindof UIViewController *> *childViewControllers;
@property(nonatomic,assign) BOOL extendedLayoutIncludesOpaqueBars;
@property(nonatomic,assign) BOOL automaticallyAdjustsScrollViewInsets;

- (void)dismissViewControllerAnimated: (BOOL)flag completion: (void (^ __nullable)(void))completion;

@end
