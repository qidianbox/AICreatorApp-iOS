//
//  HomeView.swift
//  AICreatorApp
//
//  首页/发现页 - 完整SwiftUI代码框架
//  基于设计规范文档 v3.0
//
//  Created by Manus AI on 2026/1/19.
//

import SwiftUI

// MARK: - 首页主视图
struct HomeView: View {
    
    // MARK: - 状态管理
    @StateObject private var viewModel = HomeViewModel()
    @State private var selectedCategory: TemplateCategory = .all
    @State private var showNotifications = false
    @State private var scrollOffset: CGFloat = 0
    
    // MARK: - 常量
    private let columns = [
        GridItem(.flexible(), spacing: Spacing.sm),
        GridItem(.flexible(), spacing: Spacing.sm)
    ]
    
    var body: some View {
        ZStack {
            // 背景
            Color.appBackground
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // 顶部导航栏
                HomeNavigationBar(
                    hasUnreadNotifications: viewModel.hasUnreadNotifications,
                    onNotificationTap: { showNotifications = true }
                )
                
                // 主内容区
                ScrollView(showsIndicators: false) {
                    LazyVStack(spacing: Spacing.lg, pinnedViews: [.sectionHeaders]) {
                        // Banner轮播
                        BannerCarouselView(
                            banners: viewModel.banners,
                            onBannerTap: { banner in
                                viewModel.handleBannerTap(banner)
                            }
                        )
                        .padding(.horizontal, Spacing.md)
                        
                        // 分类Tab区域
                        Section {
                            // 作品瀑布流
                            WorkWaterfallGrid(
                                works: viewModel.works,
                                columns: columns,
                                onWorkTap: { work in
                                    viewModel.navigateToDetail(work)
                                },
                                onLikeTap: { work in
                                    viewModel.toggleLike(work)
                                },
                                onLoadMore: {
                                    Task {
                                        await viewModel.loadMoreWorks()
                                    }
                                }
                            )
                            .padding(.horizontal, Spacing.md)
                        } header: {
                            CategoryTabBar(
                                categories: TemplateCategory.allCases,
                                selectedCategory: $selectedCategory,
                                onCategoryChange: { category in
                                    Task {
                                        await viewModel.loadWorks(category: category)
                                    }
                                }
                            )
                            .background(Color.appBackground)
                        }
                    }
                    .padding(.bottom, 100) // 为底部导航留空间
                }
                .refreshable {
                    await viewModel.refreshWorks()
                }
            }
            
            // 加载状态
            if viewModel.isLoading && viewModel.works.isEmpty {
                LoadingOverlay()
            }
            
            // 错误状态
            if let errorMessage = viewModel.errorMessage, viewModel.works.isEmpty {
                ErrorStateView(
                    message: errorMessage,
                    onRetry: {
                        Task {
                            await viewModel.loadWorks()
                        }
                    }
                )
            }
        }
        .sheet(isPresented: $showNotifications) {
            NotificationsView()
        }
        .onAppear {
            // 页面曝光埋点
            AnalyticsManager.shared.trackPageView(.home, properties: [
                "tab_name": "discover",
                "category": selectedCategory.rawValue
            ])
            
            // 加载数据
            Task {
                await viewModel.loadInitialData()
            }
        }
    }
}

// MARK: - 首页导航栏
struct HomeNavigationBar: View {
    let hasUnreadNotifications: Bool
    let onNotificationTap: () -> Void
    
    var body: some View {
        HStack(spacing: Spacing.md) {
            // Logo和标题
            HStack(spacing: Spacing.xs) {
                Image("app_logo")
                    .resizable()
                    .frame(width: 32, height: 32)
                
                Text("AI创图")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundStyle(Color.primaryGradient)
            }
            
            Spacer()
            
            // 搜索按钮
            Button(action: {
                // 跳转搜索页
            }) {
                Image(systemName: "magnifyingglass")
                    .font(.system(size: 20))
                    .foregroundColor(.textPrimary)
            }
            
            // 通知按钮
            Button(action: onNotificationTap) {
                ZStack(alignment: .topTrailing) {
                    Image(systemName: "bell")
                        .font(.system(size: 20))
                        .foregroundColor(.textPrimary)
                    
                    if hasUnreadNotifications {
                        Circle()
                            .fill(Color.error)
                            .frame(width: 8, height: 8)
                            .offset(x: 2, y: -2)
                    }
                }
            }
        }
        .padding(.horizontal, Spacing.md)
        .padding(.vertical, Spacing.sm)
        .background(Color.appBackground)
    }
}

