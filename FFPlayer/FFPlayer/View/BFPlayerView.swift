//
//  BFPlayerView.swift
//  Enterprise
//
//  Created by xuwen on 2023/5/8.
//

import UIKit
import AVFoundation
import AVKit

public class BFPlayerView:UIView
{
    /// 播放器回调
    weak var delegate: BFPlayerViewDelegate?
    /// 普通事件管理
    private var manager: BFVideoManager?
    /// 是否正在播放
    var isPlaying: Bool = false
    /// 播放器
    var videoPlayer: AVPlayer?
    /// 播放器layer
    var playerLayer: AVPlayerLayer? {
        didSet {
            
        }
    }
    /// 媒体资源管理对象
    var playerItem: AVPlayerItem? {
        didSet {
            if let item = playerItem {
                item.addObserver(self, forKeyPath: "status", options: .new, context: nil)
            }
        }
    }
   
    lazy var scrollView:UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.minimumZoomScale = 1.0;
        scrollView.maximumZoomScale = 2;
        scrollView.contentSize = self.bounds.size
        scrollView.delegate = self
        return scrollView
    }()
    
    /// 视频承载View
    lazy var videoView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.clear
        view.clipsToBounds = true
        return view
    }()
    /// 封面图
    var placeHoldImgView: UIImageView = {
        let imgView = UIImageView()
        imgView.isHidden = true
        imgView.contentMode = .scaleAspectFill
        imgView.clipsToBounds = true
        return imgView
    }()
    
    /// 播放器的父view
    weak var fatherView: UIView?
    
    /// 控制播放面板
    var controlBar: BFPlayerControlBar!
    
    /// 暂停View
    var pauseButton: UIButton!
    
    /// 播放进度计时器
    private var playTimer: Timer?

    //play按钮点击事件
    var playClickedBlock:(()->Void)?
    
    public convenience init(_ baseView: UIView) {
        self.init()
        self.frame = baseView.bounds
        
        fatherView = baseView
        manager = BFVideoManager(self)
        
        createBaseView()
        //添加通知
        addObserver()
        
        // 开启屏幕常亮
        UIApplication.shared.isIdleTimerDisabled = true
        //按下slider的时候会停，抬起手后恢复，其他时间计时器在运行
        playTimer = Timer.scheduledTimer(timeInterval: 0.2, target: self, selector: #selector(updatePanel(sender:)), userInfo: nil, repeats: true)
    }
    
    deinit {
        if let item = playerItem {
            item.removeObserver(self, forKeyPath: "status", context: nil)
        }
        NotificationCenter.default.removeObserver(self)
    }
    
    //MARK: 视图创建
    /** 创建基础试图*/
    private func createBaseView() {
        
        //父视图加载本视图
        fatherView?.addSubview(self)
//        snp.makeConstraints { (make) in
//            make.edges.equalToSuperview()
//        }

        //缩放视图
        addSubview(scrollView)
        
        //添加videoView 可能区分 音频View
        scrollView.addSubview(videoView)
        scrollView.frame = CGRect(x: 0, y: 0, width: self.frame.width, height: self.frame.height)
        
        videoView.frame = scrollView.bounds

        
        let videoViewTap = UITapGestureRecognizer.init(target: self, action: #selector(playerViewDidTapped))
        videoView.addGestureRecognizer(videoViewTap)
        
        //全屏界面
        //控制器界面
        createControlBar()
    
        //播放完毕之后的界面
        
        //添加封面图
//        addSubview(placeHoldImgView)
//        placeHoldImgView.snp.makeConstraints { (make) in
//            make.edges.equalToSuperview()
//        }
    }
    
    private func createControlBar(){
        
        //暂停按钮
        pauseButton = UIButton()
        pauseButton.addTarget(self, action: #selector(playButtonDidClicked), for: .touchUpInside)
        addSubview(pauseButton)
        pauseButton.frame = CGRect(x: self.frame.width/2-60, y: self.frame.height/2-60, width: 60, height: 60)
        
        //底部控制器
        controlBar = BFPlayerControlBar()
        controlBar.playButton.addTarget(self, action: #selector(playButtonDidClicked), for: .touchUpInside)
        controlBar.slider.addTarget(self, action: #selector(sliderTouchUp(_:)), for: .touchUpInside)
        controlBar.slider.addTarget(self, action: #selector(sliderTouchUp(_:)), for: .touchUpOutside)
        controlBar.slider.addTarget(self, action: #selector(sliderTouchDown(_:)), for: .touchDown)
        controlBar.slider.addTarget(self, action: #selector(sliderDraging(_:)), for: .valueChanged)
        addSubview(controlBar)
        controlBar.frame = CGRect(x: 0, y: self.frame.height-40-20, width: self.frame.width, height: 40)

    }
    
    //MARK: 通知监听
    /** 添加通知监听*/
    private func addObserver() {
        NotificationCenter.default.addObserver(self, selector: #selector(avplayerItemDidPlayToEndTime(_:)), name: .AVPlayerItemDidPlayToEndTime, object: nil)
        
    }
}

extension BFPlayerView:UIScrollViewDelegate
{
    public func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return self.videoView
    }
}

//MARK: private func
extension BFPlayerView{
    /** 播放器屏幕被点击 -> 呼出控制面板*/
    @objc func playerViewDidTapped() {
        if(manager?.playerStatus == .playing){
            if(controlBar.alpha == 0.0){
                manager?.showControlBar()
            }else{
                manager?.hideControlBar(sender: nil)
            }
        }
    }
}

//MARK: public func
extension BFPlayerView {
    
    /// 更新当前播放内容
    /// - Parameter commonConfig: 播放配置
    public func updateCurrentPlayer(videoModel: BFVidoeModel) {
        
        DispatchQueue.global().async {
            if let oldConfig = self.manager?.videoModel {
                if oldConfig.videoUrl != videoModel.videoUrl {
                    self.manager?.videoModel = videoModel
                }
            } else {
                self.manager?.videoModel = videoModel
            }
        }
    }
    
    /** 暂停播放器*/
    private func playerPause() {
        manager?.playerStatus = .pause
        playTimer?.invalidate()
    }

    /** 继续播放*/
    private func playerPlay() {
        manager?.playerStatus = .playing
        playTimer?.invalidate()
        playTimer = Timer.scheduledTimer(timeInterval: 0.2, target: self, selector: #selector(updatePanel(sender:)), userInfo: nil, repeats: true)
    }
//
    /** 重播*/
    func resetTimer() {
        playTimer?.invalidate()
        playTimer = Timer.scheduledTimer(timeInterval: 0.2, target: self, selector: #selector(updatePanel(sender:)), userInfo: nil, repeats: true)
    }

    /** 修改播放器进度*/
    func changePlayerProgress(progress: Float) {
        manager?.updatePanel()
        manager?.changePlayerProgress(progress: progress)
    }

    /** 退出页面时的处理*/
    func dealToDisappear(){
        // 关闭播放器
        manager?.playerStatus = .stop
        // 销毁播放器计时器
        playTimer?.invalidate()
        // 销毁隐藏控制面板计时器
        manager?.hideTimer?.invalidate()
        // 关闭屏幕常亮
        UIApplication.shared.isIdleTimerDisabled = false
    }
}

//MARK: 控件事件
extension BFPlayerView{
    /** playerItem的监听*/
    public override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        guard let item = self.playerItem else { return }
        
        if keyPath == "status" {
            if item.status == .readyToPlay {
                placeHoldImgView.isHidden = true
            }
        }
    }
    
    /** 播放｜暂停按钮被点击*/
    @objc private func playButtonDidClicked() {
        if let fn = self.playClickedBlock{
            fn()
        }
    }
    
    /** 全屏响应处理的方法（全屏状态回到小屏，小屏状态展开全屏）*/
    @objc private func screenButtonDidClicked() {
//        changeScreenStatus()
    }
    
    /** 刷新播放器控制面板（进度｜时间）*/
    @objc func updatePanel(sender: Timer) {
        manager?.updatePanel()
    }
    
    /** 播放器进度条按下*/
    @objc func sliderTouchDown(_ sender: Any) {
        playerPause()
    }
    
    /** 播放器进度条拖拽过程*/
    @objc func sliderDraging(_ sender: UISlider) {
        manager?.updatePanel(progress: sender.value)
    }
    
    /** 播放器进度条抬起*/
    @objc func sliderTouchUp(_ sender: UISlider) {
        changePlayerProgress(progress: sender.value)
        playerPlay()
    }
    
    /** 视频播放完毕*/
    @objc func avplayerItemDidPlayToEndTime(_ notification: Notification) {
        manager?.playerStatus = .stop
//        delegate?.stopPlayer()
    }
    
}
