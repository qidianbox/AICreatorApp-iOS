//
//  CreateView.swift
//  AICreatorApp
//
//  创作页 - 完整SwiftUI代码框架
//  基于设计规范文档 v3.0
//
//  Created by Manus AI on 2026/1/19.
//

import SwiftUI
import PhotosUI

// MARK: - 创作页主视图
struct CreateView: View {
    
    @StateObject private var viewModel = CreateViewModel()
    @State private var selectedCategory: TemplateCategory = .all
    
    private let columns = [
        GridItem(.flexible(), spacing: Spacing.sm),
        GridItem(.flexible(), spacing: Spacing.sm)
    ]
    
    var body: some View {
        ZStack {
            Color.appBackground
                .ignoresSafeArea()
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: Spacing.lg) {
                    // 顶部Banner
                    CreateBannerView()
                        .padding(.horizontal, Spacing.md)
                    
                    // 热门模板区域
                    VStack(alignment: .leading, spacing: Spacing.md) {
                        SectionHeader(title: "热门模板", subtitle: "最受欢迎的AI风格")
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: Spacing.sm) {
                                ForEach(viewModel.hotTemplates) { template in
                                    HotTemplateCard(template: template) {
                                        viewModel.selectTemplate(template)
                                    }
                                }
                            }
                            .padding(.horizontal, Spacing.md)
                        }
                    }
                    
                    // 分类Tab
                    CategoryTabBar(
                        categories: TemplateCategory.allCases,
                        selectedCategory: $selectedCategory,
                        onCategoryChange: { category in
                            Task {
                                await viewModel.loadTemplates(category: category)
                            }
                        }
                    )
                    
                    // 模板网格
                    LazyVGrid(columns: columns, spacing: Spacing.sm) {
                        ForEach(viewModel.templates) { template in
                            TemplateCard(template: template) {
                                viewModel.selectTemplate(template)
                            }
                        }
                    }
                    .padding(.horizontal, Spacing.md)
                    .padding(.bottom, 100)
                }
            }
            .refreshable {
                await viewModel.refreshTemplates()
            }
            
            // 加载状态
            if viewModel.isLoading && viewModel.templates.isEmpty {
                LoadingOverlay()
            }
        }
        .sheet(item: $viewModel.selectedTemplate) { template in
            TemplateDetailSheet(template: template, viewModel: viewModel)
        }
        .fullScreenCover(isPresented: $viewModel.showGenerating) {
            GeneratingView(viewModel: viewModel)
        }
        .onAppear {
            AnalyticsManager.shared.trackPageView(.create)
            
            Task {
                await viewModel.loadInitialData()
            }
        }
    }
}

// MARK: - 创作Banner视图
struct CreateBannerView: View {
    var body: some View {
        ZStack(alignment: .leading) {
            // 渐变背景
            RoundedRectangle(cornerRadius: CornerRadius.lg)
                .fill(Color.primaryGradient)
                .frame(height: 120)
            
            HStack {
                VStack(alignment: .leading, spacing: Spacing.xs) {
                    Text("AI一键生成")
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    Text("上传照片，选择风格，即刻生成")
                        .font(.caption1)
                        .foregroundColor(.white.opacity(0.8))
                }
                .padding(.leading, Spacing.lg)
                
                Spacer()
                
                Image(systemName: "wand.and.stars")
                    .font(.system(size: 50))
                    .foregroundColor(.white.opacity(0.3))
                    .padding(.trailing, Spacing.lg)
            }
        }
    }
}

// MARK: - 区块标题
struct SectionHeader: View {
    let title: String
    let subtitle: String?
    var showMore: Bool = false
    var onMoreTap: (() -> Void)? = nil
    
    init(title: String, subtitle: String? = nil, showMore: Bool = false, onMoreTap: (() -> Void)? = nil) {
        self.title = title
        self.subtitle = subtitle
        self.showMore = showMore
        self.onMoreTap = onMoreTap
    }
    
