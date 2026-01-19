//
//  DetailView.swift
//  AICreatorApp
//
//  作品详情页 - 完全匹配原型图设计
//  基于设计规范文档 v3.0
//
//  Created by Manus AI on 2026/1/19.
//

import SwiftUI

// MARK: - 作品详情页主视图
struct DetailView: View {
    let workId: String
    @StateObject private var viewModel = DetailViewModel()
    @Environment(\.dismiss) private var dismiss
    @State private var showShareSheet = false
    @State private var showCompare = false
    
    var body: some View {
        ZStack {
            // 背景
            Color(hex: "#0D0D0D")
                .ignoresSafeArea()
            
            // 主图区域
            VStack(spacing: 0) {
                // 主图
                MainImageSection(
                    work: viewModel.work,
                    showCompare: $showCompare
                )
                
                // 内容区域
                ContentSection(
                    work: viewModel.work,
                    followWorks: viewModel.followWorks
                )
            }
            
            // 状态栏
            VStack {
                DetailStatusBar()
                Spacer()
            }
            
            // 导航栏
            VStack {
                DetailNavHeader(
                    title: viewModel.work?.title ?? "作品详情",
                    onBack: { dismiss() },
                    onShare: { showShareSheet = true }
                )
                Spacer()
            }
            .padding(.top, 44)
            
            // 底部操作栏
            VStack {
                Spacer()
                DetailBottomActionBar(
                    isLiked: viewModel.isLiked,
                    onLikeTap: { viewModel.toggleLike() },
                    onGenerateTap: { viewModel.followGenerate() }
                )
            }
        }
        .navigationBarHidden(true)
        .sheet(isPresented: $showShareSheet) {
            DetailShareSheet(work: viewModel.work)
        }
        .onAppear {
            viewModel.loadWork(id: workId)
            AnalyticsManager.shared.trackPageView(.detail)
        }
    }
}

// MARK: - 状态栏
struct DetailStatusBar: View {
    var body: some View {
        HStack {
            Text("22:49")
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

// MARK: - 导航栏
struct DetailNavHeader: View {
    let title: String
    let onBack: () -> Void
    let onShare: () -> Void
    
    var body: some View {
        HStack {
            // 返回按钮
            Button(action: onBack) {
                ZStack {
                    Circle()
                        .fill(Color(hex: "#646464").opacity(0.5))
                        .frame(width: 36, height: 36)
                        .background(.ultraThinMaterial.opacity(0.3))
                        .clipShape(Circle())
                    
                    Image(systemName: "chevron.left")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white)
                }
            }
            
            Spacer()
            
            // 标题
            Text(title)
                .font(.system(size: 17, weight: .semibold))
                .foregroundColor(.white)
            
            Spacer()
            
            // 分享按钮
            Button(action: onShare) {
                Image(systemName: "square.and.arrow.up")
                    .font(.system(size: 20))
                    .foregroundColor(.white)
                    .frame(width: 36, height: 36)
            }
        }
        .padding(.horizontal, 15)
        .frame(height: 50)
    }
}

// MARK: - 主图区域
struct MainImageSection: View {
    let work: DetailWorkModel?
    @Binding var showCompare: Bool
    
    var body: some View {
        ZStack(alignment: .topLeading) {
            // 主图
            if let work = work, let url = URL(string: work.imageURL) {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .success(let image):
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    case .failure, .empty:
                        // 占位渐变
                        LinearGradient(
                            colors: [
                                Color(hex: "#e0f2fe"),
                                Color(hex: "#7dd3fc"),
                                Color(hex: "#0ea5e9")
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    @unknown default:
                        EmptyView()
                    }
                }
            } else {
                // 默认占位渐变
                LinearGradient(
                    colors: [
                        Color(hex: "#e0f2fe"),
                        Color(hex: "#7dd3fc"),
                        Color(hex: "#0ea5e9")
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            }
            
            // AI生成标签
            VStack {
                Spacer().frame(height: 100)
                
                HStack {
                    Text("AI生成")
                        .font(.system(size: 12))
                        .foregroundColor(.white)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color.black.opacity(0.5))
                        .background(.ultraThinMaterial.opacity(0.3))
                        .cornerRadius(15)
                    
                    Spacer()
                }
                .padding(.leading, 15)
                
                Spacer()
            }
            
            // 对比按钮
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    Button(action: { showCompare.toggle() }) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color.black.opacity(0.5))
                                .background(.ultraThinMaterial.opacity(0.3))
                                .frame(width: 40, height: 40)
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                            
                            Image(systemName: "rectangle.on.rectangle")
                                .font(.system(size: 18))
                                .foregroundColor(.white)
                        }
                    }
                    .padding(.trailing, 15)
                    .padding(.bottom, 15)
                }
            }
        }
        .frame(height: 480)
        .clipped()
    }
}

