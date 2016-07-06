//
//  YJTestClasses.m
//  YJKit
//
//  Created by huang-kun on 16/7/2.
//  Copyright © 2016年 huang-kun. All rights reserved.
//

#import "YJTestClasses.h"

@implementation Foo

- (void)sayHello { NSLog(@"instance hello"); }
+ (void)sayHello { NSLog(@"class hello"); }
+ (void)sayHi { NSLog(@"class hi"); }
- (void)dealloc {
    NSLog(@"%@ deallocated.", self);
}

@end


@implementation Bar

+ (instancetype)bar {
    static Bar *bar;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        bar = [Bar new];
    });
    return bar;
}

- (void)sayYoo { NSLog(@"instance yoo"); }
+ (void)sayYoo { NSLog(@"class yoo"); }
- (void)dealloc {
    NSLog(@"%@ deallocated.", self);
}

- (NSString *)description {
    return [NSString stringWithFormat:@"%@<%p> %@", self.class, self, self.name];
}

@end