    var body: some View {
        HStack(alignment: .bottom) {
            VStack(alignment: .leading, spacing: Spacing.xxs) {
                Text(title)
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundColor(.textPrimary)
                
                if let subtitle = subtitle {
                    Text(subtitle)
                        .font(.caption1)
                        .foregroundColor(.textSecondary)
                }
            }
            
            Spacer()
            
            if showMore {
                Button(action: { onMoreTap?() }) {
                    HStack(spacing: Spacing.xxs) {
                        Text("更多")
                            .font(.caption1)
                        Image(systemName: "chevron.right")
                            .font(.system(size: 10))
                    }
                    .foregroundColor(.textSecondary)
                }
            }
        }
        .padding(.horizontal, Spacing.md)
    }
}

// MARK: - 热门模板卡片
struct HotTemplateCard: View {
    let template: TemplateListItem
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 0) {
                // 封面图
                ZStack(alignment: .topTrailing) {
                    AsyncImage(url: URL(string: template.coverURL)) { phase in
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
                    .frame(width: 140, height: 180)
                    .clipped()
                    
                    // 标签
                    if template.isHot {
                        GradientTag(text: "热门")
                            .padding(Spacing.xs)
                    } else if template.isNew {
                        GradientTag(text: "新")
                            .padding(Spacing.xs)
                    }
                }
                
                // 信息
                VStack(alignment: .leading, spacing: Spacing.xxs) {
                    Text(template.name)
                        .font(.caption1)
                        .fontWeight(.medium)
                        .foregroundColor(.textPrimary)
                        .lineLimit(1)
                    
                    HStack(spacing: Spacing.xxs) {
                        Image(systemName: "bolt.fill")
                            .font(.system(size: 10))
                            .foregroundColor(.gradientPurple)
                        
                        Text(template.isFree ? "免费" : "\(template.pointsCost)积分")
                            .font(.caption2)
                            .foregroundColor(.textSecondary)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(Spacing.xs)
            }
            .frame(width: 140)
            .background(Color.cardBackground)
            .cornerRadius(CornerRadius.md)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - 模板卡片
struct TemplateCard: View {
    let template: TemplateListItem
    let onTap: () -> Void
    
    var body: some View {
        Button(action: {
            AnalyticsManager.shared.trackAction(.clickTemplateCard, properties: [
                "template_id": template.id,
                "template_name": template.name,
                "category": template.category.rawValue
            ])
            onTap()
        }) {
            VStack(spacing: 0) {
                // 封面图
                ZStack(alignment: .bottomTrailing) {
                    AsyncImage(url: URL(string: template.coverURL)) { phase in
                        switch phase {
                        case .success(let image):
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                        case .failure, .empty:
                            Rectangle()
                                .fill(Color.primaryGradient.opacity(0.3))
                                .overlay(
                                    Image(systemName: "photo")
                                        .foregroundColor(.textTertiary)
                                )
                        @unknown default:
                            EmptyView()
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .aspectRatio(3/4, contentMode: .fit)
                    .clipped()
                    
                    // 使用次数
                    HStack(spacing: 2) {
                        Image(systemName: "person.2.fill")
                            .font(.system(size: 10))
                        Text(formatCount(template.usageCount))
                            .font(.caption3)
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, Spacing.xs)
                    .padding(.vertical, 2)
                    .background(Color.black.opacity(0.5))
                    .cornerRadius(CornerRadius.xs)
                    .padding(Spacing.xs)
                }
                
                // 信息
                VStack(alignment: .leading, spacing: Spacing.xxs) {
                    Text(template.name)
                        .font(.caption1)
                        .fontWeight(.medium)
                        .foregroundColor(.textPrimary)
                        .lineLimit(1)
                    
                    HStack {
                        HStack(spacing: Spacing.xxs) {
                            Image(systemName: "bolt.fill")
                                .font(.system(size: 10))
                                .foregroundColor(.gradientPurple)
                            
                            Text(template.isFree ? "免费" : "\(template.pointsCost)积分")
                                .font(.caption2)
                                .foregroundColor(.textSecondary)
                        }
                        
                        Spacer()
                        
                        if template.isHot {
                            Image(systemName: "flame.fill")
                                .font(.system(size: 12))
                                .foregroundColor(.gradientOrange)
                        }
                    }
                }
                .padding(Spacing.xs)
            }
            .background(Color.cardBackground)
            .cornerRadius(CornerRadius.md)
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

// MARK: - 模板详情Sheet
struct TemplateDetailSheet: View {
    let template: TemplateListItem
    @ObservedObject var viewModel: CreateViewModel
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.appBackground
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: Spacing.lg) {
                        // 预览图
                        AsyncImage(url: URL(string: template.coverURL)) { phase in
                            switch phase {
                            case .success(let image):
                                image
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                            case .failure, .empty:
                                Rectangle()
                                    .fill(Color.primaryGradient.opacity(0.3))
                                    .aspectRatio(3/4, contentMode: .fit)
                            @unknown default:
                                EmptyView()
                            }
                        }
                        .cornerRadius(CornerRadius.lg)
                        .padding(.horizontal, Spacing.md)
                        
                        // 模板信息
                        VStack(alignment: .leading, spacing: Spacing.md) {
                            HStack {
                                Text(template.name)
                                    .font(.title2)
                                    .fontWeight(.bold)
                                    .foregroundColor(.textPrimary)
                                
                                Spacer()
                                
                                HStack(spacing: Spacing.xxs) {
                                    Image(systemName: "bolt.fill")
                                        .foregroundColor(.gradientPurple)
                                    Text(template.isFree ? "免费" : "\(template.pointsCost)积分")
                                        .fontWeight(.semibold)
                                        .foregroundStyle(Color.primaryGradient)
                                }
                            }
                            
                            HStack(spacing: Spacing.md) {
                                Label("\(template.usageCount)人使用", systemImage: "person.2.fill")
                                Label(template.category.displayName, systemImage: template.category.icon)
                            }
                            .font(.caption1)
                            .foregroundColor(.textSecondary)
                        }
                        .padding(.horizontal, Spacing.md)
                        
                        // 上传按钮
                        PhotosPicker(selection: $viewModel.selectedPhotoItem, matching: .images) {
                            HStack(spacing: Spacing.sm) {
                                Image(systemName: "photo.badge.plus")
                                    .font(.system(size: 20))
                                Text("选择照片开始生成")
                                    .font(.buttonMedium)
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 56)
                            .background(Color.primaryGradient)
                            .cornerRadius(CornerRadius.md)
                        }
                        .padding(.horizontal, Spacing.md)
                        .onChange(of: viewModel.selectedPhotoItem) { _, newValue in
                            if newValue != nil {
                                dismiss()
                                viewModel.startGeneration()
                            }
                        }
                    }
                    .padding(.vertical, Spacing.lg)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.textSecondary)
                    }
                }
            }
        }
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.visible)
    }
}