// MARK: - 内容区域
struct ContentSection: View {
    let work: DetailWorkModel?
    let followWorks: [DetailFollowWork]
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 15) {
                // 作者信息
                DetailAuthorRow(author: work?.author)
                
                // 提示词区域
                DetailPromptSection(prompt: work?.prompt ?? "")
                
                // 跟图区域
                DetailFollowSection(followWorks: followWorks)
            }
            .padding(.horizontal, 20)
            .padding(.top, 15)
            .padding(.bottom, 100)
        }
    }
}

// MARK: - 作者信息行
struct DetailAuthorRow: View {
    let author: DetailAuthor?
    
    var body: some View {
        HStack(spacing: 12) {
            // 头像
            Circle()
                .fill(
                    LinearGradient(
                        colors: [Color(hex: "#a855f7"), Color(hex: "#ec4899")],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 40, height: 40)
            
            // 用户名
            Text(author?.nickname ?? "创作者")
                .font(.system(size: 15, weight: .medium))
                .foregroundColor(.white)
            
            Spacer()
        }
    }
}

// MARK: - 提示词区域
struct DetailPromptSection: View {
    let prompt: String
    @State private var isExpanded = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            // 标题行
            HStack {
                Text("提示词")
                    .font(.system(size: 13))
                    .foregroundColor(Color(hex: "#888888"))
                
                Spacer()
                
                // 复制按钮
                Button(action: {
                    UIPasteboard.general.string = prompt
                }) {
                    Image(systemName: "doc.on.doc")
                        .font(.system(size: 16))
                        .foregroundColor(Color(hex: "#888888"))
                }
            }
            
            // 提示词内容
            HStack(alignment: .bottom) {
                Text(prompt.isEmpty ? "雪地上画一个爱心，浪漫唯美风格，高清细节..." : prompt)
                    .font(.system(size: 14))
                    .foregroundColor(Color(hex: "#cccccc"))
                    .lineLimit(isExpanded ? nil : 2)
                    .lineSpacing(4)
                
                if !isExpanded {
                    Button(action: { isExpanded = true }) {
                        Text("展开")
                            .font(.system(size: 13))
                            .foregroundColor(Color(hex: "#a855f7"))
                    }
                }
            }
        }
        .padding(15)
        .background(Color.white.opacity(0.05))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.white.opacity(0.1), lineWidth: 1)
        )
    }
}

// MARK: - 跟图区域
struct DetailFollowSection: View {
    let followWorks: [DetailFollowWork]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // 标题行
            HStack {
                Text("跟图")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(.white)
                
                Text("\(followWorks.count)")
                    .font(.system(size: 14))
                    .foregroundColor(Color(hex: "#888888"))
                
                Spacer()
            }
            
            // 跟图列表
            VStack(spacing: 15) {
                ForEach(followWorks) { work in
                    DetailFollowWorkItem(work: work)
                }
            }
        }
    }
}

// MARK: - 跟图项
struct DetailFollowWorkItem: View {
    let work: DetailFollowWork
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            // 头像
            Circle()
                .fill(
                    LinearGradient(
                        colors: [Color(hex: "#fce7f3"), Color(hex: "#f9a8d4")],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 32, height: 32)
            
            // 内容
            VStack(alignment: .leading, spacing: 8) {
                Text(work.authorName)
                    .font(.system(size: 13))
                    .foregroundColor(Color(hex: "#888888"))
                
                // 图片
                RoundedRectangle(cornerRadius: 12)
                    .fill(
                        LinearGradient(
                            colors: [Color(hex: "#e0f2fe"), Color(hex: "#7dd3fc")],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 140, height: 180)
                
                // 点赞
                HStack(spacing: 4) {
                    Image(systemName: "heart.fill")
                        .font(.system(size: 12))
                    Text("\(work.likeCount)")
                        .font(.system(size: 13))
                }
                .foregroundColor(Color(hex: "#666666"))
            }
            
            Spacer()
        }
    }
}

// MARK: - 底部操作栏
struct DetailBottomActionBar: View {
    let isLiked: Bool
    let onLikeTap: () -> Void
    let onGenerateTap: () -> Void
    
