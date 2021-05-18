//
// Created by NewPan on 2018/9/5.
// Copyright (c) 2018 NewPan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <objc/runtime.h>
#import "TheRouteConst.h"

#define the_metamacro_stringify_(VALUE) # VALUE

#define the_metamacro_stringify(VALUE) \
        the_metamacro_stringify_(VALUE)

#define the_concrete \
    optional \

#define the_class_name(NAME) NAME ## _TheProtocolMethodContainer

#define the_interface_concrete(NAME) \
    interface NAME ## _TheProtocolMethodContainer : NSObject < NAME > {} \
    + (void)loaded; \
    @end \
    @interface NAME ## _TheProtocolMethodContainer()

#define the_implementatione_concrete(NAME) \
    implementation NAME ## _TheProtocolMethodContainer \
    + (void)load { \
    if (!the_addConcreteProtocol(objc_getProtocol(the_metamacro_stringify(NAME)), self)) \
            fprintf(stderr, "ERROR: Could not load concrete protocol %s\n", the_metamacro_stringify(NAME)); \
    } \
    __attribute__((constructor)) \
    static void the_ ## NAME ## _inject (void) { \
        the_loadConcreteProtocol(objc_getProtocol(the_metamacro_stringify(NAME))); \
    }

#define the_concreteprotocol(NAME) \
    interface NAME ## _TheProtocolMethodContainer : NSObject < NAME > {} \
    @end \
    @implementation NAME ## _TheProtocolMethodContainer \
    + (void)load { \
        if (!the_addConcreteProtocol(objc_getProtocol(the_metamacro_stringify(NAME)), self)) \
            fprintf(stderr, "ERROR: Could not load concrete protocol %s\n", the_metamacro_stringify(NAME)); \
    } \
    __attribute__((constructor)) \
    static void the_ ## NAME ## _inject (void) { \
        the_loadConcreteProtocol(objc_getProtocol(the_metamacro_stringify(NAME))); \
    }

BOOL the_addConcreteProtocol (Protocol *protocol, Class methodContainer);
void the_loadConcreteProtocol (Protocol *protocol);

void theSwizzleMethod(Class clz,SEL origin,SEL swizzle);

// 实现了协议的类会尝试调用类的loaded方法
void callLibLoaded(const void * addr);
