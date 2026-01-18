//
//  LoginView.swift
//  AICreatorApp
//
//  登录页 - 完整SwiftUI代码框架
//  基于设计规范文档 v3.0
//
//  Created by Manus AI on 2026/1/19.
//

import SwiftUI
import AuthenticationServices

// MARK: - 登录页主视图
struct LoginView: View {
    
    @StateObject private var viewModel = LoginViewModel()
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ZStack {
            // 背景
            LoginBackgroundView()
            
            VStack(spacing: 0) {
                Spacer()
                
                // Logo和标题
                VStack(spacing: Spacing.md) {
                    Image("app_logo")
                        .resizable()
                        .frame(width: 80, height: 80)
                        .cornerRadius(CornerRadius.lg)
                    
                    Text("AI创图")
                        .font(.title1)
                        .fontWeight(.bold)
                        .foregroundStyle(Color.primaryGradient)
                    
                    Text("一键生成专属艺术照")
                        .font(.bodyMedium)
                        .foregroundColor(.textSecondary)
                }
                .padding(.bottom, Spacing.xxl)
                
                // 作品展示网格
                LoginWorksGridView()
                    .frame(height: 200)
                    .padding(.bottom, Spacing.xxl)
                
                Spacer()
                
                // 登录按钮区域
                VStack(spacing: Spacing.md) {
                    // 微信登录
                    LoginButton(
                        icon: "wechat_icon",
                        title: "微信登录",
                        backgroundColor: Color(hex: "#07C160")
                    ) {
                        viewModel.loginWithWechat()
                    }
                    
                    // Apple登录
                    AppleSignInButton(viewModel: viewModel)
                    
                    // 手机号登录
                    Button(action: {
                        viewModel.showPhoneLogin = true
                    }) {
                        HStack(spacing: Spacing.xs) {
                            Image(systemName: "iphone")
                                .font(.system(size: 18))
                            Text("手机号登录")
                                .font(.buttonMedium)
                        }
                        .foregroundColor(.textSecondary)
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(Color.inputBackground)
                        .cornerRadius(CornerRadius.md)
                    }
                }
                .padding(.horizontal, Spacing.xl)
                .padding(.bottom, Spacing.lg)
                
                // 用户协议
                AgreementView(isAgreed: $viewModel.isAgreed)
                    .padding(.horizontal, Spacing.xl)
                    .padding(.bottom, Spacing.xl)
            }
            
            // 加载状态
            if viewModel.isLoading {
                LoadingOverlay()
            }
        }
        .sheet(isPresented: $viewModel.showPhoneLogin) {
            PhoneLoginView(viewModel: viewModel)
        }
        .alert("登录失败", isPresented: $viewModel.showError) {
            Button("确定", role: .cancel) {}
        } message: {
            Text(viewModel.errorMessage ?? "请稍后重试")
        }
        .onAppear {
            AnalyticsManager.shared.trackPageView(.login)
        }
    }
}

// MARK: - 登录背景视图
struct LoginBackgroundView: View {
    var body: some View {
        ZStack {
            Color.appBackground
                .ignoresSafeArea()
            
            // 渐变光效
            Circle()
                .fill(
                    RadialGradient(
                        colors: [Color.gradientPurple.opacity(0.3), Color.clear],
                        center: .center,
                        startRadius: 0,
                        endRadius: 300
                    )
                )
                .frame(width: 600, height: 600)
                .offset(x: -100, y: -200)
            
            Circle()
                .fill(
                    RadialGradient(
                        colors: [Color.gradientPink.opacity(0.2), Color.clear],
                        center: .center,
                        startRadius: 0,
                        endRadius: 250
                    )
                )
                .frame(width: 500, height: 500)
                .offset(x: 150, y: 100)
        }
    }
}

// MARK: - 登录作品展示网格
struct LoginWorksGridView: View {
    
    private let sampleImages = [
        "sample_1", "sample_2", "sample_3",
        "sample_4", "sample_5", "sample_6"
    ]
    
    private let columns = [
        GridItem(.flexible(), spacing: Spacing.xs),
        GridItem(.flexible(), spacing: Spacing.xs),
        GridItem(.flexible(), spacing: Spacing.xs)
    ]
    
