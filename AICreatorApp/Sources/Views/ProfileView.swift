//
//  ProfileView.swift
//  AICreatorApp
//
//  个人中心页 - 完整SwiftUI代码框架
//  基于设计规范文档 v3.0
//
//  Created by Manus AI on 2026/1/19.
//

import SwiftUI

// MARK: - 个人中心主视图
struct ProfileView: View {
    
    @StateObject private var viewModel = ProfileViewModel()
    @State private var selectedTab: ProfileTab = .works
    
    var body: some View {
        ZStack {
            Color.appBackground
                .ignoresSafeArea()
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    // 用户信息头部
                    ProfileHeaderView(user: viewModel.user)
                    
                    // 会员卡片
                    MembershipCardView(
                        membership: viewModel.user?.membership,
                        onTap: { viewModel.navigateToMembership() }
                    )
                    .padding(.horizontal, Spacing.md)
                    .padding(.top, Spacing.md)
                    
                    // 积分和统计
                    StatsRowView(
                        points: viewModel.user?.points ?? 0,
                        worksCount: viewModel.worksCount,
                        likesCount: viewModel.likesCount,
                        onPointsTap: { viewModel.navigateToRecharge() }
                    )
                    .padding(.horizontal, Spacing.md)
                    .padding(.top, Spacing.md)
                    
                    // Tab切换
                    ProfileTabBar(selectedTab: $selectedTab)
                        .padding(.top, Spacing.lg)
                    
                    // 内容区域
                    switch selectedTab {
                    case .works:
                        WorksGridView(works: viewModel.myWorks, onWorkTap: viewModel.navigateToDetail)
                    case .likes:
                        WorksGridView(works: viewModel.likedWorks, onWorkTap: viewModel.navigateToDetail)
                    }
                    
                    Spacer(minLength: 100)
                }
            }
            .refreshable {
                await viewModel.refreshData()
            }
            
            // 设置按钮
            VStack {
                HStack {
                    Spacer()
                    
                    Button(action: { viewModel.showSettings = true }) {
                        Image(systemName: "gearshape")
                            .font(.system(size: 20))
                            .foregroundColor(.textPrimary)
                            .padding(Spacing.sm)
                    }
                }
                .padding(.horizontal, Spacing.md)
                .padding(.top, Spacing.xs)
                
                Spacer()
            }
        }
        .sheet(isPresented: $viewModel.showSettings) {
            SettingsView()
        }
        .sheet(isPresented: $viewModel.showEditProfile) {
            EditProfileView(user: viewModel.user!)
        }
        .onAppear {
            AnalyticsManager.shared.trackPageView(.profile)
            
            Task {
                await viewModel.loadData()
            }
        }
    }
}

// MARK: - 个人信息头部
struct ProfileHeaderView: View {
    let user: User?
    
    var body: some View {
        VStack(spacing: Spacing.md) {
            // 头像
            ZStack {
                Circle()
                    .fill(Color.primaryGradient)
                    .frame(width: 80, height: 80)
                
                if let avatar = user?.avatar, !avatar.isEmpty {
                    AsyncImage(url: URL(string: avatar)) { phase in
                        switch phase {
                        case .success(let image):
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                        case .failure, .empty:
                            Text(user?.avatarEmoji ?? "😊")
                                .font(.system(size: 40))
                        @unknown default:
                            EmptyView()
                        }
                    }
                    .frame(width: 80, height: 80)
                    .clipShape(Circle())
                } else {
                    Text(user?.avatarEmoji ?? "😊")
                        .font(.system(size: 40))
                }
                
                // 会员标识
                if user?.membership?.isActive == true {
                    VStack {
                        Spacer()
                        HStack {
                            Spacer()
                            Image(systemName: "crown.fill")
                                .font(.system(size: 14))
                                .foregroundColor(.gradientOrange)
                                .padding(4)
                                .background(Color.appBackground)
                                .clipShape(Circle())
                        }
                    }
                    .frame(width: 80, height: 80)
                }
            }
            
            // 昵称
            Text(user?.nickname ?? "未登录")
                .font(.title3)
                .fontWeight(.bold)
                .foregroundColor(.textPrimary)
            
            // 用户ID
            if let userId = user?.id {
                Text("ID: \(userId.prefix(8))")
                    .font(.caption1)
                    .foregroundColor(.textTertiary)
            }
        }
        .padding(.top, Spacing.xxl)
    }
}

