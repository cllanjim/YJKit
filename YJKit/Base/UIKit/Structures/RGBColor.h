//
//  RGBColor.h
//  YJKit
//
//  Created by huang-kun on 16/5/22.
//  Copyright © 2016年 huang-kun. All rights reserved.
//

#import <CoreGraphics/CGGeometry.h>

typedef struct _RGBColor {
    CGFloat red, green, blue, alpha; /* 0.0 ~ 1.0 */
} RGBColor;

#if __has_attribute(objc_boxable)
typedef struct __attribute__((objc_boxable)) _RGBColor RGBColor;
#endif

CG_EXTERN const RGBColor RGBColorNone;

CG_INLINE RGBColor RGBColorMake(CGFloat red, CGFloat green, CGFloat blue, CGFloat alpha) {
    return (RGBColor){ red, green, blue, alpha };
}

CG_INLINE bool RGBColorEqualToColor(RGBColor color1, RGBColor color2) {
    return color1.red == color2.red && color1.green == color2.green && color1.blue == color2.blue && color1.alpha == color2.alpha;
}

CG_INLINE bool RGBColorIsValidColor(RGBColor color) {
    bool (^validColorComponent)(CGFloat) = ^bool(CGFloat component){ return component >= 0.0 && component <= 1.0; };
    return !RGBColorEqualToColor(color, RGBColorNone) && validColorComponent(color.red) && validColorComponent(color.green) && validColorComponent(color.blue) && validColorComponent(color.alpha);
}

FOUNDATION_EXTERN NSString *NSStringFromRGBColor(RGBColor rgbColor);


@interface NSValue (RGBColorExtension)

+ (NSValue *)valueWithRGBColor:(RGBColor)rgbColor;

- (RGBColor)RGBColorValue;

@end


@interface NSCoder (RGBColorExtension)

- (void)encodeRGBColor:(RGBColor)rgbColor forKey:(NSString *)key;

- (RGBColor)decodeRGBColorForKey:(NSString *)key;

@end


@interface UIColor (RGBColorExtension)

+ (UIColor *)colorWithRGBColor:(RGBColor)rgbColor;

- (RGBColor)RGBColor;

@end
