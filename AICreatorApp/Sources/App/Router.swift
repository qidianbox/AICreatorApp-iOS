//
//  Router.swift
//  AICreatorApp
//
//  路由管理 - 完整SwiftUI代码框架
//  基于设计规范文档 v3.0
//
//  Created by Manus AI on 2026/1/19.
//

import SwiftUI

// MARK: - 路由路径枚举
enum Route: Hashable {
    // 主要页面
    case home
    case create
    case profile
    
    // 详情页面
    case workDetail(workId: String)
    case templateDetail(templateId: String)
    case userProfile(userId: String)
    
    // 功能页面
    case login
    case membership
    case recharge
    case settings
    case editProfile
    
    // 生成流程
    case templateSelect
    case photoUpload(templateId: String)
    case generating(taskId: String)
    case result(taskId: String, resultURL: String)
    
    // 其他
    case webView(url: String, title: String)
    case imagePreview(imageURL: String)
}

// MARK: - 路由管理器
@MainActor
class Router: ObservableObject {
    
    static let shared = Router()
    
    @Published var navigationPath = NavigationPath()
    @Published var selectedTab: TabItem = .home
    @Published var showLogin = false
    @Published var showMembership = false
    @Published var showRecharge = false
    
    private init() {
        setupNotificationObservers()
    }
    
    // MARK: - 导航方法
    func navigate(to route: Route) {
        switch route {
        case .login:
            showLogin = true
        case .membership:
            showMembership = true
        case .recharge:
            showRecharge = true
        case .home:
            selectedTab = .home
            navigationPath.removeLast(navigationPath.count)
        case .create:
            selectedTab = .create
            navigationPath.removeLast(navigationPath.count)
        case .profile:
            selectedTab = .profile
            navigationPath.removeLast(navigationPath.count)
        default:
            navigationPath.append(route)
        }
        
        // 埋点
        trackNavigation(to: route)
    }
    
    func push(_ route: Route) {
        navigationPath.append(route)
        trackNavigation(to: route)
    }
    
    func pop() {
        if !navigationPath.isEmpty {
            navigationPath.removeLast()
        }
    }
    
    func popToRoot() {
        navigationPath.removeLast(navigationPath.count)
    }
    
    func replace(with route: Route) {
        if !navigationPath.isEmpty {
            navigationPath.removeLast()
        }
        navigationPath.append(route)
        trackNavigation(to: route)
    }
    
    // MARK: - 深度链接处理
    func handleDeepLink(url: URL) {
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: true),
              let host = components.host else { return }
        
        let pathComponents = components.path.split(separator: "/").map(String.init)
        
        switch host {
        case "work":
            if let workId = pathComponents.first {
                navigate(to: .workDetail(workId: workId))
            }
        case "template":
            if let templateId = pathComponents.first {
                navigate(to: .templateDetail(templateId: templateId))
            }
        case "user":
            if let userId = pathComponents.first {
                navigate(to: .userProfile(userId: userId))
            }
        case "membership":
            navigate(to: .membership)
        case "recharge":
            navigate(to: .recharge)
        default:
            break
        }
        
        #if DEBUG
        print("[Router] Deep link handled: \(url)")
        #endif
    }
    
    // MARK: - 通知监听
    private func setupNotificationObservers() {
        NotificationCenter.default.addObserver(
            forName: .navigateToLogin,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.showLogin = true
        }
        
        NotificationCenter.default.addObserver(
            forName: .navigateToMembership,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.showMembership = true
        }
        
        NotificationCenter.default.addObserver(
            forName: .navigateToRecharge,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.showRecharge = true
        }
        
        NotificationCenter.default.addObserver(
            forName: .navigateToDetail,
            object: nil,
            queue: .main
        ) { [weak self] notification in
            if let workId = notification.userInfo?["workId"] as? String {
                self?.push(.workDetail(workId: workId))
            }
        }
        
        NotificationCenter.default.addObserver(
            forName: .navigateToCreate,
            object: nil,
            queue: .main
        ) { [weak self] notification in
            self?.selectedTab = .create
            if let templateId = notification.userInfo?["templateId"] as? String {
                self?.push(.templateDetail(templateId: templateId))
            }
        }
        
        NotificationCenter.default.addObserver(
            forName: .navigateToResult,
            object: nil,
            queue: .main
        ) { [weak self] notification in
            if let taskId = notification.userInfo?["taskId"] as? String,
               let resultURL = notification.userInfo?["resultURL"] as? String {
                self?.replace(with: .result(taskId: taskId, resultURL: resultURL))
            }
        }
        
        NotificationCenter.default.addObserver(
            forName: .userDidLogin,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.showLogin = false
        }
        
        NotificationCenter.default.addObserver(
            forName: .userDidLogout,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.popToRoot()
            self?.selectedTab = .home
        }
    }
    
    // MARK: - 埋点
    private func trackNavigation(to route: Route) {
        var pageName = ""
        var properties: [String: Any] = [:]
        
        switch route {
        case .home:
            pageName = "home"
        case .create:
            pageName = "create"
        case .profile:
            pageName = "profile"
        case .workDetail(let workId):
            pageName = "work_detail"
            properties["work_id"] = workId
        case .templateDetail(let templateId):
            pageName = "template_detail"
            properties["template_id"] = templateId
        case .membership:
            pageName = "membership"
        case .recharge:
            pageName = "recharge"
        case .generating(let taskId):
            pageName = "generating"
            properties["task_id"] = taskId
        case .result(let taskId, _):
            pageName = "result"
            properties["task_id"] = taskId
        default:
            return
        }
        
        #if DEBUG
        print("[Router] Navigate to: \(pageName) - \(properties)")
        #endif
    }
}

