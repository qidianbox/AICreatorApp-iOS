//
//  DetailView.swift
//  AICreatorApp
//
//  作品详情页 - 完整SwiftUI代码框架
//  基于设计规范文档 v3.0
//
//  Created by Manus AI on 2026/1/19.
//

import SwiftUI

// MARK: - 详情页主视图
struct DetailView: View {
    
    let workId: String
    @StateObject private var viewModel = DetailViewModel()
    @Environment(\.dismiss) private var dismiss
    @State private var showShareSheet = false
    @State private var showReportSheet = false
    @State private var imageScale: CGFloat = 1.0
    @State private var showCompare = false
    
    var body: some View {
        ZStack {
            Color.appBackground
                .ignoresSafeArea()
            
            if let work = viewModel.work {
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 0) {
                        // 作品图片
                        WorkImageSection(
                            work: work,
                            showCompare: $showCompare,
                            imageScale: $imageScale
                        )
                        
                        // 操作按钮栏
                        ActionButtonsBar(
                            work: work,
                            isLiked: viewModel.isLiked,
                            onLike: { viewModel.toggleLike() },
                            onShare: { showShareSheet = true },
                            onSave: { viewModel.saveImage() },
                            onReport: { showReportSheet = true }
                        )
                        
                        // 提示词区域
                        PromptSection(prompt: work.prompt)
                        
                        // 跟图生成区域
                        FollowGenerateSection(
                            templateId: work.templateId,
                            templateName: work.templateName
                        )
                        
                        // 相关作品
                        RelatedWorksSection(
                            works: viewModel.relatedWorks,
                            onWorkTap: { workId in
                                viewModel.navigateToWork(workId)
                            }
                        )
                        
                        Spacer(minLength: 100)
                    }
                }
                
                // 底部操作栏
                VStack {
                    Spacer()
                    BottomActionBar(
                        work: work,
                        onFollowGenerate: { viewModel.followGenerate() }
                    )
                }
            } else if viewModel.isLoading {
                LoadingOverlay()
            } else {
                EmptyStateView(
                    icon: "photo.on.rectangle.angled",
                    title: "作品不存在",
                    subtitle: "该作品可能已被删除"
                )
            }
        }
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                BackButton { dismiss() }
            }
            
            ToolbarItem(placement: .navigationBarTrailing) {
                HStack(spacing: Spacing.sm) {
                    Button(action: { showShareSheet = true }) {
                        Image(systemName: "square.and.arrow.up")
                            .foregroundColor(.textPrimary)
                    }
                    
                    Menu {
                        Button(action: { showReportSheet = true }) {
                            Label("举报", systemImage: "exclamationmark.triangle")
                        }
                    } label: {
                        Image(systemName: "ellipsis")
                            .foregroundColor(.textPrimary)
                    }
                }
            }
        }
        .sheet(isPresented: $showShareSheet) {
            ShareSheet(work: viewModel.work!)
        }
        .sheet(isPresented: $showReportSheet) {
            ReportSheet(workId: workId)
        }
        .onAppear {
            AnalyticsManager.shared.trackPageView(.detail, properties: [
                "work_id": workId
            ])
            
            Task {
                await viewModel.loadWork(id: workId)
            }
        }
    }
}

// MARK: - 作品图片区域
struct WorkImageSection: View {
    let work: WorkDetail
    @Binding var showCompare: Bool
    @Binding var imageScale: CGFloat
    
