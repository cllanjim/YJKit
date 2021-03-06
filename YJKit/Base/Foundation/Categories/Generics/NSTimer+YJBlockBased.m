//
//  NSTimer+YJBlockBased.m
//  YJKit
//
//  Created by huang-kun on 16/4/4.
//  Copyright © 2016年 huang-kun. All rights reserved.
//

#import <objc/runtime.h>
#import "NSTimer+YJBlockBased.h"
#import "YJDebugMacros.h"

static const void *YJTimerAssociatedTargetKey = &YJTimerAssociatedTargetKey;

__attribute__((visibility("hidden")))
@interface _YJTimerTarget : NSObject
@property (nonatomic, copy) void(^timerHandler)(NSTimer *);
- (instancetype)initWithTimerHandler:(void(^)(NSTimer *timer))timerHandler;
- (void)invokeSelectorFromTimer:(NSTimer *)timer;
@end

@implementation _YJTimerTarget

- (instancetype)initWithTimerHandler:(void (^)(NSTimer *))timerHandler {
    self = [super init];
    if (self) _timerHandler = [timerHandler copy];
    return self;
}

- (void)invokeSelectorFromTimer:(NSTimer *)timer {
    if (self.timerHandler) self.timerHandler(timer);
}

#if YJ_DEBUG
- (void)dealloc {
    NSLog(@"%@ dealloc.", self.class);
}
#endif

@end

@interface NSTimer ()
@property (nonatomic) _YJTimerTarget *yj_target;
@end

@implementation NSTimer (YJBlockBased)

- (void)setYj_target:(_YJTimerTarget *)yj_target {
    objc_setAssociatedObject(self, YJTimerAssociatedTargetKey, yj_target, OBJC_ASSOCIATION_ASSIGN);
}

- (_YJTimerTarget *)yj_target {
    return objc_getAssociatedObject(self, YJTimerAssociatedTargetKey);
}

+ (NSTimer *)scheduledTimerWithTimeInterval:(NSTimeInterval)seconds repeats:(BOOL)yesOrNo timerHandler:(void(^)(NSTimer *))timerHandler {
    _YJTimerTarget *target = [[_YJTimerTarget alloc] initWithTimerHandler:timerHandler];
    NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:seconds target:target selector:@selector(invokeSelectorFromTimer:) userInfo:nil repeats:yesOrNo];
    timer.yj_target = target;
    return timer;
}

+ (NSTimer *)timerWithTimeInterval:(NSTimeInterval)seconds repeats:(BOOL)yesOrNo timerHandler:(void(^)(NSTimer *))timerHandler {
    _YJTimerTarget *target = [[_YJTimerTarget alloc] initWithTimerHandler:timerHandler];
    NSTimer *timer = [NSTimer timerWithTimeInterval:seconds target:target selector:@selector(invokeSelectorFromTimer:) userInfo:nil repeats:yesOrNo];
    timer.yj_target = target;
    return timer;
}

@end
