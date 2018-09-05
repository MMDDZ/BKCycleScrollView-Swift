# BKCycleScrollView-Swift无限滚动视图

演示视图

![yanshi GIF](https://github.com/FOREVERIDIOT/BKCycleScrollView-Swift/blob/master/Images/yanshi.gif)

基本代码
```swift
let cycleScrollView = BKCycleScrollView(frame: CGRect, displayDataArr: [Any])
viewController.view.addSubView(cycleScrollView)
```
点击回调
```swift
//遵循代理
cycleScrollView.delegate = self
//实现代理
func selectItemAction(_ cycleScrollView: BKCycleScrollView, selectIndex: Int) {
    print("点击了cycleScrollView 索引为 \(selectIndex) 的 item")
}
```

## OC版BKCycleScrollView无限滚动视图链接
- [BKCycleScrollView](https://github.com/FOREVERIDIOT/BKCycleScrollView)

## 导入三方
- [Gifu](https://github.com/kaishin/Gifu)
- [Kingfisher](https://github.com/onevcat/Kingfisher)

## 版本记录
    1.0 无限轮播第一版完成
    1.1 优化无数据时滚动视图不能滑动