    var body: some View {
        ZStack {
            // 生成后的图片
            AsyncImage(url: URL(string: work.imageURL)) { phase in
                switch phase {
                case .success(let image):
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .scaleEffect(imageScale)
                        .gesture(
                            MagnificationGesture()
                                .onChanged { value in
                                    imageScale = min(max(value, 1), 3)
                                }
                                .onEnded { _ in
                                    withAnimation {
                                        imageScale = 1
                                    }
                                }
                        )
                case .failure, .empty:
                    Rectangle()
                        .fill(Color.primaryGradient.opacity(0.3))
                        .aspectRatio(3/4, contentMode: .fit)
                @unknown default:
                    EmptyView()
                }
            }
            .opacity(showCompare ? 0 : 1)
            
            // 原图（对比时显示）
            if showCompare, let originalURL = work.originalImageURL {
                AsyncImage(url: URL(string: originalURL)) { phase in
                    switch phase {
                    case .success(let image):
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                    case .failure, .empty:
                        Rectangle()
                            .fill(Color.inputBackground)
                            .aspectRatio(3/4, contentMode: .fit)
                    @unknown default:
                        EmptyView()
                    }
                }
            }
            
            // 对比按钮
            if work.originalImageURL != nil {
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        
                        Button(action: {}) {
                            HStack(spacing: Spacing.xxs) {
                                Image(systemName: showCompare ? "photo.fill" : "photo.on.rectangle")
                                    .font(.system(size: 14))
                                Text(showCompare ? "查看效果" : "查看原图")
                                    .font(.caption1)
                            }
                            .foregroundColor(.white)
                            .padding(.horizontal, Spacing.sm)
                            .padding(.vertical, Spacing.xs)
                            .background(Color.black.opacity(0.6))
                            .cornerRadius(CornerRadius.full)
                        }
                        .simultaneousGesture(
                            DragGesture(minimumDistance: 0)
                                .onChanged { _ in showCompare = true }
                                .onEnded { _ in showCompare = false }
                        )
                        .padding(Spacing.md)
                    }
                }
            }
        }
    }
}

// MARK: - 操作按钮栏
struct ActionButtonsBar: View {
    let work: WorkDetail
    let isLiked: Bool
    let onLike: () -> Void
    let onShare: () -> Void
    let onSave: () -> Void
    let onReport: () -> Void
    
    var body: some View {
        HStack(spacing: Spacing.xl) {
            // 点赞
            ActionButton(
                icon: isLiked ? "heart.fill" : "heart",
                label: formatCount(work.likeCount),
                isActive: isLiked,
                activeColor: .red
            ) {
                onLike()
            }
            
            // 分享
            ActionButton(
                icon: "arrowshape.turn.up.right",
                label: "分享"
            ) {
                onShare()
            }
            
            // 保存
            ActionButton(
                icon: "arrow.down.to.line",
                label: "保存"
            ) {
                onSave()
            }
            
            Spacer()
            
            // 用户信息
            HStack(spacing: Spacing.xs) {
                AsyncImage(url: URL(string: work.author.avatar)) { phase in
                    switch phase {
                    case .success(let image):
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    case .failure, .empty:
                        Circle()
                            .fill(Color.primaryGradient)
                    @unknown default:
                        EmptyView()
                    }
                }
                .frame(width: 32, height: 32)
                .clipShape(Circle())
                
                Text(work.author.nickname)
                    .font(.caption1)
                    .foregroundColor(.textPrimary)
            }
        }
        .padding(.horizontal, Spacing.md)
        .padding(.vertical, Spacing.sm)
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

// MARK: - 操作按钮
struct ActionButton: View {
    let icon: String
    let label: String
    var isActive: Bool = false
    var activeColor: Color = .gradientPurple
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: Spacing.xxs) {
                Image(systemName: icon)
                    .font(.system(size: 20))
                    .foregroundColor(isActive ? activeColor : .textSecondary)
                
                Text(label)
                    .font(.caption2)
                    .foregroundColor(.textSecondary)
            }
        }
        .sensoryFeedback(.impact(flexibility: .soft), trigger: isActive)
    }
}

// MARK: - 提示词区域
struct PromptSection: View {
    let prompt: String
    @State private var isCopied = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            HStack {
                Text("提示词")
                    .font(.bodyMedium)
                    .fontWeight(.semibold)
                    .foregroundColor(.textPrimary)
                
                Spacer()
                
                Button(action: copyPrompt) {
                    HStack(spacing: Spacing.xxs) {
                        Image(systemName: isCopied ? "checkmark" : "doc.on.doc")
                            .font(.system(size: 12))
                        Text(isCopied ? "已复制" : "复制")
                            .font(.caption1)
                    }
                    .foregroundColor(isCopied ? .green : .textSecondary)
                }
            }
            
            Text(prompt)
                .font(.bodySmall)
                .foregroundColor(.textSecondary)
                .lineLimit(nil)
                .padding(Spacing.sm)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.inputBackground)
                .cornerRadius(CornerRadius.sm)
        }
        .padding(.horizontal, Spacing.md)
        .padding(.vertical, Spacing.md)
    }
    
    private func copyPrompt() {
        UIPasteboard.general.string = prompt
        isCopied = true
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            isCopied = false
        }
    }
}

