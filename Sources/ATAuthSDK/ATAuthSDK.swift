import Foundation
/// 阿里云号码认证 SDK（v2.14.19）的 Swift Package 封装。
///
/// 业务方只需 `import ATAuthSDK`，即可直接使用
/// `TXCommonHandler` / `TXCustomModel` / `TXCommonUtils` / `PNSReporter` 等原生前缀 API。
@_exported import ATAuthSDK

/// 包与所封装 SDK 的版本信息。
public enum ATAuthSDKPackage {
    /// 所封装的阿里云号码认证 SDK 版本（来自 TXCommonHandler#getVersion）。
    public static var sdkVersion: String { TXCommonHandler.sharedInstance().getVersion() }
}