    var body: some View {
        LazyVGrid(columns: columns, spacing: Spacing.xs) {
            ForEach(sampleImages.indices, id: \.self) { index in
                RoundedRectangle(cornerRadius: CornerRadius.sm)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.gradientPurple.opacity(0.3 + Double(index) * 0.1),
                                Color.gradientPink.opacity(0.2 + Double(index) * 0.05)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .aspectRatio(3/4, contentMode: .fit)
                    .overlay(
                        Image(systemName: "sparkles")
                            .foregroundColor(.white.opacity(0.5))
                    )
            }
        }
        .padding(.horizontal, Spacing.xl)
    }
}

// MARK: - 登录按钮
struct LoginButton: View {
    let icon: String
    let title: String
    let backgroundColor: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: Spacing.sm) {
                Image(icon)
                    .resizable()
                    .frame(width: 24, height: 24)
                
                Text(title)
                    .font(.buttonMedium)
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .frame(height: 50)
            .background(backgroundColor)
            .cornerRadius(CornerRadius.md)
        }
    }
}

// MARK: - Apple登录按钮
struct AppleSignInButton: View {
    @ObservedObject var viewModel: LoginViewModel
    
    var body: some View {
        SignInWithAppleButton(.signIn) { request in
            request.requestedScopes = [.fullName, .email]
        } onCompletion: { result in
            viewModel.handleAppleSignIn(result: result)
        }
        .signInWithAppleButtonStyle(.white)
        .frame(height: 50)
        .cornerRadius(CornerRadius.md)
    }
}

// MARK: - 用户协议视图
struct AgreementView: View {
    @Binding var isAgreed: Bool
    
    var body: some View {
        HStack(spacing: Spacing.xs) {
            Button(action: {
                isAgreed.toggle()
            }) {
                Image(systemName: isAgreed ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(isAgreed ? .gradientPurple : .textTertiary)
                    .font(.system(size: 18))
            }
            
            Text("登录即表示同意")
                .font(.caption1)
                .foregroundColor(.textTertiary)
            
            Button(action: {
                // 打开用户协议
            }) {
                Text("《用户协议》")
                    .font(.caption1)
                    .foregroundStyle(Color.primaryGradient)
            }
            
            Text("和")
                .font(.caption1)
                .foregroundColor(.textTertiary)
            
            Button(action: {
                // 打开隐私政策
            }) {
                Text("《隐私政策》")
                    .font(.caption1)
                    .foregroundStyle(Color.primaryGradient)
            }
        }
    }
}

// MARK: - 手机号登录视图
struct PhoneLoginView: View {
    @ObservedObject var viewModel: LoginViewModel
    @Environment(\.dismiss) private var dismiss
    
    @State private var phone = ""
    @State private var verifyCode = ""
    @State private var countdown = 0
    @State private var timer: Timer?
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.appBackground
                    .ignoresSafeArea()
                
                VStack(spacing: Spacing.xl) {
                    // 标题
                    VStack(spacing: Spacing.xs) {
                        Text("手机号登录")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.textPrimary)
                        
                        Text("未注册的手机号将自动创建账号")
                            .font(.bodySmall)
                            .foregroundColor(.textSecondary)
                    }
                    .padding(.top, Spacing.xl)
                    
                    // 输入区域
                    VStack(spacing: Spacing.md) {
                        // 手机号输入
                        HStack(spacing: Spacing.sm) {
                            Text("+86")
                                .font(.bodyMedium)
                                .foregroundColor(.textPrimary)
                                .frame(width: 50)
                            
                            Divider()
                                .frame(height: 20)
                                .background(Color.borderDefault)
                            
                            TextField("请输入手机号", text: $phone)
                                .font(.bodyMedium)
                                .foregroundColor(.textPrimary)
                                .keyboardType(.phonePad)
                        }
                        .padding(.horizontal, Spacing.md)
                        .frame(height: 50)
                        .background(Color.inputBackground)
                        .cornerRadius(CornerRadius.md)
                        
                        // 验证码输入
                        HStack(spacing: Spacing.sm) {
                            TextField("请输入验证码", text: $verifyCode)
                                .font(.bodyMedium)
                                .foregroundColor(.textPrimary)
                                .keyboardType(.numberPad)
                            
                            Button(action: sendVerifyCode) {
                                Text(countdown > 0 ? "\(countdown)s" : "获取验证码")
                                    .font(.buttonSmall)
                                    .foregroundStyle(
                                        countdown > 0 ? AnyShapeStyle(Color.textTertiary) : AnyShapeStyle(Color.primaryGradient)
                                    )
                            }
                            .disabled(countdown > 0 || phone.count != 11)
                        }
                        .padding(.horizontal, Spacing.md)
                        .frame(height: 50)
                        .background(Color.inputBackground)
                        .cornerRadius(CornerRadius.md)
                    }
                    .padding(.horizontal, Spacing.xl)
                    