// MARK: - Tab枚举
enum TabItem: String, CaseIterable {
    case home = "home"
    case create = "create"
    case profile = "profile"
    
    var title: String {
        switch self {
        case .home: return "发现"
        case .create: return "创作"
        case .profile: return "我的"
        }
    }
    
    var icon: String {
        switch self {
        case .home: return "house"
        case .create: return "plus.circle"
        case .profile: return "person"
        }
    }
    
    var selectedIcon: String {
        switch self {
        case .home: return "house.fill"
        case .create: return "plus.circle.fill"
        case .profile: return "person.fill"
        }
    }
}

// MARK: - 主App入口
@main
struct AICreatorApp: App {
    
    @StateObject private var router = Router.shared
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(router)
                .onOpenURL { url in
                    router.handleDeepLink(url: url)
                }
        }
    }
}

// MARK: - 主内容视图
struct ContentView: View {
    
    @EnvironmentObject var router: Router
    @State private var showSplash = true
    
    var body: some View {
        ZStack {
            if showSplash {
                SplashView()
                    .transition(.opacity)
            } else {
                MainTabView()
                    .transition(.opacity)
            }
        }
        .animation(.easeInOut(duration: 0.3), value: showSplash)
        .onAppear {
            // 模拟启动页延迟
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                withAnimation {
                    showSplash = false
                }
            }
        }
        .fullScreenCover(isPresented: $router.showLogin) {
            LoginView()
        }
        .sheet(isPresented: $router.showMembership) {
            MembershipView()
        }
        .sheet(isPresented: $router.showRecharge) {
            RechargeView()
        }
    }
}

// MARK: - 启动页
struct SplashView: View {
    
    @State private var scale: CGFloat = 0.8
    @State private var opacity: Double = 0
    
    var body: some View {
        ZStack {
            Color.appBackground
                .ignoresSafeArea()
            
            VStack(spacing: Spacing.md) {
                Image("app_logo")
                    .resizable()
                    .frame(width: 100, height: 100)
                    .cornerRadius(CornerRadius.lg)
                    .scaleEffect(scale)
                
                Text("AI创图")
                    .font(.title1)
                    .fontWeight(.bold)
                    .foregroundStyle(Color.primaryGradient)
                    .opacity(opacity)
            }
        }
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.6)) {
                scale = 1.0
            }
            withAnimation(.easeIn(duration: 0.4).delay(0.3)) {
                opacity = 1.0
            }
            
            AnalyticsManager.shared.trackPageView(.splash)
        }
    }
}

// MARK: - 主Tab视图
struct MainTabView: View {
    
    @EnvironmentObject var router: Router
    
    var body: some View {
        ZStack(alignment: .bottom) {
            TabView(selection: $router.selectedTab) {
                // 首页
                NavigationStack(path: $router.navigationPath) {
                    HomeView()
                        .navigationDestination(for: Route.self) { route in
                            destinationView(for: route)
                        }
                }
                .tag(TabItem.home)
                
                // 创作页
                NavigationStack(path: $router.navigationPath) {
                    CreateView()
                        .navigationDestination(for: Route.self) { route in
                            destinationView(for: route)
                        }
                }
                .tag(TabItem.create)
                
                // 个人中心
                NavigationStack(path: $router.navigationPath) {
                    ProfileView()
                        .navigationDestination(for: Route.self) { route in
                            destinationView(for: route)
                        }
                }
                .tag(TabItem.profile)
            }
            
            // 自定义底部导航栏
            CustomTabBar(selectedTab: $router.selectedTab)
        }
    }
    
