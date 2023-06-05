//
//  ViewController.swift
//  FFPlayerDemo
//
//  Created by xuwen on 2023/6/5.
//

import UIKit
import FFPlayer

class ViewController: UIViewController {

    var model = BFVidoeModel(title: "网络视频测试",videoUrl: "https://video_shejigao.redocn.com/video/201806/20180606/Redcon_2018060510032115552514759.mp4",placeHoldImgStr: "tabbar_contact_icon_h")
    
    lazy var baseView = UIView(frame: CGRect(x: 0, y: 200, width: UIScreen.main.bounds.size.width, height: 300))
    
    override func viewDidLoad() {
        super.viewDidLoad()
        baseView.backgroundColor = .red
        view.addSubview(baseView)
        
       let videoView = BFPlayerView(self.baseView)
        
        videoView.updateCurrentPlayer(videoModel: model)
    }


}

