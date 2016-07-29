//
//  YJTuple.m
//  YJKit
//
//  Created by huang-kun on 16/7/28.
//  Copyright © 2016年 huang-kun. All rights reserved.
//

#import "YJTuple.h"

@implementation YJTuple {
    NSArray *_arr;
}

- (instancetype)initWithObjects:(id)firstObj, ... NS_REQUIRES_NIL_TERMINATION {
    NSMutableArray *arr = [NSMutableArray arrayWithCapacity:20];
    
    id arg = nil;
    va_list args;
    
    if (firstObj) {
        [arr addObject:firstObj];
        
        va_start(args, firstObj);
        while ((arg = va_arg(args, id))) {
            [arr addObject:arg];
        }
        va_end(args);
    }
    
    return [self initWithArray:arr];
}

- (instancetype)initWithArray:(NSArray *)array {
    self = [super init];
    if (self) {
        _arr = [array copy];
    }
    return self;
}

+ (instancetype)tupleWithObjects:(id)firstObj, ... NS_REQUIRES_NIL_TERMINATION {
    NSMutableArray *arr = [NSMutableArray arrayWithCapacity:20];
    
    id arg = nil;
    va_list args;
    
    if (firstObj) {
        [arr addObject:firstObj];
        
        va_start(args, firstObj);
        while ((arg = va_arg(args, id))) {
            [arr addObject:arg];
        }
        va_end(args);
    }
    
    return [[self alloc] initWithArray:arr];
}

+ (instancetype)tupleWithArray:(NSArray *)array {
    return [[self alloc] initWithArray:array];
}

- (id)first { return _arr.firstObject; }
- (id)second { return _arr[1]; }
- (id)third { return _arr[2]; }
- (id)fourth { return _arr[3]; }
- (id)fifth { return _arr[4]; }
- (id)last { return _arr.lastObject; }

- (nullable id)objectAtIndexedSubscript:(NSUInteger)idx {
    return idx < _arr.count ? [_arr objectAtIndex:idx] : nil;
}

- (NSUInteger)countByEnumeratingWithState:(NSFastEnumerationState *)state
                                  objects:(id __unsafe_unretained [])buffer
                                    count:(NSUInteger)len {
    
    return [_arr countByEnumeratingWithState:state
                                     objects:buffer
                                       count:len];
}

@end
