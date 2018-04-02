//
//  ViewController.m
//  KVO
//
//  Created by wqf on 2018/3/30.
//  Copyright © 2018年 wqf. All rights reserved.
//

#import "ViewController.h"
#import "person.h"
#import "NSObject+QFKVO.h"
@interface ViewController ()
@property (nonatomic, strong)person * person;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.person = [[person alloc] init];
    //系统kvo监听属性变化（可手动可自动）
//    [self.person addObserver:self forKeyPath:@"name" options:NSKeyValueObservingOptionNew context:nil];
//    [self.person addObserver:self forKeyPath:@"age" options:NSKeyValueObservingOptionNew context:nil];
//    self.person.name = @"wqf";
//    self.person.age = 20;
    
    //runtime 自定义KVO
    [self.person qf_addObserver:self forKeyPath:@"name" withBlock:^(id observer,NSString *keyPath, id oldValue, id newValue) {
        NSLog(@"%@=%@——>%@",keyPath,oldValue,newValue);
    }];
    self.person.name = @"qf";
}
-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context
{
    NSLog(@"%@",change);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
