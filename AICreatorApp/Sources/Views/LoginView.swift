//
//  LoginView.swift
//  AICreatorApp
//
//  登录页 - 完全匹配原型图设计
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
            // 纯黑背景 - 匹配原型图 #0D0D0D
            Color(hex: "#0D0D0D")
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // 状态栏
                StatusBarView()
                
                // 作品展示网格 - 3x3彩色分类
                ZStack(alignment: .topLeading) {
                    LoginGalleryGridView()
                    
                    // 探索按钮 - 左上角
                    ExploreButton()
                        .padding(.top, 16)
                        .padding(.leading, 15)
                }
                
                // 登录区域
                LoginSectionView(viewModel: viewModel)
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

// MARK: - 状态栏视图
struct StatusBarView: View {
    var body: some View {
        HStack {
            Text("22:46")
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.white)
            
            Spacer()
            
            HStack(spacing: 5) {
                // 信号图标
                Image(systemName: "cellularbars")
                    .font(.system(size: 14))
                // WiFi图标
                Image(systemName: "wifi")
                    .font(.system(size: 14))
                // 电池图标
                BatteryIcon()
            }
            .foregroundColor(.white)
        }
        .padding(.horizontal, 20)
        .frame(height: 44)
    }
}

// MARK: - 电池图标
struct BatteryIcon: View {
    var body: some View {
        HStack(spacing: 1) {
            RoundedRectangle(cornerRadius: 2)
                .stroke(Color.white, lineWidth: 1)
                .frame(width: 22, height: 10)
                .overlay(
                    RoundedRectangle(cornerRadius: 1)
                        .fill(Color(hex: "#4ade80"))
                        .frame(width: 16, height: 6)
                        .padding(.leading, 2),
                    alignment: .leading
                )
            
            RoundedRectangle(cornerRadius: 1)
                .fill(Color.white)
                .frame(width: 2, height: 4)
        }
    }
}

// MARK: - 探索按钮
struct ExploreButton: View {
    var body: some View {
        Text("探索一下")
            .font(.system(size: 13))
            .foregroundColor(.white)
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(
                Color.white.opacity(0.15)
            )
            .background(.ultraThinMaterial)
            .cornerRadius(20)
    }
}

// MARK: - 作品展示网格 - 3x3彩色分类
struct LoginGalleryGridView: View {
    
    // 分类数据 - 匹配原型图
    private let categories: [(name: String, colors: [Color])] = [
        ("美食", [Color(hex: "#fef3c7"), Color(hex: "#fcd34d")]),
        ("时尚", [Color(hex: "#e0e7ff"), Color(hex: "#c7d2fe")]),  // large
        ("风景", [Color(hex: "#dcfce7"), Color(hex: "#86efac")]),
        ("人像", [Color(hex: "#fce7f3"), Color(hex: "#f9a8d4")]),
        ("动漫", [Color(hex: "#e0f2fe"), Color(hex: "#7dd3fc")]),
        ("萌宠", [Color(hex: "#fef9c3"), Color(hex: "#fde047")]),
        ("艺术", [Color(hex: "#f3e8ff"), Color(hex: "#d8b4fe")]),
        ("复古", [Color(hex: "#ffe4e6"), Color(hex: "#fda4af")])
    ]
    
    var body: some View {
        GeometryReader { geometry in
            let spacing: CGFloat = 8
            let padding: CGFloat = 10
            let availableWidth = geometry.size.width - padding * 2 - spacing * 2
            let itemWidth = availableWidth / 3
            let itemHeight = (380 - padding * 2 - spacing * 2) / 3
            
            ZStack {
                // 背景渐变
                LinearGradient(
                    colors: [Color(hex: "#1a1a1a"), Color(hex: "#0D0D0D")],
                    startPoint: .top,
                    endPoint: .bottom
                )
                
                VStack(spacing: spacing) {
                    // 第一行
                    HStack(spacing: spacing) {
                        // 美食
                        CategoryCell(name: categories[0].name, colors: categories[0].colors)
                            .frame(width: itemWidth, height: itemHeight)
                        
                        // 时尚 (large - 占2行)
                        CategoryCell(name: categories[1].name, colors: categories[1].colors)
                            .frame(width: itemWidth, height: itemHeight * 2 + spacing)
                        
                        // 风景
                        CategoryCell(name: categories[2].name, colors: categories[2].colors)
                            .frame(width: itemWidth, height: itemHeight)
                    }
                    
                    // 第二行
                    HStack(spacing: spacing) {
                        // 人像
                        CategoryCell(name: categories[3].name, colors: categories[3].colors)
                            .frame(width: itemWidth, height: itemHeight)
                        
                        // 动漫
                        CategoryCell(name: categories[4].name, colors: categories[4].colors)
                            .frame(width: itemWidth, height: itemHeight)
                    }
                    .padding(.leading, itemWidth + spacing) // 跳过时尚格子的位置
                    .frame(maxWidth: .infinity, alignment: .leading)
                    
                    // 第三行
                    HStack(spacing: spacing) {
                        // 萌宠
                        CategoryCell(name: categories[5].name, colors: categories[5].colors)
                            .frame(width: itemWidth, height: itemHeight)
                        
                        // 艺术
                        CategoryCell(name: categories[6].name, colors: categories[6].colors)
                            .frame(width: itemWidth, height: itemHeight)
                        
                        // 复古
                        CategoryCell(name: categories[7].name, colors: categories[7].colors)
                            .frame(width: itemWidth, height: itemHeight)
                    }
                }
                .padding(padding)
            }
        }
        .frame(height: 380)
    }
}

