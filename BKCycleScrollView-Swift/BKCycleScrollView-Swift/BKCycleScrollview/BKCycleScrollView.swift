//
//  BKCycleScrollView.swift
//  BKCycleScrollView-Swift
//
//  Created by BIKE on 2018/6/27.
//  Copyright © 2018年 BIKE. All rights reserved.
//

import UIKit
import Kingfisher

enum BKDisplayCellLayoutStyle : Int {
    case normal = 0
    case middleLarger = 1
}

enum BKCycleScrollPageControlStyle : Int {
    case none = 0
    case normalDots = 1
    case longDots = 2
}

private let kAutoScrollInterval : CGFloat = 5.0//自动滚动时间间隔
private let kAllCount = 99999//初始item数量
private let kMiddleCount : Int = kAllCount/2-1//item中间数

private let kPageControlDotHeight : CGFloat = 7.0//小圆点高度
private let kPageControlDotSpace : CGFloat = 7.0//小圆点之间的间距
private let kPageControlDotBottomInset : CGFloat = 10.0//小圆点距底部边界偏移量

private let kRegisterCellID : String = "BKCycleScrollCollectionViewCell"//注册的cellID

// MARK: - 代理
@objc protocol BKCycleScrollViewDelegate : class {
    
    @objc optional func selectItemAction(_ cycleScrollView: BKCycleScrollView, selectIndex: Int)
    
    /// 自定义cell方法
    ///
    /// - Parameters:
    ///   - cycleScrollView: 无限滚动视图
    ///   - displayIndex: 索引
    ///   - displayCell: 显示的cell
    @objc optional func customCellStyle(_ cycleScrollView: BKCycleScrollView, displayIndex: Int, displayCell: UICollectionViewCell)
}

// MARK: - 类创建
class BKCycleScrollView: UIView {
    
    // MARK: - 普通属性
    /// 代理
    weak var delegate : BKCycleScrollViewDelegate?
    /// 背景颜色 默认透明
    var displayBackgroundColor : UIColor = UIColor.clear {
        didSet {
            if collectionView != nil {
                collectionView?.backgroundColor = displayBackgroundColor
            }
        }
    }
    /// 图片数组 网络图片传String 本地图片传Image或者data
    var displayDataArr : [Any]? {
        didSet {
            if collectionView != nil {
                currentIndex = 0
                collectionView?.reloadData()
                
                invalidateTimer()
                initTimer()
            }
            
            if pageControl != nil {
                pageControl?.numberOfPages = displayDataArr?.count ?? 0
                pageControl?.currentPage = 0
            }
        }
    }
    /// 占位图 无默认
    var placeholderImage : UIImage?
    /// 自动滚动时间 默认5s
    var autoScrollTime : CGFloat = kAutoScrollInterval {
        didSet {
            invalidateTimer()
            initTimer()
        }
    }
    
    // MARK: - cell属性
    /// cell显示风格
    var layoutStyle : BKDisplayCellLayoutStyle = .normal {
        didSet {
            resetLayoutProperty()
        }
    }
    /// cell间距 默认0
    var itemSpace : CGFloat = 0 {
        didSet {
            resetLayoutProperty()
        }
    }
    /// cell的宽度 默认和无限滚动视图同宽
    var itemWidth : CGFloat = 0 {
        didSet {
            resetLayoutProperty()
        }
    }//此处拿不到目前view的frame 索性在初始数据方法中重新赋值
    /**
     默认0.1 当layoutStyle = BKDisplayCellLayoutStyleMiddleLarger时有效
     除中间显示的cell不缩放外,其余cell缩放系数
     */
    var itemReduceScale : CGFloat = 0.1 {
        didSet {
            resetLayoutProperty()
        }
    }
    /// cell圆角度数 默认0
    var radius : CGFloat = 0 {
        didSet {
            if collectionView != nil {
                collectionView?.reloadData()
            }
        }
    }
    