// MARK: - 会员卡片
struct MembershipCardView: View {
    let membership: Membership?
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: Spacing.md) {
                // 图标
                ZStack {
                    Circle()
                        .fill(Color.gradientOrange.opacity(0.2))
                        .frame(width: 44, height: 44)
                    
                    Image(systemName: "crown.fill")
                        .font(.system(size: 20))
                        .foregroundColor(.gradientOrange)
                }
                
                // 信息
                VStack(alignment: .leading, spacing: Spacing.xxs) {
                    if let membership = membership, membership.isActive {
                        Text(membership.type.displayName)
                            .font(.bodyMedium)
                            .fontWeight(.semibold)
                            .foregroundColor(.textPrimary)
                        
                        Text("有效期至 \(membership.formattedExpireDate)")
                            .font(.caption1)
                            .foregroundColor(.textSecondary)
                    } else {
                        Text("开通会员")
                            .font(.bodyMedium)
                            .fontWeight(.semibold)
                            .foregroundColor(.textPrimary)
                        
                        Text("享受更多专属权益")
                            .font(.caption1)
                            .foregroundColor(.textSecondary)
                    }
                }
                
                Spacer()
                
                // 按钮
                Text(membership?.isActive == true ? "续费" : "开通")
                    .font(.caption1)
                    .fontWeight(.medium)
                    .foregroundColor(.white)
                    .padding(.horizontal, Spacing.sm)
                    .padding(.vertical, Spacing.xs)
                    .background(Color.primaryGradient)
                    .cornerRadius(CornerRadius.full)
            }
            .padding(Spacing.md)
            .background(
                LinearGradient(
                    colors: [Color(hex: "#2A2A3E"), Color(hex: "#1E1E2E")],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .cornerRadius(CornerRadius.lg)
            .overlay(
                RoundedRectangle(cornerRadius: CornerRadius.lg)
                    .stroke(Color.gradientOrange.opacity(0.3), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - 统计行
struct StatsRowView: View {
    let points: Int
    let worksCount: Int
    let likesCount: Int
    let onPointsTap: () -> Void
    
    var body: some View {
        HStack(spacing: 0) {
            // 积分
            Button(action: onPointsTap) {
                VStack(spacing: Spacing.xxs) {
                    HStack(spacing: Spacing.xxs) {
                        Image(systemName: "bolt.fill")
                            .font(.system(size: 14))
                            .foregroundColor(.gradientPurple)
                        
                        Text("\(points)")
                            .font(.title3)
                            .fontWeight(.bold)
                            .foregroundColor(.textPrimary)
                    }
                    
                    Text("积分")
                        .font(.caption1)
                        .foregroundColor(.textSecondary)
                }
                .frame(maxWidth: .infinity)
            }
            
            Divider()
                .frame(height: 30)
                .background(Color.borderDefault)
            
            // 作品
            VStack(spacing: Spacing.xxs) {
                Text("\(worksCount)")
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundColor(.textPrimary)
                
                Text("作品")
                    .font(.caption1)
                    .foregroundColor(.textSecondary)
            }
            .frame(maxWidth: .infinity)
            
            Divider()
                .frame(height: 30)
                .background(Color.borderDefault)
            
            // 获赞
            VStack(spacing: Spacing.xxs) {
                Text("\(likesCount)")
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundColor(.textPrimary)
                
                Text("获赞")
                    .font(.caption1)
                    .foregroundColor(.textSecondary)
            }
            .frame(maxWidth: .infinity)
        }
        .padding(.vertical, Spacing.md)
        .background(Color.cardBackground)
        .cornerRadius(CornerRadius.md)
    }
}

// MARK: - Profile Tab枚举
enum ProfileTab: String, CaseIterable {
    case works = "works"
    case likes = "likes"
    
    var displayName: String {
        switch self {
        case .works: return "我的作品"
        case .likes: return "我的喜欢"
        }
    }
    
    var icon: String {
        switch self {
        case .works: return "photo.on.rectangle"
        case .likes: return "heart"
        }
    }
}

// MARK: - Profile Tab栏
struct ProfileTabBar: View {
    @Binding var selectedTab: ProfileTab
    
    var body: some View {
        HStack(spacing: 0) {
            ForEach(ProfileTab.allCases, id: \.self) { tab in
                Button(action: {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        selectedTab = tab
                    }
                }) {
                    VStack(spacing: Spacing.xs) {
                        HStack(spacing: Spacing.xxs) {
                            Image(systemName: tab.icon)
                                .font(.system(size: 14))
                            Text(tab.displayName)
                                .font(.bodySmall)
                        }
                        .foregroundColor(selectedTab == tab ? .textPrimary : .textSecondary)
                        
                        // 指示器
                        Rectangle()
                            .fill(selectedTab == tab ? Color.primaryGradient : Color.clear)
                            .frame(height: 2)
                            .cornerRadius(1)
                    }
                    .frame(maxWidth: .infinity)
                }
                .sensoryFeedback(.selection, trigger: selectedTab)
            }
        }
        .padding(.horizontal, Spacing.md)
    }
}

// MARK: - 作品网格
struct WorksGridView: View {
    let works: [WorkListItem]
    let onWorkTap: (String) -> Void
    
    private let columns = [
        GridItem(.flexible(), spacing: Spacing.xs),
        GridItem(.flexible(), spacing: Spacing.xs),
        GridItem(.flexible(), spacing: Spacing.xs)
    ]
    
    var body: some View {
        if works.isEmpty {
            VStack(spacing: Spacing.md) {
                Image(systemName: "photo.on.rectangle.angled")
                    .font(.system(size: 40))
                    .foregroundColor(.textTertiary)
                
                Text("暂无作品")
                    .font(.bodySmall)
                    .foregroundColor(.textSecondary)
            }
            .frame(height: 200)
        } else {
            LazyVGrid(columns: columns, spacing: Spacing.xs) {
                ForEach(works) { work in
                    Button(action: { onWorkTap(work.id) }) {
                        AsyncImage(url: URL(string: work.imageURL)) { phase in
                            switch phase {
                            case .success(let image):
                                image
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                            case .failure, .empty:
                                Rectangle()
                                    .fill(Color.primaryGradient.opacity(0.3))
                            @unknown default:
                                EmptyView()
                            }
                        }
                        .aspectRatio(1, contentMode: .fit)
                        .clipped()
                        .cornerRadius(CornerRadius.xs)
                    }
                }
            }
            .padding(.horizontal, Spacing.md)
            .padding(.top, Spacing.md)
        }
    }
}

// MARK: - 设置页
struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var showLogoutAlert = false
    
    private let settingsItems: [(String, String, SettingsAction)] = [
        ("账号与安全", "person.badge.shield.checkmark", .accountSecurity),
        ("通知设置", "bell", .notifications),
        ("隐私设置", "lock.shield", .privacy),
        ("清除缓存", "trash", .clearCache),
        ("关于我们", "info.circle", .about),
        ("用户协议", "doc.text", .userAgreement),
        ("隐私政策", "hand.raised", .privacyPolicy),
        ("意见反馈", "envelope", .feedback)
    ]
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.appBackground
                    .ignoresSafeArea()
                
                VStack(spacing: Spacing.md) {
                    // 设置项列表
                    VStack(spacing: 0) {
                        ForEach(settingsItems, id: \.0) { item in
                            Button(action: { handleAction(item.2) }) {
                                HStack {
                                    Image(systemName: item.1)
                                        .font(.system(size: 18))
                                        .foregroundColor(.textSecondary)
                                        .frame(width: 30)
                                    
                                    Text(item.0)
                                        .font(.bodyMedium)
                                        .foregroundColor(.textPrimary)
                                    
                                    Spacer()
                                    
                                    Image(systemName: "chevron.right")
                                        .font(.system(size: 14))
                                        .foregroundColor(.textTertiary)
                                }
                                .padding(.horizontal, Spacing.md)
                                .padding(.vertical, Spacing.sm)
                            }
                            
                            if item.0 != settingsItems.last?.0 {
                                Divider()
                                    .background(Color.borderDefault)
                                    .padding(.leading, 60)
                            }
                        }
                    }
                    .background(Color.cardBackground)
                    .cornerRadius(CornerRadius.md)
                    .padding(.horizontal, Spacing.md)
                    
                    Spacer()
                    
                    // 退出登录
                    Button(action: { showLogoutAlert = true }) {
                        Text("退出登录")
                            .font(.buttonMedium)
                            .foregroundColor(.red)
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .background(Color.cardBackground)
                            .cornerRadius(CornerRadius.md)
                    }
                    .padding(.horizontal, Spacing.md)
                    
                    // 版本号
                    Text("版本 \(AppConfig.appVersion)")
                        .font(.caption1)
                        .foregroundColor(.textTertiary)
                        .padding(.bottom, Spacing.lg)
                }
                .padding(.top, Spacing.md)
            }
            .navigationTitle("设置")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark")
                            .foregroundColor(.textPrimary)
                    }
                }
            }
            .alert("确认退出", isPresented: $showLogoutAlert) {
                Button("取消", role: .cancel) {}
                Button("退出", role: .destructive) {
                    UserManager.shared.logout()
                    dismiss()
                }
            } message: {
                Text("确定要退出登录吗？")
            }
        }
        .onAppear {
            AnalyticsManager.shared.trackPageView(.settings)
        }
    }
    
    private func handleAction(_ action: SettingsAction) {
        switch action {
        case .clearCache:
            // 清除缓存
            URLCache.shared.removeAllCachedResponses()
            ErrorHandler.shared.showSuccessToast("缓存已清除")
        default:
            // 其他操作
            break
        }
    }
}

