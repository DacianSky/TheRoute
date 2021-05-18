//
//  TheAliasViewController.h
//  TheRouteDemo
//
//  Created by TheMe on 2021/5/18.
//  Copyright © 2021 sdqvsqiu@gmail.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <TheRoute/TheRoute.h>

NS_ASSUME_NONNULL_BEGIN

@interface TheAliasViewController : UIViewController <TheRoute>

@property (nonatomic,copy) NSString *name;

@end

NS_ASSUME_NONNULL_END