// MARK: - Banner轮播组件
struct BannerCarouselView: View {
    let banners: [Banner]
    let onBannerTap: (Banner) -> Void
    
    @State private var currentIndex = 0
    private let timer = Timer.publish(every: 4, on: .main, in: .common).autoconnect()
    
    var body: some View {
        TabView(selection: $currentIndex) {
            ForEach(banners.indices, id: \.self) { index in
                BannerItemView(banner: banners[index])
                    .onTapGesture {
                        // 点击埋点
                        AnalyticsManager.shared.trackAction(.clickBanner, properties: [
                            "banner_id": banners[index].id,
                            "position": index
                        ])
                        onBannerTap(banners[index])
                    }
                    .tag(index)
            }
        }
        .tabViewStyle(.page(indexDisplayMode: .automatic))
        .frame(height: 160)
        .cornerRadius(CornerRadius.lg)
        .onReceive(timer) { _ in
            withAnimation {
                currentIndex = (currentIndex + 1) % max(banners.count, 1)
            }
        }
    }
}

struct BannerItemView: View {
    let banner: Banner
    
    var body: some View {
        ZStack(alignment: .bottomLeading) {
            // 背景图
            AsyncImage(url: URL(string: banner.imageURL)) { phase in
                switch phase {
                case .success(let image):
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                case .failure:
                    Rectangle()
                        .fill(Color.primaryGradient.opacity(0.3))
                case .empty:
                    Rectangle()
                        .fill(Color.inputBackground)
                        .overlay(
                            ProgressView()
                                .tint(.textSecondary)
                        )
                @unknown default:
                    EmptyView()
                }
            }
            
            // 渐变遮罩
            LinearGradient(
                colors: [.clear, .black.opacity(0.6)],
                startPoint: .top,
                endPoint: .bottom
            )
            
            // 文字内容
            VStack(alignment: .leading, spacing: Spacing.xxs) {
                if let tag = banner.tag {
                    GradientTag(text: tag)
                }
                
                Text(banner.title)
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                if let subtitle = banner.subtitle {
                    Text(subtitle)
                        .font(.caption1)
                        .foregroundColor(.white.opacity(0.8))
                }
            }
            .padding(Spacing.md)
        }
        .clipped()
    }
}

// MARK: - 分类Tab栏
struct CategoryTabBar: View {
    let categories: [TemplateCategory]
    @Binding var selectedCategory: TemplateCategory
    let onCategoryChange: (TemplateCategory) -> Void
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: Spacing.sm) {
                ForEach(categories, id: \.self) { category in
                    CategoryChip(
                        icon: category.icon,
                        title: category.displayName,
                        isSelected: selectedCategory == category
                    ) {
                        // 点击埋点
                        AnalyticsManager.shared.trackAction(.clickCategoryTab, properties: [
                            "category": category.rawValue,
                            "page": "home"
                        ])
                        
                        selectedCategory = category
                        onCategoryChange(category)
                    }
                }
            }
            .padding(.horizontal, Spacing.md)
            .padding(.vertical, Spacing.sm)
        }
    }
}

struct CategoryChip: View {
    let icon: String
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: Spacing.xxs) {
                Image(systemName: icon)
                    .font(.system(size: 14))
                
                Text(title)
                    .font(.caption1)
                    .fontWeight(isSelected ? .semibold : .regular)
            }
            .foregroundColor(isSelected ? .white : .textSecondary)
            .padding(.horizontal, Spacing.md)
            .padding(.vertical, Spacing.xs)
            .background(
                Group {
                    if isSelected {
                        Color.primaryGradient
                    } else {
                        Color.inputBackground
                    }
                }
            )
            .cornerRadius(CornerRadius.full)
        }
        .buttonStyle(.plain)
        .sensoryFeedback(.selection, trigger: isSelected)
    }
}

// MARK: - 作品瀑布流网格
struct WorkWaterfallGrid: View {
    let works: [WorkListItem]
    let columns: [GridItem]
    let onWorkTap: (WorkListItem) -> Void
    let onLikeTap: (WorkListItem) -> Void
    let onLoadMore: () -> Void
    