// MARK: - 生成中视图
struct GeneratingView: View {
    @ObservedObject var viewModel: CreateViewModel
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ZStack {
            Color.appBackground
                .ignoresSafeArea()
            
            VStack(spacing: Spacing.xl) {
                Spacer()
                
                // 动画效果
                ZStack {
                    // 外圈
                    Circle()
                        .stroke(Color.gradientPurple.opacity(0.2), lineWidth: 8)
                        .frame(width: 150, height: 150)
                    
                    // 进度圈
                    Circle()
                        .trim(from: 0, to: CGFloat(viewModel.generationProgress) / 100)
                        .stroke(
                            Color.primaryGradient,
                            style: StrokeStyle(lineWidth: 8, lineCap: .round)
                        )
                        .frame(width: 150, height: 150)
                        .rotationEffect(.degrees(-90))
                        .animation(.easeInOut(duration: 0.3), value: viewModel.generationProgress)
                    
                    // 百分比
                    VStack(spacing: Spacing.xxs) {
                        Text("\(viewModel.generationProgress)%")
                            .font(.title1)
                            .fontWeight(.bold)
                            .foregroundStyle(Color.primaryGradient)
                        
                        Text(viewModel.generationStatus.displayName)
                            .font(.caption1)
                            .foregroundColor(.textSecondary)
                    }
                }
                
                // 提示文字
                VStack(spacing: Spacing.xs) {
                    Text("AI正在创作中")
                        .font(.title3)
                        .fontWeight(.semibold)
                        .foregroundColor(.textPrimary)
                    
                    Text("预计需要\(viewModel.estimatedTime)秒，请耐心等待")
                        .font(.bodySmall)
                        .foregroundColor(.textSecondary)
                }
                
                Spacer()
                
                // 取消按钮
                Button(action: {
                    viewModel.cancelGeneration()
                    dismiss()
                }) {
                    Text("取消生成")
                        .font(.buttonMedium)
                        .foregroundColor(.textSecondary)
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(Color.inputBackground)
                        .cornerRadius(CornerRadius.md)
                }
                .padding(.horizontal, Spacing.xl)
                .padding(.bottom, Spacing.xl)
            }
        }
        .onAppear {
            AnalyticsManager.shared.trackPageView(.generating, properties: [
                "task_id": viewModel.currentTaskId ?? ""
            ])
        }
        .onChange(of: viewModel.generationCompleted) { _, completed in
            if completed {
                dismiss()
            }
        }
    }
}

