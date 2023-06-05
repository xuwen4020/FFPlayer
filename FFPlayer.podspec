Pod::Spec.new do |spec|

  spec.name         = "FFPlayer"
  spec.version      = "0.0.1"
  spec.summary      = "Swift 视频播放器 FFPlayer."
  spec.description  = "Swift 视频播放器 FFPlayer.Swift 视频播放器 FFPlayer.Swift 视频播放器 FFPlayer."

  spec.homepage     = "https://github.com/xuwen4020/FFPlayer"
  spec.swift_version = '5.0'


  spec.license      = { :type => "MIT" }
  spec.author             = { "xuwen" => "996592197@qq.com" }

  spec.platform     = :ios, '13.0'
  spec.source       = { :git => "https://github.com/xuwen4020/FFPlayer.git", :tag => spec.version }

  spec.static_framework = true
  spec.source_files  = "FFPlayer/**/*.swift"


end