                    // 登录按钮
                    Button(action: {
                        viewModel.loginWithPhone(phone: phone, code: verifyCode)
                    }) {
                        Text("登录")
                            .font(.buttonMedium)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .background(
                                (phone.count == 11 && verifyCode.count >= 4)
                                    ? AnyShapeStyle(Color.primaryGradient)
                                    : AnyShapeStyle(Color.textDisabled)
                            )
                            .cornerRadius(CornerRadius.md)
                    }
                    .disabled(phone.count != 11 || verifyCode.count < 4)
                    .padding(.horizontal, Spacing.xl)
                    
                    Spacer()
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark")
                            .foregroundColor(.textPrimary)
                    }
                }
            }
        }
        .onDisappear {
            timer?.invalidate()
        }
    }
    
    private func sendVerifyCode() {
        guard phone.count == 11 else { return }
        
        // 埋点
        AnalyticsManager.shared.trackAction(.clickGetVerifyCode, properties: [
            "phone": String(phone.prefix(3)) + "****" + String(phone.suffix(4))
        ])
        
        // 发送验证码
        Task {
            do {
                try await APIService.shared.sendVerifyCode(phone: phone)
                startCountdown()
            } catch {
                viewModel.errorMessage = (error as? APIError)?.userMessage ?? "发送失败"
                viewModel.showError = true
            }
        }
    }
    
    private func startCountdown() {
        countdown = 60
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            if countdown > 0 {
                countdown -= 1
            } else {
                timer?.invalidate()
            }
        }
    }
}

// MARK: - 登录ViewModel
@MainActor
class LoginViewModel: ObservableObject {
    
    @Published var isLoading = false
    @Published var showError = false
    @Published var errorMessage: String?
    @Published var showPhoneLogin = false
    @Published var isAgreed = false
    
    private let authService: AuthServiceProtocol
    
    init(authService: AuthServiceProtocol = AuthService.shared) {
        self.authService = authService
    }
    
    // MARK: - 微信登录
    func loginWithWechat() {
        guard isAgreed else {
            errorMessage = "请先同意用户协议"
            showError = true
            return
        }
        
        AnalyticsManager.shared.trackAction(.clickLoginWechat)
        
        isLoading = true
        
        Task {
            do {
                // 调用微信SDK获取code
                let code = try await WechatAuthManager.shared.requestAuth()
                
                // 使用code登录
                let response = try await authService.loginWithWechat(code: code)
                handleLoginSuccess(response)
                
                AnalyticsManager.shared.trackConversion(.loginSuccess, properties: [
                    "login_type": "wechat",
                    "is_new_user": "false"
                ])
            } catch {
                handleLoginError(error, type: "wechat")
            }
            
            isLoading = false
        }
    }
    
    // MARK: - Apple登录
    func handleAppleSignIn(result: Result<ASAuthorization, Error>) {
        guard isAgreed else {
            errorMessage = "请先同意用户协议"
            showError = true
            return
        }
        
        AnalyticsManager.shared.trackAction(.clickLoginApple)
        
        isLoading = true
        
        Task {
            do {
                switch result {
                case .success(let authorization):
                    guard let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential,
                          let identityToken = appleIDCredential.identityToken,
                          let identityTokenString = String(data: identityToken, encoding: .utf8),
                          let authorizationCode = appleIDCredential.authorizationCode,
                          let authorizationCodeString = String(data: authorizationCode, encoding: .utf8) else {
                        throw APIError(code: ErrorCode.appleAuthFailed.rawValue, message: "Apple auth failed", details: nil)
                    }
                    
                    let response = try await authService.loginWithApple(
                        identityToken: identityTokenString,
                        authorizationCode: authorizationCodeString
                    )
                    handleLoginSuccess(response)
                    
                    AnalyticsManager.shared.trackConversion(.loginSuccess, properties: [
                        "login_type": "apple",
                        "is_new_user": "false"
                    ])
                    
                case .failure(let error):
                    throw error
                }
            } catch {
                handleLoginError(error, type: "apple")
            }
            
            isLoading = false
        }
    }
    
