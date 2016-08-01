# YJKit

[![CI Status](http://img.shields.io/travis/huang-kun/YJKit.svg?style=flat)](https://travis-ci.org/huang-kun/YJKit)
[![Version](https://img.shields.io/cocoapods/v/YJKit.svg?style=flat)](http://cocoapods.org/pods/YJKit)
[![License](https://img.shields.io/cocoapods/l/YJKit.svg?style=flat)](http://cocoapods.org/pods/YJKit)
[![Platform](https://img.shields.io/cocoapods/p/YJKit.svg?style=flat)](http://cocoapods.org/pods/YJKit)

## Introduction

如果你更倾向于阅读中文，可以点击[这里](https://github.com/huang-kun/YJKit/blob/master/README_CH.md)。

<br>

YJKit is a useful Cocoa Touch library extension. Here is the menu list.

* Foundation extension
	* Runtime extension
		* Method swizzling, associated identifier/tag, isClass checking, isTaggedPointer checking, isMutable checking
		* isWeakDelegateByDefault/isWeakDataSourceByDefault for checking whether is weak as property attribute for delegate or dataSource (as opposed to assign)
		* Using IMP insertion for doing extra work by calling original method. This is being used for: 1. safe kvo dealloc; 2. calling safe isEqual: method.
	* YJSafeKVO
		* Provide safe and simple API for Key value observing.
		* Provide subscribing feature and support both single and multiple key path binding.
		* Click [here](https://github.com/huang-kun/YJSafeKVO/blob/master/README.md) for more information.
	* YJCollection/YJSequence
		* Add collection extension: map, filter, reduce, flat...
		* Add sequence extension: dropFirst, dropLast, prefix, suffix...
	* Others
		* NSBundle extension API, NSTime with block supports. 
* UIKit extension
	* UIScreen with device screen adaptation (YJScreenDisplayResolution, YJScreenDisplayAspectRatio)
		* [UIScreen mainScreen].displayResolution
		* [UIScreen mainScreen].displayAspectRatio
	* YJGrid… spring & structs on UIView category
	* UIImage extension: bundle loading and image resizing.
	* UIImageView extension: yj_contentMode property, which provide combined image display options that UIViewContentMode doesn't have:
		* imageView.yj_contentMode = YJViewContentModeAspectFit | YJViewContentModeTop;
	* UIColor extension:
		* Support hexadecimal value for UIColor generation
		* Provide RGBColor as light weight c struct for storing color component values, which support NSValue and boxable wrapping.
	* UIKit block API is supported for:
		* UIControl
		* UIAlertView
		* UIGestureRecognizer
		* UIAlertSheet
		* UIBarButtonItem
	* UITextView, UITextField's autoResignFirstResponder property.
		* UITextView also support placeholder property.
	* YJMaskFamily - CALayer based rounded corner family.
		* Support IBDesignable and IBInspectable.
		* High performance without layer blended color and offscreen rendering.
		* Customized subclasses: YJRoundedCornerView, YJRoundedCornerImageView, YJCircularImageView, YJRoundedCornerButton, YJRoundedCornerLabel, YJSemicircularCornerButton, YJSemicircularCornerLabel
* CoreGraphics extension
	* NSValue+CGFloat
	* CGGeometry extension with CGSize and CGRect 
		* CGSizeScaleToSize()
		* CGRectPositionToRect()
		* CGRectPositioned()
		* See more information on demo app.
* Other extensions
	* Macros:
		* execute_once(), perform_once()...
		* Make assign attributed property delegate or dataSource performs like weak.
			* YJ_WEAKIFY_DELEGATE_AND_DATASOURCE_FOR_CLASS
			* YJ_WEAKIFY_DELEGATE_AND_DATASOURCE_BY_SWIZZLING_SETTERS
			* YJ_WEAKIFY_DELEGATE_AND_DATASOURCE_BY_IMPLEMENTING_SAFE_SETTERS
	* YJTuple：
		* Support macro initializing.
		* Subclassing recommended.
	* YJGroupedStyleTableViewController
		* Using less code to build group styled tableView with lots of detail customization.
		* The default style is iOS setting app style.
		* Click [here](https://github.com/huang-kun/YJGroupedStyleTableViewController) for more snapshots.
	* YJPhotoLibrary: Save image to iOS photo album.

## Installation

* It requires Xcode 7.3+ for `NS_SWIFT_NAME` avaliable, so it can expose APIs for swift and feels more swifty. 
* It requires Cocoapods. Add `use_frameworks!` for Podfile to avoid compiler error by defining IB_DESIGNABLE in cocoapods project

```
platform :ios, '7.0'
use_frameworks!
pod 'YJKit'
```

## Author

huang-kun, jack-huang-developer@foxmail.com

## License

YJKit is available under the MIT license. See the LICENSE file for more info.


