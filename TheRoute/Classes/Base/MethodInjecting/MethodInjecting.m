//
// Created by NewPan on 2018/9/5.
// Copyright (c) 2018 NewPan. All rights reserved.
//

#import "MethodInjecting.h"
#import <pthread.h>

#import <objc/runtime.h>
#import <dlfcn.h>
#import <mach-o/ldsyms.h>
#import <mach-o/dyld.h>

typedef struct TheSpecialProtocol {
    __unsafe_unretained Protocol *protocol;
    Class containerClass;
    BOOL ready;
} TheSpecialProtocol;

static TheSpecialProtocol * restrict the_specialProtocols = NULL;
static size_t the_specialProtocolCount = 0;
static size_t the_specialProtocolCapacity = 0;
static size_t the_specialProtocolsReady = 0;
static pthread_mutex_t the_specialProtocolsLock = PTHREAD_MUTEX_INITIALIZER;
static NSRecursiveLock *theinjecting_recursiveLock;

BOOL the_loadSpecialProtocol (Protocol *protocol, Class containerClass) {
    @autoreleasepool {
        NSCParameterAssert(protocol != nil);
        if (pthread_mutex_lock(&the_specialProtocolsLock) != 0) {
            fprintf(stderr, "ERROR: Could not synchronize on special protocol data\n");
            return NO;
        }
        
        if (the_specialProtocolCount == SIZE_MAX) {
            pthread_mutex_unlock(&the_specialProtocolsLock);
            return NO;
        }
        
        if (the_specialProtocolCount >= the_specialProtocolCapacity) {
            size_t newCapacity;
            if (the_specialProtocolCapacity == 0)
                newCapacity = 1;
            else {
                newCapacity = the_specialProtocolCapacity << 1;
                
                if (newCapacity < the_specialProtocolCapacity) {
                    newCapacity = SIZE_MAX;
                    
                    if (newCapacity <= the_specialProtocolCapacity) {
                        pthread_mutex_unlock(&the_specialProtocolsLock);
                        return NO;
                    }
                }
            }
            
            void * restrict ptr = realloc(the_specialProtocols, sizeof(*the_specialProtocols) * newCapacity);
            if (!ptr) {
                pthread_mutex_unlock(&the_specialProtocolsLock);
                return NO;
            }
            
            the_specialProtocols = ptr;
            the_specialProtocolCapacity = newCapacity;
        }
        assert(the_specialProtocolCount < the_specialProtocolCapacity);
        
#ifndef __clang_analyzer__
        
        the_specialProtocols[the_specialProtocolCount] = (TheSpecialProtocol){
            .protocol = protocol,
            .containerClass = containerClass,
            .ready = NO,
        };
#endif
        
        ++the_specialProtocolCount;
        pthread_mutex_unlock(&the_specialProtocolsLock);
    }
    
    return YES;
}

static void the_orderSpecialProtocols(void) {
    qsort_b(the_specialProtocols, the_specialProtocolCount, sizeof(TheSpecialProtocol), ^(const void *a, const void *b){
        if (a == b)
            return 0;
        
        const TheSpecialProtocol *protoA = a;
        const TheSpecialProtocol *protoB = b;
        
        int (^protocolInjectionPriority)(const TheSpecialProtocol *) = ^(const TheSpecialProtocol *specialProtocol){
            int runningTotal = 0;
            
            for (size_t i = 0;i < the_specialProtocolCount;++i) {
                if (specialProtocol == the_specialProtocols + i)
                    continue;
                
                if (protocol_conformsToProtocol(specialProtocol->protocol, the_specialProtocols[i].protocol))
                    runningTotal++;
            }
            
            return runningTotal;
        };
        return protocolInjectionPriority(protoB) - protocolInjectionPriority(protoA);
    });
}

void the_specialProtocolReadyForInjection (Protocol *protocol) {
    @autoreleasepool {
        NSCParameterAssert(protocol != nil);
        
        if (pthread_mutex_lock(&the_specialProtocolsLock) != 0) {
            fprintf(stderr, "ERROR: Could not synchronize on special protocol data\n");
            return;
        }
        for (size_t i = 0;i < the_specialProtocolCount;++i) {
            if (the_specialProtocols[i].protocol == protocol) {
                if (!the_specialProtocols[i].ready) {
                    the_specialProtocols[i].ready = YES;
                    assert(the_specialProtocolsReady < the_specialProtocolCount);
                    if (++the_specialProtocolsReady == the_specialProtocolCount)
                        the_orderSpecialProtocols();
                }
                
                break;
            }
        }
        
        pthread_mutex_unlock(&the_specialProtocolsLock);
    }
}

static void the_injectConcreteProtocolInjectMethod(Class containerClass, Class pairClass) {
    unsigned imethodCount = 0;
    Method *imethodList = class_copyMethodList(containerClass, &imethodCount);
    for (unsigned methodIndex = 0;methodIndex < imethodCount;++methodIndex) {
        Method method = imethodList[methodIndex];
        SEL selector = method_getName(method);
        IMP imp = method_getImplementation(method);
        const char *types = method_getTypeEncoding(method);
        class_addMethod(pairClass, selector, imp, types);
    }
    free(imethodList); imethodList = NULL;
    (void)[containerClass class];
    
    unsigned cmethodCount = 0;
    Method *cmethodList = class_copyMethodList(object_getClass(containerClass), &cmethodCount);
    
    Class metaclass = object_getClass(pairClass);
    for (unsigned methodIndex = 0;methodIndex < cmethodCount;++methodIndex) {
        Method method = cmethodList[methodIndex];
        SEL selector = method_getName(method);
        
        if (selector == @selector(initialize)) {
            continue;
        }
        
        IMP imp = method_getImplementation(method);
        const char *types = method_getTypeEncoding(method);
        class_addMethod(metaclass, selector, imp, types);
    }
    
    free(cmethodList); cmethodList = NULL;
    (void)[containerClass class];
}

