//
//  BFVidioManager.swift
//  Enterprise
//
//  Created by xuwen on 2023/5/8.
//

import Foundation
import AVFoundation
import UIKit

class BFVideoManager: NSObject {

    /// playerView
    weak var playerView: BFPlayerView?
    
    /// 隐藏状态栏计时器
    var hideTimer: Timer?
    
    /// 当前音视频配置
    var videoModel: BFVidoeModel? {
        willSet {
            if let newModel = newValue {
                if let oldModel = videoModel{
                    if (oldModel.videoUrl == newModel.videoUrl) {
                        // 播放链接未修改
                    }else{
                        //播放链接已修改
                    }
                }
            }
        }
        
        didSet {
            //  初始化播放器
            if let model = videoModel {
                updatePlayerItem(model: model)
            }
        }
    }

    /// 当前播放器状态
    var playerStatus: BFPlayerStatus? {
        didSet {
            if let status = playerStatus {
                
            playerView?.controlBar.playButton.setImage(status.controlPlayImg, for: .normal)
            playerView?.pauseButton.setBackgroundImage(status.controlPlayImg, for: .normal)
            playerView?.placeHoldImgView.isHidden = status != .prepare
            playerView?.pauseButton.isHidden = !(status == .pause || status == .stop)
                
            switch status {
                case .playing:
                    guard playerView?.videoPlayer?.currentItem != nil  else {
                        return
                    }

                    playerView?.isPlaying = true

                    do {
                        try AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.playback)
                    } catch let error {
                        print(error)
                    }

                    playerView?.videoPlayer?.play()

                    showControlBar()
                    resetHideTimer()
                
               
                case .pause:
                    
                    playerView?.isPlaying = false
                    showControlBar()

                    hideTimer?.invalidate()
                    playerView?.videoPlayer?.pause()

                    break
                case .stop:
                    
                    playerView?.isPlaying = false
                    showControlBar()
                    
                    playerView?.videoPlayer?.pause()
                    
                    break
                default:
                    break
                }
            }
        }
    }
    
    convenience init(_ view: BFPlayerView) {
        self.init()
        playerView = view
        
        //播放点击事假
        playerView?.playClickedBlock = {
            if self.playerStatus == .playing {
                self.playerStatus = .pause
            } else if self.playerStatus == .pause {
                self.playerStatus = .playing
            }else if(self.playerStatus == .stop){
                //播放完毕，从新播放
                self.replayPlayerItem()
            }
        }
    }
}

//MARK: - private
extension BFVideoManager{
    /// 初始化播放器
    /// - Parameter config: 配置
    private func updatePlayerItem(model: BFVidoeModel) {
        DispatchQueue.main.async {
            self.initViewWithConfig(config: model)
        }
        
        //初始化播放器
        if let urlStr = model.videoUrl, urlStr != ""{
            playVideo(urlStr: urlStr, config: model)
        }
    }
    
    /// 替换播放源时初始化基础页面
    /// - Parameter config: 播放器配置
    private func initViewWithConfig(config: BFVidoeModel) {
        
        // 封面图处理
        if let imgStr = config.placeHoldImgStr, imgStr != "" {
            if let placeHoldImg = UIImage(named: imgStr) {
                playerView?.placeHoldImgView.isHidden = false
                playerView?.placeHoldImgView.image = placeHoldImg
            } else if let imgUrl = URL(string: imgStr) {
                playerView?.placeHoldImgView.isHidden = false
                let data = try? Data(contentsOf: imgUrl)
                if let imageData = data {
                    let image = UIImage(data: imageData)
                    playerView?.placeHoldImgView.image = image
                }
            }
        }
    }
    
    /** 判断是否为网络资源*/
    func isOnlineResource(_ urlStr: String) -> Bool {
        return urlStr.starts(with: "http")
    }
    
    /// 重播
    func replayPlayerItem() {
        playerView?.resetTimer()
        playerView?.videoPlayer?.seek(to: CMTime(seconds: 0, preferredTimescale: 1))
        playerStatus = .playing
    }
    