    // MARK: - 小圆点属性
    /// 小圆点样式
    var pageControlStyle : BKCycleScrollPageControlStyle = .none {
        didSet {
            if pageControlStyle == .none {
                pageControl?.removeFromSuperview()
                pageControl = nil
            }else {
                pageControl?.pageControlStyle = pageControlStyle
            }
        }
    }
    /**
     小圆点高度 默认 7
     pageControlStyle不同状态时默认小圆点宽度不同
     pageControlStyle = BKCycleScrollPageControlStyleNormalDots 时 所有小圆点宽度与高度一样
     pageControlStyle = BKCycleScrollPageControlStyleLongDots 时 选中小圆点宽度是高度的两倍 未选中小圆点宽度与高度一样
     */
    var dotHeight : CGFloat = kPageControlDotHeight {
        didSet {
            if pageControl != nil {
                var pageControlFrame = pageControl!.frame
                pageControlFrame.size.height = dotHeight
                pageControlFrame.origin.y = frame.size.height - dotHeight - dotBottomInset
                pageControl?.frame = pageControlFrame
            }
        }
    }
    /// 小圆点之间的间距 默认7
    var dotSpace : CGFloat = kPageControlDotSpace {
        didSet {
            if pageControl != nil {
                pageControl?.dotSpace = dotSpace
            }
        }
    }
    /// 小圆点距底部边界偏移量 默认10
    var dotBottomInset : CGFloat = kPageControlDotBottomInset {
        didSet {
            if pageControl != nil {
                var pageControlFrame = pageControl!.frame
                pageControlFrame.origin.y = frame.size.height - pageControlFrame.size.height - dotBottomInset
                pageControl?.frame = pageControlFrame
            }
        }
    }
    /// 小圆点默认颜色 默认灰
    var normalDotColor : UIColor = UIColor.lightGray {
        didSet {
            if pageControl != nil {
                pageControl?.normalDotColor = normalDotColor
            }
        }
    }
    /// 小圆点选中颜色 默认白
    var selectDotColor : UIColor = UIColor.white {
        didSet {
            if pageControl != nil {
                pageControl?.selectDotColor = selectDotColor
            }
        }
    }
    /// 小圆点默认图片 无默认 级数比颜色高
    var normalDotImage : UIImage? {
        didSet {
            if pageControl != nil {
                pageControl?.normalDotImage = normalDotImage
            }
        }
    }
    /// 小圆点选中图片 无默认 级数比颜色高
    var selectDotImage : UIImage? {
        didSet {
            if pageControl != nil {
                pageControl?.selectDotImage = selectDotImage
            }
        }
    }
    
    // MARK: - 私有属性
    ///collectionView开始显示的indexPath
    fileprivate var beginIndexPath : IndexPath = IndexPath(item: kMiddleCount, section: 0)
    ///collectionView当前显示的indexPath
    fileprivate var displayIndexPath : IndexPath = IndexPath(item: kMiddleCount, section: 0)
    ///当前所看到数据的索引
    fileprivate var currentIndex : Int = 0
    
    /// 自动滚动定时器
    fileprivate var timer : Timer?
    /// 主显示view
    fileprivate var collectionView : UICollectionView?
    /// 分页显示
    fileprivate var pageControl : BKCycleScrollPageControl?
    
    
    
