//
//  YJRoundedCornerButton.m
//  YJKit
//
//  Created by huang-kun on 16/5/7.
//  Copyright © 2016年 huang-kun. All rights reserved.
//

#import "YJRoundedCornerButton.h"
#import "_YJLayerBasedMasking.h"
#import "_YJRoundedCornerView.h"
#import "NSObject+YJSafeKVO.h"
#import "NSObject+YJExtension.h"
#import "NSValue+YJGeometryExtension.h"
#import "YJObjcMacros.h"
#import "YJKVCMacros.h"
#import "YJDebugMacros.h"

@interface YJRoundedCornerButton ()
@property (nonatomic) YJContentIndents titleIndents;
@end

@implementation YJRoundedCornerButton

// Add default YJLayerBasedMasking implementations
YJ_LAYER_BASED_MASKING_PROTOCOL_DEFAULT_IMPLEMENTATION_FOR_UIVIEW_SUBCLASS

// Add default rounded corner implementations
YJ_ROUNDED_CORNER_VIEW_DEFAULT_IMPLEMENTATION_FOR_UIVIEW_SUBCLASS

/* init from code */   
- (instancetype)initWithFrame:(CGRect)frame {   
    self = [super initWithFrame:frame];   
    if (self) {   
        [self setup];
    }   
    return self;   
}   

/* init from IB */   
- (nullable instancetype)initWithCoder:(NSCoder *)decoder {
    self = [super initWithCoder:decoder];
    if (self) [self decodeIvarListWithCoder:decoder];
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

- (void)setup {
    _cornerRadius = 10.0f;
    _titleIndentationStyle = YJContentIndentationStyleDefault;
    _borderWidth = 1.0f;
    [self observeTintColor];
}

- (void)observeTintColor {
    [self observe:PACK(self, tintColor) updates:^(YJRoundedCornerButton *self, id  _Nonnull target, UIColor * _Nullable newColor) {
        if (newColor) {
            if (![self.borderColor isEqualToColor:newColor]) {
                self.borderColor = newColor;
            }
        }
    }];
}

- (void)setTitleIndentationStyle:(YJContentIndentationStyle)titleIndentationStyle {
    _titleIndentationStyle = titleIndentationStyle;
    [self setNeedsUpdateMaskLayer];
}

// Add default intrinsicContentSize implementation

- (CGSize)sizeThatFits:(CGSize)size {
    return [self intrinsicContentSize];
}

- (CGSize)intrinsicContentSize {
    CGSize size = [super intrinsicContentSize];
    YJContentIndents indents = [self titleIndentsForIdentationStyle:self.titleIndentationStyle contentSize:size];
    size.width += indents.left + indents.right;
    size.height += indents.top + indents.bottom;
    return size;
}

- (YJContentIndents)titleIndents {
    return [self titleIndentsForIdentationStyle:self.titleIndentationStyle contentSize:[super intrinsicContentSize]];
}

- (YJContentIndents)titleIndentsForIdentationStyle:(YJContentIndentationStyle)style
                                     contentSize:(CGSize)contentSize {
    CGFloat height = contentSize.height;
    YJContentIndents indents = YJContentIndentsZero;
    
    switch (style) {
        case YJContentIndentationStyleNone:
            break;
        case YJContentIndentationStyleDefault:
            indents.left = height / 2;
            indents.right = height / 2;
            break;
        case YJContentIndentationStyleLarge:
            indents.left = height / 2 * 1.8;
            indents.right = height / 2 * 1.8;
            break;
    }
    return indents;
}

@end