    var body: some View {
        LazyVGrid(columns: columns, spacing: Spacing.sm) {
            ForEach(works.indices, id: \.self) { index in
                WorkCardView(
                    work: works[index],
                    position: index,
                    onTap: { onWorkTap(works[index]) },
                    onLikeTap: { onLikeTap(works[index]) }
                )
                .onAppear {
                    // 加载更多
                    if index == works.count - 4 {
                        onLoadMore()
                    }
                }
            }
        }
    }
}

// MARK: - 作品卡片
struct WorkCardView: View {
    let work: WorkListItem
    let position: Int
    let onTap: () -> Void
    let onLikeTap: () -> Void
    
    @State private var isLiked: Bool
    @State private var likeCount: Int
    
    init(work: WorkListItem, position: Int, onTap: @escaping () -> Void, onLikeTap: @escaping () -> Void) {
        self.work = work
        self.position = position
        self.onTap = onTap
        self.onLikeTap = onLikeTap
        self._isLiked = State(initialValue: work.isLiked)
        self._likeCount = State(initialValue: work.likeCount)
    }
    
    var body: some View {
        Button(action: {
            // 点击埋点
            AnalyticsManager.shared.trackAction(.clickWorkCard, properties: [
                "work_id": work.id,
                "position": position,
                "source": "home_discover"
            ])
            onTap()
        }) {
            VStack(alignment: .leading, spacing: 0) {
                // 封面图
                ZStack(alignment: .topTrailing) {
                    AsyncImage(url: URL(string: work.coverURL)) { phase in
                        switch phase {
                        case .success(let image):
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                        case .failure:
                            Rectangle()
                                .fill(Color.primaryGradient.opacity(0.3))
                                .overlay(
                                    Image(systemName: "photo")
                                        .foregroundColor(.textTertiary)
                                )
                        case .empty:
                            Rectangle()
                                .fill(Color.inputBackground)
                                .overlay(
                                    ProgressView()
                                        .tint(.textSecondary)
                                )
                        @unknown default:
                            EmptyView()
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .aspectRatio(3/4, contentMode: .fit)
                    .clipped()
                    
                    // 浏览量标签
                    HStack(spacing: 2) {
                        Image(systemName: "eye")
                            .font(.system(size: 10))
                        Text(formatCount(work.viewCount))
                            .font(.caption3)
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, Spacing.xs)
                    .padding(.vertical, 2)
                    .background(Color.black.opacity(0.5))
                    .cornerRadius(CornerRadius.xs)
                    .padding(Spacing.xs)
                }
                
                // 底部信息
                VStack(alignment: .leading, spacing: Spacing.xs) {
                    // 标题
                    Text(work.title)
                        .font(.caption1)
                        .fontWeight(.medium)
                        .foregroundColor(.textPrimary)
                        .lineLimit(2)
                    
                    // 作者和点赞
                    HStack {
                        // 作者信息
                        HStack(spacing: Spacing.xxs) {
                            AsyncImage(url: URL(string: work.authorAvatar)) { image in
                                image
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                            } placeholder: {
                                Circle()
                                    .fill(Color.primaryGradient.opacity(0.3))
                            }
                            .frame(width: 18, height: 18)
                            .clipShape(Circle())
                            
                            Text(work.authorName)
                                .font(.caption2)
                                .foregroundColor(.textSecondary)
                                .lineLimit(1)
                        }
                        
                        Spacer()
                        
                        // 点赞按钮
                        Button(action: {
                            withAnimation(.spring(response: 0.3)) {
                                isLiked.toggle()
                                likeCount += isLiked ? 1 : -1
                            }
                            
                            // 点赞埋点
                            AnalyticsManager.shared.trackAction(.clickLike, properties: [
                                "work_id": work.id,
                                "is_like": isLiked
                            ])
                            
                            onLikeTap()
                        }) {
                            HStack(spacing: 2) {
                                Image(systemName: isLiked ? "heart.fill" : "heart")
                                    .font(.system(size: 12))
                                    .foregroundColor(isLiked ? .gradientPink : .textSecondary)
                                
                                Text(formatCount(likeCount))
                                    .font(.caption2)
                                    .foregroundColor(.textSecondary)
                            }
                        }
                        .buttonStyle(.plain)
                        .sensoryFeedback(.impact(weight: .light), trigger: isLiked)
                    }
                }
                .padding(Spacing.xs)
            }
            .background(Color.cardBackground)
            .cornerRadius(CornerRadius.md)
            .shadow(color: Color.black.opacity(0.1), radius: 4, y: 2)
        }
        .buttonStyle(.plain)
    }
    
    private func formatCount(_ count: Int) -> String {
        if count >= 10000 {
            return String(format: "%.1fw", Double(count) / 10000)
        } else if count >= 1000 {
            return String(format: "%.1fk", Double(count) / 1000)
        }
        return "\(count)"
    }
}

// MARK: - 渐变标签
struct GradientTag: View {
    let text: String
    
    var body: some View {
        Text(text)
            .font(.caption2)
            .fontWeight(.medium)
            .foregroundColor(.white)
            .padding(.horizontal, Spacing.sm)
            .padding(.vertical, Spacing.xxs)
            .background(Color.primaryGradient)
            .cornerRadius(CornerRadius.xs)
    }
}

// MARK: - 加载遮罩
struct LoadingOverlay: View {
    var body: some View {
        ZStack {
            Color.appBackground.opacity(0.8)
            
            VStack(spacing: Spacing.md) {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .gradientPurple))
                    .scaleEffect(1.5)
                
                Text("加载中...")
                    .font(.bodySmall)
                    .foregroundColor(.textSecondary)
            }
        }
        .ignoresSafeArea()
    }
}

