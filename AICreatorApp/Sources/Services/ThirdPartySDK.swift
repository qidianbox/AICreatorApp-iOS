//
//  ThirdPartySDK.swift
//  AICreatorApp
//
//  第三方SDK集成 - 微信登录、Apple登录、支付SDK
//  基于设计规范文档 v3.0
//
//  Created by Manus AI on 2026/1/19.
//

import SwiftUI
import AuthenticationServices
import StoreKit
import CryptoKit

// MARK: - ========== 微信SDK集成 ==========

/// 微信SDK配置
struct WeChatConfig {
    static let appId = "wx1234567890abcdef"  // 替换为实际的微信AppID
    static let appSecret = "your_app_secret"  // 替换为实际的AppSecret（建议放服务端）
    static let universalLink = "https://your-domain.com/app/"  // 替换为实际的Universal Link
}

/// 微信SDK管理器
@MainActor
class WeChatManager: ObservableObject {
    
    static let shared = WeChatManager()
    
    @Published var isWeChatInstalled = false
    @Published var isAuthorizing = false
    
    private var authCompletion: ((Result<WeChatAuthResult, WeChatError>) -> Void)?
    
    private init() {
        checkWeChatInstalled()
    }
    
    // MARK: - 检查微信是否安装
    func checkWeChatInstalled() {
        // 实际项目中使用: WXApi.isWXAppInstalled()
        #if DEBUG
        isWeChatInstalled = true
        #else
        if let url = URL(string: "weixin://") {
            isWeChatInstalled = UIApplication.shared.canOpenURL(url)
        }
        #endif
    }
    
    // MARK: - 注册微信SDK
    func registerApp() {
        // 实际项目中使用:
        // WXApi.registerApp(WeChatConfig.appId, universalLink: WeChatConfig.universalLink)
        
        #if DEBUG
        print("[WeChat] SDK registered with appId: \(WeChatConfig.appId)")
        #endif
    }
    
    // MARK: - 微信登录
    func login(completion: @escaping (Result<WeChatAuthResult, WeChatError>) -> Void) {
        guard isWeChatInstalled else {
            completion(.failure(.notInstalled))
            return
        }
        
        isAuthorizing = true
        authCompletion = completion
        
        // 实际项目中使用:
        // let req = SendAuthReq()
        // req.scope = "snsapi_userinfo"
        // req.state = UUID().uuidString
        // WXApi.send(req)
        
        #if DEBUG
        // 模拟微信授权
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { [weak self] in
            self?.isAuthorizing = false
            let mockResult = WeChatAuthResult(
                code: "mock_auth_code_\(UUID().uuidString.prefix(8))",
                state: "mock_state"
            )
            completion(.success(mockResult))
        }
        #endif
        
        AnalyticsManager.shared.trackAction(.clickWechatLogin)
    }
    
    // MARK: - 处理微信回调
    func handleOpenURL(_ url: URL) -> Bool {
        // 实际项目中使用:
        // return WXApi.handleOpen(url, delegate: self)
        
        #if DEBUG
        print("[WeChat] Handle URL: \(url)")
        #endif
        return true
    }
    
    // MARK: - 微信分享
    func shareToWechat(type: WeChatShareType, content: WeChatShareContent) {
        guard isWeChatInstalled else {
            ErrorHandler.shared.showErrorToast("请先安装微信")
            return
        }
        
        // 实际项目中使用:
        // let req = SendMessageToWXReq()
        // req.scene = type == .session ? Int32(WXSceneSession.rawValue) : Int32(WXSceneTimeline.rawValue)
        // ...
        
        #if DEBUG
        print("[WeChat] Share to \(type): \(content)")
        #endif
        
        AnalyticsManager.shared.trackAction(.clickShare, properties: [
            "share_type": type.rawValue,
            "content_type": content.type.rawValue
        ])
    }
}

// MARK: - 微信授权结果
struct WeChatAuthResult {
    let code: String
    let state: String
}

// MARK: - 微信错误
enum WeChatError: Error, LocalizedError {
    case notInstalled
    case authDenied
    case authCancelled
    case networkError
    case unknown(String)
    
