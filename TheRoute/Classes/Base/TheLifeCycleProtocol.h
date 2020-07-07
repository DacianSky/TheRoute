//
//  TheLifeCycleProtocol.h
//  TheRoute
//
//  Created by TheMe on 7/18/16.
//  Copyright © 2016 sdqvsqiu@gmail.com. All rights reserved.
//

#import "TheViewControlProtocol.h"

@protocol TheLifeCycleProtocol <TheViewControlProtocol>

@optional
- (BOOL)the_wouldConfig; //sub protocol override
- (void)the_config; // no override
- (void)the_configParams;
- (void)the_configViews;
- (void)the_configDatas;
- (void)the_configConstraints;

- (void)the_updataConstraints;
- (void)the_updateGlobalProperty;
- (void)the_updateViews;


- (void)onInit;
- (void)onPause;
- (void)onResume; //进入前台
- (void)onSleep;  //进入后台
- (void)onStop;   //接到内存警告，释放资源


- (void)anywayInit; // no override
- (void)onStart;  // no override
- (void)onRestart;  // no override


- (void)onDestroy;

- (void)onReturn; //返回过程中
- (void)returnClick;


- (void)onRotate:(UIDeviceOrientation)newOrientation;
- (void)rotated:(UIDeviceOrientation)oldOrientation;


- (void)reloadVC; // no override
- (BOOL)needReloadVC;
- (void)prepareReloadVC;
- (void)didReloadVC;
- (void)reloadView;

@property (nonatomic, strong) id<UINavigationControllerDelegate> transition;
- (BOOL)showAnimation;
- (BOOL)dismissAnimation;

- (UIInterfaceOrientationMask)allowOrientations;

@end
