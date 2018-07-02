//
//  BKCycleScrollCollectionViewCell.swift
//  BKCycleScrollView-Swift
//
//  Created by BIKE on 2018/6/28.
//  Copyright © 2018年 BIKE. All rights reserved.
//

import UIKit

class BKCycleScrollCollectionViewCell: UICollectionViewCell {
    
    /// cell圆角度数 默认0
    var radius : CGFloat = 0 {
        didSet {
            cutRadius(radius: radius)
        }
    }
    
    /// 占位图 无默认
    var placeholderImage : UIImage?
    
    /// 数据
    var displayData : Any? {
        didSet {
            
            displayImageView.stopAnimatingGIF()
            
            if displayData is String {
                let imageStr = displayData as! String
                let imageUrl = URL(string: imageStr)
                displayImageView.kf.setImage(with: imageUrl, placeholder: placeholderImage)
            }else if displayData is UIImage {
                let image = displayData as! UIImage
                displayImageView.image = image
            }else if displayData is Data {
                let imageData = displayData as! Data
                displayImageView.prepareForAnimation(withGIFData: imageData) {
                    self.displayImageView.startAnimatingGIF()
                }
            }else{
                displayImageView.image = nil
            }
        }
    }
    
    /// 显示图
    private lazy var displayImageView : BKCycleScrollImageView = {[weak self] in
        let displayImageView = BKCycleScrollImageView(frame: bounds)
        displayImageView.clipsToBounds = true
        displayImageView.contentMode = .scaleAspectFill
        addSubview(displayImageView)
        return displayImageView
    }()
    
    /// 切角
    ///
    /// - Parameter radius: 度数
    private func cutRadius(radius: CGFloat) {
        let path = UIBezierPath(roundedRect: bounds, cornerRadius: radius)
        let maskLayer = CAShapeLayer()
        maskLayer.path = path.cgPath
        maskLayer.frame = bounds
        layer.mask = maskLayer
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        cutRadius(radius: radius)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

