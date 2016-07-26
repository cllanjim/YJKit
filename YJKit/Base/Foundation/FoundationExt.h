//
//  FoundationExt.h
//  YJKit
//
//  Created by huang-kun on 16/5/22.
//  Copyright © 2016年 huang-kun. All rights reserved.
//

#if __has_include(<YJKit/FoundationExt.h>)

#import <YJKit/NSObject+YJExtension.h>
#import <YJKit/YJRuntimeEncapsulation.h>
#import <YJKit/NSObject+YJSafeKVO.h>

#import <YJKit/NSString+YJCollection.h>
#import <YJKit/NSString+YJSequence.h>
#import <YJKit/NSMutableString+YJSequence.h>
#import <YJKit/NSArray+YJCollection.h>
#import <YJKit/NSArray+YJSequence.h>
#import <YJKit/NSMutableArray+YJCollection.h>
#import <YJKit/NSMutableArray+YJSequence.h>
#import <YJKit/NSSet+YJCollection.h>
#import <YJKit/NSMutableSet+YJCollection.h>

#import <YJKit/NSValue+YJGeometryExtension.h>
#import <YJKit/NSBundle+YJCategory.h>
#import <YJKit/NSTimer+YJBlockBased.h>

#import <YJKit/YJDelegateAndDataSourceCrashPrecaution.h>

#else

#import "NSObject+YJExtension.h"
#import "YJRuntimeEncapsulation.h"
#import "NSObject+YJSafeKVO.h"

#import "NSString+YJCollection.h"
#import "NSString+YJSequence.h"
#import "NSMutableString+YJSequence.h"
#import "NSArray+YJCollection.h"
#import "NSArray+YJSequence.h"
#import "NSMutableArray+YJCollection.h"
#import "NSMutableArray+YJSequence.h"
#import "NSSet+YJCollection.h"
#import "NSMutableSet+YJCollection.h"

#import "NSValue+YJGeometryExtension.h"
#import "NSBundle+YJCategory.h"
#import "NSTimer+YJBlockBased.h"

#import "YJDelegateAndDataSourceCrashPrecaution.h"

#endif