    // MARK: - 手机号登录
    func loginWithPhone(phone: String, code: String) {
        guard isAgreed else {
            errorMessage = "请先同意用户协议"
            showError = true
            return
        }
        
        AnalyticsManager.shared.trackAction(.clickSubmitLogin, properties: [
            "login_type": "phone"
        ])
        
        isLoading = true
        
        Task {
            do {
                let response = try await authService.loginWithPhone(phone: phone, code: code)
                handleLoginSuccess(response)
                showPhoneLogin = false
                
                AnalyticsManager.shared.trackConversion(.loginSuccess, properties: [
                    "login_type": "phone",
                    "is_new_user": "false"
                ])
            } catch {
                handleLoginError(error, type: "phone")
            }
            
            isLoading = false
        }
    }
    
    // MARK: - 登录成功处理
    private func handleLoginSuccess(_ response: LoginResponse) {
        // 保存Token
        TokenManager.shared.saveTokens(from: response)
        
        // 保存用户信息
        UserManager.shared.currentUser = response.user
        
        // 设置埋点用户ID
        AnalyticsManager.shared.setUserId(response.user.id)
        
        // 发送登录成功通知
        NotificationCenter.default.post(name: .userDidLogin, object: nil)
    }
    
    // MARK: - 登录失败处理
    private func handleLoginError(_ error: Error, type: String) {
        if let apiError = error as? APIError {
            errorMessage = apiError.userMessage
        } else {
            errorMessage = "登录失败，请稍后重试"
        }
        showError = true
        
        AnalyticsManager.shared.trackConversion(.loginFail, properties: [
            "login_type": type,
            "error_code": (error as? APIError)?.code ?? -1
        ])
    }
}

// MARK: - 认证服务协议
protocol AuthServiceProtocol {
    func loginWithWechat(code: String) async throws -> LoginResponse
    func loginWithApple(identityToken: String, authorizationCode: String) async throws -> LoginResponse
    func loginWithPhone(phone: String, code: String) async throws -> LoginResponse
}

// MARK: - 认证服务实现
class AuthService: AuthServiceProtocol {
    static let shared = AuthService()
    
    private init() {}
    
    func loginWithWechat(code: String) async throws -> LoginResponse {
        return try await APIService.shared.loginWithWechat(code: code)
    }
    
    func loginWithApple(identityToken: String, authorizationCode: String) async throws -> LoginResponse {
        return try await APIService.shared.loginWithApple(identityToken: identityToken, authorizationCode: authorizationCode)
    }
    
    func loginWithPhone(phone: String, code: String) async throws -> LoginResponse {
        return try await APIService.shared.loginWithPhone(phone: phone, code: code)
    }
}

// MARK: - 用户管理器
class UserManager {
    static let shared = UserManager()
    
    private let userKey = "current_user"
    
    private init() {}
    
    var currentUser: User? {
        get {
            guard let data = UserDefaults.standard.data(forKey: userKey) else { return nil }
            return try? JSONDecoder().decode(User.self, from: data)
        }
        set {
            if let user = newValue {
                let data = try? JSONEncoder().encode(user)
                UserDefaults.standard.set(data, forKey: userKey)
            } else {
                UserDefaults.standard.removeObject(forKey: userKey)
            }
        }
    }
    
    var isLoggedIn: Bool {
        currentUser != nil && TokenManager.shared.isTokenValid
    }
    
    func logout() {
        currentUser = nil
        TokenManager.shared.clearTokens()
        AnalyticsManager.shared.setUserId(nil)
        NotificationCenter.default.post(name: .userDidLogout, object: nil)
    }
}

// MARK: - 通知名称扩展
extension Notification.Name {
    static let userDidLogin = Notification.Name("userDidLogin")
}

// MARK: - 预览
#Preview {
    LoginView()
        .preferredColorScheme(.dark)
}
