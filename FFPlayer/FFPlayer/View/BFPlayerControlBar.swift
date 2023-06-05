//
//  BFPlayerControlView.swift
//  Enterprise
//
//  Created by xuwen on 2023/5/8.
//

import UIKit

class BFPlayerControlBar:UIView
{
    /// 播放｜暂停
    lazy var playButton:UIButton = {
        let button = UIButton()
        button.setTitle("播", for: .normal)
        button.setTitle("停",for:.selected)
        return button
    }()
//    .then { button in
////
////
//    }
    
    /// 全屏
//    var screenButton = UIButton().then { button in
//        button.setTitle("全", for: .normal)
//        button.setTitle("缩",for:.selected)
//    }
    
    /// 播放器时间指示
    var currentTimeLabel: UILabel = {
        let lab = UILabel()
        lab.text = "00:00"
        lab.font = UIFont.systemFont(ofSize: 12)
        lab.textColor = UIColor.white
        return lab
    }()
    var timeLabel: UILabel = {
        let lab = UILabel()
        lab.text = "00:00"
        lab.font = UIFont.systemFont(ofSize: 12)
        lab.textColor = UIColor.white
        return lab
    }()
    
    /// 播放器进度条
    var slider: UISlider = {
        let slider = UISlider()
        slider.minimumValue = 0
        slider.maximumValue = 1
        slider.minimumTrackTintColor = UIColor.white
        slider.maximumTrackTintColor = UIColor.white.withAlphaComponent(0.4)
        slider.setThumbImage(UIImage(named: "bf_video_ic_slider"), for: .normal)
        return slider
    }()
    
    /// 缓存进度
    var cacheView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.white.withAlphaComponent(0.5)
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        createUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func createUI() {
        backgroundColor = .black.withAlphaComponent(0.5)
        
        addSubview(playButton)
        
        addSubview(currentTimeLabel)
        
        addSubview(timeLabel)
        
        addSubview(slider)
    }

    
    override func layoutSubviews() {
        playButton.frame = CGRectMake(0, 0, 40, 40)
        currentTimeLabel.frame = CGRect(x: 48, y: 0, width: 36, height: 40)
        let x1 = self.frame.width - 36 - 8
        timeLabel.frame = CGRectMake(x1, 0, 36, 40)
        let x2 = currentTimeLabel.frame.width + currentTimeLabel.frame.origin.x
        slider.frame = CGRect(x: x2 + 8, y: 0, width: self.frame.width - x2 - 44 - 16, height: 40)
    }
}
