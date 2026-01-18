//
//  APIService.swift
//  AICreatorApp
//
//  API服务层
//  基于设计规范文档 v3.0
//
//  Created by Manus AI on 2026/1/19.
//

import Foundation

// MARK: - API服务协议
protocol APIServiceProtocol {
    // 认证
    func loginWithWechat(code: String) async throws -> LoginResponse
    func loginWithApple(identityToken: String, authorizationCode: String) async throws -> LoginResponse
    func loginWithPhone(phone: String, code: String) async throws -> LoginResponse
    func sendVerifyCode(phone: String) async throws
    func refreshToken(refreshToken: String) async throws -> LoginResponse
    func logout() async throws
    
    // 用户
    func getCurrentUser() async throws -> User
    func updateProfile(nickname: String?, avatar: String?) async throws -> User
    
    // 作品
    func getWorks(page: Int, pageSize: Int, category: String?) async throws -> PaginatedResponse<WorkListItem>
    func getWorkDetail(id: String) async throws -> WorkDetail
    func likeWork(id: String) async throws
    func unlikeWork(id: String) async throws
    func deleteWork(id: String) async throws
    
    // 模板
    func getTemplates(page: Int, pageSize: Int, category: String?) async throws -> PaginatedResponse<TemplateListItem>
    func getTemplateDetail(id: String) async throws -> Template
    
    // 生成
    func createGeneration(templateId: String, imageURL: String) async throws -> GenerationResponse
    func getGenerationStatus(taskId: String) async throws -> GenerationTask
    func cancelGeneration(taskId: String) async throws
    
    // 上传
    func uploadImage(_ data: Data) async throws -> UploadResponse
}

// MARK: - API服务实现
class APIService: APIServiceProtocol {
    
    static let shared = APIService()
    
    private let baseURL: String
    private let session: URLSession
    private let decoder: JSONDecoder
    private let encoder: JSONEncoder
    
    private init() {
        self.baseURL = AppConfig.apiBaseURL
        
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 30
        config.timeoutIntervalForResource = 60
        self.session = URLSession(configuration: config)
        
        self.decoder = JSONDecoder()
        self.decoder.dateDecodingStrategy = .iso8601
        
        self.encoder = JSONEncoder()
        self.encoder.dateEncodingStrategy = .iso8601
    }
    
