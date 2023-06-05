//
//  BFVideoConfig.swift
//  Enterprise
//
//  Created by xuwen on 2023/5/8.
//

import Foundation
import UIKit

public struct BFVidoeModel {
    
    /// 视频标题
    var title: String?
    
    /// 视频地址
    var videoUrl: String?
    
    /// 视频封面图
    var placeHoldImgStr: String?
    
    /// 是否需要缓存
    /// 支持缓存类型：视频（mp4），音频（caf）
    var needCache: Bool = true
    
    /// 初始化播放器配置
    /// - Parameters:
    ///   - title: title
    ///   - videoUrl: videoUrl
    ///   - placeHoldImgStr: placeHolderImgStrb
    public init(title: String? = nil, videoUrl: String? = nil, placeHoldImgStr: String? = nil) {
        self.title = title
        self.videoUrl = videoUrl
        self.placeHoldImgStr = placeHoldImgStr
    }
}


enum BFPlayerStatus {
    
    /// 准备
    case prepare
    /// 正在播放
    case playing
    /// 暂停
    case pause
    /// 释放播放器（销毁时使用）
    case stop
    
    /// 控制面板播放按钮图标
    var controlPlayImg: UIImage? {
        switch self {
        case .playing:
            return UIImage(named: "bf_video_ic_pause")
        case .pause:
            return UIImage(named: "bf_video_ic_play")
        default:
            return UIImage(named: "bf_video_ic_play")
        }
    }
}
