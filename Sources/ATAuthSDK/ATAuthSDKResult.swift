import Foundation

/// 统一回调结果（业务层唯一出口，不再接触 SDK 原始字典）
public struct ATAuthSDKResult {

    /// 原始返回码字符串（未收录进 ATAuthSDKCode 时仍可追溯）
    public let rawCode: String
    /// SDK 原始回调字典
    public let raw: [AnyHashable: Any]

    public init(_ dict: [AnyHashable: Any]?) {
        self.rawCode = (dict?["resultCode"] as? String) ?? ""
        self.raw = dict ?? [:]
    }

    /// 已识别的返回码（无法识别时为 nil，可用 rawCode 追溯）
    public var code: ATAuthSDKCode? { ATAuthSDKCode(rawValue: rawCode) }
    /// 是否成功（600000）
    public var isSuccess: Bool { rawCode == ATAuthSDKCode.success.rawValue }
    /// 结果描述（优先 SDK 返回的 msg，其次错误码内置描述）
    public var message: String {
        if let msg = raw["msg"] as? String, !msg.isEmpty { return msg }
        return code?.message ?? "未知错误(\(rawCode))"
    }
    /// 一键登录 / 本机号码认证 token（仅成功时有值）
    public var token: String? { isSuccess ? raw["token"] as? String : nil }
    /// 掩码手机号（预取号成功时有值）
    public var maskPhoneNumber: String? { raw["phoneNumber"] as? String }
    /// 协议点击回调中的协议名称
    public var privacyName: String? { (raw["privacyName"] ?? raw["name"]) as? String }
    /// 协议点击回调中的协议链接
    public var privacyURL: String? { (raw["privacyUrl"] ?? raw["privacyURL"] ?? raw["url"]) as? String }
}
