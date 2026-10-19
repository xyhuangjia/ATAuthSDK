# ATAuthSDK

阿里云号码认证服务（一键登录 / 本机号码认证）的 Swift Package，基于官方 **ATAuthSDK v2.14.19** 封装。

`import ATAuthSDK` 一行即可获得完整的 `TXCommonHandler` 等原生 API，以及一套对齐官方 Swift Demo 的高层封装（返回码枚举、统一结果解析、调用日志）。

## 包结构

```
├── Package.swift                  # SPM 清单：3 个 binaryTarget + 1 个同名封装 target
├── Sources/ATAuthSDK/
│   ├── ATAuthSDK.swift            # @_exported import（原生 API 透出）
│   ├── ATAuthSDKCode.swift    # 返回码枚举（收敛 PNSReturnCode.h）
│   ├── ATAuthSDKResult.swift  # 统一回调结果（不再接触 SDK 原始字典）
│   └── ATAuthSDKManager.swift # 统一管理类（初始化/环境检查/取号/授权页）
├── xcframeworks/                  # 官方 SDK（已重打包，见下文「重要说明」）
│   ├── ATAuthSDK.xcframework      #   主 SDK（含 ATAuthSDK.bundle 授权页资源）
│   ├── YTXOperators.xcframework   #   运营商组件
│   └── YTXMonitor.xcframework     #   日志监控组件
├── Scripts/repack-static-framework.sh  # SDK 升级时需重跑的重打包脚本
└── Demo/AliyunOneClickLoginDemo   # 模拟器可运行的验证 Demo
```

target 说明：二进制目标 `ATAuthSDKCore`（即 ATAuthSDK.xcframework）、`YTXOperators`、`YTXMonitor`；对外 Swift 封装 target 与库同名，均叫 `ATAuthSDK`。

## 接入

### 1. 添加包依赖

```swift
dependencies: [
    .package(url: "https://github.com/xyhuangjia/ATAuthSDK.git", from: "2.14.19")
]
// target 依赖
.product(name: "ATAuthSDK", package: "ATAuthSDK")
```

本地调试可用 path 引用本仓库。

### 2. 在 App target 中添加 ATAuthSDK.bundle（必须）

SDK 从**主 bundle 根目录**查找授权页图标资源。SPM 不会自动拷贝静态二进制目标内的资源，请将
`xcframeworks/ATAuthSDK.xcframework/ios-arm64/ATAuthSDK.framework/ATAuthSDK.bundle`
拖入 Xcode 工程（勾选 **Copy items if needed**，加入 App target 的 **Copy Bundle Resources**）。
可参照 `Demo/` 的做法。

### 3. Info.plist 权限描述（可选）

一键登录不强制申请权限；如需在取号前判断网络类型，建议添加 `NSCellularUsageDescription`。

## 使用

```swift
import ATAuthSDK

let manager = ATAuthSDKManager.shared

// 1. 初始化鉴权信息（号码认证控制台复制）
manager.setAuthSDKInfo(authInfoJSON) { result in ... }

// 2. 环境检查
manager.checkEnvAvailable(authType: .loginToken) { result in
    if result.isSuccess { /* 可走一键登录 */ }
}

// 3. 预取号加速（可选）
manager.accelerateLoginPage()

// 4. 拉起授权页取号
manager.getLoginToken(controller: self, model: customModel) { result in
    switch result.code {
    case .success:
        // result.token 交给服务端换取手机号
        manager.cancelLoginVC()
    case .clickPrivacy, .privacyAlertClickPrivacy:
        // result.privacyName / result.privacyURL 打开协议
        break
    default: break
    }
}

// 本机号码认证
manager.getVerifyToken { result in /* result.token */ }
```

`TXCustomModel` 授权页样式、`TXCommonUtils` 运营商查询等原生 API 经 `@_exported` 透出，直接使用即可；完整调用链参见 `Demo/AliyunOneClickLoginDemo/ContentView.swift`（对齐官方 ATAuthSceneSwiftDemo）。

## 重要说明：xcframeworks 已重打包（零 -ObjC 配置）

官方静态库中包含 ObjC 分类（如 `UIViewController(PNSAnimation)`、`UIView(UAToast)` 等）。SPM 链接静态库时默认不带 `-ObjC`，分类所在目标文件会被链接器整体丢弃，运行时拉起授权页必然崩溃：
`unrecognized selector sent to instance ... presentController:model:isFullScreen:completion:`。

本仓库已用 `Scripts/repack-static-framework.sh` 将每个静态库的全部目标文件 `ld -r` 合并为单对象重打包——任何符号引用都会把分类一并链接进来，业务方**无需设置 `-ObjC`**。

**升级官方 SDK 版本时必须重跑**：

```bash
for fw in ATAuthSDK YTXOperators YTXMonitor; do
  for slice in xcframeworks/$fw.xcframework/ios-*; do
    ./Scripts/repack-static-framework.sh "$slice/$fw.framework"
  done
done
```

若不想重打包，也可以退回传统方案：在 App target 的 `Other Linker Flags` 中添加 `-ObjC`（两者二选一即可）。

## Demo

`Demo/AliyunOneClickLoginDemo.xcodeproj` 已接入本地包并内嵌 bundle：

```bash
xcodebuild -project Demo/AliyunOneClickLoginDemo.xcodeproj \
  -scheme AliyunOneClickLoginDemo \
  -destination 'platform=iOS Simulator,name=iPhone 17' build
```

模拟器无 SIM 卡，取号接口返回 600007（无 SIM）属预期；「调试授权页（debugLoginUI）」不依赖 SIM，可完整验证授权页 UI 与资源。启动参数 `--auto-debug-login-ui` 会自动拉起调试授权页，便于 CI 截图回归。

## 已验证环境

- Xcode 27.1 / iOS 27 模拟器（授权页拉起、UI 与资源渲染正常）
- 真机 Release 构建（静态链接、bundle 落位正常）
- ATAuthSDK 最低支持 iOS 9，本包声明最低 iOS 12