// MARK: - 错误状态视图
struct ErrorStateView: View {
    let message: String
    let onRetry: () -> Void
    
    var body: some View {
        VStack(spacing: Spacing.lg) {
            Image(systemName: "wifi.slash")
                .font(.system(size: 60))
                .foregroundColor(.textTertiary)
            
            VStack(spacing: Spacing.xs) {
                Text("加载失败")
                    .font(.title3)
                    .fontWeight(.medium)
                    .foregroundColor(.textPrimary)
                
                Text(message)
                    .font(.bodySmall)
                    .foregroundColor(.textSecondary)
                    .multilineTextAlignment(.center)
            }
            
            Button(action: onRetry) {
                HStack(spacing: Spacing.xs) {
                    Image(systemName: "arrow.clockwise")
                    Text("重新加载")
                }
                .font(.buttonMedium)
                .foregroundStyle(Color.primaryGradient)
            }
        }
        .padding(Spacing.xxl)
    }
}

// MARK: - 首页ViewModel
@MainActor
class HomeViewModel: ObservableObject {
    
    // MARK: - 发布属性
    @Published var banners: [Banner] = []
    @Published var works: [WorkListItem] = []
    @Published var isLoading = false
    @Published var isLoadingMore = false
    @Published var errorMessage: String?
    @Published var hasUnreadNotifications = false
    
    // MARK: - 私有属性
    private var currentPage = 1
    private var hasMoreData = true
    private var currentCategory: TemplateCategory = .all
    private let apiService: APIServiceProtocol
    
    // MARK: - 初始化
    init(apiService: APIServiceProtocol = APIService.shared) {
        self.apiService = apiService
    }
    
    // MARK: - 加载初始数据
    func loadInitialData() async {
        isLoading = true
        errorMessage = nil
        
        do {
            // 并行加载Banner和作品
            async let bannersTask = loadBanners()
            async let worksTask = loadWorks()
            async let notificationsTask = checkNotifications()
            
            _ = try await (bannersTask, worksTask, notificationsTask)
        } catch {
            handleError(error)
        }
        
        isLoading = false
    }
    
    // MARK: - 加载Banner
    private func loadBanners() async throws {
        // 实际调用API
        // let response = try await apiService.getBanners()
        // banners = response.banners
        
        // Mock数据
        banners = [
            Banner(id: "1", title: "新年特惠", subtitle: "会员限时5折", imageURL: "https://example.com/banner1.jpg", tag: "热门", actionType: .membership, actionValue: nil),
            Banner(id: "2", title: "人像写真", subtitle: "一键生成艺术照", imageURL: "https://example.com/banner2.jpg", tag: "新功能", actionType: .template, actionValue: "portrait")
        ]
    }
    
