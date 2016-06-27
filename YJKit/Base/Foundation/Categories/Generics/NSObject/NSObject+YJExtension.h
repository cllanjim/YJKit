//
//  NSObject+YJExtension.h
//  YJKit
//
//  Created by huang-kun on 16/6/17.
//  Copyright © 2016年 huang-kun. All rights reserved.
//

#import <Foundation/Foundation.h>

/* ----------------------------------- */
//   NSObject (YJMutabilityChecking)
/* ----------------------------------- */

@protocol YJMutabilityChecking <NSCopying>
- (BOOL)isMutable;
@end

/// Avoid using introspection for class cluster
/// e.g. Don't call -[string isKindOfClass:[NSMutableString class]]

@interface NSString (YJMutabilityChecking)
@property (nonatomic, readonly) BOOL isMutable;
@end

@interface NSArray (YJMutabilityChecking)
@property (nonatomic, readonly) BOOL isMutable;
@end


/* ------------------------------------ */
//     NSObject (YJCodingExtension)
/* ------------------------------------ */

@interface NSObject (YJCodingExtension)

- (void)encodeIvarListWithCoder:(NSCoder *)coder;
- (void)encodeIvarListWithCoder:(NSCoder *)coder forClass:(Class)cls;

- (void)decodeIvarListWithCoder:(NSCoder *)decoder;
- (void)decodeIvarListWithCoder:(NSCoder *)decoder forClass:(Class)cls; /// MUST call this in class inheritance chain to specify the class type.

@end