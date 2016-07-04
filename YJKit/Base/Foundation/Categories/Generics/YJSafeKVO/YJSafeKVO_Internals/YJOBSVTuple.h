//
//  YJOBSVTuple.h
//  YJKit
//
//  Created by huang-kun on 16/7/3.
//  Copyright © 2016年 huang-kun. All rights reserved.
//

#import <Foundation/Foundation.h>

/// The class for wrapping observed target and it's key path

@interface YJOBSVTuple : NSObject

+ (instancetype)target:(__kindof NSObject *)target keyPath:(NSString *)keyPath;

@property (nonatomic, readonly, strong) __kindof NSObject *target;
@property (nonatomic, readonly, strong) NSString *keyPath;

@end
