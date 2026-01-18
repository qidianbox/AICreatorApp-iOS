//
//  DesignSystem.swift
//  AICreatorApp
//
//  设计系统 - 颜色、字体、间距、圆角定义
//  基于设计规范文档 v3.0
//
//  Created by Manus AI on 2026/1/19.
//

import SwiftUI

// MARK: - 颜色系统
extension Color {
    
    // MARK: - 主色调
    static let gradientPurple = Color(hex: "#8B5CF6")
    static let gradientPink = Color(hex: "#EC4899")
    static let gradientOrange = Color(hex: "#F97316")
    
    // MARK: - 渐变色
    static let primaryGradient = LinearGradient(
        colors: [gradientPurple, gradientPink],
        startPoint: .leading,
        endPoint: .trailing
    )
    
    static let secondaryGradient = LinearGradient(
        colors: [gradientPink, gradientOrange],
        startPoint: .leading,
        endPoint: .trailing
    )
    
    // MARK: - 背景色
    static let appBackground = Color(hex: "#0F0F1A")
    static let surfaceBackground = Color(hex: "#1A1A2E")
    static let cardBackground = Color(hex: "#252540")
    static let inputBackground = Color(hex: "#2D2D4A")
    
    // MARK: - 文字色
    static let textPrimary = Color(hex: "#FFFFFF")
    static let textSecondary = Color(hex: "#A0A0B0")
    static let textTertiary = Color(hex: "#6B6B80")
    static let textDisabled = Color(hex: "#4A4A5A")
    
    // MARK: - 边框色
    static let borderDefault = Color(hex: "#3D3D5C")
    static let borderFocused = Color(hex: "#8B5CF6")
    
    // MARK: - 功能色
    static let success = Color(hex: "#22C55E")
    static let warning = Color(hex: "#F59E0B")
    static let error = Color(hex: "#EF4444")
    static let info = Color(hex: "#3B82F6")
    
    // MARK: - Hex初始化
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

// MARK: - 字体系统
extension Font {
    
    // MARK: - 标题字体
    static let largeTitle = Font.system(size: 34, weight: .bold)
    static let title1 = Font.system(size: 28, weight: .bold)
    static let title2 = Font.system(size: 22, weight: .bold)
    static let title3 = Font.system(size: 20, weight: .semibold)
    
    // MARK: - 正文字体
    static let bodyLarge = Font.system(size: 17, weight: .regular)
    static let bodyMedium = Font.system(size: 15, weight: .regular)
    static let bodySmall = Font.system(size: 13, weight: .regular)
    
    // MARK: - 辅助字体
    static let caption1 = Font.system(size: 12, weight: .regular)
    static let caption2 = Font.system(size: 11, weight: .regular)
    static let caption3 = Font.system(size: 10, weight: .regular)
    
    // MARK: - 按钮字体
    static let buttonLarge = Font.system(size: 17, weight: .semibold)
    static let buttonMedium = Font.system(size: 15, weight: .semibold)
    static let buttonSmall = Font.system(size: 13, weight: .semibold)
}

// MARK: - 间距系统
enum Spacing {
    static let xxs: CGFloat = 4
    static let xs: CGFloat = 8
    static let sm: CGFloat = 12
    static let md: CGFloat = 16
    static let lg: CGFloat = 24
    static let xl: CGFloat = 32
    static let xxl: CGFloat = 48
}

// MARK: - 圆角系统
enum CornerRadius {
    static let xs: CGFloat = 4
    static let sm: CGFloat = 8
    static let md: CGFloat = 12
    static let lg: CGFloat = 16
    static let xl: CGFloat = 24
    static let full: CGFloat = 9999
}

// MARK: - 动画时长
enum AnimationDuration {
    static let fast: Double = 0.15
    static let normal: Double = 0.25
    static let slow: Double = 0.35
}

// MARK: - 阴影样式
extension View {
    func cardShadow() -> some View {
        self.shadow(color: Color.black.opacity(0.2), radius: 8, x: 0, y: 4)
    }
    
    func softShadow() -> some View {
        self.shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
    }
}

// MARK: - 模板分类枚举
enum TemplateCategory: String, CaseIterable, Codable {
    case all = "all"
    case portrait = "portrait"
    case anime = "anime"
    case artistic = "artistic"
    case vintage = "vintage"
    case fashion = "fashion"
    case fantasy = "fantasy"
    
    var displayName: String {
        switch self {
        case .all: return "全部"
        case .portrait: return "人像"
        case .anime: return "动漫"
        case .artistic: return "艺术"
        case .vintage: return "复古"
        case .fashion: return "时尚"
        case .fantasy: return "奇幻"
        }
    }
    
    var icon: String {
        switch self {
        case .all: return "square.grid.2x2"
        case .portrait: return "person.fill"
        case .anime: return "sparkles"
        case .artistic: return "paintbrush.fill"
        case .vintage: return "camera.fill"
        case .fashion: return "tshirt.fill"
        case .fantasy: return "wand.and.stars"
        }
    }
}

// MARK: - 生成风格枚举
enum GenerationStyle: String, CaseIterable, Codable {
    case portrait = "portrait"
    case anime = "anime"
    case artistic = "artistic"
    case realistic = "realistic"
    case fantasy = "fantasy"
    
    var displayName: String {
        switch self {
        case .portrait: return "人像写真"
        case .anime: return "动漫风格"
        case .artistic: return "艺术绘画"
        case .realistic: return "超写实"
        case .fantasy: return "奇幻风格"
        }
    }
}

// MARK: - 会员类型枚举
enum MembershipType: String, Codable {
    case none = "none"
    case weekly = "weekly"
    case monthly = "monthly"
    case quarterly = "quarterly"
    case yearly = "yearly"
    
    var displayName: String {
        switch self {
        case .none: return "普通用户"
        case .weekly: return "周会员"
        case .monthly: return "月会员"
        case .quarterly: return "季会员"
        case .yearly: return "年会员"
        }
    }
}

// MARK: - 生成任务状态枚举
enum GenerationStatus: String, Codable {
    case pending = "pending"
    case processing = "processing"
    case completed = "completed"
    case failed = "failed"
    case cancelled = "cancelled"
    
    var displayName: String {
        switch self {
        case .pending: return "排队中"
        case .processing: return "生成中"
        case .completed: return "已完成"
        case .failed: return "生成失败"
        case .cancelled: return "已取消"
        }
    }
}
