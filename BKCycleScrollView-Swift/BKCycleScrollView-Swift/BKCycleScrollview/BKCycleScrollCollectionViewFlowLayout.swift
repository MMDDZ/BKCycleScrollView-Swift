//
//  BKCycleScrollCollectionViewFlowLayout.swift
//  BKCycleScrollView-Swift
//
//  Created by zhaolin on 2018/6/28.
//  Copyright © 2018年 BIKE. All rights reserved.
//

import UIKit

// MARK: - 基础数据
class BKCycleScrollCollectionViewFlowLayout: UICollectionViewFlowLayout {

    /// cell显示风格
    var layoutStyle : BKDisplayCellLayoutStyle = .normal
    /// cell间距 默认0
    var itemSpace : CGFloat = 0
    /// cell距四周边界的偏移量 默认UIEdgeInsetsZero
    var itemInset : UIEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 0)
    /**
     默认0.1 当layoutStyle = BKDisplayCellLayoutStyleMiddleLarger时有效
     除中间显示的cell不缩放外,其余cell缩放系数
     */
    var itemReduceScale : CGFloat = 0.1

}

// MARK: - 修改布局
extension BKCycleScrollCollectionViewFlowLayout {
    
    override func prepare() {
        super.prepare()
        
        if let collectionView = collectionView {
            itemSize = CGSize(width: collectionView.frame.size.width - itemInset.left - itemInset.right, height: collectionView.frame.size.height - itemInset.top - itemInset.bottom)
        }
        minimumLineSpacing = itemSpace
        minimumInteritemSpacing = 0
        sectionInset = itemInset
        scrollDirection = .horizontal
    }
    
    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        return true
    }
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        
        guard let array = super.layoutAttributesForElements(in: rect) else { return nil }
        
        if layoutStyle == .normal {
            return array
        }
        
        if let collectionView = collectionView {
            let visialbeRect : CGRect = CGRect(origin: collectionView.contentOffset, size: collectionView.frame.size)
            
            let centerX = collectionView.contentOffset.x + collectionView.frame.size.width/2
            for attributes in array {
                if !visialbeRect.intersects(attributes.frame) {
                    continue
                }
                
                let itemCenterX = attributes.center.x
                let gap = fabs(itemCenterX - centerX)
//              除中间原大小外 其余缩放比例相同
//                let max_gap = minimumInteritemSpacing + itemSize.width
//                if gap > max_gap {
//                    gap = max_gap
//                }

                let scale = 1 - (gap / (collectionView.frame.size.width/2)) * itemReduceScale
                
                attributes.transform3D = CATransform3DMakeScale(scale, scale, 1.0)
            }
        }
        
        return array
    }
    
    override func targetContentOffset(forProposedContentOffset proposedContentOffset: CGPoint, withScrollingVelocity velocity: CGPoint) -> CGPoint {
        
        let supperPoint = super.targetContentOffset(forProposedContentOffset: proposedContentOffset, withScrollingVelocity: velocity)
        
        if let collectionView = collectionView {
            let lastRect = CGRect(origin: collectionView.contentOffset, size: collectionView.frame.size)
            
            let centerX = collectionView.contentOffset.x + collectionView.frame.size.width/2
            
            guard let array = layoutAttributesForElements(in: lastRect) else { return supperPoint }
            
            var adjustOffsetX = Float.greatestFiniteMagnitude
            for attributes in array {
                if adjustOffsetX == Float.greatestFiniteMagnitude {
                    adjustOffsetX = Float(attributes.center.x - centerX)
                }else {
                    let temp_adjustOffsetX = Float(attributes.center.x - centerX)
                    if velocity.x == 0 {//速度为0时判断 哪个item离中心近
                        if fabs(temp_adjustOffsetX) < fabs(adjustOffsetX) {
                            adjustOffsetX = temp_adjustOffsetX
                        }
                    }else if velocity.x > 0 {//往左划 选最大
                        if temp_adjustOffsetX > adjustOffsetX {
                            adjustOffsetX = temp_adjustOffsetX
                        }
                    }else if velocity.x < 0 {//往右划 选最小
                        if temp_adjustOffsetX < adjustOffsetX {
                            adjustOffsetX = temp_adjustOffsetX
                        }
                    }
                }
            }
            
            let contentOffsetX = collectionView.contentOffset.x + CGFloat(adjustOffsetX)
            let targetContentOffset = CGPoint(x: contentOffsetX, y: collectionView.contentOffset.y)
            
            return targetContentOffset
        }
        
        return supperPoint
    }
}
