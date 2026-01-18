//
//  Models.swift
//  AICreatorApp
//
//  数据模型定义
//  基于设计规范文档 v3.0
//
//  Created by Manus AI on 2026/1/19.
//

import Foundation

// MARK: - 用户模型
struct User: Codable, Identifiable {
    let id: String
    var nickname: String
    var avatar: String
    var phone: String?
    var wechatOpenId: String?
    var appleId: String?
    var membershipType: MembershipType
    var membershipExpireTime: Date?
    var points: Int
    var totalWorks: Int
    var totalLikes: Int
    var createdAt: Date
    var updatedAt: Date
    
    // MARK: - 计算属性
    var isMember: Bool {
        guard membershipType != .none,
              let expireTime = membershipExpireTime else {
            return false
        }
        return expireTime > Date()
    }
    
    var membershipDaysLeft: Int {
        guard let expireTime = membershipExpireTime else { return 0 }
        let days = Calendar.current.dateComponents([.day], from: Date(), to: expireTime).day ?? 0
        return max(0, days)
    }
    
    var displayAvatar: String {
        avatar.isEmpty ? "default_avatar" : avatar
    }
}

// MARK: - 作品列表项
struct WorkListItem: Codable, Identifiable {
    let id: String
    let title: String
    let coverURL: String
    let authorId: String
    let authorName: String
    let authorAvatar: String
    var likeCount: Int
    var viewCount: Int
    var isLiked: Bool
    let createdAt: Date
}

// MARK: - 作品详情
struct WorkDetail: Codable, Identifiable {
    let id: String
    let title: String
    let description: String?
    let originalImageURL: String
    let resultImageURL: String
    let prompt: String
    let negativePrompt: String?
    let templateId: String
    let templateName: String
    let authorId: String
    let authorName: String
    let authorAvatar: String
    var likeCount: Int
    var viewCount: Int
    var shareCount: Int
    var isLiked: Bool
    let isPublic: Bool
    let createdAt: Date
    let followWorks: [WorkListItem]?
    
    // MARK: - 计算属性
    var formattedCreatedAt: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm"
        return formatter.string(from: createdAt)
    }
}

// MARK: - 模板模型
struct Template: Codable, Identifiable {
    let id: String
    let name: String
    let description: String
    let coverURL: String
    let previewImages: [String]
    let category: TemplateCategory
    let style: GenerationStyle
    let pointsCost: Int
    let isFree: Bool
    let isHot: Bool
    let isNew: Bool
    let usageCount: Int
    let createdAt: Date
    
    // MARK: - 计算属性
    var displayCost: String {
        isFree ? "免费" : "\(pointsCost)积分"
    }
}

// MARK: - 模板列表项
struct TemplateListItem: Codable, Identifiable {
    let id: String
    let name: String
    let coverURL: String
    let category: TemplateCategory
    let pointsCost: Int
    let isFree: Bool
    let isHot: Bool
    let isNew: Bool
    let usageCount: Int
}

// MARK: - 订单模型
struct Order: Codable, Identifiable {
    let id: String
    let userId: String
    let type: OrderType
    let productId: String
    let productName: String
    let amount: Double
    let currency: String
    let status: OrderStatus
    let paymentMethod: PaymentMethod?
    let transactionId: String?
    let createdAt: Date
    let paidAt: Date?
    let expiredAt: Date
    
    // MARK: - 计算属性
    var isExpired: Bool {
        status == .pending && Date() > expiredAt
    }
    
    var displayAmount: String {
        String(format: "%.2f", amount)
    }
}

enum OrderType: String, Codable {
    case membership = "membership"
    case points = "points"
}

enum OrderStatus: String, Codable {
    case pending = "pending"
    case paid = "paid"
    case failed = "failed"
    case cancelled = "cancelled"
    case refunded = "refunded"
}

enum PaymentMethod: String, Codable {
    case wechat = "wechat"
    case alipay = "alipay"
    case apple = "apple"
}

// MARK: - 积分套餐
struct PointsPackage: Codable, Identifiable {
    let id: String
    let points: Int
    let bonusPoints: Int
    let price: Double
    let originalPrice: Double?
    let isHot: Bool
    
    var totalPoints: Int {
        points + bonusPoints
    }
    
    var displayPrice: String {
        String(format: "¥%.2f", price)
    }
    
    var discount: Int? {
        guard let original = originalPrice, original > price else { return nil }
        return Int((1 - price / original) * 100)
    }
}

// MARK: - 会员套餐
struct MembershipPlan: Codable, Identifiable {
    let id: String
    let type: MembershipType
    let name: String
    let price: Double
    let originalPrice: Double?
    let dailyPoints: Int
    let benefits: [String]
    let isRecommended: Bool
    
    var displayPrice: String {
        String(format: "¥%.2f", price)
    }
    
    var discount: Int? {
        guard let original = originalPrice, original > price else { return nil }
        return Int((1 - price / original) * 100)
    }
}

// MARK: - 通知模型
struct AppNotification: Codable, Identifiable {
    let id: String
    let type: NotificationType
    let title: String
    let content: String
    let imageURL: String?
    let actionType: String?
    let actionValue: String?
    var isRead: Bool
    let createdAt: Date
}

enum NotificationType: String, Codable {
    case system = "system"
    case activity = "activity"
    case work = "work"
    case social = "social"
}

// MARK: - 生成任务
struct GenerationTask: Codable, Identifiable {
    let id: String
    let userId: String
    let templateId: String
    let templateName: String
    let originalImageURL: String
    var resultImageURL: String?
    var status: GenerationStatus
    var progress: Int
    let pointsCost: Int
    let createdAt: Date
    var completedAt: Date?
    var errorMessage: String?
    
    var isCompleted: Bool {
        status == .completed
    }
    
    var isFailed: Bool {
        status == .failed
    }
}

// MARK: - API响应包装
struct APIResponse<T: Codable>: Codable {
    let code: Int
    let message: String
    let data: T?
    
    var isSuccess: Bool {
        code == 0
    }
}

// MARK: - 分页响应
struct PaginatedResponse<T: Codable>: Codable {
    let items: [T]
    let total: Int
    let page: Int
    let pageSize: Int
    let hasMore: Bool
}

// MARK: - 登录响应
struct LoginResponse: Codable {
    let accessToken: String
    let refreshToken: String
    let expiresIn: Int
    let user: User
}

// MARK: - 生成响应
struct GenerationResponse: Codable {
    let taskId: String
    let estimatedTime: Int
    let queuePosition: Int?
}

// MARK: - 上传响应
struct UploadResponse: Codable {
    let url: String
    let key: String
}