// MARK: - 设置操作
enum SettingsAction {
    case accountSecurity
    case notifications
    case privacy
    case clearCache
    case about
    case userAgreement
    case privacyPolicy
    case feedback
}

// MARK: - 编辑资料页
struct EditProfileView: View {
    let user: User
    @Environment(\.dismiss) private var dismiss
    @State private var nickname: String = ""
    @State private var selectedEmoji: String = ""
    @State private var isSaving = false
    
    private let emojis = ["😊", "😎", "🥳", "🤩", "😇", "🥰", "🤗", "😋", "🙃", "😏", "🤓", "🧐"]
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.appBackground
                    .ignoresSafeArea()
                
                VStack(spacing: Spacing.xl) {
                    // 头像选择
                    VStack(spacing: Spacing.md) {
                        Text("选择头像")
                            .font(.bodyMedium)
                            .foregroundColor(.textSecondary)
                        
                        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 6), spacing: Spacing.sm) {
                            ForEach(emojis, id: \.self) { emoji in
                                Button(action: { selectedEmoji = emoji }) {
                                    Text(emoji)
                                        .font(.system(size: 32))
                                        .frame(width: 50, height: 50)
                                        .background(
                                            selectedEmoji == emoji
                                                ? Color.primaryGradient.opacity(0.3)
                                                : Color.inputBackground
                                        )
                                        .cornerRadius(CornerRadius.sm)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: CornerRadius.sm)
                                                .stroke(
                                                    selectedEmoji == emoji
                                                        ? Color.gradientPurple
                                                        : Color.clear,
                                                    lineWidth: 2
                                                )
                                        )
                                }
                            }
                        }
                    }
                    .padding(.horizontal, Spacing.md)
                    
                    // 昵称输入
                    VStack(alignment: .leading, spacing: Spacing.xs) {
                        Text("昵称")
                            .font(.bodyMedium)
                            .foregroundColor(.textSecondary)
                        
                        TextField("请输入昵称", text: $nickname)
                            .font(.bodyMedium)
                            .foregroundColor(.textPrimary)
                            .padding(.horizontal, Spacing.md)
                            .frame(height: 50)
                            .background(Color.inputBackground)
                            .cornerRadius(CornerRadius.md)
                    }
                    .padding(.horizontal, Spacing.md)
                    
                    Spacer()
                    
                    // 保存按钮
                    Button(action: saveProfile) {
                        if isSaving {
                            ProgressView()
                                .tint(.white)
                        } else {
                            Text("保存")
                                .font(.buttonMedium)
                        }
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(Color.primaryGradient)
                    .cornerRadius(CornerRadius.md)
                    .padding(.horizontal, Spacing.md)
                    .padding(.bottom, Spacing.lg)
                }
                .padding(.top, Spacing.lg)
            }
            .navigationTitle("编辑资料")
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
            nickname = user.nickname
            selectedEmoji = user.avatarEmoji ?? "😊"
        }
    }
    
    private func saveProfile() {
        isSaving = true
        
        Task {
            do {
                _ = try await APIService.shared.updateProfile(
                    nickname: nickname,
                    avatar: selectedEmoji
                )
                
                await MainActor.run {
                    isSaving = false
                    ErrorHandler.shared.showSuccessToast("保存成功")
                    dismiss()
                }
            } catch {
                await MainActor.run {
                    isSaving = false
                    ErrorHandler.shared.handleAPIError(error as! APIError, context: .profile)
                }
            }
        }
    }
}