static NSArray * the_injectMethod(id object) {
    NSMutableArray *the_matchSpecialProtocolsToClass = @[].mutableCopy;
    for (size_t i = 0;i < the_specialProtocolCount;++i) {
        @autoreleasepool {
            Protocol *protocol = the_specialProtocols[i].protocol;
            if (!class_conformsToProtocol([object class], protocol)) {
                continue;
            }
            [the_matchSpecialProtocolsToClass addObject:[NSValue value:&the_specialProtocols[i] withObjCType:@encode(struct TheSpecialProtocol)]];
        }
    }
    
    if(!the_matchSpecialProtocolsToClass.count) {
        return nil;
    }
    
    struct TheSpecialProtocol protocol;
    for(NSValue *value in the_matchSpecialProtocolsToClass) {
        [value getValue:&protocol];
        the_injectConcreteProtocolInjectMethod(protocol.containerClass, [object class]);
    }
    return the_matchSpecialProtocolsToClass.copy;
}

static bool the_resolveMethodForObject(id object) {
    @autoreleasepool {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            theinjecting_recursiveLock = [NSRecursiveLock new];
        });
        
        [theinjecting_recursiveLock lock];
        
        // 处理继承自有注入的父类.
        Class currentClass = [object class];
        NSArray *matchSpecialProtocolsToClass = nil;
        do {
            NSArray *protocols = the_injectMethod(currentClass);
            if(!matchSpecialProtocolsToClass) {
                matchSpecialProtocolsToClass = protocols;
            }
        }while((currentClass = class_getSuperclass(currentClass)));
        
        if(!matchSpecialProtocolsToClass.count) {
            [theinjecting_recursiveLock unlock];
            return nil;
        }
        
        [theinjecting_recursiveLock unlock];
        return YES;
    }
}

BOOL the_addConcreteProtocol (Protocol *protocol, Class containerClass) {
    return the_loadSpecialProtocol(protocol, containerClass);
}

void the_loadConcreteProtocol (Protocol *protocol) {
    the_specialProtocolReadyForInjection(protocol);
}

void theSwizzleMethod(Class clz,SEL origin,SEL swizzle)
{
    Method originalMethod = class_getInstanceMethod(clz, origin);
    Method swizzledMethod = class_getInstanceMethod(clz, swizzle);
    
    BOOL success = class_addMethod(clz, origin, method_getImplementation(swizzledMethod), method_getTypeEncoding(swizzledMethod));
    if (success) {
        class_replaceMethod(clz, swizzle, method_getImplementation(originalMethod), method_getTypeEncoding(originalMethod));
    } else {
        method_exchangeImplementations(originalMethod, swizzledMethod);
    }
}

@interface NSObject(TheInjecting)

@end

@implementation NSObject(TheInjecting)

+ (void)load {
    [self theSwizzleResolveMethod:@selector(resolveInstanceMethod:) :@selector(theinjecting_resolveInstanceMethod:)];
    [self theSwizzleResolveMethod:@selector(resolveClassMethod:) :@selector(theinjecting_resolveClassMethod:)];
}

+ (void)theSwizzleResolveMethod:(SEL)origin :(SEL)swizzle
{
    theSwizzleMethod(object_getClass([self class]),origin, swizzle);
}

+ (BOOL)theinjecting_resolveClassMethod:(SEL)sel {
    if(the_resolveMethodForObject(self)) {
        return YES;
    }
    return [self theinjecting_resolveClassMethod:sel];
}

+ (BOOL)theinjecting_resolveInstanceMethod:(SEL)sel {
    if(the_resolveMethodForObject(self)) {
        return YES;
    }
    return [self theinjecting_resolveInstanceMethod:sel];
}

@end




BOOL class_conformTheSpecialProtocol(Class class)
{
    for (size_t i = 0;i < the_specialProtocolCount;++i) {
        @autoreleasepool {
            Protocol *protocol = the_specialProtocols[i].protocol;
            if ([class conformsToProtocol:protocol]) {
                return YES;
            }
        }
    }
    return NO;
}

NSArray <Class> * getSpecialClzes(const void * addr)
{
    NSMutableArray *resultArray = [NSMutableArray array];
    
    unsigned int classCount;
    const char **classes;
    Dl_info info;
    
    dladdr(addr, &info);
    classes = objc_copyClassNamesForImage(info.dli_fname, &classCount);
    
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(1);
    dispatch_apply(classCount, dispatch_get_global_queue(0, 0), ^(size_t index) {
        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
        NSString *className = [NSString stringWithCString:classes[index] encoding:NSUTF8StringEncoding];
        Class class = NSClassFromString(className);
        if (class_conformTheSpecialProtocol(class)) {
            [resultArray addObject:class];
        }
        dispatch_semaphore_signal(semaphore);
    });
    free(classes);
    
    return resultArray.mutableCopy;
}

// 实现了协议的类会尝试调用类的loaded方法,所有类的loaded被调用的顺序是随机的，可能子类的loaded会比父类先调用
void callLibLoaded(const void * addr)
{
    NSArray <Class> *list = getSpecialClzes(addr);
    for (int i = 0; i < list.count; i++) {
        theExecuteUndeclaredSelector(list[i],@selector(loaded));
    }
}

