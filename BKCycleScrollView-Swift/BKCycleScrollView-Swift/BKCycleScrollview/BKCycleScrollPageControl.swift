//
//  BKCycleScrollPageControl.swift
//  BKCycleScrollView-Swift
//
//  Created by zhaolin on 2018/6/28.
//  Copyright © 2018年 BIKE. All rights reserved.
//

import UIKit

class BKCycleScrollPageControl: UIView {

    /// 圆点总数
    var numberOfPages : Int = 0 {
        didSet {
            resetUI()
        }
    }
    /// 当前选中的圆点
    var currentPage : Int = 0 {
        didSet {
            resetUI()
        }
    }

    /// 小圆点样式
    var pageControlStyle : BKCycleScrollPageControlStyle = .none {
        didSet {
            resetUI()
        }
    }
    /// 小圆点之间的间距 默认7 (上级传入 此处先赋值0)
    var dotSpace : CGFloat = 0 {
        didSet {
            resetUI()
        }
    }
    /// 小圆点默认颜色 默认灰
    var normalDotColor : UIColor = UIColor.lightGray {
        didSet {
            resetUI()
        }
    }
    /// 小圆点默认颜色 默认白
    var selectDotColor : UIColor = UIColor.white {
        didSet {
            resetUI()
        }
    }
    /// 小圆点默认图片 无默认 级数比颜色高
    var normalDotImage : UIImage? {
        didSet {
            resetUI()
        }
    }
    /// 小圆点默认图片 无默认 级数比颜色高
    var selectDotImage : UIImage? {
        didSet {
            resetUI()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor.clear
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension BKCycleScrollPageControl {
    fileprivate func resetUI() {
        subviews.forEach { (item) in
            item.removeFromSuperview()
        }
        
        if numberOfPages > 0 {
            
            let normal_w = frame.size.height
            var select_w : CGFloat = 0.0
            if pageControlStyle == .longDots {
                select_w = normal_w * 2
            }else {
                select_w = normal_w
            }
            let space = dotSpace
            
            let width = CGFloat(numberOfPages-1) * (normal_w+dotSpace) + select_w
            let beginX = (frame.size.width - width)/2
            
            var lasetView : UIImageView? = nil
            for index in 0..<numberOfPages {
                let dot = UIImageView()
                let x = lasetView != nil ? (lasetView?.frame.maxX)! + space : beginX
                if index == currentPage {
                    dot.frame = CGRect(x: x, y: 0, width: select_w, height: normal_w)
                    if selectDotImage != nil {
                        dot.image = selectDotImage
                    }else {
                        dot.backgroundColor = selectDotColor
                    }
                }else {
                    dot.frame = CGRect(x: x, y: 0, width: normal_w, height: normal_w)
                    if normalDotImage != nil {
                        dot.image = normalDotImage
                    }else {
                        dot.backgroundColor = normalDotColor
                    }
                }
                
                dot.layer.cornerRadius = dot.frame.size.height/2
                dot.contentMode = .scaleAspectFit
                dot.clipsToBounds = true
                addSubview(dot)
                
                lasetView = dot
            }
        }
    }
}
