//
//  HomeView.swift
//  AICreatorApp
//
//  首页/发现页 - 完全匹配原型图设计
//  基于设计规范文档 v3.0
//
//  Created by Manus AI on 2026/1/19.
//

import SwiftUI

// MARK: - 首页主视图
struct HomeView: View {
    @StateObject private var viewModel = HomeViewModel()
    @State private var selectedTab = 0
    
    var body: some View {
        ZStack {
            // 背景
            Color(hex: "#0D0D0D")
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // 状态栏
                HomeStatusBar()
                
                // 顶部导航
                HomeHeader(points: viewModel.userPoints)
                
                // 分类Tab
                CategoryTabsView(selectedTab: $selectedTab)
                
                // 内容区域
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 0) {
                        // Banner轮播
                        BannerCarouselView()
                        
                        // 热门模板
                        TemplateSection(title: "热门模板", templates: viewModel.templates)
                        
                        // 发现作品
                        DiscoverSection(title: "发现", works: viewModel.works)
                    }
                    .padding(.bottom, 100)
                }
                
                Spacer()
            }
            
            // 底部导航
            VStack {
                Spacer()
                BottomNavigationBar(selectedIndex: 0)
            }
        }
        .onAppear {
            viewModel.loadData()
            AnalyticsManager.shared.trackPageView(.home)
        }
    }
}

// MARK: - 首页状态栏
struct HomeStatusBar: View {
    var body: some View {
        HStack {
            Text("22:46")
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.white)
            
            Spacer()
            
            HStack(spacing: 5) {
                Image(systemName: "cellularbars")
                    .font(.system(size: 14))
                Image(systemName: "wifi")
                    .font(.system(size: 14))
                BatteryIcon()
            }
            .foregroundColor(.white)
        }
        .padding(.horizontal, 20)
        .frame(height: 44)
        .background(
            LinearGradient(
                colors: [Color(hex: "#2d1f4e"), Color(hex: "#0D0D0D")],
                startPoint: .top,
                endPoint: .bottom
            )
        )
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

// MARK: - 顶部导航
struct HomeHeader: View {
    let points: Int
    
    var body: some View {
        HStack {
            // Logo
            Text("AI创图")
                .font(.system(size: 24, weight: .heavy))
                .italic()
                .foregroundStyle(
                    LinearGradient(
                        colors: [.white, Color(hex: "#e0e0e0")],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
            
            Spacer()
            
            // 积分徽章
            HStack(spacing: 6) {
                Image(systemName: "star.fill")
                    .font(.system(size: 14))
                    .foregroundColor(Color(hex: "#a855f7"))
                
                Text("\(points)")
                    .font(.system(size: 14))
                    .foregroundColor(.white)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(Color.white.opacity(0.1))
            .cornerRadius(20)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 10)
    }
}

// MARK: - 分类Tab
struct CategoryTabsView: View {
    @Binding var selectedTab: Int
    
    private let tabs = [
        ("推荐", "sparkles"),
        ("美颜", "face.smiling"),
        ("生活", "leaf"),
        ("一键变", "wand.and.stars")
    ]
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(tabs.indices, id: \.self) { index in
                    Button(action: {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            selectedTab = index
                        }
                    }) {
                        HStack(spacing: 6) {
                            Image(systemName: tabs[index].1)
                                .font(.system(size: 14))
                            
                            Text(tabs[index].0)
                                .font(.system(size: 14))
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(
                            Group {
                                if selectedTab == index {
                                    LinearGradient(
                                        colors: [Color(hex: "#a855f7"), Color(hex: "#ec4899")],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                } else {
                                    Color.clear
                                }
                            }
                        )
                        .foregroundColor(selectedTab == index ? .white : Color(hex: "#888888"))
                        .cornerRadius(20)
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 10)
        }
    }
}

// MARK: - Banner轮播
struct BannerCarouselView: View {
    @State private var currentPage = 0
    
    var body: some View {
        VStack(spacing: 10) {
            // Banner卡片
            ZStack {
                // 黄色渐变背景
                LinearGradient(
                    colors: [Color(hex: "#fef3c7"), Color(hex: "#fde68a"), Color(hex: "#fbbf24")],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                
                HStack {
                    // 左侧文字
                    VStack(alignment: .leading, spacing: 8) {
                        Text("一键美发")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(Color(hex: "#1a1a1a"))
                        
                        Text("AI智能换发型")
                            .font(.system(size: 12))
                            .foregroundColor(Color(hex: "#666666"))
                    }
                    .padding(.leading, 20)
                    
                    Spacer()
                    
                    // 右侧图片占位
                    RoundedRectangle(cornerRadius: 12)
                        .fill(
                            LinearGradient(
                                colors: [Color(hex: "#fce7f3"), Color(hex: "#f9a8d4")],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 100, height: 120)
                        .padding(.trailing, 20)
                }
                
                // 箭头按钮
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        ZStack {
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color.black.opacity(0.2))
                                .frame(width: 32, height: 32)
                            
                            Image(systemName: "arrow.right")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.white)
                        }
                        .padding(.trailing, 15)
                        .padding(.bottom, 15)
                    }
                }
            }
            .frame(height: 160)
            .cornerRadius(16)
            .padding(.horizontal, 20)
            
            // 轮播指示器
            HStack(spacing: 6) {
                ForEach(0..<3, id: \.self) { index in
                    RoundedRectangle(cornerRadius: 2)
                        .fill(index == currentPage ? Color.white : Color(hex: "#333333"))
                        .frame(width: 20, height: 4)
                }
            }
        }
        .padding(.bottom, 10)
    }
}

// MARK: - 热门模板区域
struct TemplateSection: View {
    let title: String
    let templates: [TemplateItem]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // 标题栏
            HStack {
                Text(title)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)
                
