//
//  YJObjectCombination.m
//  YJKit
//
//  Created by huang-kun on 16/7/28.
//  Copyright © 2016年 huang-kun. All rights reserved.
//

#import "YJObjectCombination.h"
#import <objc/runtime.h>

id yj_comb_new(Class cls, id first, ...) {
    
    if (!class_conformsToProtocol(cls, @protocol(YJObjectCombination)))
        return nil;
    
    id <YJObjectCombination> tuple = [cls new];
    
    int i = 0;
    id arg = nil;
    va_list args;
    
    if (first) {
        yj_comb_set(tuple, first, i); i++; // tuple[i++] = first;
        
        va_start(args, first);
        while ((arg = va_arg(args, id))) {
            yj_comb_set(tuple, arg, i); i++; // tuple[i++] = arg;
        }
        va_end(args);
    }
    
    return tuple;
}

void yj_comb_set(id <YJObjectCombination> tuple, id obj, NSUInteger idx) {
    NSCParameterAssert(idx >= 0 && idx < YJ_MUTABLE_TUPLE_MAX_NUMBER_OF_VALUES);
    switch (idx) {
        case 0: [tuple setFirst:obj]; break;
        case 1: [tuple setSecond:obj]; break;
        case 2: [tuple setThird:obj]; break;
        case 3: [tuple setFourth:obj]; break;
        case 4: [tuple setFifth:obj]; break;
        case 5: [tuple setSixth:obj]; break;
        case 6: [tuple setSeventh:obj]; break;
        case 7: [tuple setEighth:obj]; break;
        case 8: [tuple setNinth:obj]; break;
        case 9: [tuple setTenth:obj]; break;
        default: break;
    }
}

id yj_comb_get(id <YJObjectCombination> tuple, NSUInteger idx) {
    NSCParameterAssert(idx >= 0 && idx < YJ_MUTABLE_TUPLE_MAX_NUMBER_OF_VALUES);
    switch (idx) {
        case 0: return [tuple first];
        case 1: return [tuple second];
        case 2: return [tuple third];
        case 3: return [tuple fourth];
        case 4: return [tuple fifth];
        case 5: return [tuple sixth];
        case 6: return [tuple seventh];
        case 7: return [tuple eighth];
        case 8: return [tuple ninth];
        case 9: return [tuple tenth];
        default: return nil;
    }
}