    @ViewBuilder
    private func destinationView(for route: Route) -> some View {
        switch route {
        case .workDetail(let workId):
            DetailView(workId: workId)
        case .templateDetail(let templateId):
            TemplateDetailView(templateId: templateId)
        case .userProfile(let userId):
            UserProfileView(userId: userId)
        case .result(let taskId, let resultURL):
            ResultView(taskId: taskId, resultURL: resultURL)
        case .imagePreview(let imageURL):
            ImagePreviewView(imageURL: imageURL)
        case .webView(let url, let title):
            WebViewPage(url: url, title: title)
        default:
            EmptyView()
        }
    }
}

// MARK: - 自定义底部导航栏
struct CustomTabBar: View {
    
    @Binding var selectedTab: TabItem
    
    var body: some View {
        HStack(spacing: 0) {
            // 首页
            TabBarButton(
                tab: .home,
                isSelected: selectedTab == .home,
                action: { selectedTab = .home }
            )
            
            // 创作（中间大按钮）
            Button(action: { selectedTab = .create }) {
                ZStack {
                    Circle()
                        .fill(Color.primaryGradient)
                        .frame(width: 56, height: 56)
                        .shadow(color: Color.gradientPurple.opacity(0.4), radius: 10, y: 5)
                    
                    Image(systemName: "plus")
                        .font(.system(size: 24, weight: .medium))
                        .foregroundColor(.white)
                }
            }
            .offset(y: -15)
            .sensoryFeedback(.impact(flexibility: .soft), trigger: selectedTab == .create)
            
            // 我的
            TabBarButton(
                tab: .profile,
                isSelected: selectedTab == .profile,
                action: { selectedTab = .profile }
            )
        }
        .padding(.horizontal, Spacing.xl)
        .padding(.top, Spacing.sm)
        .padding(.bottom, Spacing.md)
        .background(
            Color.appBackground
                .shadow(color: .black.opacity(0.1), radius: 10, y: -5)
        )
    }
}

// MARK: - Tab按钮
struct TabBarButton: View {
    
    let tab: TabItem
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: Spacing.xxs) {
                Image(systemName: isSelected ? tab.selectedIcon : tab.icon)
                    .font(.system(size: 22))
                    .foregroundColor(isSelected ? .gradientPurple : .textTertiary)
                
                Text(tab.title)
                    .font(.caption2)
                    .foregroundColor(isSelected ? .gradientPurple : .textTertiary)
            }
            .frame(maxWidth: .infinity)
        }
        .sensoryFeedback(.selection, trigger: isSelected)
    }
}

// MARK: - 占位视图
struct TemplateDetailView: View {
    let templateId: String
    
    var body: some View {
        Text("模板详情: \(templateId)")
    }
}

struct UserProfileView: View {
    let userId: String
    
    var body: some View {
        Text("用户主页: \(userId)")
    }
}

struct ResultView: View {
    let taskId: String
    let resultURL: String
    
    var body: some View {
        Text("生成结果: \(taskId)")
    }
}

struct ImagePreviewView: View {
    let imageURL: String
    
    var body: some View {
        AsyncImage(url: URL(string: imageURL)) { phase in
            switch phase {
            case .success(let image):
                image
                    .resizable()
                    .aspectRatio(contentMode: .fit)
            case .failure, .empty:
                ProgressView()
            @unknown default:
                EmptyView()
            }
        }
    }
}

struct WebViewPage: View {
    let url: String
    let title: String
    
    var body: some View {
        Text("WebView: \(url)")
            .navigationTitle(title)
    }
}

struct MembershipView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.appBackground
                    .ignoresSafeArea()
                
                Text("会员订阅页面")
                    .foregroundColor(.textPrimary)
            }
            .navigationTitle("会员中心")
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
        .onAppear {
            AnalyticsManager.shared.trackPageView(.membership)
        }
    }
}

struct RechargeView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.appBackground
                    .ignoresSafeArea()
                
                Text("积分充值页面")
                    .foregroundColor(.textPrimary)
            }
            .navigationTitle("积分充值")
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
        .onAppear {
            AnalyticsManager.shared.trackPageView(.recharge)
        }
    }
}

// MARK: - 加载覆盖层
struct LoadingOverlay: View {
    var body: some View {
        ZStack {
            Color.black.opacity(0.4)
                .ignoresSafeArea()
            
            VStack(spacing: Spacing.md) {
                ProgressView()
                    .scaleEffect(1.5)
                    .tint(.white)
                
                Text("加载中...")
                    .font(.caption1)
                    .foregroundColor(.white)
            }
            .padding(Spacing.xl)
            .background(Color.cardBackground)
            .cornerRadius(CornerRadius.md)
        }
    }
}

// MARK: - 预览
#Preview {
    ContentView()
        .environmentObject(Router.shared)
        .preferredColorScheme(.dark)
}
