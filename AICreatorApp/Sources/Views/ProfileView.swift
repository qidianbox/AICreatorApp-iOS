//
//  ProfileView.swift
//  AICreatorApp
//
//  个人中心页 - 完全匹配原型图设计
//  基于设计规范文档 v3.0
//
//  Created by Manus AI on 2026/1/19.
//

import SwiftUI

// MARK: - 个人中心页主视图
struct ProfileView: View {
    @StateObject private var viewModel = ProfileViewModel()
    @State private var selectedTab = 0
    
    var body: some View {
        ZStack {
            // 背景
            Color(hex: "#0D0D0D")
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // 状态栏
                ProfileStatusBar()
                
                // 个人信息头部
                ProfileHeader(
                    user: viewModel.user,
                    onSettingsTap: { viewModel.openSettings() }
                )
                
                // 统计卡片
                StatsRow(
                    credits: viewModel.user?.credits ?? 0,
                    memberDays: viewModel.user?.memberDaysLeft ?? 0,
                    onCreditsTap: { viewModel.openRecharge() },
                    onMemberTap: { viewModel.openMembership() }
                )
                
                // 内容Tab
                ProfileContentTabs(selectedTab: $selectedTab)
                
                // 内容区域
                ProfileContentArea(
                    selectedTab: selectedTab,
                    works: viewModel.myWorks,
                    likedWorks: viewModel.likedWorks
                )
                
                Spacer()
            }
            
            // 底部导航
            VStack {
                Spacer()
                ProfileBottomNav()
            }
        }
        .onAppear {
            viewModel.loadUserData()
            AnalyticsManager.shared.trackPageView(.profile)
        }
    }
}

// MARK: - 状态栏
struct ProfileStatusBar: View {
    var body: some View {
        HStack {
            Text("22:48")
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.white)
            
            Spacer()
            
            HStack(spacing: 5) {
                // 信号
                HStack(spacing: 1) {
                    ForEach(0..<4, id: \.self) { i in
                        RoundedRectangle(cornerRadius: 1)
                            .fill(Color.white)
                            .frame(width: 3, height: CGFloat(4 + i * 2))
                    }
                }
                
                // WiFi
                Image(systemName: "wifi")
                    .font(.system(size: 14))
                
                // 电池
                BatteryIcon()
            }
            .foregroundColor(.white)
        }
        .padding(.horizontal, 20)
        .frame(height: 44)
    }
}

// MARK: - 个人信息头部
struct ProfileHeader: View {
    let user: ProfileUser?
    let onSettingsTap: () -> Void
    
    var body: some View {
        ZStack {
            // 渐变背景
            LinearGradient(
                colors: [
                    Color(hex: "#2d1f4e"),
                    Color(hex: "#1a1030"),
                    Color(hex: "#0D0D0D")
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            
            VStack(spacing: 0) {
                // 设置按钮
                HStack {
                    Spacer()
                    Button(action: onSettingsTap) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color.white.opacity(0.1))
                                .frame(width: 36, height: 36)
                            
                            Image(systemName: "gearshape")
                                .font(.system(size: 18))
                                .foregroundColor(.white)
                        }
                    }
                }
                .padding(.horizontal, 15)
                .padding(.top, 10)
                
                // 头像
                ZStack {
                    Circle()
                        .fill(Color.black)
                        .frame(width: 80, height: 80)
                    
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color(hex: "#fce7f3"),
                                    Color(hex: "#f9a8d4"),
                                    Color(hex: "#ec4899")
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 60, height: 60)
                    
                    Image(systemName: "person.fill")
                        .font(.system(size: 30))
                        .foregroundColor(.white)
                }
                .padding(.bottom, 12)
                
                // 用户名
                Text(user?.nickname ?? "泡泡のred")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.white)
                    .padding(.bottom, 20)
            }
        }
        .frame(height: 200)
    }
}

// MARK: - 统计卡片行
struct StatsRow: View {
    let credits: Int
    let memberDays: Int
    let onCreditsTap: () -> Void
    let onMemberTap: () -> Void
    
