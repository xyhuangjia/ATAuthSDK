import SwiftUI
import ATAuthSDK

/// 阿里云号码认证 SPM 集成验证 Demo
///
/// 流程参照官方 ATAuthSceneSwiftDemo：
/// 初始化密钥 -> checkEnvAvailable -> 一键登录 getLoginToken / 本机号码认证 getVerifyToken -> token 交服务端换号。
/// 模拟器无 SIM 卡，取号接口会返回 600007/600025 等环境错误码，属预期；
/// 「调试授权页」走 debugLoginUI，不依赖 SIM，可验证授权页 UI 与 bundle 资源。
struct ContentView: View {
    @State private var authInfo = ""
    @State private var logText = "点按按钮开始\n"
    @State private var checkResult = ""

    var body: some View {
        NavigationStack {
            Form {
                Section("SDK 信息") {
                    LabeledContent("SDK 版本", value: ATAuthSDKManager.shared.sdkVersion)
                    LabeledContent("当前运营商", value: ATAuthSDKManager.shared.currentCarrierName)
                    LabeledContent("有 SIM 卡", value: ATAuthSDKManager.shared.hasSIMCard ? "是" : "否")
                }

                Section("鉴权密钥（控制台复制的 authInfo JSON，可留空）") {
                    TextField("setAuthSDKInfo", text: $authInfo, axis: .vertical)
                        .font(.system(.footnote, design: .monospaced))
                        .lineLimit(3)
                    Button("1. 初始化密钥") { setAuthInfo() }
                }

                Section("环境检查") {
                    Button("2. 检查一键登录环境") { checkEnv(.loginToken) }
                    Button("3. 检查本机号码认证环境") { checkEnv(.verifyToken) }
                    if !checkResult.isEmpty {
                        Text(checkResult).font(.footnote).foregroundStyle(.secondary)
                    }
                }

                Section("一键登录") {
                    Button("4. 预取号（accelerateLoginPage）") { accelerateLogin() }
                    Button("5. 拉起授权页（getLoginToken）") { presentAuthPage(debug: false) }
                    Button("6. 调试授权页（debugLoginUI）") { presentAuthPage(debug: true) }
                }

                Section("本机号码认证") {
                    Button("7. 获取认证 Token（getVerifyToken）") { getVerifyToken() }
                }

                Section("运行日志") {
                    Text(logText)
                        .font(.system(.caption2, design: .monospaced))
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .textSelection(.enabled)
                }
            }
            .navigationTitle("号码认证 Demo")
            .onAppear { handleLaunchArgs() }
        }
    }

    /// CI / 自动化验证入口：`--auto-debug-login-ui` 启动参数自动拉起调试授权页
    private func handleLaunchArgs() {
        guard ProcessInfo.processInfo.arguments.contains("--auto-debug-login-ui") else { return }
        appendLog("自动验证：等待场景就绪后拉起调试授权页")
        waitForTopController { controller in
            guard let controller else {
                appendLog("自动验证失败：未找到容器控制器")
                return
            }
            appendLog("容器控制器: \(type(of: controller))")
            checkEnv(.loginToken)
            presentAuthPage(debug: true, controller: controller)
        }
    }

    /// 轮询等待 foregroundActive 的 keyWindow root 出现（模拟器冷启动可能需要数秒）
    private func waitForTopController(timeout: TimeInterval = 10, completion: @escaping (UIViewController?) -> Void) {
        var waited: TimeInterval = 0
        DispatchQueue.main.async {
            func attempt() {
                if let top = self.topViewController() {
                    completion(top)
                } else if waited < timeout {
                    waited += 0.5
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: attempt)
                } else {
                    completion(nil)
                }
            }
            attempt()
        }
    }

    // MARK: - Actions

    private func setAuthInfo() {
        guard !authInfo.isEmpty else {
            appendLog("跳过初始化（未填密钥）")
            return
        }
        ATAuthSDKManager.shared.setAuthSDKInfo(authInfo) { result in
            appendLog("setAuthSDKInfo: \(result.rawCode) \(result.message)")
        }
    }

    private func checkEnv(_ type: PNSAuthType) {
        ATAuthSDKManager.shared.checkEnvAvailable(authType: type) { result in
            checkResult = "\(type == .loginToken ? "一键登录" : "本机认证"): \(result.rawCode) \(result.message)"
            appendLog("checkEnv(\(type == .loginToken ? "login" : "verify")): \(result.rawCode) \(result.message)")
        }
    }

    private func accelerateLogin() {
        ATAuthSDKManager.shared.accelerateLoginPage { result in
            appendLog("accelerateLoginPage: \(result.rawCode) \(result.message)")
        }
    }

    private func presentAuthPage(debug: Bool, controller: UIViewController? = nil) {
        let container = controller ?? topViewController()
        guard let controller = container else {
            appendLog("拉起授权页失败：未找到容器控制器")
            return
        }
        let model = AuthPageStyleBuilder.buildBottomSheetModel()

        let handler: (ATAuthSDKResult) -> Void = { result in
            appendLog("authPage: \(result.rawCode) \(result.message)")
            switch result.code {
            case .success:
                appendLog("获取 token 成功，交服务端换号（Demo 仅展示 token 前 8 位）：\(String((result.token ?? "").prefix(8)))…")
                ATAuthSDKManager.shared.cancelLoginVC()
            case .clickPrivacy, .privacyAlertClickPrivacy:
                appendLog("点击协议: \(result.privacyName ?? "-") \(result.privacyURL ?? "-")")
            default:
                break
            }
        }

        if debug {
            ATAuthSDKManager.shared.debugLoginUI(controller: controller, model: model, completion: handler)
        } else {
            ATAuthSDKManager.shared.getLoginToken(controller: controller, model: model, completion: handler)
        }
    }

    private func getVerifyToken() {
        ATAuthSDKManager.shared.getVerifyToken { result in
            if let token = result.token {
                appendLog("getVerifyToken 成功 token: \(String(token.prefix(8)))…")
            } else {
                appendLog("getVerifyToken: \(result.rawCode) \(result.message)")
            }
        }
    }

    // MARK: - Helpers

    @MainActor
    private func appendLog(_ line: String) {
        logText = logText + line + "\n"
    }

    private func topViewController() -> UIViewController? {
        let scene = UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .first { $0.keyWindow != nil }
        let root = scene?.keyWindow?.rootViewController
        var top = root
        while let presented = top?.presentedViewController { top = presented }
        return top
    }
}

/// 授权页样式构建（简化自官方 Demo 的 PNSAuthPageStyleBuilder，演示底部弹窗样式）
enum AuthPageStyleBuilder {

    static func buildBottomSheetModel() -> TXCustomModel {
        let model = TXCustomModel()

        // 底部弹窗容器
        model.contentViewFrameBlock = { screenSize, _, _ in
            let height = screenSize.height * 0.65
            return CGRect(x: 0, y: screenSize.height - height, width: screenSize.width, height: height)
        }
        // 弹窗样式需隐藏导航返回
        model.navIsHidden = true

        // 授权页协议（自定义协议页容器）
        model.privacyVCIsCustomized = true

        // 二次协议确认弹窗
        model.privacyAlertIsNeedShow = true
        model.privacyAlertIsNeedAutoLogin = true
        model.privacyAlertTitleContent = "服务协议与隐私政策"
        model.privacyAlertBtnContent = "同意并继续"
        model.privacyAlertBackgroundColor = .white
        model.privacyAlertCornerRadiusArray = [20, 20, 20, 20]

        return model
    }
}
