//
//  UIView+YJCategory.m
//  YJKit
//
//  Created by huang-kun on 16/3/21.
//  Copyright © 2016年 huang-kun. All rights reserved.
//

#import "UIView+YJCategory.h"
#import "YJUIMacros.h"

@implementation UIView (YJCategory)

#pragma mark - Geometry

#pragma mark * Setter

- (void)setTop:(CGFloat)top {
    CGRect frame = self.frame;
    frame.origin.y = top;
    self.frame = frame;
}

- (void)setLeft:(CGFloat)left {
    CGRect frame = self.frame;
    frame.origin.x = left;
    self.frame = frame;
}

- (void)setBottom:(CGFloat)bottom {
    CGRect frame = self.frame;
    frame.origin.y = bottom - frame.size.height;
    self.frame = frame;
}

- (void)setRight:(CGFloat)right {
    CGRect frame = self.frame;
    frame.origin.x = right - frame.size.width;
    self.frame = frame;
}

- (void)setCenterX:(CGFloat)centerX {
    CGPoint center = self.center;
    center.x = centerX;
    self.center = center;
}

- (void)setCenterY:(CGFloat)centerY {
    CGPoint center = self.center;
    center.y = centerY;
    self.center = center;
}

- (void)setOrigin:(CGPoint)origin {
    CGRect frame = self.frame;
    frame.origin = origin;
    self.frame = frame;
}

- (void)setSize:(CGSize)size {
    CGRect frame = self.frame;
    frame.size = size;
    self.frame = frame;
}

- (void)setTopInPixel:(CGFloat)topInPixel {
    self.top = topInPixel / kUIScreenScale;
}

- (void)setLeftInPixel:(CGFloat)leftInPixel {
    self.left = leftInPixel / kUIScreenScale;
}

- (void)setBottomInPixel:(CGFloat)bottomInPixel {
    self.bottom = bottomInPixel / kUIScreenScale;
}

- (void)setRightInPixel:(CGFloat)rightInPixel {
    self.right = rightInPixel / kUIScreenScale;
}

- (void)setCenterXInPixel:(CGFloat)centerXInPixel {
    self.centerX = centerXInPixel / kUIScreenScale;
}

- (void)setCenterYInPixel:(CGFloat)centerYInPixel {
    self.centerY = centerYInPixel / kUIScreenScale;
}

- (void)setOriginInPixel:(CGPoint)originInPixel {
    self.origin = (CGPoint){ originInPixel.x / kUIScreenScale, originInPixel.y / kUIScreenScale };
}

- (void)setSizeInPixel:(CGSize)sizeInPixel {
    self.size = (CGSize){ sizeInPixel.width / kUIScreenScale, sizeInPixel.height / kUIScreenScale };
}

#pragma mark * Getter

- (CGFloat)top { return self.frame.origin.y; }
- (CGFloat)left { return self.frame.origin.x; }
- (CGFloat)bottom { return self.frame.origin.y + self.frame.size.height; }
- (CGFloat)right { return self.frame.origin.x + self.frame.size.width; }
- (CGFloat)centerX { return self.center.x; }
- (CGFloat)centerY { return self.center.y; }
- (CGPoint)origin { return self.frame.origin; }
- (CGSize)size { return self.frame.size; }

- (CGFloat)topInPixel { return self.top * kUIScreenScale; }
- (CGFloat)leftInPixel { return self.left * kUIScreenScale; }
- (CGFloat)bottomInPixel { return self.bottom * kUIScreenScale; }
- (CGFloat)rightInPixel { return self.right * kUIScreenScale; }
- (CGFloat)centerXInPixel { return self.centerX * kUIScreenScale; }
- (CGFloat)centerYInPixel { return self.centerY * kUIScreenScale; }
- (CGPoint)originInPixel { return (CGPoint){ self.origin.x * kUIScreenScale, self.origin.y * kUIScreenScale }; }
- (CGSize)sizeInPixel { return (CGSize){ self.size.width * kUIScreenScale, self.size.height * kUIScreenScale }; }