    var body: some View {
        HStack(spacing: 12) {
            // 积分卡片
            Button(action: onCreditsTap) {
                HStack {
                    HStack(spacing: 8) {
                        // 图标
                        Image(systemName: "square.grid.2x2")
                            .font(.system(size: 18))
                            .foregroundColor(Color(hex: "#a855f7"))
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text("积分")
                                .font(.system(size: 12))
                                .foregroundColor(Color(hex: "#888888"))
                            
                            Text("\(credits)")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.white)
                        }
                    }
                    
                    Spacer()
                    
                    // 充值按钮
                    Text("充值")
                        .font(.system(size: 11))
                        .foregroundColor(.white)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(Color.white.opacity(0.15))
                        .cornerRadius(12)
                }
                .padding(.horizontal, 15)
                .padding(.vertical, 12)
                .background(Color.white.opacity(0.08))
                .cornerRadius(12)
            }
            
            // 会员卡片
            Button(action: onMemberTap) {
                HStack {
                    HStack(spacing: 8) {
                        // 图标
                        Image(systemName: "crown")
                            .font(.system(size: 18))
                            .foregroundColor(Color(hex: "#a855f7"))
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text("会员")
                                .font(.system(size: 12))
                                .foregroundColor(Color(hex: "#888888"))
                            
                            Text(memberDays > 0 ? "\(memberDays)天" : "未开通")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.white)
                        }
                    }
                    
                    Spacer()
                    
                    // 添加按钮
                    Image(systemName: "plus")
                        .font(.system(size: 16))
                        .foregroundColor(Color(hex: "#888888"))
                        .frame(width: 24, height: 24)
                }
                .padding(.horizontal, 15)
                .padding(.vertical, 12)
                .background(Color.white.opacity(0.08))
                .cornerRadius(12)
            }
        }
        .padding(.horizontal, 20)
    }
}

// MARK: - 内容Tab
struct ProfileContentTabs: View {
    @Binding var selectedTab: Int
    
    var body: some View {
        HStack(spacing: 0) {
            ForEach(0..<3, id: \.self) { index in
                Button(action: { 
                    withAnimation(.easeInOut(duration: 0.2)) {
                        selectedTab = index 
                    }
                }) {
                    VStack(spacing: 0) {
                        Text(tabTitle(for: index))
                            .font(.system(size: 15))
                            .foregroundColor(selectedTab == index ? .white : Color(hex: "#666666"))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 15)
                        
                        // 下划线
                        if selectedTab == index {
                            RoundedRectangle(cornerRadius: 2)
                                .fill(Color.white)
                                .frame(width: 30, height: 3)
                        } else {
                            Color.clear
                                .frame(width: 30, height: 3)
                        }
                    }
                }
            }
        }
        .padding(.top, 25)
        .overlay(
            Rectangle()
                .fill(Color.white.opacity(0.1))
                .frame(height: 1),
            alignment: .bottom
        )
    }
    
    private func tabTitle(for index: Int) -> String {
        switch index {
        case 0: return "作品"
        case 1: return "点赞"
        case 2: return "收藏"
        default: return ""
        }
    }
}

// MARK: - 内容区域
struct ProfileContentArea: View {
    let selectedTab: Int
    let works: [ProfileWork]
    let likedWorks: [ProfileWork]
    
