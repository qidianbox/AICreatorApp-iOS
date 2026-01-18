//
//  Analytics.swift
//  AICreatorApp
//
//  埋点和错误处理服务
//  基于设计规范文档 v3.0
//
//  Created by Manus AI on 2026/1/19.
//

import Foundation
import SwiftUI

// MARK: - 页面埋点枚举
enum PageEvent: String {
    case splash = "page_splash"
    case login = "page_login"
    case home = "page_home"
    case create = "page_create"
    case templateSelect = "page_template_select"
    case upload = "page_upload"
    case generating = "page_generating"
    case result = "page_result"
    case detail = "page_detail"
    case profile = "page_profile"
    case membership = "page_membership"
    case recharge = "page_recharge"
    case settings = "page_settings"
    
    var pageId: String { rawValue }
}

// MARK: - 用户行为事件枚举
enum UserActionEvent: String {
    // 登录相关
    case clickLoginWechat = "click_login_wechat"
    case clickLoginApple = "click_login_apple"
    case clickLoginPhone = "click_login_phone"
    case clickGetVerifyCode = "click_get_verify_code"
    case clickSubmitLogin = "click_submit_login"
    
    // 浏览相关
    case clickCategoryTab = "click_category_tab"
    case clickWorkCard = "click_work_card"
    case clickTemplateCard = "click_template_card"
    case clickBanner = "click_banner"
    case scrollWorkList = "scroll_work_list"
    case pullRefresh = "pull_refresh"
    
    // 创作相关
    case clickUploadImage = "click_upload_image"
    case clickStartGenerate = "click_start_generate"
    case clickCancelGenerate = "click_cancel_generate"
    case clickFollowGenerate = "click_follow_generate"
    
    // 互动相关
    case clickSaveImage = "click_save_image"
    case clickShare = "click_share"
    case clickLike = "click_like"
    
    // 付费相关
    case clickBuyMembership = "click_buy_membership"
    case clickBuyPoints = "click_buy_points"
    case clickPay = "click_pay"
    
    // 其他
    case clickNotification = "click_notification"
}

// MARK: - 转化事件枚举
enum ConversionEvent: String {
    // 登录注册
    case loginSuccess = "login_success"
    case loginFail = "login_fail"
    case registerSuccess = "register_success"
    
    // 上传
    case uploadSuccess = "upload_success"
    case uploadFail = "upload_fail"
    
    // 生成
    case generateStart = "generate_start"
    case generateSuccess = "generate_success"
    case generateFail = "generate_fail"
    case generateCancel = "generate_cancel"
    
    // 发布分享
    case publishSuccess = "publish_success"
    case shareSuccess = "share_success"
    
    // 支付
    case payStart = "pay_start"
    case paySuccess = "pay_success"
    case payFail = "pay_fail"
    case payCancel = "pay_cancel"
    
    // 会员积分
    case membershipActivate = "membership_activate"
    case pointsRecharge = "points_recharge"
}

// MARK: - 事件类型
enum EventType: String, Codable {
    case pageView = "page_view"
    case userAction = "user_action"
    case conversion = "conversion"
    case performance = "performance"
    case error = "error"
}

// MARK: - 埋点事件模型
struct AnalyticsEvent: Codable {
    let eventId: String
    let eventName: String
    let eventType: EventType
    let timestamp: Date
    let userId: String?
    let sessionId: String
    let pageId: String?
    let properties: [String: String]
}

// MARK: - 埋点管理器
class AnalyticsManager {
    static let shared = AnalyticsManager()
    
    private var sessionId: String
    private var eventQueue: [AnalyticsEvent] = []
    private let maxQueueSize = 50
    private let uploadInterval: TimeInterval = 30
    private var uploadTimer: Timer?
    
    private init() {
        sessionId = UUID().uuidString
        startUploadTimer()
        setupAppLifecycleObservers()
    }
    
