import Foundation

/// 阿里云号码认证 SDK 返回码（收敛自 PNSReturnCode.h，业务层禁止使用字符串魔法值）
public enum OneClickLoginCode: String {
    // MARK: 通用返回码

    /// 接口成功
    case success = "600000"
    /// 获取运营商配置信息失败
    case getOperatorInfoFailed = "600004"
    /// 未检测到 SIM 卡
    case noSIMCard = "600007"
    /// 蜂窝网络未开启或不稳定
    case noCellularNetwork = "600008"
    /// 无法判运营商
    case unknownOperator = "600009"
    /// 未知异常
    case unknownError = "600010"
    /// 获取 token 失败
    case getTokenFailed = "600011"
    /// 预取号失败
    case getMaskPhoneFailed = "600012"
    /// 运营商维护升级，该功能不可用
    case interfaceDemoted = "600013"
    /// 运营商维护升级，该功能已达最大调用次数
    case interfaceLimited = "600014"
    /// 接口超时
    case timeout = "600015"
    /// AppID、AppKey 解析失败
    case decodeAppInfoFailed = "600017"
    /// 该号码已被运营商管控
    case phoneBlack = "600018"
    /// 运营商已切换
    case carrierChanged = "600021"
    /// 终端环境检测失败
    case envCheckFailed = "600025"

    // MARK: 授权页返回码

    /// 唤起授权页成功
    case loginPagePresentSuccess = "600001"
    /// 唤起授权页失败
    case loginPagePresentFailed = "600002"
    /// 授权页已加载时不允许调用加速或预取号接口
    case preLoginInAuthPage = "600026"
    /// 点击返回，用户取消一键登录
    case clickCancel = "700000"
    /// 点击切换按钮，用户取消免密登录
    case clickSwitchButton = "700001"
    /// 点击登录按钮事件
    case clickLoginButton = "700002"
    /// 点击 CheckBox 事件
    case clickCheckBox = "700003"
    /// 点击协议富文本文字（主授权页）
    case clickPrivacy = "700004"
    /// suspendDisMissVC 模式下点击返回
    case suspendDismiss = "700010"
    /// 授权页已销毁
    case loginPageDealloc = "700020"

    // MARK: 二次协议弹窗返回码

    /// 拉起授权页二次弹窗
    case privacyAlertPresent = "700006"
    /// 二次协议弹窗关闭
    case privacyAlertClose = "700007"
    /// 二次协议弹窗点击确认并继续
    case privacyAlertContinue = "700008"
    /// 点击二次弹窗协议富文本
    case privacyAlertClickPrivacy = "700009"
}

extension OneClickLoginCode {

    /// 用户主动操作或中间态（不应按错误处理）
    public var isUserInteraction: Bool {
        switch self {
        case .loginPagePresentSuccess,
             .clickCancel, .clickSwitchButton, .clickLoginButton, .clickCheckBox,
             .clickPrivacy, .suspendDismiss, .loginPageDealloc,
             .privacyAlertPresent, .privacyAlertClose, .privacyAlertContinue,
             .privacyAlertClickPrivacy:
            return true
        default:
            return false
        }
    }

    /// 内置中文描述
    public var message: String {
        switch self {
        case .success:                      return "成功"
        case .getOperatorInfoFailed:        return "获取运营商配置信息失败"
        case .noSIMCard:                    return "未检测到 SIM 卡"
        case .noCellularNetwork:            return "蜂窝网络未开启或不稳定"
        case .unknownOperator:              return "无法判运营商"
        case .unknownError:                 return "未知异常"
        case .getTokenFailed:               return "获取 token 失败"
        case .getMaskPhoneFailed:           return "预取号失败"
        case .interfaceDemoted:             return "运营商维护升级，该功能不可用"
        case .interfaceLimited:             return "运营商维护升级，该功能已达最大调用次数"
        case .timeout:                      return "接口超时"
        case .decodeAppInfoFailed:          return "AppID、AppKey 解析失败"
        case .phoneBlack:                   return "该号码已被运营商管控"
        case .carrierChanged:               return "运营商已切换"
        case .envCheckFailed:               return "终端环境检测失败"
        case .loginPagePresentSuccess:      return "授权页唤起成功"
        case .loginPagePresentFailed:       return "授权页唤起失败"
        case .preLoginInAuthPage:           return "授权页已加载时不允许调用预取号"
        case .clickCancel:                  return "用户取消一键登录"
        case .clickSwitchButton:            return "用户切换其他登录方式"
        case .clickLoginButton:             return "用户点击登录"
        case .clickCheckBox:                return "用户点击协议勾选框"
        case .clickPrivacy:                 return "用户点击协议富文本"
        case .suspendDismiss:               return "用户中断页面"
        case .loginPageDealloc:             return "授权页已销毁"
        case .privacyAlertPresent:          return "二次协议弹窗已展示"
        case .privacyAlertClose:            return "二次协议弹窗已关闭"
        case .privacyAlertContinue:         return "用户点击确认并继续"
        case .privacyAlertClickPrivacy:     return "用户点击二次弹窗协议"
        }
    }
}