    // MARK: - 系统父类方法&初始化方法
    override func willMove(toWindow newWindow: UIWindow?) {
        super.willMove(toWindow: newWindow)
        
        if newWindow == nil {
            invalidateTimer()
        }else{
            initTimer()
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        if collectionView == nil {
            currentIndex = 0
            initCollectionView()
            
            invalidateTimer()
            initTimer()
        }
        if pageControl == nil {
            initPageControl()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initData()
    }
    
    init(frame: CGRect, displayDataArr: [Any]) {
        super.init(frame: frame)
        initData()
        self.displayDataArr = displayDataArr
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        invalidateTimer()
        NotificationCenter.default.removeObserver(self)
    }
}

// MARK: - 初始化数据 & 通知
extension BKCycleScrollView {
    func initData() {
        backgroundColor = UIColor.clear
        itemWidth = frame.size.width

        NotificationCenter.default.addObserver(self, selector: #selector(didEnterBackgroundNotification(notification:)), name: NSNotification.Name.UIApplicationDidEnterBackground, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(didBecomeActiveNotification(notification:)), name: NSNotification.Name.UIApplicationDidBecomeActive, object: nil)
    }
    
    /// 当前看见的索引重新赋值
    ///
    /// - Parameters:
    ///   - index: 当前所看到数据的索引
    ///   - indexPath: collectionView当前显示的indexPath
    fileprivate func resetCurrentIndex(index : Int, indexPath : IndexPath) {
        currentIndex = index
        displayIndexPath = indexPath
        
        pageControl?.currentPage = currentIndex
    }
    
    @objc private func didEnterBackgroundNotification(notification: NSNotification) {
        invalidateTimer()
    }
    
    @objc private func didBecomeActiveNotification(notification: NSNotification) {
        initTimer()
    }
}

// MARK: - UI
extension BKCycleScrollView {
    
    /// 创建Layout
    fileprivate func initLayout() -> BKCycleScrollCollectionViewFlowLayout {
    
        let left_right_inset = (frame.size.width - itemWidth)/2
        
        let layout = BKCycleScrollCollectionViewFlowLayout()
        layout.layoutStyle = layoutStyle
        layout.itemSpace = itemSpace
        layout.itemInset = UIEdgeInsetsMake(0, left_right_inset, 0, left_right_inset)
        layout.itemReduceScale = itemReduceScale
        
        return layout
    }
    
    /// 创建CollectionView
    fileprivate func initCollectionView() {
        
        let layout = initLayout()
        
        collectionView = UICollectionView(frame: self.bounds, collectionViewLayout: layout)
        collectionView?.delegate = self
        collectionView?.dataSource = self
        collectionView?.backgroundColor = displayBackgroundColor
        collectionView?.showsHorizontalScrollIndicator = false
        collectionView?.bounces = false
        collectionView?.decelerationRate = 0
        if #available(iOS 11.0, *) {
            self.collectionView?.contentInsetAdjustmentBehavior = .never
        }
        collectionView?.register(BKCycleScrollCollectionViewCell.self, forCellWithReuseIdentifier: kRegisterCellID)
        collectionView?.scrollToItem(at: displayIndexPath, at: .centeredHorizontally, animated: false)
        
        if pageControl != nil {
            insertSubview(collectionView!, belowSubview: pageControl!)
        }else {
            addSubview(collectionView!)
        }
    }
    
    /// 初始化cell的Layout属性时重新创建collectionView
    fileprivate func resetLayoutProperty() {
        if collectionView != nil {
            collectionView?.removeFromSuperview()
            collectionView = nil
            
            invalidateTimer()
            resetCurrentIndex(index: 0, indexPath: beginIndexPath)
            initCollectionView()
            initTimer()
        }
        if pageControl != nil {
            pageControl?.numberOfPages = displayDataArr?.count ?? 0
            pageControl?.currentPage = 0
        }
    }
    
    /// 创建pageControl
    fileprivate func initPageControl() {
        
        if pageControlStyle == .none {
            if pageControl != nil {
                pageControl?.removeFromSuperview()
                pageControl = nil
            }
            return
        }
        
        if pageControl == nil {
            pageControl = BKCycleScrollPageControl(frame: CGRect(x: 0, y: frame.size.height - dotBottomInset - dotHeight, width: frame.size.width, height: dotHeight))
            addSubview(pageControl!)
        }
        pageControl?.numberOfPages = displayDataArr?.count ?? 0
        pageControl?.currentPage = 0
        pageControl?.pageControlStyle = pageControlStyle
        pageControl?.dotSpace = dotSpace
        pageControl?.normalDotColor = normalDotColor
        pageControl?.selectDotColor = selectDotColor
        pageControl?.normalDotImage = normalDotImage
        pageControl?.selectDotImage = selectDotImage
    }
}

// MARK: - UICollectionViewDelegate, UICollectionViewDataSource
extension BKCycleScrollView : UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return displayDataArr?.count == 0 ? 0 : kAllCount
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: kRegisterCellID, for: indexPath) as! BKCycleScrollCollectionViewCell
        
        let selectIndex = getDisplayIndex(indexPath: indexPath)
        
        if ((delegate?.customCellStyle?(self, displayIndex: selectIndex, displayCell: cell)) != nil) {
            return cell
        }
        