    // MARK: - 页面浏览
    func trackPageView(_ page: PageEvent, properties: [String: Any] = [:]) {
        var props = convertProperties(properties)
        props["page_id"] = page.pageId
        
        let event = createEvent(
            name: page.rawValue,
            type: .pageView,
            pageId: page.pageId,
            properties: props
        )
        
        enqueueEvent(event)
        
        // Debug日志
        #if DEBUG
        print("[Analytics] PageView: \(page.rawValue) - \(props)")
        #endif
    }
    
    // MARK: - 用户行为
    func trackAction(_ action: UserActionEvent, properties: [String: Any] = [:]) {
        let props = convertProperties(properties)
        
        let event = createEvent(
            name: action.rawValue,
            type: .userAction,
            pageId: currentPageId,
            properties: props
        )
        
        enqueueEvent(event)
        
        #if DEBUG
        print("[Analytics] Action: \(action.rawValue) - \(props)")
        #endif
    }
    
    // MARK: - 业务转化
    func trackConversion(_ conversion: ConversionEvent, properties: [String: Any] = [:]) {
        let props = convertProperties(properties)
        
        let event = createEvent(
            name: conversion.rawValue,
            type: .conversion,
            pageId: currentPageId,
            properties: props
        )
        
        // 转化事件立即上报
        uploadEvents([event])
        
        #if DEBUG
        print("[Analytics] Conversion: \(conversion.rawValue) - \(props)")
        #endif
    }
    
    // MARK: - 性能监控
    func trackPerformance(name: String, duration: TimeInterval, properties: [String: Any] = [:]) {
        var props = convertProperties(properties)
        props["duration"] = String(format: "%.2f", duration)
        
        let event = createEvent(
            name: name,
            type: .performance,
            pageId: currentPageId,
            properties: props
        )
        
        enqueueEvent(event)
    }
    
    // MARK: - 错误监控
    func trackError(name: String, error: Error, properties: [String: Any] = [:]) {
        var props = convertProperties(properties)
        props["error_message"] = error.localizedDescription
        if let apiError = error as? APIError {
            props["error_code"] = String(apiError.code)
        }
        
        let event = createEvent(
            name: name,
            type: .error,
            pageId: currentPageId,
            properties: props
        )
        
        // 错误事件立即上报
        uploadEvents([event])
    }
    
    // MARK: - 设置用户ID
    func setUserId(_ userId: String?) {
        UserDefaults.standard.set(userId, forKey: "analytics_user_id")
    }
    
    // MARK: - 重置会话
    func resetSession() {
        sessionId = UUID().uuidString
    }
    
    // MARK: - 私有方法
    private var currentPageId: String? {
        return PageTracker.shared.currentPageId
    }
    
    private var currentUserId: String? {
        return UserDefaults.standard.string(forKey: "analytics_user_id")
    }
    
    private func convertProperties(_ properties: [String: Any]) -> [String: String] {
        var result: [String: String] = [:]
        for (key, value) in properties {
            result[key] = String(describing: value)
        }
        return result
    }
    
    private func createEvent(
        name: String,
        type: EventType,
        pageId: String?,
        properties: [String: String]
    ) -> AnalyticsEvent {
        return AnalyticsEvent(
            eventId: UUID().uuidString,
            eventName: name,
            eventType: type,
            timestamp: Date(),
            userId: currentUserId,
            sessionId: sessionId,
            pageId: pageId,
            properties: properties
        )
    }
    
    private func enqueueEvent(_ event: AnalyticsEvent) {
        eventQueue.append(event)
        
        if eventQueue.count >= maxQueueSize {
            flushEvents()
        }
    }
    
    private func flushEvents() {
        guard !eventQueue.isEmpty else { return }
        
        let eventsToUpload = eventQueue
        eventQueue.removeAll()
        
        uploadEvents(eventsToUpload)
    }
    
    private func uploadEvents(_ events: [AnalyticsEvent]) {
        // 实际实现：发送到服务器
        Task {
            // try await AnalyticsAPI.upload(events: events)
        }
    }
    