#pragma mark - Springs & Struts

CGFloat YJGridLengthInContainerLength(CGFloat containerLength, NSUInteger gridCount, CGFloat padding) {
    return containerLength / gridCount - padding * (gridCount + 1) / gridCount;
}

CGFloat YJGridWidthInContainerWidth(CGFloat containerWidth, NSUInteger gridCount, CGFloat padding) {
    return YJGridLengthInContainerLength(containerWidth, gridCount, padding);
}

CGFloat YJGridHeightInContainerHeight(CGFloat containerHeight, NSUInteger gridCount, CGFloat padding) {
    return YJGridLengthInContainerLength(containerHeight, gridCount, padding);
}

CGFloat YJGridOffsetAtIndex(NSUInteger index, CGFloat gridLength, CGFloat padding) {
    return padding + index * (gridLength + padding);
}

CGFloat YJGridOffsetXAtIndex(NSUInteger index, CGFloat gridWidth, CGFloat padding) {
    return YJGridOffsetAtIndex(index, gridWidth, padding);
}

CGFloat YJGridOffsetYAtIndex(NSUInteger index, CGFloat gridHeight, CGFloat padding) {
    return YJGridOffsetAtIndex(index, gridHeight, padding);
}

NSUInteger YJGridCountInContainerLength(CGFloat containerLength, CGFloat gridLength, CGFloat padding) {
    return (containerLength + padding) / (gridLength + padding);
}

NSUInteger YJGridCountInContainerWidth(CGFloat containerWidth, CGFloat gridWidth, CGFloat padding) {
    return YJGridCountInContainerLength(containerWidth, gridWidth, padding);
}

NSUInteger YJGridCountInContainerHeight(CGFloat containerHeight, CGFloat gridHeight, CGFloat padding) {
    return YJGridCountInContainerLength(containerHeight, gridHeight, padding);
}

CGFloat YJGridPaddingInContainerLength(CGFloat containerLength, CGFloat gridLength, NSUInteger gridCount) {
    return (containerLength - gridLength * gridCount) / (gridCount + 1);
}

CGFloat YJGridPaddingInContainerWidth(CGFloat containerWidth, CGFloat gridWidth, NSUInteger gridCount) {
    return YJGridPaddingInContainerLength(containerWidth, gridWidth, gridCount);
}

CGFloat YJGridPaddingInContainerHeight(CGFloat containerHeight, CGFloat gridHeight, NSUInteger gridCount) {
    return YJGridPaddingInContainerLength(containerHeight, gridHeight, gridCount);
}

@end


@implementation UIView (YJGeometryExtension)

- (YJViewContentMode)mappedYJContentMode {
    switch (self.contentMode) {
        case UIViewContentModeTop: return YJViewContentModeTop;
        case UIViewContentModeLeft: return YJViewContentModeLeft;
        case UIViewContentModeRight: return YJViewContentModeRight;
        case UIViewContentModeBottom: return YJViewContentModeBottom;
        case UIViewContentModeCenter: return YJViewContentModeCenter;
        case UIViewContentModeTopLeft: return (YJViewContentModeTop | YJViewContentModeLeft);
        case UIViewContentModeTopRight: return (YJViewContentModeTop | YJViewContentModeRight);
        case UIViewContentModeBottomLeft: return (YJViewContentModeBottom | YJViewContentModeLeft);
        case UIViewContentModeBottomRight: return (YJViewContentModeBottom | YJViewContentModeRight);
        case UIViewContentModeScaleToFill: return YJViewContentModeUnspecified;
        case UIViewContentModeScaleAspectFit: return YJViewContentModeScaleAspectFit;
        case UIViewContentModeScaleAspectFill: return YJViewContentModeScaleAspectFill;
        case UIViewContentModeRedraw: return YJViewContentModeUnspecified;
    }
}

@end
