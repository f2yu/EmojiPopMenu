# EmojiPopMenu
仿微博iOS版表情点赞，支持所有动效、手势、适配，支持自定义资源配置。触发方式为长按+持续拖动、长按后不拖动+点击，支持自定义触发。

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

![demo png](https://github.com/f2yu/EmojiPopMenu/blob/master/demo.png)

![demo gif](https://github.com/f2yu/EmojiPopMenu/blob/master/demo.gif)

## 使用说明
```swift
//EmojiPopMenu.shared.xxx
public class EmojiPopMenu {
...
    //配置、更新表情资源
    public func update(_ items: [EmojiPopMenuItem]) {...}
    
    //注册视图，将给视图添加触发手势，处理手势不中断的情况下选择表情的问题
    public func register(view: UIView, selectedBlock: ((_ item: EmojiPopMenuItem?) -> ())?) {...}
    
    //取消接管
    public func resign(view: UIView) {...}
    
    //主动触发表情控件方法
    public func showOn(_ view: UIView, selectedBlock: ((_ item: EmojiPopMenuItem?) -> ())?) {...}
...
}
```

## 配置说明
表情控件配置
```swift
//EmojiPopMenu.shared.config.xxx
public class EmojiPopMenuConfig {
...
    //缩放动画时间、选中后轨迹动画时间
    public var animationTime: TimeInterval = 0.33
    //true -> 轨迹会根据目标视图进行大小缩放，false ->默认缩放
    public var isTraceTargetView: Bool = true
    //表情间距
    public var itemSpace: CGFloat = 10
    //表情大小
    public var itemSize: CGSize = CGSize(width: 34, height: 34)
    //表情位于选中状态放大倍数
    public var itemZoomInScale: CGFloat = 1.55
    //其他表情位于选中状态时，表情的缩小倍数
    public var itemZoomOutScale: CGFloat = 0.88
    //表情托盘padding
    public var contentEdge: UIEdgeInsets = .init(top: 10, left: 12, bottom: 10, right: 12)
    //长按移动时垂直区域额外触发距离
    public var touchInZoomVerticalExt: CGFloat = 20
    //显示的title配置
    public var titleLabelConfig: EmojiPopMenuTitleLabelConfig = EmojiPopMenuTitleLabelConfig()
    //锚点视图是否根据上下边显示自动旋转
    public var isAnchorViewAutoRotation = true
    //距离目标point的距离，point为屏幕坐标
    public var distanceToTarget: CGFloat = 12
...
}
```
表情控件子视图配置
```swift
//EmojiPopMenu.shared.menuView.xxx
public class EmojiPopMenuView: UIView {
...
    //图片背景图，配置阴影、背景色等
    public lazy var backgroundView: UIView = {...}()
    
    //锚点视图，配置锚点样式
    public lazy var anchorImageView: UIImageView = {...}()
...
}
```
表情title配置
```swift
public class EmojiPopMenuTitleLabelConfig {
    // font，需除以缩放倍数  11 / 1.55
    public var font: UIFont = UIFont.systemFont(ofSize: 11 / 1.55)
    public var textColor: UIColor = .white
    public var textAlignment: NSTextAlignment = .center
    public var backgroundColor: UIColor = .black.withAlphaComponent(0.5)
    public var height: CGFloat = 20 / 1.55
    //距离 background 的水平边距
    public var horizontalMargin: CGFloat = 6 / 1.55
    //离表情的距离
    public var distanceToImage: CGFloat = 5.5 / 1.55
}
```

## Installation

EmojiPopMenu is available through [CocoaPods](https://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'EmojiPopMenu'
```

## Author

f2yu, 470623403@qq.com

## License

EmojiPopMenu is available under the MIT license. See the LICENSE file for more info.