// MARK: - 分类格子
struct CategoryCell: View {
    let name: String
    let colors: [Color]
    
    var body: some View {
        ZStack {
            LinearGradient(
                colors: colors,
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            
            Text(name)
                .font(.system(size: 10))
                .foregroundColor(Color(hex: "#666666"))
        }
        .cornerRadius(12)
    }
}

// MARK: - 登录区域
struct LoginSectionView: View {
    @ObservedObject var viewModel: LoginViewModel
    
    var body: some View {
        VStack(spacing: 0) {
            // App名称
            Text("AI创图")
                .font(.system(size: 28, weight: .bold))
                .foregroundStyle(
                    LinearGradient(
                        colors: [.white, Color(hex: "#e0e0e0")],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .padding(.bottom, 8)
            
            // Slogan - 匹配原型图
            HStack(spacing: 0) {
                Text("释放你的")
                    .foregroundColor(.white)
                Text(""无限"")
                    .foregroundColor(Color(hex: "#a855f7"))
                Text("创意")
                    .foregroundColor(.white)
            }
            .font(.system(size: 18))
            .padding(.bottom, 30)
            
            // 登录按钮区域
            VStack(spacing: 15) {
                // 微信登录 - 紫粉渐变
                Button(action: {
                    viewModel.loginWithWechat()
                }) {
                    HStack(spacing: 10) {
                        WeChatIcon()
                            .frame(width: 22, height: 22)
                        Text("微信登录")
                            .font(.system(size: 16, weight: .medium))
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 52)
                    .background(
                        LinearGradient(
                            colors: [Color(hex: "#a855f7"), Color(hex: "#ec4899")],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .cornerRadius(30)
                }
                
                // 手机验证码登录 - 白色背景
                Button(action: {
                    viewModel.showPhoneLogin = true
                }) {
                    HStack(spacing: 10) {
                        PhoneIcon()
                            .frame(width: 20, height: 20)
                        Text("手机验证码登录")
                            .font(.system(size: 16, weight: .medium))
                    }
                    .foregroundColor(Color(hex: "#333333"))
                    .frame(maxWidth: .infinity)
                    .frame(height: 52)
                    .background(Color.white)
                    .cornerRadius(30)
                }
                
                // Apple登录 - 白色背景
                Button(action: {
                    viewModel.loginWithApple()
                }) {
                    HStack(spacing: 10) {
                        AppleIcon()
                            .frame(width: 20, height: 20)
                        Text("Apple 账号登录")
                            .font(.system(size: 16, weight: .medium))
                    }
                    .foregroundColor(Color(hex: "#333333"))
                    .frame(maxWidth: .infinity)
                    .frame(height: 52)
                    .background(Color.white)
                    .cornerRadius(30)
                }
            }
            .padding(.horizontal, 25)
            .padding(.bottom, 20)
            
            // 用户协议
            AgreementView(isAgreed: $viewModel.isAgreed)
                .padding(.bottom, 30)
        }
        .padding(.top, 30)
    }
}

// MARK: - 微信图标
struct WeChatIcon: View {
    var body: some View {
        Image(systemName: "message.fill")
            .resizable()
            .aspectRatio(contentMode: .fit)
            .foregroundColor(.white)
    }
}

// MARK: - 手机图标
struct PhoneIcon: View {
    var body: some View {
        Image(systemName: "iphone")
            .resizable()
            .aspectRatio(contentMode: .fit)
            .foregroundColor(Color(hex: "#333333"))
    }
}

// MARK: - Apple图标
struct AppleIcon: View {
    var body: some View {
        Image(systemName: "apple.logo")
            .resizable()
            .aspectRatio(contentMode: .fit)
            .foregroundColor(Color(hex: "#333333"))
    }
}

// MARK: - 用户协议视图
struct AgreementView: View {
    @Binding var isAgreed: Bool
    
    var body: some View {
        HStack(spacing: 8) {
            // 圆形checkbox
            Button(action: {
                isAgreed.toggle()
            }) {
                Circle()
                    .stroke(isAgreed ? Color(hex: "#a855f7") : Color(hex: "#444444"), lineWidth: 2)
                    .frame(width: 18, height: 18)
                    .overlay(
                        Circle()
                            .fill(isAgreed ? Color(hex: "#a855f7") : Color.clear)
                            .frame(width: 10, height: 10)
                    )
            }
            
            HStack(spacing: 0) {
                Text("我已阅读并接受 ")
                    .foregroundColor(Color(hex: "#888888"))
                
                Button(action: {
                    // 打开用户协议
                }) {
                    Text("用户协议")
                        .foregroundColor(Color(hex: "#a855f7"))
                }
                
                Text(" 和 ")
                    .foregroundColor(Color(hex: "#888888"))
                
                Button(action: {
                    // 打开隐私政策
                }) {
                    Text("隐私政策")
                        .foregroundColor(Color(hex: "#a855f7"))
                }
            }
            .font(.system(size: 12))
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
                // 背景
                Color(hex: "#0D0D0D")
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // 状态栏
                    StatusBarView()
                    
                    // 返回按钮
                    HStack {
                        Button(action: {
                            dismiss()
                        }) {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 20, weight: .medium))
                                .foregroundColor(.white)
                                .frame(width: 44, height: 44)
                        }
                        Spacer()
                    }
                    .padding(.horizontal, 10)
                    
                    Spacer()
                        .frame(height: 40)
                    
                    // 标题
                    VStack(spacing: 8) {
                        Text("登录后体验完整功能")
                            .font(.system(size: 22, weight: .bold))
                            .foregroundColor(.white)
                        
                        Text("使用手机号登录")
                            .font(.system(size: 14))
                            .foregroundColor(Color(hex: "#888888"))
                    }
                    .padding(.bottom, 40)
                    
                    // 手机号输入
                    VStack(spacing: 20) {
                        HStack {
                            TextField("", text: $phone)
                                .placeholder(when: phone.isEmpty) {
                                    Text("18638933359")
                                        .foregroundColor(Color(hex: "#666666"))
                                }
                                .font(.system(size: 18))
                                .foregroundColor(.white)
                                .keyboardType(.phonePad)
                            
                            Text("11/11")
                                .font(.system(size: 14))
                                .foregroundColor(Color(hex: "#666666"))
                        }
                        .padding(.horizontal, 20)
                        .padding(.vertical, 16)
                        .background(Color(hex: "#1a1a1a"))
                        .cornerRadius(12)
                        
                        // 获取验证码按钮
                        Button(action: {
                            startCountdown()
                            viewModel.sendVerifyCode(phone: phone)
                        }) {
                            Text(countdown > 0 ? "\(countdown)s后重新获取" : "获取验证码")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .frame(height: 52)
                                .background(
                                    LinearGradient(
                                        colors: [Color(hex: "#a855f7"), Color(hex: "#ec4899")],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .cornerRadius(30)
                        }
                        .disabled(countdown > 0 || phone.count < 11)
                        .opacity(countdown > 0 || phone.count < 11 ? 0.6 : 1)
                    }
                    .padding(.horizontal, 25)
                    
                    Spacer()
                    
                    // 数字键盘
                    NumericKeypad(text: $phone)
                        .padding(.bottom, 20)
                }
            }
            .navigationBarHidden(true)
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

// MARK: - 数字键盘
struct NumericKeypad: View {
    @Binding var text: String
    
    private let keys = [
        ["1", "2", "3"],
        ["4", "5", "6"],
        ["7", "8", "9"],
        ["+*#", "0", "⌫"]
    ]
    
    private let subLabels = [
        ["", "ABC", "DEF"],
        ["GHI", "JKL", "MNO"],
        ["PQRS", "TUV", "WXYZ"],
        ["", "", ""]
    ]
    
    var body: some View {
        VStack(spacing: 8) {
            ForEach(0..<4, id: \.self) { row in
                HStack(spacing: 8) {
                    ForEach(0..<3, id: \.self) { col in
                        let key = keys[row][col]
                        let subLabel = subLabels[row][col]
                        
                        Button(action: {
                            handleKeyPress(key)
                        }) {
                            VStack(spacing: 2) {
                                Text(key)
                                    .font(.system(size: 24, weight: .medium))
                                    .foregroundColor(.black)
                                
                                if !subLabel.isEmpty {
                                    Text(subLabel)
                                        .font(.system(size: 10))
                                        .foregroundColor(Color(hex: "#666666"))
                                }
                            }
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .background(Color(hex: "#d1d5db"))
                            .cornerRadius(8)
                        }
                    }
                }
            }
        }
        .padding(.horizontal, 4)
        .background(Color(hex: "#c7c7c7"))
    }
    
    private func handleKeyPress(_ key: String) {
        if key == "⌫" {
            if !text.isEmpty {
                text.removeLast()
            }
        } else if key != "+*#" {
            if text.count < 11 {
                text.append(key)
            }
        }
    }
}

// MARK: - Placeholder扩展
extension View {
    func placeholder<Content: View>(
        when shouldShow: Bool,
        alignment: Alignment = .leading,
        @ViewBuilder placeholder: () -> Content
    ) -> some View {
        ZStack(alignment: alignment) {
            placeholder().opacity(shouldShow ? 1 : 0)
            self
        }
    }
}

// MARK: - 加载遮罩
struct LoadingOverlay: View {
    var body: some View {
        ZStack {
            Color.black.opacity(0.5)
                .ignoresSafeArea()
            
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                .scaleEffect(1.5)
        }
    }
}

// MARK: - 登录ViewModel
class LoginViewModel: ObservableObject {
    @Published var isLoading = false
    @Published var showError = false
    @Published var errorMessage: String?
    @Published var showPhoneLogin = false
    @Published var isAgreed = false
    
    func loginWithWechat() {
        guard isAgreed else {
            showError = true
            errorMessage = "请先同意用户协议和隐私政策"
            return
        }
        
        isLoading = true
        // 调用微信SDK登录
        WeChatManager.shared.login { [weak self] result in
            DispatchQueue.main.async {
                self?.isLoading = false
                switch result {
                case .success(let token):
                    // 登录成功，保存token
                    TokenManager.shared.saveToken(token)
                    AnalyticsManager.shared.trackEvent(.login, properties: ["method": "wechat"])
                case .failure(let error):
                    self?.showError = true
                    self?.errorMessage = error.localizedDescription
                }
            }
        }
    }
    
    func loginWithApple() {
        guard isAgreed else {
            showError = true
            errorMessage = "请先同意用户协议和隐私政策"
            return
        }
        
        // Apple登录逻辑
        AnalyticsManager.shared.trackEvent(.login, properties: ["method": "apple"])
    }
    
    func handleAppleSignIn(result: Result<ASAuthorization, Error>) {
        switch result {
        case .success(let authorization):
            if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
                let userIdentifier = appleIDCredential.user
                let fullName = appleIDCredential.fullName
                let email = appleIDCredential.email
                
                // 发送到后端验证
                isLoading = true
                APIService.shared.loginWithApple(
                    userIdentifier: userIdentifier,
                    fullName: fullName,
                    email: email
                ) { [weak self] result in
                    DispatchQueue.main.async {
                        self?.isLoading = false
                        switch result {
                        case .success(let response):
                            TokenManager.shared.saveToken(response.token)
                        case .failure(let error):
                            self?.showError = true
                            self?.errorMessage = error.localizedDescription
                        }
                    }
                }
            }
        case .failure(let error):
            showError = true
            errorMessage = error.localizedDescription
        }
    }
    
    func sendVerifyCode(phone: String) {
        isLoading = true
        APIService.shared.sendVerifyCode(phone: phone) { [weak self] result in
            DispatchQueue.main.async {
                self?.isLoading = false
                switch result {
                case .success:
                    // 验证码发送成功
                    break
                case .failure(let error):
                    self?.showError = true
                    self?.errorMessage = error.localizedDescription
                }
            }
        }
    }
    
    func loginWithPhone(phone: String, code: String) {
        guard isAgreed else {
            showError = true
            errorMessage = "请先同意用户协议和隐私政策"
            return
        }
        
        isLoading = true
        APIService.shared.loginWithPhone(phone: phone, code: code) { [weak self] result in
            DispatchQueue.main.async {
                self?.isLoading = false
                switch result {
                case .success(let response):
                    TokenManager.shared.saveToken(response.token)
                    AnalyticsManager.shared.trackEvent(.login, properties: ["method": "phone"])
                case .failure(let error):
                    self?.showError = true
                    self?.errorMessage = error.localizedDescription
                }
            }
        }
    }
}

// MARK: - Color扩展
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

// MARK: - 预览
#Preview {
    LoginView()
}
