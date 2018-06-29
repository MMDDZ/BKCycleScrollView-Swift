//
//  ViewController.swift
//  BKCycleScrollView-Swift
//
//  Created by BIKE on 2018/6/27.
//  Copyright © 2018年 BIKE. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    private let localImageArr : [Any] = {
        let imageUrl = Bundle.main.url(forResource: "4", withExtension: "gif")!
        let imageData : Any = UIImageJPEGRepresentation(UIImage(named: "3")!, 1) ?? ""
        let gifData : Any = (try? Data(contentsOf: imageUrl)) ?? ""
        return [UIImage(named: "1") ?? "", UIImage(named: "2") ?? "", imageData, gifData]
    }()
    private let netImageArr = ["https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1528368399685&di=d6d322d6cf932ebbf569303d0bade418&imgtype=0&src=http%3A%2F%2Fpic1.16pic.com%2F00%2F07%2F66%2F16pic_766152_b.jpg","https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1528368294842&di=5de9f86a4001b2f04d04b65e1573122d&imgtype=0&src=http%3A%2F%2Fpic.qiantucdn.com%2F58pic%2F13%2F71%2F35%2F24k58PICSiB_1024.jpg","https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1528368334917&di=fc058e94d3951768c4151104f707a347&imgtype=0&src=http%3A%2F%2Fimg1.3lian.com%2F2015%2Fa1%2F63%2Fd%2F121.jpg"]
    private let netImageArr2 = ["http://img.taopic.com/uploads/allimg/140118/234914-14011PZ32692.jpg","http://pic1.win4000.com/wallpaper/5/58c74e21e2228.jpg","http://imgsrc.baidu.com/imgad/pic/item/42a98226cffc1e17d453210c4190f603738de91b.jpg","https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1529388176527&di=7a047e6e2c065af002f71b594793d777&imgtype=0&src=http%3A%2F%2Fimg.zcool.cn%2Fcommunity%2F01c3cf5544d0c70000019ae97686ea.jpg","http://img.mp.sohu.com/upload/20170801/8b8854e3a09245b68e2058fc8b30fc02_th.png"]
    
    private lazy var cycleScrollView1 : BKCycleScrollView = {[weak self] in
        let cycleScrollView1 = BKCycleScrollView(frame: CGRect(x: 0, y: UIApplication.shared.statusBarFrame.height + 20, width: view.frame.size.width, height: 150), displayDataArr: netImageArr)
        cycleScrollView1.layoutStyle = .middleLarger
        cycleScrollView1.itemSpace = -18
        cycleScrollView1.itemWidth = view.frame.size.width - 40
        cycleScrollView1.itemReduceScale = 0.1
        cycleScrollView1.radius = 12
        return cycleScrollView1
    }()

    private lazy var cycleScrollView2 : BKCycleScrollView = {[weak self] in
        let cycleScrollView2 = BKCycleScrollView(frame: CGRect(x: 0, y: cycleScrollView1.frame.maxY + 40, width: view.frame.size.width, height: 150), displayDataArr: localImageArr)
        cycleScrollView2.layoutStyle = .normal
        cycleScrollView2.pageControlStyle = .normalDots
        return cycleScrollView2
    }()
    
    private lazy var cycleScrollView3 : BKCycleScrollView = {[weak self] in
        let cycleScrollView3 = BKCycleScrollView(frame: CGRect(x: 0, y: cycleScrollView2.frame.maxY + 40, width: view.frame.size.width, height: 150), displayDataArr: netImageArr2)
        cycleScrollView3.placeholderImage = UIImage(named: "placeholder")
        cycleScrollView3.layoutStyle = .middleLarger;
        cycleScrollView3.itemSpace = 0;
        cycleScrollView3.itemWidth = 50;
        cycleScrollView3.itemReduceScale = 0.2;
        cycleScrollView3.radius = 0;
        cycleScrollView3.pageControlStyle = .longDots
        cycleScrollView3.normalDotColor = UIColor.yellow
        cycleScrollView3.selectDotColor = UIColor.brown
        
    
        
        return cycleScrollView3
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(cycleScrollView1)
        view.addSubview(cycleScrollView2)
        view.addSubview(cycleScrollView3)
        
    }

}

