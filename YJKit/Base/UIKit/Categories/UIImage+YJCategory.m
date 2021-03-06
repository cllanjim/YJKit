//
//  UIImage+YJCategory.m
//  YJKit
//
//  Created by huang-kun on 16/3/20.
//  Copyright © 2016年 huang-kun. All rights reserved.
//

#import "UIImage+YJCategory.h"
#import "NSBundle+YJCategory.h"
#import "YJMemoryCache.h"
#import "YJUIMacros.h"

@implementation UIImage (YJCategory)

#pragma mark - NSBundle loading

static NSString *_yj_cachedKeyForUIImageName(NSString *name, UIImageOrientation orientation) {
    if (orientation == UIImageOrientationUp) return name;
    return [NSString stringWithFormat:@"%@_%@", name, @(orientation)];
}

+ (nullable UIImage *)imageNamed:(NSString *)name scaledInBundle:(nullable NSBundle *)bundle {
    return [self imageNamed:name orientation:UIImageOrientationUp scaledInBundle:bundle];
}

+ (nullable UIImage *)imageNamed:(NSString *)name orientation:(UIImageOrientation)orientation scaledInBundle:(nullable NSBundle *)bundle {
    if (!name.length) return nil;
    if (!bundle) bundle = [NSBundle mainBundle];
    NSString *key = _yj_cachedKeyForUIImageName(name, orientation);
    UIImage *image = [YJMemoryCache defaultMemoryCache][key];
    if (!image) {
        NSString *imagePath = nil;
        NSArray *imageTypes = @[@"png", @"jpg", @"jpeg"];
        for (NSString *type in imageTypes) {
            imagePath = [bundle pathForScaledResource:name ofType:type];
            if (imagePath) break;
        }
        if (!imagePath) return nil;
        image = [UIImage imageWithContentsOfFile:imagePath];
        if (orientation != UIImageOrientationUp) image = [UIImage imageWithCGImage:image.CGImage scale:image.scale orientation:orientation];
        if (image) [YJMemoryCache defaultMemoryCache][key] = image;
    }
    return image;
}

#pragma mark - resizing

- (UIImage *)resizedImageForSize:(CGSize)size {
    UIGraphicsBeginImageContextWithOptions(size, NO, self.scale);
    [self drawInRect:(CGRect){CGPointZero, size}];
    UIImage *resizedImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return resizedImage;
}

- (UIImage *)resizedImageByMultiplier:(CGFloat)multiplier {
    CGSize newSize = (CGSize){self.size.width * multiplier, self.size.height * multiplier};
    return [self resizedImageForSize:newSize];
}

- (UIImage *)resizedImageForWidth:(CGFloat)width {
    CGFloat height = self.size.height * width / self.size.width;
    CGSize newSize = (CGSize){width, height};
    return [self resizedImageForSize:newSize];
}

- (UIImage *)resizedImageForHeight:(CGFloat)height {
    CGFloat width = self.size.width * height / self.size.height;
    CGSize newSize = (CGSize){width, height};
    return [self resizedImageForSize:newSize];
}

- (UIImage *)resizedImageForWidthInPixel:(CGFloat)widthInPixel {
    CGFloat width = widthInPixel * kUIScreenScale;
    return [self resizedImageForWidth:width];
}

- (UIImage *)resizedImageForHeightInPixel:(CGFloat)heightInPixel {
    CGFloat height = heightInPixel * kUIScreenScale;
    return [self resizedImageForHeight:height];
}

@end