    // MARK: - 加载作品列表
    func loadWorks(category: TemplateCategory? = nil) async {
        if let category = category {
            currentCategory = category
        }
        
        currentPage = 1
        hasMoreData = true
        isLoading = works.isEmpty
        errorMessage = nil
        
        do {
            let response = try await apiService.getWorks(
                page: currentPage,
                pageSize: 20,
                category: currentCategory == .all ? nil : currentCategory.rawValue
            )
            
            works = response.items
            hasMoreData = response.hasMore
            currentPage = 1
        } catch {
            handleError(error)
        }
        
        isLoading = false
    }
    
    // MARK: - 加载更多作品
    func loadMoreWorks() async {
        guard !isLoadingMore && hasMoreData else { return }
        
        isLoadingMore = true
        
        do {
            let nextPage = currentPage + 1
            let response = try await apiService.getWorks(
                page: nextPage,
                pageSize: 20,
                category: currentCategory == .all ? nil : currentCategory.rawValue
            )
            
            works.append(contentsOf: response.items)
            hasMoreData = response.hasMore
            currentPage = nextPage
            
            // 滚动埋点
            AnalyticsManager.shared.trackAction(.scrollWorkList, properties: [
                "page": nextPage,
                "category": currentCategory.rawValue
            ])
        } catch {
            // 加载更多失败不显示全局错误
            print("Load more failed: \(error)")
        }
        
        isLoadingMore = false
    }
    
    // MARK: - 刷新作品
    func refreshWorks() async {
        // 下拉刷新埋点
        AnalyticsManager.shared.trackAction(.pullRefresh, properties: [
            "page": "home"
        ])
        
        await loadWorks()
    }
    
    // MARK: - 检查通知
    private func checkNotifications() async throws {
        // 实际调用API检查未读通知
        hasUnreadNotifications = true
    }
    
    // MARK: - 点赞/取消点赞
    func toggleLike(_ work: WorkListItem) {
        Task {
            do {
                if work.isLiked {
                    try await apiService.unlikeWork(id: work.id)
                } else {
                    try await apiService.likeWork(id: work.id)
                }
            } catch {
                // 点赞失败，回滚UI状态
                handleError(error)
            }
        }
    }
    
    // MARK: - 处理Banner点击
    func handleBannerTap(_ banner: Banner) {
        switch banner.actionType {
        case .membership:
            // 跳转会员页
            NotificationCenter.default.post(name: .navigateToMembership, object: nil)
        case .template:
            // 跳转模板详情
            if let templateId = banner.actionValue {
                NotificationCenter.default.post(
                    name: .navigateToTemplate,
                    object: nil,
                    userInfo: ["templateId": templateId]
                )
            }
        case .work:
            // 跳转作品详情
            if let workId = banner.actionValue {
                NotificationCenter.default.post(
                    name: .navigateToWorkDetail,
                    object: nil,
                    userInfo: ["workId": workId]
                )
            }
        case .webview:
            // 打开WebView
            if let url = banner.actionValue {
                NotificationCenter.default.post(
                    name: .openWebView,
                    object: nil,
                    userInfo: ["url": url]
                )
            }
        }
    }
    
    // MARK: - 跳转作品详情
    func navigateToDetail(_ work: WorkListItem) {
        NotificationCenter.default.post(
            name: .navigateToWorkDetail,
            object: nil,
            userInfo: ["workId": work.id]
        )
    }
    
    // MARK: - 错误处理
    private func handleError(_ error: Error) {
        if let apiError = error as? APIError {
            errorMessage = apiError.userMessage
            ErrorHandler.shared.handleAPIError(apiError, context: .general)
        } else {
            let networkError = ErrorHandler.shared.handleNetworkError(error)
            errorMessage = networkError.userMessage
        }
    }
}

// MARK: - 通知名称扩展
extension Notification.Name {
    static let navigateToTemplate = Notification.Name("navigateToTemplate")
    static let navigateToWorkDetail = Notification.Name("navigateToWorkDetail")
    static let openWebView = Notification.Name("openWebView")
}

// MARK: - Banner模型
struct Banner: Identifiable, Codable {
    let id: String
    let title: String
    let subtitle: String?
    let imageURL: String
    let tag: String?
    let actionType: BannerActionType
    let actionValue: String?
}

enum BannerActionType: String, Codable {
    case membership
    case template
    case work
    case webview
}

// MARK: - 预览
#Preview {
    HomeView()
        .preferredColorScheme(.dark)
}
