//
//  TheRouteConst.h
//  TheRoute
//
//  Created by TheMe on 2019/1/18.
//  Copyright © 2019 sdqvsqiu@gmail.com. All rights reserved.
//

#ifndef TheRouteConst_h
#define TheRouteConst_h

#define theExecuteUndeclaredSelector(who,sel) \
do { \
_Pragma("clang diagnostic push") \
_Pragma("clang diagnostic ignored \"-Wundeclared-selector\"") \
![who respondsToSelector:sel]? nil : [who performSelector:sel]; \
_Pragma("clang diagnostic pop") \
} while (0)

#endif /* TheRouteConst_h */
