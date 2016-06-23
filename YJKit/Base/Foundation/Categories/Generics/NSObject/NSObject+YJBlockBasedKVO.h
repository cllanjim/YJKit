//
//  NSObject+YJBlockBasedKVO.h
//  YJKit
//
//  Created by huang-kun on 16/4/3.
//  Copyright © 2016年 huang-kun. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSObject (YJBlockBasedKVO)

/**
 *  @brief      Key-Value observing the key path and execute the handler block when observed value changes.
 *  @discussion This method performs as same as add observer with options (NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew). 
                The observer will be generated implicitly and it's safe for not removing observer explicitly because eventually observer 
                will be removed when receiver gets deallocated. It's vaild to use it multiple times for applying different changeHandler 
                block with same key path.
    @code
 
    [foo observeKeyPath:@keyPath(foo.friend) forChanges:^(id  _Nonnull object, id  _Nullable oldValue, id  _Nullable newValue) {
        NSLog(@"foo <%@> meets its new friend <%@>.", object, newValue);
    }];
 
    @endcode
 
 *  @remark              The handler block captures inner objects while the receiver is alive.
 *  @param keyPath       The key path, relative to the array, of the property to observe. This value must not be nil.
 *  @param changeHandler The block of code will be performed when observed value get changed.
 *  @note  Better to use \@keyPath macro in keyPath parameter for safe compile checking instead of using string literals.
 */
- (void)observeKeyPath:(NSString *)keyPath forChanges:(void(^)(id object, id _Nullable oldValue, id _Nullable newValue))changeHandler;


/**
 *  @brief      Key-Value observing the key path and execute the handler block when observed value get initially setup.
 *  @discussion This method performs as same as add observer with options (NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew). 
                The observer will be generated implicitly and it's safe for not removing observer explicitly because eventually observer 
                will be removed when receiver gets deallocated. It's vaild to use it multiple times for applying different setupHandler 
                block with same key path.
 *  @remark              The handler block captures inner objects while the receiver is alive.
 *  @param keyPath       The key path, relative to the array, of the property to observe. This value must not be nil.
 *  @param setupHandler  The block of code will be performed when observed value get setup.
 *  @note  Better to use \@keyPath macro in keyPath parameter for safe compile checking instead of using string literals.
 */
- (void)observeKeyPath:(NSString *)keyPath forInitialSetup:(void(^)(id object, id _Nullable newValue))setupHandler;


/**
 *  @brief Stops observing property specified by a given key-path relative to the receiver.
 *  @note  If you don't call this method when finish key value observing. All implicit generated observers will be removed from receiver 
           before receiver is deallocated. The internal observers will keep alive as long as receiver is alive. This method is for the 
           case when receiver is alive and you've done the obverving job. You can call this to manually remove all observers, then the
           block you've used for key value observing method will be released as well.
    @note  If you observe the same key path multiple times for different reason, you call -stopObservingKeyPath: only once is good.
 *  @param keyPath       The key path, relative to the array, of the property to observe. This value must not be nil.
 *  @note  Better to use \@keyPath macro in keyPath parameter for safe compile checking instead of using string literals.
 */
- (void)stopObservingKeyPath:(NSString *)keyPath;


/**
 *  @brief Stops observing all properties relative to the receiver.
 *  @note  If you don't call this method when finish key value observing. All implicit generated observers will be removed from receiver
           before receiver is deallocated. The internal observers will keep alive as long as receiver is alive. This method is for the
           case when receiver is alive and you've done the obverving job. You can call this to manually remove all observers, then the
           block you've used for key value observing method will be released as well.
 */
- (void)stopObservingAllKeyPaths;


/* -------------------- Deprecated ------------------- */

- (void)registerObserverForKeyPath:(NSString *)keyPath handleChanges:(void(^)(id object, id _Nullable oldValue, id _Nullable newValue))changeHandler DEPRECATED_MSG_ATTRIBUTE("This method is deprecated. Call observeKeyPath:forChanges: instead.");

- (void)registerObserverForKeyPath:(NSString *)keyPath handleSetup:(void(^)(id object, id _Nullable newValue))setupHandler DEPRECATED_MSG_ATTRIBUTE("This method is deprecated. Call observeKeyPath:forInitialSetup: instead.");

- (void)removeObservedKeyPath:(NSString *)keyPath DEPRECATED_MSG_ATTRIBUTE("This method is deprecated. Call stopObservingKeyPath: instead.");

- (void)removeAllObservedKeyPaths DEPRECATED_MSG_ATTRIBUTE("This method is deprecated. Call stopObservingAllKeyPaths: instead.");

@end

NS_ASSUME_NONNULL_END