    /** 播放视频*/
    private func playVideo(urlStr: String, config: BFVidoeModel) {
        
        //内部方法 ， 初始化player
        func playVideo(item: AVPlayerItem) {
            
            playerView?.playerItem = item
            
            playerView?.videoPlayer?.pause()
            
            if playerView?.videoPlayer == nil {
                // 初始化播放器
                playerView?.videoPlayer = AVPlayer(playerItem: item)
                playerView?.playerLayer = AVPlayerLayer(player: playerView?.videoPlayer)
                playerView?.playerLayer?.videoGravity = .resizeAspect
                playerView?.playerLayer?.frame = playerView!.bounds
                
                playerView?.videoView.layer.addSublayer((playerView?.playerLayer!)!)
            } else {
                // 替换播放资源
                playerView?.videoPlayer?.replaceCurrentItem(with: item)
            }
            
           
            //开始播放， 在set方法区找播放源
            playerStatus = .playing
        }

        //1.是否为网上资源，不同的资源获取URL不同
        var isOnlineSource: Bool = true
        // 播放地址
        let playerUrl: URL
        if isOnlineResource(urlStr) {
            playerUrl = URL(string: urlStr)!
        } else {
            isOnlineSource = false
            playerUrl = URL(fileURLWithPath: urlStr)
        }
        

        // 3.根据是否缓存来选择播放资源，是否去缓存
        let vidoeitem: AVPlayerItem? = playItem(needCache: config.needCache, isOnlineResource: isOnlineSource,playerUrl: playerUrl)
        
        //4.播放vidoe
        DispatchQueue.main.async {
            if let videoItem = vidoeitem{
                playVideo(item: videoItem)
            }
        }
    }
    
    private func playItem(needCache:Bool,isOnlineResource:Bool,playerUrl:URL) -> AVPlayerItem? {
        
//        if needCache && isOnlineResource {
            
//            if let asset = BFMediaCacher.makeVideoCache(url: playerUrl){
//                let item = AVPlayerItem(asset: asset)
//                return item
//            }
//            print("视频无法播放")
//            return nil
//        }else{
            // 不缓存 -> 直接播放
            let onlineUrl: URL
            
            //这里可以进行鉴权，如果需要的话
            onlineUrl = playerUrl
            
            let item: AVPlayerItem = AVPlayerItem(url: onlineUrl)
            
            return item
//        }
    }
}

//MARK: 控制面板相关
extension BFVideoManager {
    /** 刷新播放器控制面板（进度｜时间）*/
    func updatePanel(progress: Float? = nil) {
        guard let currentTime = playerView?.videoPlayer?.currentItem?.currentTime().seconds,
              let timescale = playerView?.videoPlayer?.currentTime().timescale,
              let duration = playerView?.videoPlayer?.currentItem?.duration.seconds,
              !currentTime.isNaN && !duration.isNaN
        else {
            return
        }
        
        // 更改控制面板显示
        let totalMM = Int(duration / 60)
        let totalSS = Int(duration.truncatingRemainder(dividingBy: 60))
        let currentMM = Int(currentTime / 60)
        let currentSS = Int(currentTime.truncatingRemainder(dividingBy: 60))
        let currentString = String(format: "%.2i:%.2i", currentMM, currentSS)
        let string = String(format: "%.2i:%.2i", totalMM, totalSS)
        
        // 时间显示修改
        playerView?.controlBar.currentTimeLabel.text = currentString
        playerView?.controlBar.timeLabel.text = string
        // 进度条修改
        if let progress = progress {
            let time = CMTime(seconds: duration * Double(progress), preferredTimescale: timescale)
            playerView?.videoPlayer?.seek(to: time)
        } else {
            playerView?.controlBar.slider.value = Float(currentTime) / Float(duration)
        }
    }
    
    
    /// 修改播放器进度
    /// - Parameter progress: 进度
    func changePlayerProgress(progress: Float) {
        if let timescale = playerView?.videoPlayer?.currentTime().timescale,
            let duration = playerView?.videoPlayer?.currentItem?.duration.seconds,
            !duration.isNaN
        {
            
            let currentTime: Double
            if progress < 1 {
                currentTime = (Double(progress) * duration)
            } else {
                currentTime = duration - 2
            }
            
            let time = CMTime(seconds: currentTime, preferredTimescale: timescale)
            //更新时间
            playerView?.videoPlayer?.seek(to: time)
        }
    }
    
    
    /** 显示和隐藏控制面板*/
    func showControlBar(){
        UIView.animate(withDuration: 0.25, animations: {
            self.playerView?.delegate?.playerViewShowControlBar()
            self.playerView?.controlBar.alpha = 1
        }) { (_) in
        }
        
        resetHideTimer()
    }
    
    // 隐藏控制面板
    @objc func hideControlBar(sender: Timer?) {
        sender?.invalidate()
        
        if !(playerStatus == .pause || playerStatus == .stop) {
            UIView.animate(withDuration: 0.25, animations: {
                self.playerView?.delegate?.playerViewHideControlBar()
                self.playerView?.controlBar.alpha = 0
            }) { (_) in
            }
        }
    }
    
    
    /** 重置隐藏控制面板计时器*/
    func resetHideTimer() {
        hideTimer?.invalidate()
        hideTimer = Timer.scheduledTimer(timeInterval: 3, target: self, selector: #selector(hideControlBar(sender:)), userInfo: nil, repeats: false)
    }
}
