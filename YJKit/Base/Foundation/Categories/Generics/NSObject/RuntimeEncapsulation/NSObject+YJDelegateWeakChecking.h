//
//  NSObject+YJDelegateWeakChecking.h
//  YJKit
//
//  Created by huang-kun on 16/7/18.
//  Copyright © 2016年 huang-kun. All rights reserved.
//

#import <Foundation/Foundation.h>

/// For older version of iOS, the delegate of UITableView, UITextView ...
/// is not defined as weak attribute, so here is a way for checking that.

@interface NSObject (YJDelegateWeakChecking)

/**
 @brief Checking if the delegate property has weak attribute. 
 @warning This is only checking weak or assign delegate for
          system historical reason. 
 @return YES means it has delegate property which is weak supported.
         NO means either it has no delegate property or the delegate
         is may be assigned.
 */
- (BOOL)isWeakDelegateByDefault;


/**
 @brief Checking if the dataSource property has weak attribute.
 @warning This is only checking weak or assign dataSource for
          system historical reason.
 @return YES means it has dataSource property which is weak supported.
         NO means either it has no dataSource property or the dataSource
         is may be assigned.
 */
- (BOOL)isWeakDataSourceByDefault;

@end