// MARK: - 创作ViewModel
@MainActor
class CreateViewModel: ObservableObject {
    
    @Published var hotTemplates: [TemplateListItem] = []
    @Published var templates: [TemplateListItem] = []
    @Published var selectedTemplate: TemplateListItem?
    @Published var selectedPhotoItem: PhotosPickerItem?
    @Published var uploadedImageURL: String?
    
    @Published var isLoading = false
    @Published var showGenerating = false
    @Published var generationProgress = 0
    @Published var generationStatus: GenerationStatus = .pending
    @Published var estimatedTime = 30
    @Published var generationCompleted = false
    @Published var currentTaskId: String?
    
    private var currentCategory: TemplateCategory = .all
    private var pollingTimer: Timer?
    
    // MARK: - 加载初始数据
    func loadInitialData() async {
        isLoading = true
        
        do {
            async let hotTask = loadHotTemplates()
            async let allTask = loadTemplates()
            
            _ = try await (hotTask, allTask)
        } catch {
            ErrorHandler.shared.handleAPIError(error as! APIError)
        }
        
        isLoading = false
    }
    
    // MARK: - 加载热门模板
    private func loadHotTemplates() async throws {
        // Mock数据
        hotTemplates = [
            TemplateListItem(id: "1", name: "韩式证件照", coverURL: "https://example.com/t1.jpg", category: .portrait, pointsCost: 10, isFree: false, isHot: true, isNew: false, usageCount: 12500),
            TemplateListItem(id: "2", name: "动漫头像", coverURL: "https://example.com/t2.jpg", category: .anime, pointsCost: 0, isFree: true, isHot: true, isNew: false, usageCount: 8900),
            TemplateListItem(id: "3", name: "油画风格", coverURL: "https://example.com/t3.jpg", category: .artistic, pointsCost: 15, isFree: false, isHot: false, isNew: true, usageCount: 5600)
        ]
    }
    
    // MARK: - 加载模板列表
    func loadTemplates(category: TemplateCategory? = nil) async {
        if let category = category {
            currentCategory = category
        }
        
        isLoading = templates.isEmpty
        
        do {
            let response = try await APIService.shared.getTemplates(
                page: 1,
                pageSize: 20,
                category: currentCategory == .all ? nil : currentCategory.rawValue
            )
            templates = response.items
        } catch {
            // 使用Mock数据
            templates = [
                TemplateListItem(id: "1", name: "韩式证件照", coverURL: "https://example.com/t1.jpg", category: .portrait, pointsCost: 10, isFree: false, isHot: true, isNew: false, usageCount: 12500),
                TemplateListItem(id: "2", name: "动漫头像", coverURL: "https://example.com/t2.jpg", category: .anime, pointsCost: 0, isFree: true, isHot: true, isNew: false, usageCount: 8900)
            ]
        }
        
        isLoading = false
    }
    
    // MARK: - 刷新模板
    func refreshTemplates() async {
        await loadTemplates()
    }
    
    // MARK: - 选择模板
    func selectTemplate(_ template: TemplateListItem) {
        selectedTemplate = template
        
        AnalyticsManager.shared.trackPageView(.templateSelect, properties: [
            "template_id": template.id
        ])
    }
    