// MARK: - 跟图生成区域
struct FollowGenerateSection: View {
    let templateId: String
    let templateName: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            Text("使用模板")
                .font(.bodyMedium)
                .fontWeight(.semibold)
                .foregroundColor(.textPrimary)
            
            HStack(spacing: Spacing.sm) {
                // 模板图标
                RoundedRectangle(cornerRadius: CornerRadius.sm)
                    .fill(Color.primaryGradient)
                    .frame(width: 50, height: 50)
                    .overlay(
                        Image(systemName: "wand.and.stars")
                            .foregroundColor(.white)
                    )
                
                VStack(alignment: .leading, spacing: Spacing.xxs) {
                    Text(templateName)
                        .font(.bodyMedium)
                        .foregroundColor(.textPrimary)
                    
                    Text("点击使用同款模板生成")
                        .font(.caption1)
                        .foregroundColor(.textSecondary)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .foregroundColor(.textTertiary)
            }
            .padding(Spacing.sm)
            .background(Color.cardBackground)
            .cornerRadius(CornerRadius.md)
        }
        .padding(.horizontal, Spacing.md)
    }
}

// MARK: - 相关作品区域
struct RelatedWorksSection: View {
    let works: [WorkListItem]
    let onWorkTap: (String) -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            Text("相关作品")
                .font(.bodyMedium)
                .fontWeight(.semibold)
                .foregroundColor(.textPrimary)
                .padding(.horizontal, Spacing.md)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: Spacing.sm) {
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
                            .frame(width: 100, height: 130)
                            .clipped()
                            .cornerRadius(CornerRadius.sm)
                        }
                    }
                }
                .padding(.horizontal, Spacing.md)
            }
        }
        .padding(.vertical, Spacing.md)
    }
}

// MARK: - 底部操作栏
struct BottomActionBar: View {
    let work: WorkDetail
    let onFollowGenerate: () -> Void
    
    var body: some View {
        HStack(spacing: Spacing.md) {
            // 跟图生成按钮
            Button(action: {
                AnalyticsManager.shared.trackAction(.clickFollowGenerate, properties: [
                    "work_id": work.id,
                    "template_id": work.templateId
                ])
                onFollowGenerate()
            }) {
                HStack(spacing: Spacing.xs) {
                    Image(systemName: "wand.and.stars")
                        .font(.system(size: 18))
                    Text("跟图生成")
                        .font(.buttonMedium)
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 50)
                .background(Color.primaryGradient)
                .cornerRadius(CornerRadius.md)
            }
        }
        .padding(.horizontal, Spacing.md)
        .padding(.vertical, Spacing.sm)
        .background(
            Color.appBackground
                .shadow(color: .black.opacity(0.1), radius: 10, y: -5)
        )
    }
}

// MARK: - 分享Sheet
struct ShareSheet: View {
    let work: WorkDetail
    @Environment(\.dismiss) private var dismiss
    
    private let shareOptions = [
        ("微信好友", "wechat_icon", Color(hex: "#07C160")),
        ("朋友圈", "moments_icon", Color(hex: "#07C160")),
        ("保存图片", "arrow.down.to.line", Color.textSecondary),
        ("复制链接", "link", Color.textSecondary)
    ]
    
    var body: some View {
        VStack(spacing: Spacing.lg) {
            // 拖动指示器
            RoundedRectangle(cornerRadius: 2)
                .fill(Color.textTertiary)
                .frame(width: 40, height: 4)
                .padding(.top, Spacing.sm)
            
            Text("分享到")
                .font(.bodyMedium)
                .fontWeight(.semibold)
                .foregroundColor(.textPrimary)
            
            // 分享选项
            HStack(spacing: Spacing.xl) {
                ForEach(shareOptions, id: \.0) { option in
                    Button(action: {
                        handleShare(option.0)
                    }) {
                        VStack(spacing: Spacing.xs) {
                            ZStack {
                                Circle()
                                    .fill(option.2.opacity(0.1))
                                    .frame(width: 56, height: 56)
                                
                                if option.1.contains("_icon") {
                                    Image(option.1)
                                        .resizable()
                                        .frame(width: 28, height: 28)
                                } else {
                                    Image(systemName: option.1)
                                        .font(.system(size: 24))
                                        .foregroundColor(option.2)
                                }
                            }
                            
                            Text(option.0)
                                .font(.caption1)
                                .foregroundColor(.textSecondary)
                        }
                    }
                }
            }
            .padding(.horizontal, Spacing.lg)
            
            // 取消按钮
            Button(action: { dismiss() }) {
                Text("取消")
                    .font(.buttonMedium)
                    .foregroundColor(.textSecondary)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(Color.inputBackground)
                    .cornerRadius(CornerRadius.md)
            }
            .padding(.horizontal, Spacing.md)
            .padding(.bottom, Spacing.lg)
        }
        .background(Color.appBackground)
        .presentationDetents([.height(280)])
        .presentationDragIndicator(.hidden)
    }
    
