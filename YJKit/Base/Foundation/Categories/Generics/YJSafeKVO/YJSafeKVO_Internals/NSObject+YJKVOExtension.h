//
//  NSObject+YJKVOExtension.h
//  YJKit
//
//  Created by huang-kun on 16/7/3.
//  Copyright © 2016年 huang-kun. All rights reserved.
//

#import <Foundation/Foundation.h>

@class _YJKVOManager, _YJKVOTracker;


/* ------------------------- */
//         YJKVOTarget
/* ------------------------- */

@interface NSObject (YJKVOTarget)

/// Associated with a manager for managing porters
@property (nonatomic, strong) _YJKVOManager *yj_KVOManager;

@end


/* ------------------------- */
//       YJKVOObserver
/* ------------------------- */

@interface NSObject (YJKVOObserver)

/// Associated with a tracker for tracking porters
@property (nonatomic, strong) _YJKVOTracker *yj_KVOTracker;

@end


/* ------------------------- */
//        YJKVOBinding
/* ------------------------- */

@interface NSObject (YJKVOBinding)

/// Associated with a key path for receiving binding changes
@property (nonatomic, copy) NSString *yj_KVOBindingKeyPath;

@end
