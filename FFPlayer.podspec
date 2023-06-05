Pod::Spec.new do |spec|

  spec.name         = "FFPlayer"
  spec.version      = "0.0.1"
  spec.summary      = "Swift 视频播放器 FFPlayer."
  spec.description  = "Swift 视频播放器 FFPlayer.Swift 视频播放器 FFPlayer.Swift 视频播放器 FFPlayer."

  spec.homepage     = "https://github.com/xuwen4020/FFPlayer"
  spec.swift_version = '5.0'
  # spec.screenshots  = "www.example.com/screenshots_1.gif", "www.example.com/screenshots_2.gif"


  spec.license      = { :type => "MIT" }
  spec.author             = { "xuwen" => "996592197@qq.com" }

  spec.platform     = :ios, '13.0'
  spec.source       = { :git => "https://github.com/xuwen4020/FFPlayer.git", :tag => spec.version }

  spec.static_framework = true
  spec.source_files  = "FFPlayer/**/*"



  # ――― Resources ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  # spec.resource  = "icon.png"
  # spec.resources = "Resources/*.png"
  # spec.preserve_paths = "FilesToSave", "MoreFilesToSave"


  # ――― Project Linking ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  # spec.framework  = "SomeFramework"
  # spec.frameworks = "SomeFramework", "AnotherFramework"
  # spec.library   = "iconv"
  # spec.libraries = "iconv", "xml2"


  # ――― Project Settings ――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  # spec.requires_arc = true
  # spec.xcconfig = { "HEADER_SEARCH_PATHS" => "$(SDKROOT)/usr/include/libxml2" }
  # spec.dependency "JSONKit", "~> 1.4"

end
