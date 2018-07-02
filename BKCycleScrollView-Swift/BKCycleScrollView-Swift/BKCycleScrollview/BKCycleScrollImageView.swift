//
//  BKCycleScrollImageView.swift
//  BKCycleScrollView-Swift
//
//  Created by BIKE on 2018/6/29.
//  Copyright © 2018年 BIKE. All rights reserved.
//

import UIKit
import Gifu

class BKCycleScrollImageView: UIImageView, GIFAnimatable {
    
    lazy var animator: Animator? = {
       return Animator(withDelegate: self)
    }()
    
    override func display(_ layer: CALayer) {
        updateImageIfNeeded()
    }

}
