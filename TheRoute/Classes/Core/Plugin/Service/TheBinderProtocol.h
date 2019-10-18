//
//  TheBinderProtocol.h
//  TheRoute
//
//  Created by TheMe on 7/23/16.
//  Copyright © 2016 sdqvsqiu@gmail.com. All rights reserved.
//

#import "Intent.h"

@protocol TheBinderProtocol <NSObject>

@property (nonatomic,getter=isPause) BOOL pause;

@property (nonatomic) void (^lisner)(Intent *intent);

@end