    private func startUploadTimer() {
        uploadTimer = Timer.scheduledTimer(withTimeInterval: uploadInterval, repeats: true) { [weak self] _ in
            self?.flushEvents()
        }
    }
    
    private func setupAppLifecycleObservers() {
        NotificationCenter.default.addObserver(
            forName: UIApplication.willResignActiveNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.flushEvents()
        }
        
        NotificationCenter.default.addObserver(
            forName: UIApplication.didBecomeActiveNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.resetSession()
        }
    }
}

// MARK: - 页面追踪器
class PageTracker {
    static let shared = PageTracker()
    
    private var pageStack: [String] = []
    
    var currentPageId: String? {
        pageStack.last
    }
    
    func pushPage(_ pageId: String) {
        pageStack.append(pageId)
    }
    
    func popPage() {
        _ = pageStack.popLast()
    }
}

// MARK: - 错误码枚举
enum ErrorCode: Int, CaseIterable {
    
    // 成功
    case success = 0
    
    // 认证错误 (1000-1999)
    case tokenExpired = 1001
    case tokenInvalid = 1002
    case refreshTokenExpired = 1003
    case loginFailed = 1004
    case verifyCodeInvalid = 1005
    case verifyCodeExpired = 1006
    case verifyCodeTooFrequent = 1007
    case accountDisabled = 1008
    case accountNotFound = 1009
    case wechatAuthFailed = 1010
    case appleAuthFailed = 1011
    
    // 业务错误 (2000-2999)
    case insufficientPoints = 2001
    case pointsDeductFailed = 2002
    case membershipExpired = 2003
    case generationFailed = 2009
    case generationTimeout = 2010
    case generationCancelled = 2011
    case generationQueueFull = 2012
    case dailyLimitExceeded = 2013
    case contentViolation = 2014
    case faceNotDetected = 2017
    
    // 资源错误 (3000-3999)
    case workNotFound = 3001
    case templateNotFound = 3004
    case userNotFound = 3006
    
    // 参数错误 (4000-4999)
    case parameterMissing = 4001
    case parameterInvalid = 4002
    case phoneInvalid = 4003
    
    // 系统错误 (5000-5999)
    case serverError = 5001
    case serverMaintenance = 5002
    case serverBusy = 5003
    
    // 客户端错误 (负数)
    case networkError = -1
    case networkTimeout = -2
    case networkNoConnection = -3
    case parseError = -4
    case unknownError = -999
    
    // MARK: - 用户提示文案
    var userMessage: String {
        switch self {
        case .success:
            return "操作成功"
        case .tokenExpired, .tokenInvalid, .refreshTokenExpired:
            return "登录已过期，请重新登录"
        case .loginFailed:
            return "登录失败，请稍后重试"
        case .verifyCodeInvalid:
            return "验证码错误，请重新输入"
        case .verifyCodeExpired:
            return "验证码已过期，请重新获取"
        case .verifyCodeTooFrequent:
            return "验证码发送太频繁，请稍后再试"
        case .accountDisabled:
            return "账号已被禁用，请联系客服"
        case .accountNotFound:
            return "账号不存在"
        case .wechatAuthFailed:
            return "微信授权失败，请重试"
        case .appleAuthFailed:
            return "Apple登录失败，请重试"
        case .insufficientPoints:
            return "积分不足，请先充值"
        case .pointsDeductFailed:
            return "积分扣除失败，请重试"
        case .membershipExpired:
            return "会员已过期，请续费"
        case .generationFailed:
            return "生成失败，积分已退还"
        case .generationTimeout:
            return "生成超时，积分已退还"
        case .generationCancelled:
            return "生成已取消"
        case .generationQueueFull:
            return "当前排队人数较多，请稍后再试"
        case .dailyLimitExceeded:
            return "今日生成次数已达上限"
        case .contentViolation:
            return "内容违规，请更换图片"
        case .faceNotDetected:
            return "未检测到人脸，请更换照片"
        case .workNotFound:
            return "作品不存在或已删除"
        case .templateNotFound:
            return "模板不可用"
        case .userNotFound:
            return "用户不存在"
        case .parameterMissing:
            return "请填写完整信息"
        case .parameterInvalid:
            return "参数格式错误"
        case .phoneInvalid:
            return "请输入正确的手机号"
        case .serverError:
            return "服务器开小差了，请稍后重试"
        case .serverMaintenance:
            return "系统维护中，请稍后再来"
        case .serverBusy:
            return "服务器繁忙，请稍后重试"
        case .networkError:
            return "网络异常，请检查网络连接"
        case .networkTimeout:
            return "网络超时，请重试"
        case .networkNoConnection:
            return "无网络连接，请检查网络设置"
        case .parseError:
            return "数据解析失败"
        case .unknownError:
            return "未知错误，请稍后重试"
        }
    }
    