    private func handleShare(_ option: String) {
        AnalyticsManager.shared.trackAction(.clickShare, properties: [
            "work_id": work.id,
            "share_type": option
        ])
        
        switch option {
        case "微信好友":
            // 调用微信分享
            break
        case "朋友圈":
            // 调用朋友圈分享
            break
        case "保存图片":
            // 保存图片到相册
            break
        case "复制链接":
            UIPasteboard.general.string = "https://aicreator.app/work/\(work.id)"
            ErrorHandler.shared.showSuccessToast("链接已复制")
        default:
            break
        }
        
        dismiss()
    }
}

// MARK: - 举报Sheet
struct ReportSheet: View {
    let workId: String
    @Environment(\.dismiss) private var dismiss
    @State private var selectedReason: ReportReason?
    @State private var additionalInfo = ""
    @State private var isSubmitting = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.appBackground
                    .ignoresSafeArea()
                
                VStack(spacing: Spacing.lg) {
                    // 举报原因列表
                    VStack(spacing: 0) {
                        ForEach(ReportReason.allCases, id: \.self) { reason in
                            Button(action: { selectedReason = reason }) {
                                HStack {
                                    Text(reason.displayName)
                                        .font(.bodyMedium)
                                        .foregroundColor(.textPrimary)
                                    
                                    Spacer()
                                    
                                    if selectedReason == reason {
                                        Image(systemName: "checkmark")
                                            .foregroundStyle(Color.primaryGradient)
                                    }
                                }
                                .padding(.horizontal, Spacing.md)
                                .padding(.vertical, Spacing.sm)
                            }
                            
                            Divider()
                                .background(Color.borderDefault)
                        }
                    }
                    .background(Color.cardBackground)
                    .cornerRadius(CornerRadius.md)
                    .padding(.horizontal, Spacing.md)
                    
                    // 补充说明
                    VStack(alignment: .leading, spacing: Spacing.xs) {
                        Text("补充说明（选填）")
                            .font(.caption1)
                            .foregroundColor(.textSecondary)
                        
                        TextEditor(text: $additionalInfo)
                            .font(.bodySmall)
                            .foregroundColor(.textPrimary)
                            .frame(height: 100)
                            .padding(Spacing.xs)
                            .background(Color.inputBackground)
                            .cornerRadius(CornerRadius.sm)
                    }
                    .padding(.horizontal, Spacing.md)
                    
                    Spacer()
                    
                    // 提交按钮
                    Button(action: submitReport) {
                        if isSubmitting {
                            ProgressView()
                                .tint(.white)
                        } else {
                            Text("提交举报")
                                .font(.buttonMedium)
                        }
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(
                        selectedReason != nil
                            ? AnyShapeStyle(Color.primaryGradient)
                            : AnyShapeStyle(Color.textDisabled)
                    )
                    .cornerRadius(CornerRadius.md)
                    .disabled(selectedReason == nil || isSubmitting)
                    .padding(.horizontal, Spacing.md)
                    .padding(.bottom, Spacing.lg)
                }
                .padding(.top, Spacing.md)
            }
            .navigationTitle("举报")
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
    }
    
    private func submitReport() {
        guard let reason = selectedReason else { return }
        
        isSubmitting = true
        
        Task {
            // 提交举报
            try? await Task.sleep(nanoseconds: 1_000_000_000)
            
            await MainActor.run {
                isSubmitting = false
                ErrorHandler.shared.showSuccessToast("举报已提交，我们会尽快处理")
                dismiss()
            }
        }
    }
}

