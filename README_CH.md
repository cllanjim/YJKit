# YJKit

[![CI Status](http://img.shields.io/travis/huang-kun/YJKit.svg?style=flat)](https://travis-ci.org/huang-kun/YJKit)
[![Version](https://img.shields.io/cocoapods/v/YJKit.svg?style=flat)](http://cocoapods.org/pods/YJKit)
[![License](https://img.shields.io/cocoapods/l/YJKit.svg?style=flat)](http://cocoapods.org/pods/YJKit)
[![Platform](https://img.shields.io/cocoapods/p/YJKit.svg?style=flat)](http://cocoapods.org/pods/YJKit)

## 简介

If you prefer reading in English, tap [here](https://github.com/huang-kun/YJKit/blob/master/README.md).

<br>

YJKit是一个由iOS开发而衍生的开源项目，内容包含：

* Foundation的扩展
	* 动态库扩展
		* 方法交换封装、关联标记、isClass检查、isTaggedPointer检查、isMutable检查等
		* 对老版本的iOS包含delegate或者dataSource属性关键字是assign还是weak的检查(isWeakDelegateByDefault/isWeakDataSourceByDefault)
		* 通过对原生方法实现的额外动态插入，可以实现：1.安全的dealloc；2.安全的isEqual:
	* YJSafeKVO
		* 提供安全易用的kvo接口，只需观察，无需释放。
		* 提供绑定特性，支持持续订阅观察值的变化，支持组建复杂的一对一绑定，支持一对多绑定。
		* 详情可以参考[这里](https://github.com/huang-kun/YJSafeKVO/blob/master/README_CH.md)
	* YJCollection/YJSequence
		* 对集合类添加简单的集合特性的扩展，如map, filter, reduce, flat...
		* 对带有序列的集合添加简单的序列特性，如dropFirst, dropLast, prefix, suffix...
	* 其它扩展
		* NSBundle的图片资源管理, NSTime+block特性 
* UIKit的扩展
	* UIScreen屏幕尺寸适配(YJScreenDisplayResolution, YJScreenDisplayAspectRatio)
		* [UIScreen mainScreen].displayResolution
		* [UIScreen mainScreen].displayAspectRatio
	* YJGrid…简单的spring&structs布局公式，详情参考[YJKit的keynote分享]
	* UIImage的扩展：支持bundle资源加载，图片等比缩放
	* UIImageView的扩展：yj_contentMode，可以实现UIViewContentMode没有提供展示组合
		* imageView.yj_contentMode = YJViewContentModeAspectFit | YJViewContentModeTop;
	* UIColor的扩展：
		* 支持十六进制色值参数，
		* 作为C结构体的RGBColor，方便保存颜色信息，轻量，支持NSValue, boxable的对象化
	* 支持Block特性
		* UIControl
		* UIAlertView
		* UIGestureRecognizer
		* UIAlertSheet
		* UIBarButtonItem
	* UITextView, UITextField支持自动撤销键盘(autoResignFirstResponder)
		* UITextView支持placeholder特性
	* YJMaskFamily - 基于CALayer绘制的圆角家族
		* 支持IBDesignable：所见即所得
		* 性能保障：不会触发由于CALayer混合渲染以及离屏渲染带来的开销
		* 丰富的子类化扩展：YJRoundedCornerView, YJRoundedCornerImageView, YJCircularImageView, YJRoundedCornerButton, YJRoundedCornerLabel, YJSemicircularCornerButton, YJSemicircularCornerLabel
		* 详情参考[YJKit的keynote分享]
* CoreGraphics扩展
	* NSValue+CGFloat
	* CGGeometry扩展
		* CGSizeScaleToSize()
		* CGRectPositionToRect()
		* CGRectPositioned()
		* 使用详情参考[YJKit更新日志]和github demo
* 其它扩展
	* 宏定义：
		* 函数或方法执行限制execute_once(), perform_once()..., 使用详情参考文档
		* 将assign的delegate或dataSource实现weak的特性
			* YJ_WEAKIFY_DELEGATE_AND_DATASOURCE_FOR_CLASS
			* YJ_WEAKIFY_DELEGATE_AND_DATASOURCE_BY_SWIZZLING_SETTERS
			* YJ_WEAKIFY_DELEGATE_AND_DATASOURCE_BY_IMPLEMENTING_SAFE_SETTERS
			* 可以参考[YJKit的keynote分享]
	* YJTuple：
		* 支持宏的初始化创建
		* 使用时推荐子类化，可以参考[YJKit的keynote分享]
	* YJGroupedStyleTableViewController
		* 用少量的代码完成可以订制复杂细节的静态tableView
		* 适用于创建简洁个性的app设置界面
		* 截图可以参考[这里](https://github.com/huang-kun/YJGroupedStyleTableViewController)
	* YJPhotoLibrary：保存图片至相册

## Keynote

[YJKit的keynote分享](https://github.com/huang-kun/YJKit/tree/master/Keynote/)，通过`clone or download`下载，在目录中找到Keynote文件夹，找到YJKit.key

## 更新日志

[YJKit更新日志](https://github.com/huang-kun/YJKit/blob/master/YJKit_updates.md)

## 安装

需要Xcode 7.3以上的支持，用于使用`NS_SWIFT_NAME`来创建swift的API

```
platform :ios, '7.0'
pod 'YJKit'
```

## 作者

huang-kun, jack-huang-developer@foxmail.com

## 许可

YJKit基于MIT许可，更多内容请查看LICENSE文件。