    var requiresRelogin: Bool {
        switch self {
        case .tokenExpired, .tokenInvalid, .refreshTokenExpired, .accountDisabled:
            return true
        default:
            return false
        }
    }
    
    var isRetryable: Bool {
        switch self {
        case .networkError, .networkTimeout, .serverBusy, .serverError, .generationQueueFull:
            return true
        default:
            return false
        }
    }
}

// MARK: - 错误处理器
class ErrorHandler {
    static let shared = ErrorHandler()
    
    private init() {}
    
    func handleAPIError(_ error: APIError, context: ErrorContext = .general) {
        // 记录错误日志
        logError(error, context: context)
        
        // 检查是否需要重新登录
        if error.requiresRelogin {
            handleReloginRequired()
            return
        }
        
        // 显示错误提示
        showErrorToast(error.userMessage)
    }
    
    func handleNetworkError(_ error: Error) -> APIError {
        let nsError = error as NSError
        
        switch nsError.code {
        case NSURLErrorNotConnectedToInternet:
            return APIError(code: ErrorCode.networkNoConnection.rawValue, message: "No network", details: nil)
        case NSURLErrorTimedOut:
            return APIError(code: ErrorCode.networkTimeout.rawValue, message: "Timeout", details: nil)
        default:
            return APIError(code: ErrorCode.networkError.rawValue, message: error.localizedDescription, details: nil)
        }
    }
    
    func showErrorToast(_ message: String) {
        DispatchQueue.main.async {
            NotificationCenter.default.post(
                name: .showToast,
                object: nil,
                userInfo: ["message": message, "type": "error"]
            )
        }
    }
    
    func showSuccessToast(_ message: String) {
        DispatchQueue.main.async {
            NotificationCenter.default.post(
                name: .showToast,
                object: nil,
                userInfo: ["message": message, "type": "success"]
            )
        }
    }
    
    private func handleReloginRequired() {
        TokenManager.shared.clearTokens()
        
        DispatchQueue.main.async {
            NotificationCenter.default.post(name: .userDidLogout, object: nil)
        }
        
        showErrorToast("登录已过期，请重新登录")
    }
    
    private func logError(_ error: APIError, context: ErrorContext) {
        #if DEBUG
        print("[Error] Code: \(error.code), Message: \(error.message), Context: \(context.rawValue)")
        #endif
    }
}

// MARK: - 错误上下文
enum ErrorContext: String {
    case general = "general"
    case login = "login"
    case generation = "generation"
    case payment = "payment"
    case upload = "upload"
    case profile = "profile"
}

// MARK: - 通知名称
extension Notification.Name {
    static let showToast = Notification.Name("showToast")
    static let userDidLogout = Notification.Name("userDidLogout")
    static let navigateToLogin = Notification.Name("navigateToLogin")
    static let navigateToRecharge = Notification.Name("navigateToRecharge")
    static let navigateToMembership = Notification.Name("navigateToMembership")
}

// MARK: - Toast类型
enum ToastType: String {
    case success
    case error
    case warning
    case info
}
