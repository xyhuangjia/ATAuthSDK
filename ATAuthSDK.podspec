Pod::Spec.new do |s|
  s.name             = 'ATAuthSDK'
  s.version          = '2.14.19'
  s.summary          = '阿里云号码认证服务（一键登录 / 本机号码认证）的 Swift 封装。'
  s.description      = <<-DESC
    基于官方 ATAuthSDK v2.14.19 封装，提供一键登录、本机号码认证、
    授权页自定义等能力，并附带返回码枚举、统一结果解析与调用日志。
  DESC
  s.homepage         = 'https://github.com/xyhuangjia/ATAuthSDK'
  s.license          = { :type => 'Copyright', :text => 'Copyright (c) 2026 Aliyun. All rights reserved.' }
  s.author           = { 'xyhuangjia' => 'xyhuangjia@users.noreply.github.com' }
  s.source           = { :git => 'https://github.com/xyhuangjia/ATAuthSDK.git', :tag => s.version.to_s }

  s.platform         = :ios, '12.0'
  s.swift_version    = '5.0'
  s.requires_arc     = true
  # 官方 SDK 为静态库，封装层同样以静态方式集成
  s.static_framework = true

  # 官方二进制框架本身就叫 ATAuthSDK，本 pod 若同名会触发 Swift 自导入，
  # 因此 Swift 封装层以 ATAuthSDKKit 作为模块名对外提供。
  s.module_name      = 'ATAuthSDKKit'

  # Swift 高层封装（与 SPM target 共用同一份源码）
  s.source_files     = 'Sources/ATAuthSDK/**/*.swift'

  # 官方 SDK 静态二进制（已重打包，无需业务方配置 -ObjC）
  s.vendored_frameworks = [
    'xcframeworks/ATAuthSDK.xcframework',
    'xcframeworks/YTXOperators.xcframework',
    'xcframeworks/YTXMonitor.xcframework'
  ]

  # SDK 从主 bundle 根目录查找授权页图标资源，需随 App 一起拷贝
  s.resources = 'Resources/ATAuthSDK.bundle'

  # 三个二进制静态框架各自携带隐私清单，CocoaPods 不会自动拷贝，需分别打进独立 bundle
  s.resource_bundles = {
    'ATAuthSDKPrivacy'   => ['Resources/Privacy/ATAuthSDK/PrivacyInfo.xcprivacy'],
    'YTXOperatorsPrivacy' => ['Resources/Privacy/YTXOperators/PrivacyInfo.xcprivacy'],
    'YTXMonitorPrivacy'   => ['Resources/Privacy/YTXMonitor/PrivacyInfo.xcprivacy']
  }

  s.frameworks = 'UIKit', 'Foundation', 'CoreTelephony', 'SystemConfiguration',
                 'Network', 'WebKit', 'Security', 'AdSupport'
  s.libraries  = 'c++', 'z', 'sqlite3'
end