        cell.radius = radius
        cell.placeholderImage = placeholderImage
        
        if let displayDataArr = displayDataArr {
            cell.displayData = displayDataArr[selectIndex]
        }else {
            cell.displayData = nil
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        invalidateTimer()
        initTimer()
        
        let selectIndex = getDisplayIndex(indexPath: indexPath)
        delegate?.selectItemAction?(self, selectIndex: selectIndex)
    }
}

// MARK: - 获取目标indexPath显示的index
extension BKCycleScrollView {
    /// 获取目标indexPath显示的index
    ///
    /// - Parameter indexPath: 无线循环view上的目标显示的indexPath
    /// - Returns: 实际显示的index数据
    fileprivate func getDisplayIndex(indexPath: IndexPath) -> Int {
        let index = indexPath.item
        
        var selectIndex = currentIndex
        if index != displayIndexPath.item {
            selectIndex = selectIndex - (displayIndexPath.item - index)
        }
        //如果没有数据返回0
        guard let count = displayDataArr?.count else {
            return 0
        }
        if selectIndex < 0 {
            selectIndex = (count + selectIndex % count) % count
        }else if selectIndex > count - 1 {
            selectIndex = selectIndex % count
        }
        return selectIndex
    }
}

// MARK: - UIScrollViewDelegate
extension BKCycleScrollView : UIScrollViewDelegate {
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        invalidateTimer()
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        initTimer()
    }
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        //因为偏移量最终位置collectionView一屏中显示3个item 滚动停止后targetContentOffset肯定比目前显示cell的item小1 所以偏移量x调成了中心
        //因为缩放原因 cell的y值不一定为0 所以把偏移量y调成了中心
        let offset = targetContentOffset.pointee
        if let collectionView = collectionView {
            let x = offset.x + collectionView.frame.size.width/2
            let y = collectionView.frame.size.height/2
            let newTargetContentOffset = CGPoint(x: x, y: y)
            guard let currentIndexPath = collectionView.indexPathForItem(at: newTargetContentOffset) else {
                return
            }
            let selectIndex = getDisplayIndex(indexPath: currentIndexPath)
            resetCurrentIndex(index: selectIndex, indexPath: currentIndexPath)
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        scrollViewDidEndScrollingAnimation(scrollView)
    }
    
    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        //延迟0s 防止定时器动画结束刹那闪屏现象
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()) {
            guard let visibleIndexPaths = self.collectionView?.indexPathsForVisibleItems else {
                return
            }
            var isExist = false
            for indexPath in visibleIndexPaths {
                //为了适配一屏显示多个时 返回滚动不出现bug 建议目前滚动item与初始item相差屏幕显示最大item数量*2 我这默认设置成99
                if self.beginIndexPath.item + 99 > indexPath.item {
                    isExist = true
                    break
                }
            }
            
            if isExist == false {
                self.displayIndexPath = self.beginIndexPath
                self.collectionView?.scrollToItem(at: self.displayIndexPath, at: .centeredHorizontally, animated: false)
            }
        }
    }
}

// MARK: - 定时器
extension BKCycleScrollView {
    fileprivate func initTimer() {
        invalidateTimer()
        timer = Timer(timeInterval: TimeInterval(kAutoScrollInterval), target: self, selector: #selector(autoScrollTimer(timer:)), userInfo: nil, repeats: true)
        RunLoop.main.add(timer!, forMode: .commonModes)
    }
    
    fileprivate func invalidateTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    @objc fileprivate func autoScrollTimer(timer : Timer) {
        
        if let collectionView = collectionView {
            let point = convert(collectionView.center, to: collectionView)
            guard let currentIndexPath = collectionView.indexPathForItem(at: point) else {
                return
            }
            let nextIndexPath = IndexPath(item: currentIndexPath.item + 1, section: 0)
            let selectIndex = getDisplayIndex(indexPath: nextIndexPath)
            resetCurrentIndex(index: selectIndex, indexPath: nextIndexPath)
            
            collectionView.scrollToItem(at: displayIndexPath, at: .centeredHorizontally, animated: true)
        }
    }
}