    var body: some View {
        let currentWorks = selectedTab == 0 ? works : (selectedTab == 1 ? likedWorks : [])
        
        if currentWorks.isEmpty {
            // 空状态
            VStack(spacing: 20) {
                // 空状态图标
                ZStack {
                    Circle()
                        .stroke(Color(hex: "#333333"), lineWidth: 2)
                        .frame(width: 60, height: 60)
                    
                    Image(systemName: emptyIcon(for: selectedTab))
                        .font(.system(size: 24))
                        .foregroundColor(Color(hex: "#444444"))
                }
                
                Text(emptyText(for: selectedTab))
                    .font(.system(size: 14))
                    .foregroundColor(Color(hex: "#666666"))
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .padding(.top, 60)
        } else {
            // 作品网格
            ScrollView(showsIndicators: false) {
                LazyVGrid(columns: [
                    GridItem(.flexible(), spacing: 8),
                    GridItem(.flexible(), spacing: 8)
                ], spacing: 8) {
                    ForEach(currentWorks) { work in
                        ProfileWorkCard(work: work)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 15)
                .padding(.bottom, 100)
            }
        }
    }
    
    private func emptyIcon(for tab: Int) -> String {
        switch tab {
        case 0: return "photo.on.rectangle"
        case 1: return "heart"
        case 2: return "star"
        default: return "photo"
        }
    }
    
    private func emptyText(for tab: Int) -> String {
        switch tab {
        case 0: return "还没有作品\n快去创作你的第一个AI作品吧"
        case 1: return "还没有点赞\n发现喜欢的作品点个赞吧"
        case 2: return "还没有收藏\n收藏喜欢的作品方便查看"
        default: return ""
        }
    }
}

// MARK: - 作品卡片
struct ProfileWorkCard: View {
    let work: ProfileWork
    
    var body: some View {
        ZStack(alignment: .bottomLeading) {
            // 图片
            if let url = URL(string: work.imageURL) {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .success(let image):
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    case .failure, .empty:
                        LinearGradient(
                            colors: [Color(hex: "#a855f7"), Color(hex: "#ec4899")],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    @unknown default:
                        EmptyView()
                    }
                }
            } else {
                LinearGradient(
                    colors: [Color(hex: "#a855f7"), Color(hex: "#ec4899")],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            }
            
            // 点赞数
            HStack(spacing: 4) {
                Image(systemName: "heart.fill")
                    .font(.system(size: 10))
                Text("\(work.likeCount)")
                    .font(.system(size: 11))
            }
            .foregroundColor(.white)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(Color.black.opacity(0.5))
            .cornerRadius(10)
            .padding(8)
        }
        .frame(height: 200)
        .cornerRadius(12)
        .clipped()
    }
}

// MARK: - 底部导航
struct ProfileBottomNav: View {
    var body: some View {
        HStack {
            // 首页
            VStack(spacing: 4) {
                Image(systemName: "house")
                    .font(.system(size: 22))
                Text("首页")
                    .font(.system(size: 10))
            }
            .foregroundColor(Color(hex: "#666666"))
            .frame(maxWidth: .infinity)
            
            // 创作按钮
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
                    .shadow(color: Color(hex: "#a855f7").opacity(0.4), radius: 10, x: 0, y: 4)
                
                Image(systemName: "plus")
                    .font(.system(size: 24, weight: .medium))
                    .foregroundColor(.white)
            }
            .offset(y: -20)
            
            // 我的（选中状态）
            VStack(spacing: 4) {
                Image(systemName: "person.fill")
                    .font(.system(size: 22))
                Text("我的")
                    .font(.system(size: 10))
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
        }
        .frame(height: 80)
        .background(
            LinearGradient(
                colors: [Color.clear, Color(hex: "#0D0D0D")],
                startPoint: .top,
                endPoint: .bottom
            )
        )
        .padding(.bottom, 20)
    }
}

// MARK: - 数据模型
struct ProfileUser {
    let id: String
    let nickname: String
    let avatarURL: String
    let credits: Int
    let memberDaysLeft: Int
    let isMember: Bool
}

struct ProfileWork: Identifiable {
    let id: String
    let imageURL: String
    let likeCount: Int
}

// MARK: - ViewModel
class ProfileViewModel: ObservableObject {
    @Published var user: ProfileUser?
    @Published var myWorks: [ProfileWork] = []
    @Published var likedWorks: [ProfileWork] = []
    @Published var isLoading = false
    
    func loadUserData() {
        isLoading = true
        
        // 模拟加载数据
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            self?.user = ProfileUser(
                id: "1",
                nickname: "泡泡のred",
                avatarURL: "",
                credits: 100,
                memberDaysLeft: 0,
                isMember: false
            )
            
            // 模拟空状态
            self?.myWorks = []
            self?.likedWorks = []
            
            self?.isLoading = false
        }
    }
    
    func openSettings() {
        AnalyticsManager.shared.trackAction(.clickSettings, properties: [:])
        // 跳转到设置页
    }
    
    func openRecharge() {
        AnalyticsManager.shared.trackAction(.clickRecharge, properties: [:])
        // 跳转到充值页
    }
    
    func openMembership() {
        AnalyticsManager.shared.trackAction(.clickMembership, properties: [:])
        // 跳转到会员页
    }
}

// MARK: - 预览
#Preview {
    ProfileView()
}
