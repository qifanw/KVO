//
//  person.m
//  KVO
//
//  Created by wqf on 2018/3/30.
//  Copyright © 2018年 wqf. All rights reserved.
//

#import "person.h"

@implementation person

+(BOOL)automaticallyNotifiesObserversForKey:(NSString *)key
{
    if ([key isEqualToString:@"age"]) {
        //手动监听
        return NO;
    }
    //自动监听
    return YES;
}
-(void)setAge:(NSInteger)age
{
    //手动观察
    [self willChangeValueForKey:@"age"];
    _age = age;
    [self didChangeValueForKey:@"age"];
}
@end