    var body: some View {
        HStack(spacing: 15) {
            // 点赞按钮
            Button(action: onLikeTap) {
                Image(systemName: isLiked ? "heart.fill" : "heart")
                    .font(.system(size: 28))
                    .foregroundColor(Color(hex: "#ec4899"))
                    .frame(width: 44, height: 44)
            }
            .sensoryFeedback(.impact(flexibility: .soft), trigger: isLiked)
            
            // 跟图生成按钮
            Button(action: onGenerateTap) {
                Text("跟图生成")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(
                        LinearGradient(
                            colors: [Color(hex: "#a855f7"), Color(hex: "#ec4899")],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .cornerRadius(25)
            }
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 25)
        .frame(height: 90)
        .background(
            LinearGradient(
                colors: [Color.clear, Color(hex: "#0D0D0D")],
                startPoint: .top,
                endPoint: .bottom
            )
        )
    }
}

// MARK: - 分享Sheet
struct DetailShareSheet: View {
    let work: DetailWorkModel?
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack(spacing: 20) {
            // 拖动指示器
            RoundedRectangle(cornerRadius: 2.5)
                .fill(Color.gray.opacity(0.5))
                .frame(width: 36, height: 5)
                .padding(.top, 10)
            
            Text("分享到")
                .font(.system(size: 17, weight: .semibold))
                .foregroundColor(.white)
            
            // 分享选项
            HStack(spacing: 30) {
                DetailShareOption(icon: "message.fill", title: "微信", color: Color(hex: "#07C160"))
                DetailShareOption(icon: "person.2.fill", title: "朋友圈", color: Color(hex: "#07C160"))
                DetailShareOption(icon: "link", title: "复制链接", color: Color(hex: "#888888"))
                DetailShareOption(icon: "square.and.arrow.down", title: "保存图片", color: Color(hex: "#888888"))
            }
            .padding(.vertical, 20)
            
            // 取消按钮
            Button(action: { dismiss() }) {
                Text("取消")
                    .font(.system(size: 16))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(Color.white.opacity(0.1))
                    .cornerRadius(25)
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 30)
        }
        .background(Color(hex: "#1a1a1a"))
        .presentationDetents([.height(280)])
        .presentationDragIndicator(.hidden)
    }
}

// MARK: - 分享选项
struct DetailShareOption: View {
    let icon: String
    let title: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            ZStack {
                Circle()
                    .fill(color.opacity(0.2))
                    .frame(width: 56, height: 56)
                
                Image(systemName: icon)
                    .font(.system(size: 24))
                    .foregroundColor(color)
            }
            
            Text(title)
                .font(.system(size: 12))
                .foregroundColor(Color(hex: "#888888"))
        }
    }
}

// MARK: - 数据模型
struct DetailWorkModel: Identifiable {
    let id: String
    let title: String
    let imageURL: String
    let prompt: String
    let author: DetailAuthor
    let likeCount: Int
    let viewCount: Int
}

struct DetailAuthor {
    let id: String
    let nickname: String
    let avatarURL: String
}

struct DetailFollowWork: Identifiable {
    let id: String
    let authorName: String
    let imageURL: String
    let likeCount: Int
}

// MARK: - ViewModel
class DetailViewModel: ObservableObject {
    @Published var work: DetailWorkModel?
    @Published var followWorks: [DetailFollowWork] = []
    @Published var isLiked = false
    @Published var isLoading = false
    
    func loadWork(id: String) {
        isLoading = true
        
        // 模拟加载数据
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            self?.work = DetailWorkModel(
                id: id,
                title: "雪地爱心",
                imageURL: "",
                prompt: "雪地上画一个爱心，浪漫唯美风格，高清细节，冬日阳光照射，温暖氛围",
                author: DetailAuthor(id: "1", nickname: "创意小达人", avatarURL: ""),
                likeCount: 1234,
                viewCount: 5678
            )
            
            self?.followWorks = [
                DetailFollowWork(id: "1", authorName: "用户A", imageURL: "", likeCount: 128),
                DetailFollowWork(id: "2", authorName: "用户B", imageURL: "", likeCount: 256)
            ]
            
            self?.isLoading = false
        }
    }
    
    func toggleLike() {
        isLiked.toggle()
        
        AnalyticsManager.shared.trackAction(
            isLiked ? .likeWork : .unlikeWork,
            properties: ["work_id": work?.id ?? ""]
        )
    }
    
    func followGenerate() {
        AnalyticsManager.shared.trackAction(.clickFollowGenerate, properties: [
            "work_id": work?.id ?? ""
        ])
        // 跳转到生成页面
    }
}

// MARK: - 预览
#Preview {
    DetailView(workId: "test-123")
}
