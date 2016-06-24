//
//  _YJResignFirstResponderDefaultImp.h
//  YJKit
//
//  Created by huang-kun on 16/6/17.
//  Copyright © 2016年 huang-kun. All rights reserved.
//

#ifndef _YJResignFirstResponderDefaultImp_h
#define _YJResignFirstResponderDefaultImp_h

#import "NSObject+YJRuntimeEncapsulation.h"
#import "NSObject+YJBlockBasedKVO.h"
#import "NSArray+YJCollection.h"

#ifndef YJ_AUTO_RESIGN_FIRST_RESPONDER_DEFALT_METHODS_SWIZZLING
#define YJ_AUTO_RESIGN_FIRST_RESPONDER_DEFALT_METHODS_SWIZZLING(XXX) \
    [self swizzleInstanceMethodsBySelector:@selector(layoutSubviews) andSelector:@selector(yj_##XXX##LayoutSubviews)]; \
    [self swizzleInstanceMethodsBySelector:@selector(willMoveToSuperview:) andSelector:@selector(yj_##XXX##WillMoveToSuperview:)]; \
    [self swizzleInstanceMethodsBySelector:@selector(removeFromSuperview) andSelector:@selector(yj_##XXX##RemoveFromSuperview)];

#endif


#ifndef YJ_AUTO_RESIGN_FIRST_RESPONDER_DEFALT_IMPLEMENTATION
#define YJ_AUTO_RESIGN_FIRST_RESPONDER_DEFALT_IMPLEMENTATION(XXX) \
\
- (void)setAutoResignFirstResponder:(BOOL)autoResignFirstResponder {  \
    objc_setAssociatedObject(self, @selector(autoResignFirstResponder), (autoResignFirstResponder ? @1 : @0), OBJC_ASSOCIATION_COPY_NONATOMIC);  \
    if (!autoResignFirstResponder) {  \
        [self yj_removeResignFirstResponderTapAction];  \
    }  \
}  \
  \
- (BOOL)autoResignFirstResponder {  \
    return [objc_getAssociatedObject(self, _cmd) intValue] ? YES : NO;  \
}  \
  \
- (UIView *)providedARFRView {  \
    UIView *view = self.superview;  \
    id <YJ##XXX##Delegate> delegate = (id)self.delegate;  \
    if ([delegate respondsToSelector:@selector(viewForAutoResigningFirstResponderFor##XXX:)]) {  \
        UIView *tempView = [delegate viewForAutoResigningFirstResponderFor##XXX:self];  \
        if (tempView) view = tempView;  \
    }  \
    return view;  \
}  \
  \
- (void)yj_##XXX##LayoutSubviews {  \
    [self yj_##XXX##LayoutSubviews];  \
      \
    if (self.autoResignFirstResponder) {  \
        UIView *view = self.providedARFRView;  \
        UITapGestureRecognizer *tap = nil;  \
        NSArray *taps = [view.gestureRecognizers filtered:^BOOL(__kindof UIGestureRecognizer * _Nonnull obj) {  \
            return [obj isKindOfClass:[UITapGestureRecognizer class]];  \
        }];  \
        if (taps.count) {  \
            tap = taps.lastObject;  \
        } else {  \
            tap = [[UITapGestureRecognizer alloc] initWithTarget:nil action:nil];  \
            tap.delegate = self;  \
            [view addGestureRecognizer:tap];  \
        }  \
        [tap removeTarget:self action:@selector(yj_handleResignFirstResponderTap)];  \
        [tap addTarget:self action:@selector(yj_handleResignFirstResponderTap)];  \
    }  \
}  \
  \
- (void)yj_##XXX##WillMoveToSuperview:(UIView *)superview {  \
    [self yj_##XXX##WillMoveToSuperview:superview];  \
      \
    if (!superview) return; \
    /* In iOS 7.0.4. To access textView/textField.delegate when delegate is deallocated, */  \
    /* the delegate property will not being set to nil and exc_bad_access crash. */  \
    /* So we need to modify its delegate's -dealloc method. */  \
    if (self.delegate) {  \
        [self yj_insertImpFor##XXX##Delegate:self.delegate];  \
    } else {  \
        [self observeKeyPath:@"delegate" forUpdates:^(id  _Nonnull object, id  _Nullable newValue) {  \
            if (newValue) {  \
                [object yj_insertImpFor##XXX##Delegate:newValue];  \
            }  \
        }];  \
    }  \
}  \
  \
- (void)yj_insertImpFor##XXX##Delegate:(NSObject *)delegate {  \
    SEL deallocSel = NSSelectorFromString(@"dealloc");  \
    __weak id weakSelf = self; \
     /* Must not use same identifier for both textField and textView, otherwise one of them will get filtered out. */ \
    [delegate insertBlocksIntoMethodBySelector:deallocSel  \
                                    identifier:nil \
                                        before:^(id  _Nonnull receiver){  \
                                            [weakSelf setDelegate:nil];  \
                                        } after:nil];  \
}  \
  \
- (void)yj_##XXX##RemoveFromSuperview {  \
    if (self.autoResignFirstResponder) {  \
        [self yj_removeResignFirstResponderTapAction];  \
    }  \
    [self yj_##XXX##RemoveFromSuperview];  \
}  \
  \
- (void)yj_removeResignFirstResponderTapAction {  \
    UIView *view = self.providedARFRView;  \
    for (UIGestureRecognizer *gesture in view.gestureRecognizers) {  \
        if ([gesture isKindOfClass:[UITapGestureRecognizer class]]) {  \
            [gesture removeTarget:self action:@selector(yj_handleResignFirstResponderTap)];  \
        }  \
    }  \
}  \
  \
- (void)yj_handleResignFirstResponderTap {  \
    [self resignFirstResponder];  \
}  \
  \
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {  \
    return [self isFirstResponder] ? YES : NO;  \
}

#endif

#endif /* _YJResignFirstResponderDefaultImp_h */
