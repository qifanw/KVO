//
//  NSObject+QFKVO.h
//  KVO
//
//  Created by wqf on 2018/3/30.
//  Copyright © 2018年 wqf. All rights reserved.
//

#import <Foundation/Foundation.h>
typedef void (^QFKVOBlock)(id observer,NSString * keyPath,id oldValue,id newValue );
@interface NSObject (QFKVO)

- (void)qf_addObserver:(NSObject *)observer forKeyPath:(NSString *)keyPath withBlock:(QFKVOBlock)Block;

@end
