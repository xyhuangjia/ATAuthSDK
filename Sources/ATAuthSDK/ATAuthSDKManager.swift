import UIKit
import ATAuthSDK

/// 阿里云号码认证统一管理类
///
/// 封装所有 SDK 相关调用：返回码、结果解析、接口调用均收敛于此，
/// 业务层只使用 ATAuthSDKResult / ATAuthSDKCode，禁止直接触碰 SDK 原始字典与字符串码。
public final class ATAuthSDKManager {

    // MARK: - Singleton

    public static let shared = ATAuthSDKManager()

    private init() {}

    // MARK: - Public Properties

    /// 当前 SDK 版本号
    public var sdkVersion: String {
        TXCommonHandler.sharedInstance().getVersion()
    }

    // MARK: - SDK Initialization

    /// 设置 SDK 鉴权信息（控制台复制的一键登录密钥 JSON）
    public func setAuthSDKInfo(_ info: String, completion: ((ATAuthSDKResult) -> Void)? = nil) {
        TXCommonHandler.sharedInstance().setAuthSDKInfo(info) { resultDic in
            let result = ATAuthSDKResult(resultDic)
            Self.log("setAuthSDKInfo", result)
            completion?(result)
        }
    }

    // MARK: - Environment Check

    /// 检查当前环境是否支持一键登录/本机号码认证（isSuccess 为 true 才可继续后续流程）
    public func checkEnvAvailable(authType: PNSAuthType,
                                  completion: @escaping (ATAuthSDKResult) -> Void) {
        TXCommonHandler.sharedInstance().checkEnvAvailable(with: authType) { resultDic in
            let result = ATAuthSDKResult(resultDic)
            Self.log("checkEnvAvailable", result)
            completion(result)
        }
    }

    // MARK: - Phone Verification (本机号码认证)

    /// 加速本机号码认证（预取号）
    public func accelerateVerify(timeout: TimeInterval = 5.0,
                                 completion: ((ATAuthSDKResult) -> Void)? = nil) {
        TXCommonHandler.sharedInstance().accelerateVerify(withTimeout: timeout) { resultDic in
            let result = ATAuthSDKResult(resultDic)
            Self.log("accelerateVerify", result)
            completion?(result)
        }
    }

    /// 获取本机号码认证 Token
    public func getVerifyToken(timeout: TimeInterval = 5.0,
                               completion: @escaping (ATAuthSDKResult) -> Void) {
        TXCommonHandler.sharedInstance().getVerifyToken(withTimeout: timeout) { resultDic in
            let result = ATAuthSDKResult(resultDic)
            Self.log("getVerifyToken", result)
            completion(result)
        }
    }

    // MARK: - One-Click Login (一键登录)

    /// 加速一键登录（预取号，成功后拉起授权页速度更快）
    public func accelerateLoginPage(timeout: TimeInterval = 5.0,
                                    completion: ((ATAuthSDKResult) -> Void)? = nil) {
        TXCommonHandler.sharedInstance().accelerateLoginPage(withTimeout: timeout) { resultDic in
            let result = ATAuthSDKResult(resultDic)
            Self.log("accelerateLoginPage", result)
            completion?(result)
        }
    }

    /// 获取一键登录 Token（会弹出授权页）
    /// - Parameters:
    ///   - timeout: 超时时间（秒）
    ///   - controller: 弹出授权页的容器控制器
    ///   - model: 自定义授权页样式配置（可为 nil，使用 SDK 默认样式）
    ///   - completion: 结果回调（成功时 token 有值；点击协议时 privacyName / privacyURL 有值）
    public func getLoginToken(timeout: TimeInterval = 5.0,
                              controller: UIViewController,
                              model: TXCustomModel? = nil,
                              completion: @escaping (ATAuthSDKResult) -> Void) {
        TXCommonHandler.sharedInstance().getLoginToken(withTimeout: timeout,
                                                       controller: controller,
                                                       model: model) { resultDic in
            let result = ATAuthSDKResult(resultDic)
            Self.log("getLoginToken", result)
            completion(result)
        }
    }

    /// 在模拟器或真机上拉起调试授权页，方便开发进行 UI 适配
    public func debugLoginUI(controller: UIViewController,
                             model: TXCustomModel? = nil,
                             completion: ((ATAuthSDKResult) -> Void)? = nil) {
        TXCommonHandler.sharedInstance().debugLoginUI(with: controller, model: model) { resultDic in
            let result = ATAuthSDKResult(resultDic)
            Self.log("debugLoginUI", result)
            completion?(result)
        }
    }

    /// 取消/关闭授权页
    public func cancelLoginVC(animated: Bool = true, completion: (() -> Void)? = nil) {
        TXCommonHandler.sharedInstance().cancelLoginVC(animated: animated, complete: completion)
    }

    /// 隐藏登录加载动画
    public func hideLoginLoading() {
        TXCommonHandler.sharedInstance().hideLoginLoading()
    }

    // MARK: - Privacy Agreement (二次协议)

    /// 关闭二次授权弹窗
    public func closePrivacyAlertView() {
        TXCommonHandler.sharedInstance().closePrivactAlertView()
    }

    // MARK: - Checkbox / Animation

    /// 设置授权页 checkbox 选中状态
    public func setCheckboxIsChecked(_ isChecked: Bool) {
        TXCommonHandler.sharedInstance().setCheckboxIsChecked(isChecked)
    }

    /// 查询授权页 checkbox 选中状态
    public var isCheckBoxChecked: Bool {
        TXCommonHandler.sharedInstance().queryCheckBoxIsChecked()
    }

    /// 启动 checkbox 动画
    public func startCheckboxAnimation() {
        TXCommonHandler.sharedInstance().checkboxAnimationStart()
    }

    /// 启动协议动画
    public func startPrivacyAnimation() {
        TXCommonHandler.sharedInstance().privacyAnimationStart()
    }

    // MARK: - Utility Methods

    /// 获取日志埋点控制对象
    public func getReporter() -> PNSReporter {
        TXCommonHandler.sharedInstance().getReporter()
    }

    // MARK: - Logging

    /// 统一输出 SDK 调用日志（收敛所有 print，仅 Debug 生效）
    static func log(_ api: String, _ result: ATAuthSDKResult) {
        #if DEBUG
        print("[ATAuthSDK] \(api) -> code=\(result.rawCode), success=\(result.isSuccess), msg=\(result.message)")
        if !result.raw.isEmpty {
            print("[ATAuthSDK] \(api) raw: \(result.raw)")
        }
        #endif
    }
}

// MARK: - 便捷扩展：运营商信息查询

extension ATAuthSDKManager {

    /// 判断当前设备蜂窝数据网络是否开启
    public var isCellularDataEnabled: Bool {
        TXCommonUtils.checkDeviceCellularDataEnable()
    }

    /// 判断当前上网卡运营商是否是中国联通
    public var isChinaUnicom: Bool { TXCommonUtils.isChinaUnicom() }

    /// 判断当前上网卡运营商是否是中国移动
    public var isChinaMobile: Bool { TXCommonUtils.isChinaMobile() }

    /// 判断当前上网卡运营商是否是中国电信
    public var isChinaTelecom: Bool { TXCommonUtils.isChinaTelecom() }

    /// 获取当前上网卡运营商名称
    public var currentCarrierName: String { TXCommonUtils.getCurrentCarrierName() }

    /// 获取当前上网卡网络类型
    public var networkType: String { TXCommonUtils.getNetworktype() }

    /// 判断当前设备是否有 SIM 卡
    public var hasSIMCard: Bool { TXCommonUtils.simSupportedIsOK() }
}