// MARK: - 举报原因
enum ReportReason: String, CaseIterable {
    case inappropriate = "inappropriate"
    case copyright = "copyright"
    case spam = "spam"
    case fraud = "fraud"
    case other = "other"
    
    var displayName: String {
        switch self {
        case .inappropriate: return "内容不适当"
        case .copyright: return "侵犯版权"
        case .spam: return "垃圾广告"
        case .fraud: return "欺诈信息"
        case .other: return "其他原因"
        }
    }
}

// MARK: - 返回按钮
struct BackButton: View {
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Image(systemName: "chevron.left")
                .font(.system(size: 18, weight: .medium))
                .foregroundColor(.textPrimary)
        }
    }
}

// MARK: - 空状态视图
struct EmptyStateView: View {
    let icon: String
    let title: String
    let subtitle: String
    
    var body: some View {
        VStack(spacing: Spacing.md) {
            Image(systemName: icon)
                .font(.system(size: 50))
                .foregroundColor(.textTertiary)
            
            Text(title)
                .font(.bodyMedium)
                .fontWeight(.medium)
                .foregroundColor(.textPrimary)
            
            Text(subtitle)
                .font(.caption1)
                .foregroundColor(.textSecondary)
        }
    }
}

// MARK: - 详情ViewModel
@MainActor
class DetailViewModel: ObservableObject {
    
    @Published var work: WorkDetail?
    @Published var relatedWorks: [WorkListItem] = []
    @Published var isLoading = false
    @Published var isLiked = false
    
    // MARK: - 加载作品详情
    func loadWork(id: String) async {
        isLoading = true
        
        do {
            work = try await APIService.shared.getWorkDetail(id: id)
            isLiked = work?.isLiked ?? false
            
            // 加载相关作品
            await loadRelatedWorks()
        } catch {
            ErrorHandler.shared.handleAPIError(error as! APIError)
        }
        
        isLoading = false
    }
    
    // MARK: - 加载相关作品
    private func loadRelatedWorks() async {
        guard let work = work else { return }
        
        do {
            let response = try await APIService.shared.getWorks(
                page: 1,
                pageSize: 10,
                category: work.category.rawValue
            )
            relatedWorks = response.items.filter { $0.id != work.id }
        } catch {
            // 忽略错误
        }
    }
    
    // MARK: - 切换点赞
    func toggleLike() {
        guard let work = work else { return }
        
        isLiked.toggle()
        
        // 触觉反馈
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
        
        AnalyticsManager.shared.trackAction(.clickLike, properties: [
            "work_id": work.id,
            "is_liked": isLiked
        ])
        
        Task {
            do {
                if isLiked {
                    try await APIService.shared.likeWork(id: work.id)
                } else {
                    try await APIService.shared.unlikeWork(id: work.id)
                }
            } catch {
                // 回滚状态
                isLiked.toggle()
            }
        }
    }
    
    // MARK: - 保存图片
    func saveImage() {
        guard let work = work else { return }
        
        AnalyticsManager.shared.trackAction(.clickSaveImage, properties: [
            "work_id": work.id
        ])
        
        Task {
            do {
                guard let url = URL(string: work.imageURL),
                      let (data, _) = try? await URLSession.shared.data(from: url),
                      let image = UIImage(data: data) else {
                    throw APIError(code: -1, message: "Failed to load image", details: nil)
                }
                
                UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
                ErrorHandler.shared.showSuccessToast("图片已保存到相册")
            } catch {
                ErrorHandler.shared.showErrorToast("保存失败")
            }
        }
    }
    
    // MARK: - 跟图生成
    func followGenerate() {
        guard let work = work else { return }
        
        NotificationCenter.default.post(
            name: .navigateToCreate,
            object: nil,
            userInfo: ["templateId": work.templateId]
        )
    }
    
    // MARK: - 导航到作品
    func navigateToWork(_ workId: String) {
        NotificationCenter.default.post(
            name: .navigateToDetail,
            object: nil,
            userInfo: ["workId": workId]
        )
    }
}

// MARK: - 通知名称扩展
extension Notification.Name {
    static let navigateToCreate = Notification.Name("navigateToCreate")
    static let navigateToDetail = Notification.Name("navigateToDetail")
}

// MARK: - 预览
#Preview {
    NavigationStack {
        DetailView(workId: "1")
    }
    .preferredColorScheme(.dark)
}