    // MARK: - 开始生成
    func startGeneration() {
        guard let template = selectedTemplate,
              let photoItem = selectedPhotoItem else { return }
        
        showGenerating = true
        generationProgress = 0
        generationStatus = .pending
        
        Task {
            do {
                // 1. 上传图片
                generationStatus = .pending
                let imageData = try await loadImageData(from: photoItem)
                let uploadResponse = try await APIService.shared.uploadImage(imageData)
                uploadedImageURL = uploadResponse.url
                
                // 2. 创建生成任务
                AnalyticsManager.shared.trackConversion(.generateStart, properties: [
                    "template_id": template.id,
                    "points_cost": template.pointsCost
                ])
                
                let response = try await APIService.shared.createGeneration(
                    templateId: template.id,
                    imageURL: uploadResponse.url
                )
                
                currentTaskId = response.taskId
                estimatedTime = response.estimatedTime
                generationStatus = .processing
                
                // 3. 轮询状态
                startPolling(taskId: response.taskId)
                
            } catch {
                handleGenerationError(error)
            }
        }
    }
    
    // MARK: - 加载图片数据
    private func loadImageData(from item: PhotosPickerItem) async throws -> Data {
        guard let data = try await item.loadTransferable(type: Data.self) else {
            throw APIError(code: -1, message: "Failed to load image", details: nil)
        }
        return data
    }
    
    // MARK: - 开始轮询
    private func startPolling(taskId: String) {
        pollingTimer = Timer.scheduledTimer(withTimeInterval: 2, repeats: true) { [weak self] _ in
            Task { @MainActor in
                await self?.checkGenerationStatus(taskId: taskId)
            }
        }
    }
    
    // MARK: - 检查生成状态
    private func checkGenerationStatus(taskId: String) async {
        do {
            let task = try await APIService.shared.getGenerationStatus(taskId: taskId)
            
            generationProgress = task.progress
            generationStatus = task.status
            
            if task.isCompleted {
                pollingTimer?.invalidate()
                generationCompleted = true
                
                AnalyticsManager.shared.trackConversion(.generateSuccess, properties: [
                    "task_id": taskId,
                    "template_id": selectedTemplate?.id ?? ""
                ])
                
                // 跳转到结果页
                NotificationCenter.default.post(
                    name: .navigateToResult,
                    object: nil,
                    userInfo: ["taskId": taskId, "resultURL": task.resultImageURL ?? ""]
                )
            } else if task.isFailed {
                pollingTimer?.invalidate()
                handleGenerationError(APIError(code: ErrorCode.generationFailed.rawValue, message: task.errorMessage ?? "生成失败", details: nil))
            }
        } catch {
            // 继续轮询
        }
    }
    
    // MARK: - 取消生成
    func cancelGeneration() {
        pollingTimer?.invalidate()
        
        if let taskId = currentTaskId {
            AnalyticsManager.shared.trackConversion(.generateCancel, properties: [
                "task_id": taskId,
                "progress": generationProgress
            ])
            
            Task {
                try? await APIService.shared.cancelGeneration(taskId: taskId)
            }
        }
        
        resetGenerationState()
    }
    
    // MARK: - 处理生成错误
    private func handleGenerationError(_ error: Error) {
        pollingTimer?.invalidate()
        showGenerating = false
        
        if let apiError = error as? APIError {
            ErrorHandler.shared.handleAPIError(apiError, context: .generation)
        }
        
        AnalyticsManager.shared.trackConversion(.generateFail, properties: [
            "template_id": selectedTemplate?.id ?? "",
            "error_code": (error as? APIError)?.code ?? -1
        ])
        
        resetGenerationState()
    }
    
    // MARK: - 重置生成状态
    private func resetGenerationState() {
        generationProgress = 0
        generationStatus = .pending
        generationCompleted = false
        currentTaskId = nil
        selectedPhotoItem = nil
        uploadedImageURL = nil
    }
}

// MARK: - 通知名称扩展
extension Notification.Name {
    static let navigateToResult = Notification.Name("navigateToResult")
}

// MARK: - 预览
#Preview {
    CreateView()
        .preferredColorScheme(.dark)
}