                Spacer()
                
                // 更多按钮
                Circle()
                    .fill(Color.white.opacity(0.1))
                    .frame(width: 28, height: 28)
                    .overlay(
                        Image(systemName: "chevron.right")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(.white)
                    )
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 15)
            
            // 模板横向滚动
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(templates) { template in
                        TemplateCard(template: template)
                    }
                }
                .padding(.horizontal, 20)
            }
        }
    }
}

// MARK: - 模板卡片
struct TemplateCard: View {
    let template: TemplateItem
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // 模板图片
            RoundedRectangle(cornerRadius: 12)
                .fill(
                    LinearGradient(
                        colors: template.gradientColors,
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 110, height: 140)
                .overlay(
                    Image(systemName: template.icon)
                        .font(.system(size: 30))
                        .foregroundColor(.white.opacity(0.8))
                )
            
            // 模板名称
            Text(template.name)
                .font(.system(size: 13))
                .foregroundColor(.white)
        }
        .frame(width: 110)
    }
}

// MARK: - 发现区域
struct DiscoverSection: View {
    let title: String
    let works: [WorkItem]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // 标题栏
            HStack {
                Text(title)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)
                
                Spacer()
                
                Circle()
                    .fill(Color.white.opacity(0.1))
                    .frame(width: 28, height: 28)
                    .overlay(
                        Image(systemName: "chevron.right")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(.white)
                    )
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 15)
            
            // 瀑布流
            WaterfallGrid(works: works)
                .padding(.horizontal, 20)
        }
    }
}

// MARK: - 瀑布流网格
struct WaterfallGrid: View {
    let works: [WorkItem]
    
    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            // 左列
            VStack(spacing: 10) {
                ForEach(works.indices.filter { $0 % 2 == 0 }, id: \.self) { index in
                    WorkCard(work: works[index])
                }
            }
            
            // 右列
            VStack(spacing: 10) {
                ForEach(works.indices.filter { $0 % 2 == 1 }, id: \.self) { index in
                    WorkCard(work: works[index])
                }
            }
        }
    }
}

// MARK: - 作品卡片
struct WorkCard: View {
    let work: WorkItem
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // 作品图片
            ZStack(alignment: .bottom) {
                RoundedRectangle(cornerRadius: 12)
                    .fill(
                        LinearGradient(
                            colors: work.gradientColors,
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .aspectRatio(3/4, contentMode: .fit)
                
                // 底部缩略图
                if work.showThumbnails {
                    HStack(spacing: 4) {
                        ForEach(0..<3, id: \.self) { _ in
                            RoundedRectangle(cornerRadius: 6)
                                .fill(Color.white.opacity(0.3))
                                .frame(width: 50, height: 50)
                        }
                    }
                    .padding(4)
                    .background(Color.black.opacity(0.3))
                }
            }
            .cornerRadius(12)
            
            // 作品信息
            VStack(alignment: .leading, spacing: 8) {
                Text(work.title)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.white)
                    .lineLimit(1)
                
                HStack {
                    // 作者信息
                    HStack(spacing: 6) {
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [Color(hex: "#a855f7"), Color(hex: "#ec4899")],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 20, height: 20)
                        
                        Text(work.authorName)
                            .font(.system(size: 12))
                            .foregroundColor(Color(hex: "#888888"))
                    }
                    
                    Spacer()
                    
                    // 浏览量
                    HStack(spacing: 4) {
                        Image(systemName: "eye")
                            .font(.system(size: 10))
                        Text(work.viewCount)
                            .font(.system(size: 12))
                    }
                    .foregroundColor(Color(hex: "#666666"))
                }
            }
            .padding(10)
        }
        .background(Color(hex: "#1a1a1a"))
        .cornerRadius(12)
    }
}