    var errorDescription: String? {
        switch self {
        case .notInstalled:
            return "请先安装微信"
        case .authDenied:
            return "授权被拒绝"
        case .authCancelled:
            return "授权已取消"
        case .networkError:
            return "网络错误，请重试"
        case .unknown(let message):
            return message
        }
    }
}

// MARK: - 微信分享类型
enum WeChatShareType: String {
    case session = "session"      // 好友
    case timeline = "timeline"    // 朋友圈
}

// MARK: - 微信分享内容
struct WeChatShareContent {
    enum ContentType: String {
        case text = "text"
        case image = "image"
        case webPage = "webpage"
        case miniProgram = "miniprogram"
    }
    
    let type: ContentType
    let title: String?
    let description: String?
    let thumbImage: UIImage?
    let url: String?
    let imageData: Data?
}


// MARK: - ========== Apple登录集成 ==========

/// Apple登录管理器
@MainActor
class AppleSignInManager: NSObject, ObservableObject {
    
    static let shared = AppleSignInManager()
    
    @Published var isAuthorizing = false
    
    private var authCompletion: ((Result<AppleAuthResult, AppleSignInError>) -> Void)?
    
    private override init() {
        super.init()
    }
    
    // MARK: - Apple登录
    func signIn(completion: @escaping (Result<AppleAuthResult, AppleSignInError>) -> Void) {
        isAuthorizing = true
        authCompletion = completion
        
        let provider = ASAuthorizationAppleIDProvider()
        let request = provider.createRequest()
        request.requestedScopes = [.fullName, .email]
        
        let controller = ASAuthorizationController(authorizationRequests: [request])
        controller.delegate = self
        controller.presentationContextProvider = self
        controller.performRequests()
        
        AnalyticsManager.shared.trackAction(.clickAppleLogin)
    }
    
    // MARK: - 检查授权状态
    func checkCredentialState(userId: String, completion: @escaping (ASAuthorizationAppleIDProvider.CredentialState) -> Void) {
        let provider = ASAuthorizationAppleIDProvider()
        provider.getCredentialState(forUserID: userId) { state, error in
            DispatchQueue.main.async {
                completion(state)
            }
        }
    }
}

// MARK: - ASAuthorizationControllerDelegate
extension AppleSignInManager: ASAuthorizationControllerDelegate {
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        isAuthorizing = false
        
        guard let credential = authorization.credential as? ASAuthorizationAppleIDCredential else {
            authCompletion?(.failure(.invalidCredential))
            return
        }
        
        let result = AppleAuthResult(
            userId: credential.user,
            email: credential.email,
            fullName: credential.fullName,
            identityToken: credential.identityToken,
            authorizationCode: credential.authorizationCode
        )
        
        authCompletion?(.success(result))
        
        #if DEBUG
        print("[Apple] Sign in success: \(result.userId)")
        #endif
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        isAuthorizing = false
        
        let authError = error as? ASAuthorizationError
        
        switch authError?.code {
        case .canceled:
            authCompletion?(.failure(.cancelled))
        case .failed:
            authCompletion?(.failure(.failed))
        case .invalidResponse:
            authCompletion?(.failure(.invalidResponse))
        case .notHandled:
            authCompletion?(.failure(.notHandled))
        default:
            authCompletion?(.failure(.unknown(error.localizedDescription)))
        }
        
        #if DEBUG
        print("[Apple] Sign in error: \(error.localizedDescription)")
        #endif
    }
}

// MARK: - ASAuthorizationControllerPresentationContextProviding
extension AppleSignInManager: ASAuthorizationControllerPresentationContextProviding {
    
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first else {
            return UIWindow()
        }
        return window
    }
}

// MARK: - Apple授权结果
struct AppleAuthResult {
    let userId: String
    let email: String?
    let fullName: PersonNameComponents?
    let identityToken: Data?
    let authorizationCode: Data?
    
    var identityTokenString: String? {
        guard let token = identityToken else { return nil }
        return String(data: token, encoding: .utf8)
    }
    
