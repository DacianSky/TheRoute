//
//  TheStoryBoardConfig.m
//  TheRoute
//
//  Created by TheMe on 7/11/16.
//  Copyright © 2016 sdqvsqiu@gmail.com. All rights reserved.
//

#import "TheStoryBoardConfig.h"
#import "TheRouter.h"

@implementation TheStoryBoardConfig

- (NSDictionary *)buildConfig:(id)manifest
{
    [self configRoute_storyboard:manifest];
    return nil;
}

- (void)configRoute_storyboard:(NSDictionary *)manifest
{
    // storyboardID不应当重复。并且建议不要和viewcontroller中名字重复。
    NSDictionary *sb = manifest[@"storyboard"];
    [sb enumerateKeysAndObjectsUsingBlock:^(NSString *storyboardName, NSArray *restorationIDs, BOOL * _Nonnull stop) {
        [restorationIDs enumerateObjectsUsingBlock:^(NSString *storyboardID, NSUInteger idx, BOOL * _Nonnull stop) {
            [_theRoute.core registerKey:storyboardID action:^UIViewController *{
                UIStoryboard *sb = [UIStoryboard storyboardWithName:storyboardName bundle:[NSBundle mainBundle]];
                return [sb instantiateViewControllerWithIdentifier:storyboardID];
            }];
        }];
    }];
}

@end
