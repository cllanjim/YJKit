title: YJKit更新日志
date: 2016-04-12 21:50:49
tags: YJKit

---

## 简介

YJKit(云江库)是基于iOS平台的一个开源项目，目前由云江科技iOS开发者黄琨建立和维护，初心是为了在开发iOS项目中少写一些bug以及增加代码的重用，因此封装了一些常用的特性，提高开发效率。

* YJKit编写语言为`Objective C`，同时含有少量C语言
* YJKit因需求涵盖了对部分Cocoa Touch library的components进行扩展，主要包含`Foundation`, `UIKit`
* YJKit同样支持引入到Swift项目

<br>

## 安装

YJKit的安装是基于CocoaPods项目管理工具，需要在项目中建立Podfile，其中标明`use_frameworks!`的原因是避免编译器对于Pod中使用`IBDesignable`的报错，以确保其正常使用：

```
platform :ios, '7.0'
use_frameworks! 
pod 'YJKit'
```

在`terminal`进入在Podfile目录下，使用命令`pod install`，安装成功后，在项目的`.pch`文件中加入

```
#ifdef __OBJC__
    #import <YJKit/YJKit.h>
    #import <YJKit/AVCaptureSession+YJCategory.h> // optional, import if needed
#endif
```

不过由于苹果面对开发者不合理的使用`.pch`导致影响编译时间的问题，自从`Xcode 6`以来项目就不在生成默认的`.pch`文件了，点击[这里](http://stackoverflow.com/questions/24305211/pch-file-in-xcode-6)有关于自己为项目搭建`.pch`文件的步骤。对于Swift项目，可以使用CocoaPods来引入安装，另外仍需要创建`ProjectName-Bridging-Header.h`

<br>

## 版本更新

在`terminal`中使用`pod update YJKit`即可实现版本更新。这里特别需要注意，**Xcode缓存的`DerivedData`可能会造成新的代码不被编译**，如果遇到编译不过或者运行后没有识别新的代码等问题，可以尝试删除`DerivedData`。首先退出Xcode，然后在`terminal`中进行：

```
cd ~/Library/Developer/Xcode
rm -rf DerivedData
```

<br>

## YJKit Demo

[YJKit Demo](https://github.com/huang-kun/YJKit) 进入后点击`Download ZIP`

<br>

## 版本 1.0.0（2016-8-1）

* 修复YJSafeKVO的bug
* 发布1.0.0

<br>

## 版本 0.4.5（2016-7-27）

* 更新`YJSafeKVO`，进入`0.4.0`版本就意味着重写了大部分内部实现的代码，增加了稳定性和性能，建立的`观察模式`,`订阅模式`,`发布模式`等概念，优化了许多细节。
* 添加了防止delegate崩溃的情况
	* 比如`UITableView`在老版本的iOS中的delegate和dataSource属性的引用关键字其实是`assign`而非`weak`，这样以来，由于其delegate释放以后再次访问`tableView.delegate`就会崩溃。
	* 不仅是`UITableView`，还涉及到常用的`UICollectionView`, `UITextView`...
	* 解决方法是：
		* 如果你没有实现`UITableView`的load方法，那么以后也不打算实现的话，就使用`YJ_WEAKIFY_DELEGATE_AND_DATASOURCE_FOR_CLASS(UITableView)`，通过在load中使用方法交换来实现一个类似`__weak`的`delegate`和`dataSource`。
		* 如果你已经实现了`UITableView`的load方法，那么在实现代码中加入以下两个宏即可实现一样的效果。
			1. YJ_WEAKIFY_DELEGATE_AND_DATASOURCE_BY_SWIZZLING_SETTERS
			2. YJ_WEAKIFY_DELEGATE_AND_DATASOURCE_BY_IMPLEMENTING_SAFE_SETTERS

<br>

## 版本 0.3.8（2016-7-9）

* 更新`YJSafeKVO`
	* 添加了绑定机制
	* 更新了内部实现

<br>

## 版本 0.3.5（2016-7-6）

* 改进`YJSafeKVO`
* 改进了很多内部实现，更新了很多方法名称，拆分文件等等

<br>

## 版本 0.3.0

改进了原先一直使用的`YJBlockBasedKVO`，这次推翻了先前的API设计，调换了观察者的概念，让调用`-observe:updates:`新方法的对象称之为观察者，这样更容易理解和使用kvo，并且重新命名为`YJSafeKVO`，由此进入`0.3.0`版本。更多关于`YJSafeKVO`的内容，可以查看[这里](https://github.com/huang-kun/YJSafeKVO/blob/master/README_CH.md)

<br>

## 版本 0.2.6（2016-6-27）

* **又一次修改了KVO的方法名称**，目前简要介绍这两个APIs的区别：
	* `observeKeyPath:forChanges:`，意味着观察接收者的一个属性的值从旧到新变化，实现方法等同于使用`(NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew)`
	* `observeKeyPath:forUpdates:`，意味着观察接收者的一个属性更新的值，实现方法等同于使用`(NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew)`
	* 在后者方法中特别加入了initial，即后者的block会在调用观察keyPath方法之后立即被执行一次
* 对于结束观察行为的话，可以通过以下方式：
	* 调用`unobserveForKeyPath:`来终止对于指定keyPath的观察
	* 调用`unobserveAllKeyPaths`来终止对自己所有属性的观察
	* 还可以选择什么也不干。。
* 给kvo以上的扩展方法添加了带有identifier参数的版本，便于标记每个观察行为，因此可以去除指定标记的观察行为
	* 比如一个全局的对象或者单例对象的同一个属性被多个其他对象用于观察，如果某一个对象结束了观察行为，这时候调用`[sharedObject unobserveForKeyPath:]`，结果会停止所有关于这个keyPath的观察行为，导致其他对象无法继续观察该属性。应对这种情况可以通过identifier来标记属于自己的观察行为，而在结束观察的时候调用`[sharedObject unobserveForKeyPath:forIdentifier:]`结束给定标记的观察行为，而不会影响其他的观察行为。
* 给kvo的扩展方法添加了`NSOperationQueue`的支持，可以指派一个queue来执行block语句。
* 最后补充了kvo的文档，详情参见`NSObject+YJBlockBasedKVO.h`。对于应对大多数基本业务和需求的情况下，这几个APIs足够替代苹果官方提供的即难用又不安全的kvo调用了。

以下是关于使用block的一点建议：

* 避免在block中直接使用实例变量，会导致block隐式捕获self；建议显式写明self来搭配@strongify
* 即便使用`self->_ivar`，self也可能存在nil的情况，会产生崩溃
* 在block中，使用属性会比ivar更加安全

```
// bad
@weakify(self);
[self block:^{
    @strongify(self);
    _ivar = ...
}];

// better
@weakify(self);
[self block:^{
    @strongify(self);
    if (self) self->_ivar = ...
}];
```

<br>

## 版本 0.2.0（2016-6-23）

* 更新了`NSObject+YJBlockBasedKVO`
	* 内部创建了一个类来封装并管理所有添加给当前对象的观察者
	* **关于KVO所有扩展方法的重命名**，比如将原先的`-registerObserverForKeyPath:handleChanges:`方法名更新为`-observeKeyPath:forChanges:`，语义表述更简明清晰，同时更新了文档
* 添加`@keyPath`特性，参考自`extobjc`，并添加了文档
	* 苹果在`WWDC 2016`关于`Swift 3`的session中官方宣布支持了`#keyPath`来进行keyPath参数的静态检查，因此可以理解为苹果对于引进keyPath的静态检查特性也是众望所归吧。这里的`@keyPath`只适用于`Objective C`
	* 适合KVC和KVO的APIs，在填写keyPath参数的时候使用`@keyPath`可以进行静态编译检查，防止拼写错误
	* 如果被观察类的属性在未来被重新命名，那么在方法调用时候使用了`@keyPath`的地方同样会收到错误提示，防止运行时crash

```
// KVC
[foo setValue:@"Jack" forKeyPath:@keyPath(foo.friend.name)];

// KVO
[foo observeKeyPath:@keyPath(foo.friend.name) forChanges:^(id  _Nonnull object, id  _Nullable oldValue, id  _Nullable newValue) {
    // ...
}];
```

<br>

## 版本 0.1.70（2016-6-19）

修复bugs以及改善性能

* 删减并整合了一些文件
* 改进了`UITextView`和`UITextField`关于点击背景撤销`first responder`的代码
* 修复了`YJKit`应用于`iOS 7`的一些崩溃和其他问题
* 改进了`YJMaskFamily`的APIs，提升部分性能
* 修复了编译器不支持boxable特性而带来的编译出错问题
* 重命名一些方法和宏

<br>

增加新特性

* 给动态库添加一点扩展：
	* 由于官方的`object_isClass`仅支持`iOS 8`以上，所以YJKit提供一个`yj_object_isClass`
	* `NSObject`方便encode或者decode当前类的ivarList，但是在类继承链中使用的话，需要将当前的类作为参数传递。虽然这个API使用起来比较奇怪，为什么调用的时候还需要传递当前类作为参数，这里主要是避免该类被子类化以后，其子类在调用super时decode的ivarList仍然是子类的ivarList。
	* `NSObject`加入`containsSelector:`，即查看该类的`dispatch table`中是否含有selector，而不包括继承自父类的方法，因此用法不同于`respondsToSelector:`
	* `NSObject`支持向指定的方法添加额外的代码块

```
[foo insertImplementationBlocksIntoInstanceMethodBySelector:@selector(sayHello)
                                                  identifier:@"TEST"
                                                      before:^(id  _Nonnull receiver) {
                                                         NSLog(@"Run before sayHello");
                                                      } after:^(id  _Nonnull receiver) {
                                                         NSLog(@"Run after sayHello");
                                                      }];
[foo sayHello];
```

**特别提示** 后续版本中已将该方法称改为`performBlocksByInvokingSelector:before:after:`，调用是请遵循以下规则：

* 如果方法接收者是实例对象，那么selector参数必须对应一个实例方法
* 如果方法接收者是类对象，那么selector参数必须对应一个类方法
* 总结起来就是接收者需要能够响应传入的selector

由于定义了这样的规则，在方法命名的时候就可以将`InstanceMethod`简化为`Method`。如果一个类中含有同名的类方法和实例方法，那么通过发送给不同类型的接收者则会修改不同类型的方法。

<br>

## 版本 0.1.62（2016-6-4）

* 修复了`UITextView`和`UITextField`的category中的一些bugs
* 添加`YJGroupedStyleTableViewController`，通过子类化该类可以方便创建一个静态列表，特性包括：
	* 提供比`UITableViewStyleGrouped`实现更多的定制：
		* 可以为每个section的cell指定不同的`UITableViewCellStyle`样式
		* 更改section间距的背景颜色，以及section间距的高度
		* 可以制定分割线的颜色、粗细程度、左对齐样式、以及显示状态（全显示、全隐藏或部分隐藏）
		* 简单设置section header或footer的文字内容等
		* 如果开发者注册一个带有背景色的header置于顶部显示（将header创建为UITableViewCell的子类），配置好UI和约束以后，那么这个table会配置好相应的下拉背景色。
		* 可以为某个section注册自定义的cell
	* 存在不足的地方：
		* 继承自`UITableViewStyleGrouped`的子类默认不推荐向`tableView`的`backgroundView`添加背景图片。
		* 对于section header或footer不支持过长的文字内容，会被裁减。

<br>

## 版本 0.1.48 (2016-5-26)

* 在`NSObject`基础上增加一些扩展：
	* 添加了关联标记`associatedIdentifier`，通过运行时关联对象的特性，可以给任何对象一个字符串标记；
	* 添加了`isMutable`，确保实现对于某些类簇进行正确的可变或不可变版本的判断（比如`NSString`），而不是通过自省（introspection）的方式。
	* 添加了`isTaggedPointer`，用来判断一个指针表示对象还是`tagged pointer`，需要注意的是`tagged pointer`是对支持64位的设备而生的系统优化特性，指针指向的对象不会在堆中申请内存，因此也就不可以绑定关联对象，否则运行会遭遇`exc_bad_access`，因此这里就需要该特性对实现关联标记的时候进行保护。
* **按照objective c的命名惯例修改了所有`YJCollection`和`YJSequence`相关的APIs**，同时确保避免将类似的方法（比如mapped:）暴露给Swift环境，推荐在编写Swift的时候使用Swift集合自己的APIs
* 添加`UITextView`和`UITextField`的扩展，二者都是默认在用户点击背景的时候自动撤销键盘，并且`UITextView`带有了`placeholder`特性
* 修复了一些`YJGroupedStyleTableViewController`的bug
* 规整了YJKit的文件目录结构
* **更改了支持block特性的kvo代码**，弃用`-[NSObject addObservedKeyPath:...]`，推荐`-[NSObject registerObserverForKeyPath:...]`，这里借鉴了开源项目`BlocksKit`的特性，注册kvo后可以无需手动移除观察者，一切由YJKit负责移除清理。

<br>

## 版本 0.1.45（2016-5-21）

* 添加`NSString+YJCollection`特性，比如`@"hello"[1]`返回`@"e"`
* 针对在`UITableViewCell`上能够添加YJ圆角特性的视图子类而优化圆角性能

<br>

## 版本 0.1.44（2016-5-20）

* 在原有的特性中增添了一些APIs
* 修复若干bugs
* 给`NSString`, `NSArray`添加`Sequence`特性，比如

```
- (id)dropFirst:(NSUInteger)count;
- (id)dropLast:(NSUInteger)count;
- (id)prefix:(NSUInteger)count;
- (id)suffix:(NSUInteger)count;
- (id)prefixUpTo:(NSUInteger)upToIndex;
- (id)suffixFrom:(NSUInteger)fromIndex;
```

* 给`NSArray`, `NSMutableArray`, `NSSet`, `NSMutableSet`集合加入了一些`Collection`扩展，包括其他语言常用的`map(), filter(), reduce()`等

以下为`NSArray`的`Collection`扩展

```
- (NSArray *)map:(U(^)(T obj))mapping;
- (NSArray *)filter:(BOOL(^)(T obj))condition;
- (T)reduce:(U)initial combine:(U(^)(U result, T obj))combine;
- (NSArray *)flatten;
- (NSArray *)flatMap:(U(^)(T obj))mapping;
```

* ~~对于可变字符串以及可变集合，同样实现了以`-ing`方式命名的版本，比如`[mutableArray mapping:]`，`[mutableString droppingFirst]`用于修改自身且无返回对象。~~


另外还有关于圆角视图家族的更新和问题修复。

* 添加`YJSemicircularCornerButton`和`YJSemicircularCornerLabel`，即特殊的圆角button和label，其左右边的圆角均是半圆形状（目前在命名上实在想不到又短又能精准描述其功能的类名了）。
* ~~给YJ圆角家族新增`YJRoundedCornerTextView`~~，其实做到圆角效果的`UITextView`，只要在textView添加到一个尺寸稍大的`YJRoundedCornerView`中作为它的subview就好了。


<br>

## 版本 0.1.30（2016-5-9）

* 添加了方便在IB开发阶段展示圆形效果的视图，包含：
	* `YJCircularImageView`（比如方便使用在需要圆形头像作为图标的UIImageView）
* 添加了方便在IB开发阶段展示圆角效果的视图，包含：
	* `YJRoundedCornerView`
	* `YJRoundedCornerImageView`
	* `YJRoundedCornerButton`
	* `YJRoundedCornerLabel`
* 注意：这些圆角views是通过创建一个layer覆盖在上面，并且使得layer的角落颜色与圆角view的superview的background color相同，而达到在视觉上的圆角效果，并且避免了图层合成渲染（layer color blending）带来的性能开销。但是如果圆角view的superview的background color默认为nil的话，那么就不会出现圆角效果了。比如在UITableViewCell中加入这些view，但是cell.contentView的背景色默认为nil；比如在UIStackView中加入这些view，而UIStackView没有对应的layer提供背景色绘制等等。遇到superview没有backgroundColor的解决方法有两个：
	* 手动设置superview的背景色，比如`cell.contentView.backgroundColor = [UIColor whiteColor]`，就可以显示圆角效果；
	* 如果无法设置superview的背景色，还可以直接设置圆角view的`maskColor`属性，将颜色设置为背景色即可。

<br>

## 版本 0.1.14（2016-4-25）

* 改正了block-based KVO的问题 
* 添加一些函数或方法的运行标记相关的宏定义`YJExecutionMacros.h`:
	* 创建执行标记`execute_init()`
	* 函数或方法执行一次的标记，如`execute_once(), execute_once_begin(), execute_once_end()`，并且能够在同一个函数或方法内多次使用`execute_once_begin(), execute_once_end()`配对
	* 方法可重复执行一次的标记，如`perform_once(), perform_once_begin(), perform_once_end()`，关于`perform_once`的实现借鉴了`sunnyxx`的self-managed关联对象来查看该方法是否被重复调用。
	* 避免同一个函数或方法在运行中多次被重复执行，如`execute_once_on(), execute_once_off()`

<br>

## 版本 0.1.10（2016-4-20）

* 添加了`YJPhotoLibrary`，方便存入图片到指定相册:
	* 假如项目app名为“XYZ”，那么调用以下方法，就会将image保存到系统的“XYZ”相册中，没有的话会创建一个“XYZ”相册。
	* 如果设置了`forceAlbumCreationAfterUserDeleted = YES`，那么用户将无法在Photo App中删除该相册，即删除后，下次进入依然存在。

```
[[YJPhotoLibrary sharedLibrary] saveImage:image metadata:nil success:^{
    NSLog(@"保存成功");
} failure:^(NSError * _Nonnull error) {
    NSLog(@"保存失败");
}];

```

<br>

## 版本 0.1.6 (2016-4-18)

* 添加了UIActionSheet支持block
* 改进了UIAlertView的block API

<br>

## 版本 0.1.0

* 发布版0.1.0

<br>

## 版本 0.0.25

* 修复了UIImageView_YJ的潜在bug

<br>

## 版本 0.0.21

* 更新了`YJMacros.h`:
* 将`kYJScreen...`简化为`kScreen...`
* 增加了`UIWindowSnapshot..`, `UIStatusBarHide..`和`onExit`

<br>

## 版本 0.0.18

* UIControl, UIGestureRecognizer在支持block特性的基础上，添加删除action block的API
* UIControl, UIGestureRecognizer在添加action block的时候可以对其进行标签

<br>

## 版本 0.0.16

* NSTimer, KVO支持Block特性

**使用KVO+Block注意事项**：

* 使用时需要注意引用循环，避免在block中直接使用实例变量
* KVO如果使用block多次注册观察了同一个keyPath，那么最后移除的时候只允许对相应的keyPath调用`-removeObservedKeyPath:`一次！
* KVO在使用`-[NSObject addObservedKeyPath:handleChanges:]`的block回调不一定发生在主线程，比如在其它线程中改变了被观察的keyPath的状态，那么回调会发生在状态改变的线程中。

**使用NSTimer+Block注意事项**：

* 使用时需要注意引用循环，避免在block中直接使用实例变量
* NSTimer仍需要调用`-[timer invalidate]`来释放timer的block
* 使用NSTimer的block需要注意以下问题：

e.g. 在controller中加入NSTimer，并且设置repeats = YES，
如果运行以下代码，创建出的NSTimer对象会被加入到RunLoop中，在timer的block中直接使用self会使得controller在timer运行时期不会被释放（即使dismiss controller），而controller本身对timer没有强引用，因此timer与controller之间不存在引用循环问题。

```
static int i = 0;
[NSTimer scheduledTimerWithTimeInterval:1.0 repeats:YES timerHandler:^(NSTimer *timer) {
    if (i > 4) {
        i = 0;
        [timer invalidate];
    } else {
        NSLog(@"i = %@ in %@", @(i), [self class]);
    }
    i++;
}];
```

如果修改了上述代码，给controller创建一个strong的timer属性，那么在timer运行的时候，timer和controller是构成引用循环的。但是如果人为调用`-[timer invalidate]`，就会使得timer的block被及时释放，从而打破引用循环。因此下面的代码也没有问题。

```
static int i = 0;
self.timer = [NSTimer scheduledTimerWithTimeInterval:1.0 repeats:YES timerHandler:^(NSTimer *timer) {
    if (i > 4) {
        i = 0;
        [timer invalidate];
    } else {
        NSLog(@"i = %@ in %@", @(i), [self class]);
    }
    i++;
}];
```

如果在代码中加入`weakSelf`和`strongSelf`的话，说明timer和controller之间没有引用循环。可是如果在timer被`-invalidate`之前，强行退出controller的话，等到下一次timer的block被调用的时候，block中的`strongSelf`仍会指向block外的`weakSelf`，但此时`controller`和`weakSelf`已被释放，所以block中的strongSelf就成了nil，这样造成了调用后面几次block的时候输出`strongSelf`为`(null)`的情况。

```
static int i = 0;
__weak id weakSelf = self;
self.timer = [NSTimer scheduledTimerWithTimeInterval:1.0 repeats:YES timerHandler:^(NSTimer *timer) {
    __strong id strongSelf = weakSelf;
    if (i > 4) {
        i = 0;
        [timer invalidate];
    } else {
        NSLog(@"i = %@ in %@", @(i), [strongSelf class]);
    }
    i++;
}];
```

解决方案：

* 在controller退出或释放的时候调用`-[timer invalidate]`
* 或者修改代码为`if (strongSelf) NSLog(@"i = %@ in %@", @(i), [strongSelf class]);`

<br>

## 版本 0.0.10

* UIControl, UIGestureRecognizer, UIBarButtonItem, UIAlertView支持Block特性

<br>

#### UIKit+Block特性

使用方法：

```
@weakify(self)
UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithActionHandler:^(UIGestureRecognizer * _Nonnull gestureRecognizer) {
    if (gestureRecognizer.state == UIGestureRecognizerStateRecognized) {
        @strongify(self)
        NSLog(@"<%@> tap location: %@", self.class, NSStringFromCGPoint([gestureRecognizer locationInView:gestureRecognizer.view]));
    }
}];
[self.view addGestureRecognizer:tap];
```

注意事项：

* 使用时需要避免引用循环，避免在block中直接使用实例变量
* (可能会)增加调试难度？

<br>

## 版本 0.0.8

* 支持hex color

<br>

#### Hex Color

```
UIColor *whiteColor = RGBColor(0xffffff, 1);
UIColor *blackColor = [UIColor colorWithHex:0x0 alpha:1.0];
UIColor *anotherColor = [UIColor colorWithHexString:@"0xffffff"];

if ([blackColor isEqualToRGBColor:[UIColor blackColor]]) {
    ...
}
```

<br>

## 版本 0.0.7

* 为UIImage添加缩放功能
* 为UIImageView添加yj_contentMode，用于替代UIViewContentMode
* 其它特性
	* 添加了弧度与角度转换（详见YJMacros.h）
	* 添加了springs and struts公式（详见UIView+YJCategory.h）

<br>

#### 为UIImage添加缩放功能

* 将UIImage按照指定的width(或者height)进行按比例伸缩
* 将UIImage按照指定的像素宽度(或者像素宽度)进行按比例伸缩

<br>

#### 为UIImageView添加yj_contentMode，用于替代UIViewContentMode

`UIImageView`可以通过`UIViewContentMode`指定如何进行图片展示，比如`UIViewContentModeScaleAspectFit`或者`UIViewContentModeLeft`，但是如果我不仅需要`ScaleAspectFit`，然后在其前提下继续进行`Left`的话，就很苦恼。

在YJKit中，使用`YJViewContentMode`即可。

```
imageView.yj_contentMode = YJViewContentModeScaleAspectFit | YJViewContentModeLeft;
```

详情可参考[UIImageView_YJ](https://github.com/huang-kun/UIImageView_YJ/blob/master/README.md)

<br>

## 版本 0.0.5 (2016-4-12)

* 常用图片资源(如icon)的独立封装和准确加载，这里借鉴了`ibireme`的`YYKit`对于NSBundle的扩展
* 指定屏幕像素尺寸
* CGGeometry的扩展
* 其它特性
	* 支持@weakify和@strongify特性 
	* 定义AVCaptureSession的输出格式(720p, 1080p, VGA, etc...)
	* 定义UIView的CGGeometry相关属性(top, centerX, topInPixel, etc...)

<br>

#### 常用图片资源(如icon)的独立封装和准确加载

在iOS项目中常用的图片加载主要通过一个UIImage的实例方法，即`-[UIImage imageNamed:]`，其作用是从项目的`Assets.xcasets`中根据图片名称和屏幕支持的分辨率来寻找尺寸大小合适的图片资源并返回。由于所有的图片资源集中至一处，意味着资源与项目的耦合度太高而不便重用。

YJKit提供的重用方案：

1. 单独创建一个`.bundle`文件，负责管理相关模块的图片资源
2. 调用UIImage的API

```
+ (nullable UIImage *)imageNamed:(NSString *)name scaledInBundle:(nullable NSBundle *)bundle;
```

即从指定的`.bundle`文件中选择图片资源，其它行为调用与`-[UIImage imageNamed:]`方法一致。

```
// 比如iPhone5s运行程序时，需要从名为AFTCameraUI.bundle中获取icon@2x.png文件，用于图标
// 调用方法如下：
NSBundle *bundle = [NSBundle bundleWithName:@"AFTCameraUI"];
UIImage *image = [UIImage imageNamed:@"icon" scaledInBundle:bundle];
[button setImage:image forState:UIControlStateNormal];
```

如果加载的图片有不同展示方向的需求，那么可以使用：

```
+ (nullable UIImage *)imageNamed:(NSString *)name orientation:(UIImageOrientation)orientation scaledInBundle:(nullable NSBundle *)bundle;
```

由于返回的是一个缓存的图片，因此重复调用不会去bundle中进行多次加载。

```
// 比如获取一个图片icon后，需要顺时针旋转90度，作为图标展示
UIImage *image = [UIImage imageNamed:@"icon" orientation:UIImageOrientationRight scaledInBundle:bundle];
[button setImage:image forState:UIControlStateNormal];
```

**注意**：该版本的bundle对于图片资源的格式仅支持png, jpg, jpeg; 尺寸格式包含@1x, @2x, @3x

<br>

#### 指定屏幕像素尺寸

如果以前项目中出现这样的宏定义：

```
#define iPhone6 CGSizeEqualToSize([UIScreen mainScreen].currentMode.size, CGSizeMake(750, 1334))
```

严格说来是不正确的，原因有两个：

1. 如果开启了iPhone 6的display zoom的话（可以在设置里调节），那么其屏幕尺寸的分辨率会从750x1134转变为640x1136，后者等同于是iPhone 5的屏幕分辨率。
2. 如果屏幕由竖屏转向横屏的话，屏幕的长和宽的值是会交换的

结论是：不可以仅通过屏幕分辨率来定义设备型号。

在项目中之所以会出现这样的定义，其实更多是用于创建的UI能够适配到不同的屏幕尺寸，比如

```
- (void)configureCell:(UITableViewCell *)cell {
    cell.height = ...
    if (iPhone6) {
        cell.height += extraHeight;
    }
}
```

YJKit提供的方案：通过对UIScreen创建displayResolution属性，来直接定义屏幕尺寸

```
@property (nonatomic, readonly) UIScreenDisplayResolution displayResolution;
```

具体可选的类型覆盖了所有iOS设备：

```
typedef NS_ENUM(NSInteger, UIScreenDisplayResolution) {
    UIScreenDisplayResolutionUndefined,
    // iPhone (includes iPod Touch)
    UIScreenDisplayResolutionPixel320x480,       // older type
    UIScreenDisplayResolutionPixel640x960,       // 4, 4s
    UIScreenDisplayResolutionPixel640x1136,      // 5, 5s, 6(display zoom), 6s(display zoom), SE 1
    UIScreenDisplayResolutionPixel750x1334,      // 6, 6s
    UIScreenDisplayResolutionPixel1125x2001,     // 6+(display zoom), 6s+(display zoom)
    UIScreenDisplayResolutionPixel1242x2208,     // 6+, 6s+
    // iPad
    UIScreenDisplayResolutionPixel768x1024,      // 1, 2, mini 1
    UIScreenDisplayResolutionPixel1536x2048,     // 3, 4, Air(1, 2) mini(2, 3, 4), Pro 2<9.7-inch>
    UIScreenDisplayResolutionPixel2048x2732,     // Pro (1, 2<12.9-inch>)
};
```

将代码中的`iPhone6`替换对应的`UIScreenDisplayResolutionPixel750x1334`就能够避免出现意外bug，并且某些尺寸涵盖了多部设备，使用非常方便。（比如iPad）

YJKit中同样提供了计算屏幕宽高比的方法，即访问UIScreen的displayAspectRatio属性。

```
@property (nonatomic, readonly) UIScreenDisplayAspectRatio displayAspectRatio;
```

其选项也包含了目前iOS的所有设备的屏幕比例

```
typedef NS_ENUM(NSInteger, UIScreenDisplayAspectRatio) {
    UIScreenDisplayAspectRatioUndefined,
    UIScreenDisplayAspectRatio_3_2,             // 3:2
    UIScreenDisplayAspectRatio_4_3,             // 4:3
    UIScreenDisplayAspectRatio_16_9,            // 16:9
};
```

~~详情可参考[UIScreen_YJ](https://github.com/huang-kun/UIScreen_YJ/blob/master/README.md)~~ 

**特别声明** 版本更新以后，这里的`UIScreenDisplay...`已经全部命名为`YJScreenDisplay...`

<br>

#### CGGeometry的扩展

该特性是对于CGGeometry.h的扩展，主要添加了对CGSize, CGRect支持等比例伸缩以及对齐的计算。以下重点介绍三个APIs：

* 将一个size按比例伸缩至一个指定大小的size中，获得一个伸缩后的size

```
CGSize CGSizeScaleToSize(CGSize originalSize, CGSize inSize, CGSizeScaleRule scaleRule);
```

可以伸缩的规则有：`CGSizeScaleNone`(不伸缩), `CGSizeScaleAspectFit`(完全填充至目标尺寸), `CGSizeScaleAspectFill`(完全覆盖目标尺寸)

```
CGSize newSize1 = CGSizeScaleToSize((CGSize){50,200}, (CGSize){100,100}, CGSizeScaleAspectFit)
CGSize newSize2 = CGSizeScaleToSize((CGSize){50,200}, (CGSize){100,100}, CGSizeScaleAspectFill)
// newSize1 = {25,100}, newSize2 = {100,400}
```

* 将一个rect按比例伸缩(或者移位)至一个指定大小的rect中

```
CGRect CGRectPositionToRect(CGRect originalRect, CGRect inRect, CGRectScaleRule scaleRule, CGRectAlignRule alignRule);
```

参数scaleRule表示伸缩规则，alignRule表示移动规则。
伸缩规则有3个：`CGRectScaleNone`, `CGRectScaleAspectFit`, `CGRectScaleAspectFill`
移动规则多个：`CGRectAlignCenter`, `..Top`, `..Bottom`, `..Left`, `..Right`, `..TopLeft`, `..TopRight`, `..BottomLeft`, `..BottomRight`

```
CGRect originalRect = (CGRect){0,0,50,200};
CGRect targetRect = (CGRect){100,100,100,100};

// 矩形左对齐
CGRect r1 = CGRectPositionToRect(originalRect, targetRect, CGRectScaleNone, CGRectAlignLeft);
// r1 = {110,140,50,200};

// 矩形左上角对齐
CGRect r2 = CGRectPositionToRect(originalRect, targetRect, CGRectScaleNone, CGRectAlignTopLeft);
// r2 = {110,190,50,200};

// 矩形AspectFit + 左对齐
CGRect r3 = CGRectPositionToRect(originalRect, targetRect, CGRectScaleAspectFit, CGRectAlignLeft);
// r3 = {110,190,25,100};

// 矩形AspectFit + 左上角对齐
CGRect r4 = CGRectPositionToRect(originalRect, targetRect, CGRectScaleAspectFit, CGRectAlignTopLeft);
// r4 = {110,190,25,100};
```

* 还有一个方便的API，效果与`CGRectPositionToRect()`一致，只是用法不同。比如同样实现一个矩形AspectFit + 左上角对齐的效果，可以调用：

```
CGRect r = CGRectPositionToRect(r1, r2, CGRectScaleAspectFit, CGRectAlignTopLeft);
```

也可以这样调用：

```
CGRect r = CGRectPositioned(r1, r2, CGRectScaleAspectFit | CGRectAlignTop | CGRectAlignLeft);
```

其参数包含上述的伸缩规格和移动规则，可以灵活组合搭配，但是也会出现滥用的情况，比如：(Fit | Fill), (Top | Bottom), (Left | Center)等等，类似的情况可以归纳为参数冲突。

YJKit处理此类冲突的方案，就是选择和舍弃，标准是依据每个参数的优先级的进行取舍。优先级的定义如下：

* 伸缩规格 > 移动规则，即遇到参数中带有Fit或者Fill，就会首先进行伸缩，然后进行平移；
* 伸缩规格中Fit > Fill，即参数同时存在(Fit | Fill)，则舍弃Fill，选择Fit
* 移动规则中Top > Left > Right > Bottom > Center，如果存在冲突，会依次舍弃低优先级的值
  * 比如参数为(Top | Bottom)，结果是Top
  * 比如参数为(Top | Bottom | Left)，结果是(Top | Left)
  * 比如参数为(Top | Bottom | Right)，结果是(Top | Right)

具体应用还可以参考这里的[Github Demo](https://github.com/huang-kun/CGGeometry_YJ)，进入后选择`Download ZIP`

<br>

#### @weakify和@strongify特性

这里是在block中常见的一段为避免引用循环而写的代码

```
__weak typeof(self) weakSelf = self;
self.completionBlock:^{
    __strong typeof(self) strongSelf = weakSelf;
    [strongSelf updateData];
    strongSelf.label.text = self.dataInfo;
};
```

**注意**在上述代码的block中由于疏忽而把`strongSelf.dataInfo`写成了`self.dataInfo`，就导致了引用循环问题。

使用@weakify和@strongify就是为了避免上述问题。

```
@weakify(self);
self.completionBlock:^{
    @strongify(self);
    [self updateData];
    self.label.text = self.dataInfo;
};
```

代码既美观，又不会产生引用循环。参考自`extobjc`

<br>






