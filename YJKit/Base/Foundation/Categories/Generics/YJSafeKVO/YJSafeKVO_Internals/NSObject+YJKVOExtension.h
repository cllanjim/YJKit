//
//  NSObject+YJKVOExtension.h
//  YJKit
//
//  Created by huang-kun on 16/7/3.
//  Copyright © 2016年 huang-kun. All rights reserved.
//

#import <Foundation/Foundation.h>

@class _YJKVOManager, _YJKVOPorter, _YJKVOTracker;


/* ------------------------- */
//         YJKVOTarget
/* ------------------------- */

@interface NSObject (YJKVOTarget)

// Associated with a manager for managing porters
@property (nonatomic, strong) _YJKVOManager *yj_KVOManager;

- (void)yj_kvoDismissAllPorters;

@end


/* ------------------------- */
//       YJKVOObserver
/* ------------------------- */

@interface NSObject (YJKVOObserver)

// The tracker object
@property (nonatomic, strong) _YJKVOTracker *yj_KVOTracker;

// The identifier for KVO registering, which will connect observer with related porters
//@property (nonatomic, copy) NSString *yj_KVOIdentifier;

- (void)yj_kvoDismissRelatedPorters;

@end