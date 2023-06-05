//
//  BFPlayerViewDelegate.swift
//  Enterprise
//
//  Created by xuwen on 2023/5/9.
//

import Foundation
protocol BFPlayerViewDelegate: NSObjectProtocol {

    /** 展示控制台*/
    func playerViewShowControlBar()
    
    /** 隐藏控制台*/
    func playerViewHideControlBar()

}
