//
//  NSObject+YJKVOExtension.h
//  YJKit
//
//  Created by huang-kun on 16/7/3.
//  Copyright © 2016年 huang-kun. All rights reserved.
//

#import <Foundation/Foundation.h>

@class _YJKVOPorterManager, _YJKVOPorterTracker, _YJKVOKeyPathManager;


/* ------------------------- */
//         YJKVOTarget
/* ------------------------- */

@interface NSObject (YJKVOTarget)

/// Associated with a porter manager for managing porters
@property (nonatomic, strong) _YJKVOPorterManager *yj_KVOPorterManager;

@end


/* ------------------------- */
//       YJKVOObserver
/* ------------------------- */

@interface NSObject (YJKVOObserver)

/// Associated with a tracker for tracking porters
@property (nonatomic, strong) _YJKVOPorterTracker *yj_KVOTracker;

@end


/* ------------------------- */
//        YJKVOBinding
/* ------------------------- */

@interface NSObject (YJKVOBinding)

/// Associated with a key path manager for organizing key paths
@property (nonatomic, strong) _YJKVOKeyPathManager *yj_KVOKeyPathManager;

/// For keeping the key path temporarily and use it later
/// It should be disposable and get released after using it.
@property (nonatomic, strong) NSString *yj_KVOTemporaryKeyPath;

@end
