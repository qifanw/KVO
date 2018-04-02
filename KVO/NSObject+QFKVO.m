//
//  NSObject+QFKVO.m
//  KVO
//
//  Created by wqf on 2018/3/30.
//  Copyright © 2018年 wqf. All rights reserved.
//

#import "NSObject+QFKVO.h"
#import <objc/message.h>
static NSString * const KQFKVOPrefix = @"QFKVO_";
static NSString * const KQFKVOAssonciaKey = @"KQFKVOAssonciaKey_";

@interface QFKVO_info :NSObject
@property(nonatomic, copy) QFKVOBlock block;

@property(nonatomic, weak) NSObject *observer;

@property(nonatomic, copy) NSString *keyPath;
@end

@implementation QFKVO_info
-(instancetype)initWithObeserver:(NSObject *)observer keyPath:(NSString *)keyPath withBlok:(QFKVOBlock)block
{
    if (self == [super init]) {
        _observer = observer;
        _keyPath = keyPath;
        _block = block;
    }
    return self;
}
@end


@implementation NSObject (QFKVO)
- (void)qf_addObserver:(NSObject *)observer forKeyPath:(NSString *)keyPath withBlock:(QFKVOBlock)Block
{
    //判断特殊条件,防异常
    //获取类
    Class superClass = object_getClass(self);
    //sel 方法编号
    SEL setterSelector = NSSelectorFromString(setterFromGetter(keyPath));
    Method setterMethod = class_getInstanceMethod(superClass, setterSelector);
    if (!setterMethod) {
        @throw [NSException exceptionWithName:NSInvalidArgumentException reason:[NSString stringWithFormat:@"%@ not have setter",self] userInfo:nil];
    }
    //动态创建类 --- NSKVONotifiying_A
    NSString * superName = NSStringFromClass(superClass);
    Class newClass = [self creatClassFromSuperName:superName];
    //替换父类
    object_setClass(self, newClass);
    //添加setter方法
    const char * types = method_getTypeEncoding(setterMethod);
    class_addMethod(newClass, setterSelector, (IMP)QFKVO_setter, types);
    //保持信息
    QFKVO_info * info = [[QFKVO_info alloc] initWithObeserver:observer keyPath:keyPath withBlok:Block];
    
    NSMutableArray * infoArray= objc_getAssociatedObject(self, (__bridge const void * _Nonnull)(KQFKVOAssonciaKey));
    
    if (!infoArray) {
        infoArray = [NSMutableArray array];
        objc_setAssociatedObject(self, (__bridge const void * _Nonnull)(KQFKVOAssonciaKey), infoArray, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    [infoArray addObject:info];
}
-(Class)creatClassFromSuperName:(NSString *)superName{
    //创建类
    /**
     1.superClass: 父类
     2.类名： QFKVO
     3.空间
     */
    
    Class superClass = NSClassFromString(superName);
    NSString * newClassName = [KQFKVOPrefix stringByAppendingString:superName];
    
    Class newClass = objc_allocateClassPair(superClass, newClassName.UTF8String, 0);
    //动态添加方法
    /**
     1.类
     2.SEL
     3.IMP implementation  指针 ---- .方法实现
     */
    Method classMethod = class_getClassMethod(superClass, @selector(class));
    const char * types = method_getTypeEncoding(classMethod);
    class_addMethod(newClass, @selector(class), (IMP)QFKVO_class, types);
    
    //注册
    objc_registerClassPair(newClass);
    return newClass;
}
#pragma mark --- 函数区

static void QFKVO_setter(id self, SEL _cmd, id newValue){
    //name getter方法
    NSString * setterName = NSStringFromSelector(_cmd);
    NSString * getterName = getterFromSetter(setterName);
    if (!getterName) {
        @throw [NSException exceptionWithName:NSInvalidArgumentException reason:[NSString stringWithFormat:@"%@ not have getter",self] userInfo:nil];
    }
    id oldValue = [self valueForKey:getterName];
    //手动开启监听
    [self willChangeValueForKey:getterName];
    
    //消息转发
    //直接用导致内存泄漏
    //objc_msgSendSuper();
    void (*objc_msgSendQFKVO)(void *, SEL, id) =(void *)objc_msgSendSuper;
    struct objc_super superClassStruct = {
        .receiver = self,
        .super_class = class_getSuperclass(object_getClass(self))
    };
    objc_msgSendQFKVO(&superClassStruct,_cmd,newValue);
    
    
    [self didChangeValueForKey:getterName];
    
    NSMutableArray * infoArray= objc_getAssociatedObject(self, (__bridge const void * _Nonnull)(KQFKVOAssonciaKey));
    for (QFKVO_info * info in infoArray) {
        dispatch_async(dispatch_queue_create(0, 0), ^{
            info.block(self, info.keyPath, oldValue, newValue);
        });
    }
    
}
static Class QFKVO_class(id self)
{
    Class class = object_getClass(self);
    return class_getSuperclass(class);
}
#pragma mark -- name====> setName:
static NSString * setterFromGetter(NSString * getter){
    if (getter.length<=0) {return nil;}
    NSString * firstStr = [getter substringToIndex:1].uppercaseString;
    NSString * leaveStr = [getter substringFromIndex:1];
    return [NSString stringWithFormat:@"set%@%@:",firstStr,leaveStr];
}
#pragma mark -- setName:====>name
static NSString * getterFromSetter(NSString * setter){
    if (setter.length<=0||![setter hasPrefix:@"set"]||![setter hasSuffix:@":"]) {return nil;}
    NSRange range = NSMakeRange(3, setter.length-4);
    NSString * getter = [setter substringWithRange:range];
    NSString * firstStr = [getter substringToIndex:1].lowercaseString
    ;
    return [getter stringByReplacingCharactersInRange:NSMakeRange(0, 1) withString:firstStr];
}































@end