    var authorizationCodeString: String? {
        guard let code = authorizationCode else { return nil }
        return String(data: code, encoding: .utf8)
    }
    
    var displayName: String {
        if let fullName = fullName {
            return [fullName.givenName, fullName.familyName]
                .compactMap { $0 }
                .joined(separator: " ")
        }
        return ""
    }
}

// MARK: - Apple登录错误
enum AppleSignInError: Error, LocalizedError {
    case cancelled
    case failed
    case invalidResponse
    case notHandled
    case invalidCredential
    case unknown(String)
    
    var errorDescription: String? {
        switch self {
        case .cancelled:
            return "登录已取消"
        case .failed:
            return "登录失败"
        case .invalidResponse:
            return "无效响应"
        case .notHandled:
            return "请求未处理"
        case .invalidCredential:
            return "无效凭证"
        case .unknown(let message):
            return message
        }
    }
}

// MARK: - Apple登录按钮
struct AppleSignInButton: View {
    
    let onComplete: (Result<AppleAuthResult, AppleSignInError>) -> Void
    
    var body: some View {
        SignInWithAppleButton(.signIn) { request in
            request.requestedScopes = [.fullName, .email]
        } onCompletion: { result in
            switch result {
            case .success(let authorization):
                guard let credential = authorization.credential as? ASAuthorizationAppleIDCredential else {
                    onComplete(.failure(.invalidCredential))
                    return
                }
                
                let authResult = AppleAuthResult(
                    userId: credential.user,
                    email: credential.email,
                    fullName: credential.fullName,
                    identityToken: credential.identityToken,
                    authorizationCode: credential.authorizationCode
                )
                onComplete(.success(authResult))
                
            case .failure(let error):
                let authError = error as? ASAuthorizationError
                switch authError?.code {
                case .canceled:
                    onComplete(.failure(.cancelled))
                default:
                    onComplete(.failure(.unknown(error.localizedDescription)))
                }
            }
        }
        .signInWithAppleButtonStyle(.white)
        .frame(height: 50)
        .cornerRadius(CornerRadius.md)
    }
}


// MARK: - ========== 支付SDK集成 ==========

/// 支付管理器
@MainActor
class PaymentManager: NSObject, ObservableObject {
    
    static let shared = PaymentManager()
    
    @Published var products: [Product] = []
    @Published var purchasedProductIDs: Set<String> = []
    @Published var isLoading = false
    @Published var isPurchasing = false
    
    private var updateListenerTask: Task<Void, Error>?
    
    private override init() {
        super.init()
        startTransactionListener()
    }
    
    deinit {
        updateListenerTask?.cancel()
    }
    
    // MARK: - 产品ID
    struct ProductID {
        // 会员订阅
        static let weeklyMembership = "com.aicreator.membership.weekly"
        static let monthlyMembership = "com.aicreator.membership.monthly"
        static let quarterlyMembership = "com.aicreator.membership.quarterly"
        static let yearlyMembership = "com.aicreator.membership.yearly"
        
        // 积分包
        static let points100 = "com.aicreator.points.100"
        static let points500 = "com.aicreator.points.500"
        static let points1000 = "com.aicreator.points.1000"
        static let points5000 = "com.aicreator.points.5000"
        
        static var allMemberships: [String] {
            [weeklyMembership, monthlyMembership, quarterlyMembership, yearlyMembership]
        }
        
        static var allPoints: [String] {
            [points100, points500, points1000, points5000]
        }
        
        static var all: [String] {
            allMemberships + allPoints
        }
    }
    
    // MARK: - 加载产品
    func loadProducts() async {
        isLoading = true
        
        do {
            products = try await Product.products(for: ProductID.all)
            
            #if DEBUG
            print("[Payment] Loaded \(products.count) products")
            for product in products {
                print("  - \(product.id): \(product.displayPrice)")
            }
            #endif
        } catch {
            #if DEBUG
            print("[Payment] Failed to load products: \(error)")
            #endif
        }
        
        isLoading = false
    }
    