    // MARK: - 通用请求方法
    private func request<T: Codable>(
        endpoint: String,
        method: HTTPMethod = .get,
        body: [String: Any]? = nil,
        requiresAuth: Bool = true
    ) async throws -> T {
        guard let url = URL(string: baseURL + endpoint) else {
            throw APIError(code: -1, message: "Invalid URL", details: nil)
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // 添加认证Token
        if requiresAuth, let token = TokenManager.shared.accessToken {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        // 添加请求体
        if let body = body {
            request.httpBody = try JSONSerialization.data(withJSONObject: body)
        }
        
        // 发送请求
        let (data, response) = try await session.data(for: request)
        
        // 检查HTTP状态码
        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError(code: -1, message: "Invalid response", details: nil)
        }
        
        // 解析响应
        let apiResponse = try decoder.decode(APIResponse<T>.self, from: data)
        
        // 检查业务状态码
        guard apiResponse.isSuccess, let responseData = apiResponse.data else {
            throw APIError(
                code: apiResponse.code,
                message: apiResponse.message,
                details: nil
            )
        }
        
        return responseData
    }
    
    // MARK: - 认证接口
    func loginWithWechat(code: String) async throws -> LoginResponse {
        return try await request(
            endpoint: "/auth/wechat",
            method: .post,
            body: ["code": code],
            requiresAuth: false
        )
    }
    
    func loginWithApple(identityToken: String, authorizationCode: String) async throws -> LoginResponse {
        return try await request(
            endpoint: "/auth/apple",
            method: .post,
            body: [
                "identity_token": identityToken,
                "authorization_code": authorizationCode
            ],
            requiresAuth: false
        )
    }
    
    func loginWithPhone(phone: String, code: String) async throws -> LoginResponse {
        return try await request(
            endpoint: "/auth/phone",
            method: .post,
            body: [
                "phone": phone,
                "code": code
            ],
            requiresAuth: false
        )
    }
    
    func sendVerifyCode(phone: String) async throws {
        let _: EmptyResponse = try await request(
            endpoint: "/auth/verify-code",
            method: .post,
            body: ["phone": phone],
            requiresAuth: false
        )
    }
    
    func refreshToken(refreshToken: String) async throws -> LoginResponse {
        return try await request(
            endpoint: "/auth/refresh",
            method: .post,
            body: ["refresh_token": refreshToken],
            requiresAuth: false
        )
    }
    
    func logout() async throws {
        let _: EmptyResponse = try await request(
            endpoint: "/auth/logout",
            method: .post
        )
        TokenManager.shared.clearTokens()
    }
    
    // MARK: - 用户接口
    func getCurrentUser() async throws -> User {
        return try await request(endpoint: "/user/me")
    }
    
    func updateProfile(nickname: String?, avatar: String?) async throws -> User {
        var body: [String: Any] = [:]
        if let nickname = nickname { body["nickname"] = nickname }
        if let avatar = avatar { body["avatar"] = avatar }
        
        return try await request(
            endpoint: "/user/profile",
            method: .put,
            body: body
        )
    }
    
    // MARK: - 作品接口
    func getWorks(page: Int, pageSize: Int, category: String?) async throws -> PaginatedResponse<WorkListItem> {
        var endpoint = "/works?page=\(page)&page_size=\(pageSize)"
        if let category = category {
            endpoint += "&category=\(category)"
        }
        return try await request(endpoint: endpoint, requiresAuth: false)
    }
    
    func getWorkDetail(id: String) async throws -> WorkDetail {
        return try await request(endpoint: "/works/\(id)")
    }
    
    func likeWork(id: String) async throws {
        let _: EmptyResponse = try await request(
            endpoint: "/works/\(id)/like",
            method: .post
        )
    }
    
    func unlikeWork(id: String) async throws {
        let _: EmptyResponse = try await request(
            endpoint: "/works/\(id)/like",
            method: .delete
        )
    }
    
    func deleteWork(id: String) async throws {
        let _: EmptyResponse = try await request(
            endpoint: "/works/\(id)",
            method: .delete
        )
    }
    
    // MARK: - 模板接口
    func getTemplates(page: Int, pageSize: Int, category: String?) async throws -> PaginatedResponse<TemplateListItem> {
        var endpoint = "/templates?page=\(page)&page_size=\(pageSize)"
        if let category = category {
            endpoint += "&category=\(category)"
        }
        return try await request(endpoint: endpoint, requiresAuth: false)
    }
    
    func getTemplateDetail(id: String) async throws -> Template {
        return try await request(endpoint: "/templates/\(id)")
    }
    
    // MARK: - 生成接口
    func createGeneration(templateId: String, imageURL: String) async throws -> GenerationResponse {
        return try await request(
            endpoint: "/generation/create",
            method: .post,
            body: [
                "template_id": templateId,
                "image_url": imageURL
            ]
        )
    }
    
    func getGenerationStatus(taskId: String) async throws -> GenerationTask {
        return try await request(endpoint: "/generation/\(taskId)")
    }
    
    func cancelGeneration(taskId: String) async throws {
        let _: EmptyResponse = try await request(
            endpoint: "/generation/\(taskId)/cancel",
            method: .post
        )
    }
    
    // MARK: - 上传接口
    func uploadImage(_ data: Data) async throws -> UploadResponse {
        guard let url = URL(string: baseURL + "/upload/image") else {
            throw APIError(code: -1, message: "Invalid URL", details: nil)
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        let boundary = UUID().uuidString
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        if let token = TokenManager.shared.accessToken {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        var body = Data()
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"file\"; filename=\"image.jpg\"\r\n".data(using: .utf8)!)
        body.append("Content-Type: image/jpeg\r\n\r\n".data(using: .utf8)!)
        body.append(data)
        body.append("\r\n--\(boundary)--\r\n".data(using: .utf8)!)
        
        request.httpBody = body
        
        let (responseData, _) = try await session.data(for: request)
        let apiResponse = try decoder.decode(APIResponse<UploadResponse>.self, from: responseData)
        
        guard apiResponse.isSuccess, let uploadResponse = apiResponse.data else {
            throw APIError(code: apiResponse.code, message: apiResponse.message, details: nil)
        }
        
        return uploadResponse
    }
}

// MARK: - HTTP方法
enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case delete = "DELETE"
    case patch = "PATCH"
}

// MARK: - 空响应
struct EmptyResponse: Codable {}

// MARK: - API错误
struct APIError: Error, Codable {
    let code: Int
    let message: String
    let details: String?
    
    var errorCode: ErrorCode {
        ErrorCode(rawValue: code) ?? .unknownError
    }
    
    var userMessage: String {
        errorCode.userMessage
    }
    
    var requiresRelogin: Bool {
        errorCode.requiresRelogin
    }
    
    var isRetryable: Bool {
        errorCode.isRetryable
    }
}

// MARK: - Token管理器
class TokenManager {
    static let shared = TokenManager()
    
    private let accessTokenKey = "access_token"
    private let refreshTokenKey = "refresh_token"
    private let expiresAtKey = "token_expires_at"
    
    private init() {}
    
    var accessToken: String? {
        get { UserDefaults.standard.string(forKey: accessTokenKey) }
        set { UserDefaults.standard.set(newValue, forKey: accessTokenKey) }
    }
    
    var refreshToken: String? {
        get { UserDefaults.standard.string(forKey: refreshTokenKey) }
        set { UserDefaults.standard.set(newValue, forKey: refreshTokenKey) }
    }
    
    var expiresAt: Date? {
        get { UserDefaults.standard.object(forKey: expiresAtKey) as? Date }
        set { UserDefaults.standard.set(newValue, forKey: expiresAtKey) }
    }
    
    var isTokenValid: Bool {
        guard let _ = accessToken, let expiresAt = expiresAt else { return false }
        return expiresAt > Date()
    }
    
    func saveTokens(from response: LoginResponse) {
        accessToken = response.accessToken
        refreshToken = response.refreshToken
        expiresAt = Date().addingTimeInterval(TimeInterval(response.expiresIn))
    }
    
    func clearTokens() {
        accessToken = nil
        refreshToken = nil
        expiresAt = nil
    }
}

// MARK: - 应用配置
enum AppConfig {
    static let apiBaseURL = "https://api.aicreator.app/v1"
    static let appVersion = Bundle.main.appVersion
    static let buildNumber = Bundle.main.buildNumber
}

extension Bundle {
    var appVersion: String {
        infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0.0"
    }
}