// MARK: - 个人中心ViewModel
@MainActor
class ProfileViewModel: ObservableObject {
    
    @Published var user: User?
    @Published var myWorks: [WorkListItem] = []
    @Published var likedWorks: [WorkListItem] = []
    @Published var worksCount = 0
    @Published var likesCount = 0
    @Published var showSettings = false
    @Published var showEditProfile = false
    
    // MARK: - 加载数据
    func loadData() async {
        // 加载用户信息
        do {
            user = try await APIService.shared.getCurrentUser()
        } catch {
            // 使用本地缓存
            user = UserManager.shared.currentUser
        }
        
        // 加载作品
        await loadMyWorks()
        await loadLikedWorks()
    }
    
    // MARK: - 刷新数据
    func refreshData() async {
        await loadData()
    }
    
    // MARK: - 加载我的作品
    private func loadMyWorks() async {
        do {
            let response = try await APIService.shared.getWorks(page: 1, pageSize: 50, category: nil)
            myWorks = response.items
            worksCount = response.total
        } catch {
            // 使用Mock数据
            myWorks = []
            worksCount = 0
        }
    }
    
    // MARK: - 加载喜欢的作品
    private func loadLikedWorks() async {
        // Mock数据
        likedWorks = []
        likesCount = 0
    }
    
    // MARK: - 导航到会员页
    func navigateToMembership() {
        AnalyticsManager.shared.trackAction(.clickBuyMembership)
        NotificationCenter.default.post(name: .navigateToMembership, object: nil)
    }
    
    // MARK: - 导航到充值页
    func navigateToRecharge() {
        AnalyticsManager.shared.trackAction(.clickBuyPoints)
        NotificationCenter.default.post(name: .navigateToRecharge, object: nil)
    }
    
    // MARK: - 导航到详情页
    func navigateToDetail(_ workId: String) {
        NotificationCenter.default.post(
            name: .navigateToDetail,
            object: nil,
            userInfo: ["workId": workId]
        )
    }
}

// MARK: - 预览
#Preview {
    ProfileView()
        .preferredColorScheme(.dark)
}