    // MARK: - 购买产品
    func purchase(_ product: Product) async throws -> Transaction? {
        isPurchasing = true
        
        defer {
            isPurchasing = false
        }
        
        AnalyticsManager.shared.trackAction(.clickPurchase, properties: [
            "product_id": product.id,
            "price": product.price.description
        ])
        
        let result = try await product.purchase()
        
        switch result {
        case .success(let verification):
            let transaction = try checkVerified(verification)
            
            // 更新购买状态
            await updatePurchasedProducts()
            
            // 完成交易
            await transaction.finish()
            
            // 上报服务端
            await reportPurchaseToServer(transaction: transaction, product: product)
            
            AnalyticsManager.shared.trackConversion(.purchaseSuccess, properties: [
                "product_id": product.id,
                "transaction_id": String(transaction.id)
            ])
            
            #if DEBUG
            print("[Payment] Purchase success: \(product.id)")
            #endif
            
            return transaction
            
        case .userCancelled:
            #if DEBUG
            print("[Payment] User cancelled")
            #endif
            return nil
            
        case .pending:
            #if DEBUG
            print("[Payment] Purchase pending")
            #endif
            return nil
            
        @unknown default:
            return nil
        }
    }
    
    // MARK: - 恢复购买
    func restorePurchases() async {
        isLoading = true
        
        do {
            try await AppStore.sync()
            await updatePurchasedProducts()
            
            ErrorHandler.shared.showSuccessToast("恢复购买成功")
            
            #if DEBUG
            print("[Payment] Restore purchases success")
            #endif
        } catch {
            ErrorHandler.shared.showErrorToast("恢复购买失败")
            
            #if DEBUG
            print("[Payment] Restore purchases failed: \(error)")
            #endif
        }
        
        isLoading = false
    }
    
    // MARK: - 检查订阅状态
    func checkSubscriptionStatus() async -> SubscriptionStatus {
        for await result in Transaction.currentEntitlements {
            guard case .verified(let transaction) = result else { continue }
            
            if ProductID.allMemberships.contains(transaction.productID) {
                if let expirationDate = transaction.expirationDate {
                    if expirationDate > Date() {
                        return SubscriptionStatus(
                            isActive: true,
                            productId: transaction.productID,
                            expirationDate: expirationDate
                        )
                    }
                }
            }
        }
        
        return SubscriptionStatus(isActive: false, productId: nil, expirationDate: nil)
    }
    
    // MARK: - 私有方法
    private func startTransactionListener() {
        updateListenerTask = Task.detached {
            for await result in Transaction.updates {
                do {
                    let transaction = try self.checkVerified(result)
                    await self.updatePurchasedProducts()
                    await transaction.finish()
                } catch {
                    #if DEBUG
                    print("[Payment] Transaction verification failed: \(error)")
                    #endif
                }
            }
        }
    }
    
    private func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
        switch result {
        case .unverified:
            throw PaymentError.verificationFailed
        case .verified(let safe):
            return safe
        }
    }
    
    private func updatePurchasedProducts() async {
        var purchased: Set<String> = []
        
        for await result in Transaction.currentEntitlements {
            guard case .verified(let transaction) = result else { continue }
            purchased.insert(transaction.productID)
        }
        
        await MainActor.run {
            self.purchasedProductIDs = purchased
        }
    }
    
    private func reportPurchaseToServer(transaction: Transaction, product: Product) async {
        // 上报购买信息到服务端验证
        do {
            let receipt = try await getAppStoreReceipt()
            
            _ = try await APIService.shared.verifyPurchase(
                productId: product.id,
                transactionId: String(transaction.id),
                receipt: receipt
            )
            
            #if DEBUG
            print("[Payment] Purchase reported to server")
            #endif
        } catch {
            #if DEBUG
            print("[Payment] Failed to report purchase: \(error)")
            #endif
        }
    }
    
    private func getAppStoreReceipt() async throws -> String {
        guard let receiptURL = Bundle.main.appStoreReceiptURL,
              FileManager.default.fileExists(atPath: receiptURL.path) else {
            throw PaymentError.receiptNotFound
        }
        
        let receiptData = try Data(contentsOf: receiptURL)
        return receiptData.base64EncodedString()
    }
}

