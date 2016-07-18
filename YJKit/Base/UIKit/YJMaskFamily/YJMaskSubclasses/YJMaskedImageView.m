//
//  YJMaskedImageView.m
//  YJKit
//
//  Created by huang-kun on 16/5/5.
//  Copyright © 2016年 huang-kun. All rights reserved.
//

#import "YJMaskedImageView.h"
#import "UIView+YJCategory.h"
#import "YJGeometryExtension.h"
#import "YJDebugMacros.h"
#import "_YJLayerBasedMasking.h"
#import "NSObject+YJExtension.h"
#import "YJUIMacros.h"

@implementation YJMaskedImageView

// Add default YJLayerBasedMasking implementations
YJ_LAYER_BASED_MASKING_PROTOCOL_DEFAULT_IMPLEMENTATION_FOR_YJMASKEDVIEW_SUBCLASS /* set _transparantFrame later */


#pragma mark - init & dealloc

// init from IB
- (nullable instancetype)initWithCoder:(NSCoder *)decoder {
    self = [super initWithCoder:decoder];
    if (self) [self decodeIvarListWithCoder:decoder forClass:YJMaskedImageView.self];
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
    [self encodeIvarListWithCoder:coder];
    [super encodeWithCoder:coder];
}

#if YJ_DEBUG
- (void)dealloc {
    NSLog(@"%@ <%p> dealloc", self.class, self);
}
#endif

#pragma mark - override setters

- (void)setImage:(UIImage *)image {
    [super setImage:image];
    if (!image) return;
    self.backgroundColor = nil;
    [self updateTransparentFrameIfNeeded];
    [self setNeedsUpdateMaskLayer];
}

- (void)setContentMode:(UIViewContentMode)contentMode {
    [super setContentMode:contentMode];
    [self updateTransparentFrameIfNeeded];
    [self setNeedsUpdateMaskLayer];
}

#pragma mark - masking

- (void)updateTransparentFrameIfNeeded {
    YJViewContentMode mode = [self mappedYJContentMode];
    if (mode == YJViewContentModeUnspecified) return;
    CGRect displayedImageRect = CGRectPositioned((CGRect){ CGPointZero, self.image.size }, self.bounds, mode);
    CGRect finalRect = CGRectIntersection(displayedImageRect, self.bounds);
    if (!CGRectIsNull(finalRect)) _transparentFrame = finalRect;
}

// Deprecated
//- (UIColor *)_backgroundColorRecursivelyFromSuperviewOfView:(UIView *)view {
//    UIView *superview = view.superview;
//    if (!view || !superview) return nil;
//    UIColor *color = superview.backgroundColor;
//    if (color && superview.alpha) return color;
//    else return [self _backgroundColorRecursivelyFromSuperviewOfView:superview];
//}

// Quote From WWDC: This is going to be invoked on our view right before it renders into the canvas, and it's a last miniute chance for us to do any additional setup.
- (void)prepareForInterfaceBuilder {
    if (!self.image && iOS_version >= 8.0) {
        NSBundle *bundle = [NSBundle bundleForClass:[self class]];
        self.image = [UIImage imageNamed:@"yj_head_icon" inBundle:bundle compatibleWithTraitCollection:nil];
    }
}

@end