// MARK: - 底部导航栏
struct BottomNavigationBar: View {
    let selectedIndex: Int
    
    private let items = [
        ("首页", "house.fill"),
        ("发现", "safari"),
        ("创作", "plus"),
        ("我的", "person")
    ]
    
    var body: some View {
        HStack {
            ForEach(items.indices, id: \.self) { index in
                if index == 2 {
                    // 中间创作按钮
                    CreateButton()
                } else {
                    NavItem(
                        icon: items[index].1,
                        title: items[index].0,
                        isSelected: selectedIndex == index
                    )
                }
            }
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 20)
        .frame(height: 80)
        .background(
            LinearGradient(
                colors: [Color.clear, Color(hex: "#0D0D0D")],
                startPoint: .top,
                endPoint: .bottom
            )
        )
    }
}

// MARK: - 导航项
struct NavItem: View {
    let icon: String
    let title: String
    let isSelected: Bool
    
    var body: some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .font(.system(size: 24))
            
            Text(title)
                .font(.system(size: 10))
        }
        .foregroundColor(isSelected ? .white : Color(hex: "#666666"))
        .frame(maxWidth: .infinity)
    }
}

// MARK: - 创作按钮
struct CreateButton: View {
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 16)
                .fill(
                    LinearGradient(
                        colors: [Color(hex: "#a855f7"), Color(hex: "#ec4899")],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 56, height: 56)
                .shadow(color: Color(hex: "#a855f7").opacity(0.4), radius: 10, y: 4)
            
            Image(systemName: "plus")
                .font(.system(size: 28, weight: .medium))
                .foregroundColor(.white)
        }
        .offset(y: -20)
    }
}

// MARK: - 数据模型
struct TemplateItem: Identifiable {
    let id = UUID()
    let name: String
    let icon: String
    let gradientColors: [Color]
}

struct WorkItem: Identifiable {
    let id = UUID()
    let title: String
    let authorName: String
    let viewCount: String
    let gradientColors: [Color]
    let showThumbnails: Bool
}

// MARK: - ViewModel
class HomeViewModel: ObservableObject {
    @Published var userPoints: Int = 100
    @Published var templates: [TemplateItem] = []
    @Published var works: [WorkItem] = []
    
    func loadData() {
        // 加载模板数据
        templates = [
            TemplateItem(name: "国风古韵", icon: "leaf", gradientColors: [Color(hex: "#fce7f3"), Color(hex: "#f9a8d4")]),
            TemplateItem(name: "赛博朋克", icon: "bolt", gradientColors: [Color(hex: "#e0e7ff"), Color(hex: "#c7d2fe")]),
            TemplateItem(name: "日系清新", icon: "sun.max", gradientColors: [Color(hex: "#dcfce7"), Color(hex: "#86efac")]),
            TemplateItem(name: "复古胶片", icon: "camera", gradientColors: [Color(hex: "#fef3c7"), Color(hex: "#fcd34d")])
        ]
        
        // 加载作品数据
        works = [
            WorkItem(title: "国风美人", authorName: "小红", viewCount: "1.2k", gradientColors: [Color(hex: "#fce7f3"), Color(hex: "#f9a8d4")], showThumbnails: true),
            WorkItem(title: "赛博少女", authorName: "阿明", viewCount: "856", gradientColors: [Color(hex: "#e0e7ff"), Color(hex: "#c7d2fe")], showThumbnails: false),
            WorkItem(title: "日系写真", authorName: "小美", viewCount: "2.3k", gradientColors: [Color(hex: "#dcfce7"), Color(hex: "#86efac")], showThumbnails: true),
            WorkItem(title: "复古港风", authorName: "大华", viewCount: "1.5k", gradientColors: [Color(hex: "#fef3c7"), Color(hex: "#fcd34d")], showThumbnails: false)
        ]
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
    HomeView()
}