// MARK: - 订阅状态
struct SubscriptionStatus {
    let isActive: Bool
    let productId: String?
    let expirationDate: Date?
    
    var formattedExpirationDate: String {
        guard let date = expirationDate else { return "" }
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: date)
    }
}

// MARK: - 支付错误
enum PaymentError: Error, LocalizedError {
    case verificationFailed
    case receiptNotFound
    case serverError
    case unknown(String)
    
    var errorDescription: String? {
        switch self {
        case .verificationFailed:
            return "购买验证失败"
        case .receiptNotFound:
            return "收据未找到"
        case .serverError:
            return "服务器错误"
        case .unknown(let message):
            return message
        }
    }
}


// MARK: - ========== 用户管理器 ==========

/// 用户管理器
@MainActor
class UserManager: ObservableObject {
    
    static let shared = UserManager()
    
    @Published var currentUser: User?
    @Published var isLoggedIn = false
    
    private let userDefaultsKey = "current_user"
    private let tokenKey = "auth_token"
    
    private init() {
        loadCachedUser()
    }
    
    // MARK: - 微信登录
    func loginWithWeChat() async throws {
        return try await withCheckedThrowingContinuation { continuation in
            WeChatManager.shared.login { result in
                switch result {
                case .success(let authResult):
                    Task {
                        do {
                            // 使用code换取用户信息
                            let response = try await APIService.shared.loginWithWeChat(code: authResult.code)
                            
                            await MainActor.run {
                                self.handleLoginSuccess(user: response.user, token: response.token)
                            }
                            
                            continuation.resume()
                        } catch {
                            continuation.resume(throwing: error)
                        }
                    }
                case .failure(let error):
                    continuation.resume(throwing: error)
                }
            }
        }
    }
    
    // MARK: - Apple登录
    func loginWithApple() async throws {
        return try await withCheckedThrowingContinuation { continuation in
            AppleSignInManager.shared.signIn { result in
                switch result {
                case .success(let authResult):
                    Task {
                        do {
                            guard let identityToken = authResult.identityTokenString else {
                                throw AppleSignInError.invalidCredential
                            }
                            
                            let response = try await APIService.shared.loginWithApple(
                                identityToken: identityToken,
                                authorizationCode: authResult.authorizationCodeString ?? ""
                            )
                            
                            await MainActor.run {
                                self.handleLoginSuccess(user: response.user, token: response.token)
                            }
                            
                            continuation.resume()
                        } catch {
                            continuation.resume(throwing: error)
                        }
                    }
                case .failure(let error):
                    continuation.resume(throwing: error)
                }
            }
        }
    }
    
    // MARK: - 手机号登录
    func loginWithPhone(phone: String, code: String) async throws {
        let response = try await APIService.shared.loginWithPhone(phone: phone, code: code)
        handleLoginSuccess(user: response.user, token: response.token)
    }
    
    // MARK: - 发送验证码
    func sendVerificationCode(phone: String) async throws {
        try await APIService.shared.sendVerificationCode(phone: phone)
    }
    
    // MARK: - 登出
    func logout() {
        currentUser = nil
        isLoggedIn = false
        
        // 清除缓存
        UserDefaults.standard.removeObject(forKey: userDefaultsKey)
        TokenManager.shared.clearToken()
        
        // 发送通知
        NotificationCenter.default.post(name: .userDidLogout, object: nil)
        
        AnalyticsManager.shared.trackAction(.clickLogout)
        
        #if DEBUG
        print("[User] Logged out")
        #endif
    }
    
    // MARK: - 刷新用户信息
    func refreshUserInfo() async {
        do {
            currentUser = try await APIService.shared.getCurrentUser()
            cacheUser()
        } catch {
            #if DEBUG
            print("[User] Failed to refresh user info: \(error)")
            #endif
        }
    }
    
