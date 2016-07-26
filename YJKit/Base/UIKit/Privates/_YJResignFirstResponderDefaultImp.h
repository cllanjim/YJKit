//
//  _YJResignFirstResponderDefaultImp.h
//  YJKit
//
//  Created by huang-kun on 16/6/17.
//  Copyright © 2016年 huang-kun. All rights reserved.
//

#ifndef _YJResignFirstResponderDefaultImp_h
#define _YJResignFirstResponderDefaultImp_h

#import "YJRuntimeEncapsulation.h"
#import "NSObject+YJSafeKVO.h"
#import "NSArray+YJCollection.h"

#ifndef YJ_AUTO_RESIGN_FIRST_RESPONDER_DEFALT_METHODS_SWIZZLING
#define YJ_AUTO_RESIGN_FIRST_RESPONDER_DEFALT_METHODS_SWIZZLING(XXX) \
    [self swizzleInstanceMethodsBySelector:@selector(layoutSubviews) andSelector:@selector(yj_##XXX##LayoutSubviews)]; \
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