    // MARK: - 私有方法
    private func handleLoginSuccess(user: User, token: String) {
        currentUser = user
        isLoggedIn = true
        
        // 保存Token
        TokenManager.shared.saveToken(token)
        
        // 缓存用户信息
        cacheUser()
        
        // 发送通知
        NotificationCenter.default.post(name: .userDidLogin, object: nil)
        
        AnalyticsManager.shared.trackConversion(.loginSuccess, properties: [
            "user_id": user.id
        ])
        
        #if DEBUG
        print("[User] Login success: \(user.nickname)")
        #endif
    }
    
    private func cacheUser() {
        guard let user = currentUser else { return }
        
        if let encoded = try? JSONEncoder().encode(user) {
            UserDefaults.standard.set(encoded, forKey: userDefaultsKey)
        }
    }
    
    private func loadCachedUser() {
        guard let data = UserDefaults.standard.data(forKey: userDefaultsKey),
              let user = try? JSONDecoder().decode(User.self, from: data) else {
            return
        }
        
        currentUser = user
        isLoggedIn = TokenManager.shared.hasValidToken
        
        #if DEBUG
        print("[User] Loaded cached user: \(user.nickname)")
        #endif
    }
}


// MARK: - ========== 通知名称扩展 ==========

extension Notification.Name {
    static let navigateToLogin = Notification.Name("navigateToLogin")
    static let navigateToMembership = Notification.Name("navigateToMembership")
    static let navigateToRecharge = Notification.Name("navigateToRecharge")
    static let navigateToResult = Notification.Name("navigateToResult")
    static let userDidLogin = Notification.Name("userDidLogin")
    static let userDidLogout = Notification.Name("userDidLogout")
}


// MARK: - ========== API扩展 ==========

extension APIService {
    
    // MARK: - 微信登录
    func loginWithWeChat(code: String) async throws -> LoginResponse {
        let body: [String: Any] = [
            "code": code,
            "platform": "wechat"
        ]
        
        return try await request(
            endpoint: "/auth/wechat",
            method: "POST",
            body: body
        )
    }
    
    // MARK: - Apple登录
    func loginWithApple(identityToken: String, authorizationCode: String) async throws -> LoginResponse {
        let body: [String: Any] = [
            "identity_token": identityToken,
            "authorization_code": authorizationCode,
            "platform": "apple"
        ]
        
        return try await request(
            endpoint: "/auth/apple",
            method: "POST",
            body: body
        )
    }
    
    // MARK: - 手机号登录
    func loginWithPhone(phone: String, code: String) async throws -> LoginResponse {
        let body: [String: Any] = [
            "phone": phone,
            "code": code
        ]
        
        return try await request(
            endpoint: "/auth/phone",
            method: "POST",
            body: body
        )
    }
    
    // MARK: - 发送验证码
    func sendVerificationCode(phone: String) async throws {
        let body: [String: Any] = [
            "phone": phone
        ]
        
        let _: EmptyResponse = try await request(
            endpoint: "/auth/send-code",
            method: "POST",
            body: body
        )
    }
    
    // MARK: - 验证购买
    func verifyPurchase(productId: String, transactionId: String, receipt: String) async throws -> VerifyPurchaseResponse {
        let body: [String: Any] = [
            "product_id": productId,
            "transaction_id": transactionId,
            "receipt": receipt,
            "platform": "ios"
        ]
        
        return try await request(
            endpoint: "/payment/verify",
            method: "POST",
            body: body
        )
    }
}

// MARK: - 登录响应
struct LoginResponse: Codable {
    let user: User
    let token: String
}

// MARK: - 空响应
struct EmptyResponse: Codable {}

// MARK: - 验证购买响应
struct VerifyPurchaseResponse: Codable {
    let success: Bool
    let message: String?
    let points: Int?
    let membership: Membership?
}


// MARK: - ========== 预览 ==========

#Preview("Apple Sign In Button") {
    AppleSignInButton { result in
        switch result {
        case .success(let auth):
            print("Success: \(auth.userId)")
        case .failure(let error):
            print("Error: \(error)")
        }
    }
    .padding()
    .preferredColorScheme(.dark)
}
