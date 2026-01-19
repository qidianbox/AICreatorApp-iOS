//
//  CreateView.swift
//  AICreatorApp
//
//  创作页 - 完全匹配原型图设计
//  基于设计规范文档 v3.0
//
//  Created by Manus AI on 2026/1/19.
//

import SwiftUI
import PhotosUI

// MARK: - 创作页主视图
struct CreateView: View {
    @StateObject private var viewModel = CreateViewModel()
    @State private var showImagePicker = false
    @State private var showCamera = false
    @State private var selectedPhotoItem: PhotosPickerItem?
    
    var body: some View {
        ZStack {
            // 背景
            Color(hex: "#0D0D0D")
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // 状态栏
                CreateStatusBar()
                
                // Hero区域
                HeroSection(templates: viewModel.featuredTemplates)
                
                // 快捷操作
                QuickActionsView(actions: viewModel.quickActions)
                
                // 上传区域
                UploadSection(
                    onCameraTap: { showCamera = true },
                    onUploadTap: { showImagePicker = true }
                )
                
                Spacer()
            }
            
            // 底部导航
            VStack {
                Spacer()
                CreateBottomNav()
            }
        }
        .photosPicker(isPresented: $showImagePicker, selection: $selectedPhotoItem, matching: .images)
        .sheet(isPresented: $showCamera) {
            CameraPlaceholder()
        }
        .onChange(of: selectedPhotoItem) { _, newValue in
            if newValue != nil {
                viewModel.startGeneration()
            }
        }
        .fullScreenCover(isPresented: $viewModel.showGenerating) {
            GeneratingView(viewModel: viewModel)
        }
        .onAppear {
            viewModel.loadData()
            AnalyticsManager.shared.trackPageView(.create)
        }
    }
}

// MARK: - 状态栏
struct CreateStatusBar: View {
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

// MARK: - Hero区域
struct HeroSection: View {
    let templates: [FeaturedTemplate]
    
    var body: some View {
        ZStack {
            // 背景光晕
            RadialGradient(
                colors: [Color(hex: "#a855f7").opacity(0.2), Color.clear],
                center: .center,
                startRadius: 0,
                endRadius: 200
            )
            .blur(radius: 60)
            
            VStack(spacing: 0) {
                // 标题
                VStack(spacing: 10) {
                    Text("好看、好玩、好有趣")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(.white)
                    
                    Text("AI创图，释放你的无限创意")
                        .font(.system(size: 16))
                        .foregroundColor(Color(hex: "#888888"))
                }
                .padding(.top, 30)
                .padding(.bottom, 40)
                
                // 模板轮播
                TemplateCarousel(templates: templates)
            }
        }
        .frame(height: 380)
    }
}

// MARK: - 模板轮播
struct TemplateCarousel: View {
    let templates: [FeaturedTemplate]
    
    var body: some View {
        HStack(spacing: 15) {
            ForEach(templates.indices, id: \.self) { index in
                TemplatePreviewCard(
                    template: templates[index],
                    rotation: getRotation(for: index),
                    scale: getScale(for: index),
                    zIndex: getZIndex(for: index)
                )
            }
        }
        .padding(.horizontal, 30)
    }
    
    private func getRotation(for index: Int) -> Double {
        switch index {
        case 0: return -5
        case 1: return 0
        case 2: return 5
        default: return 0
        }
    }
    
    private func getScale(for index: Int) -> CGFloat {
        return index == 1 ? 1.05 : 1.0
    }
    
    private func getZIndex(for index: Int) -> Double {
        return index == 1 ? 2 : 1
    }
}

// MARK: - 模板预览卡片
struct TemplatePreviewCard: View {
    let template: FeaturedTemplate
    let rotation: Double
    let scale: CGFloat
    let zIndex: Double
    
    var body: some View {
        ZStack {
            // 背景渐变
            RoundedRectangle(cornerRadius: 16)
                .fill(
                    LinearGradient(
                        colors: template.gradientColors,
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
            
            // 标签
            VStack {
                HStack {
                    Text(template.name)
                        .font(.system(size: 12))
                        .foregroundColor(.white)
                        .shadow(color: .black.opacity(0.5), radius: 3, y: 1)
                    Spacer()
                }
                .padding(10)
                
                Spacer()
                
                // 生成按钮
                HStack(spacing: 4) {
                    Text("生成")
                        .font(.system(size: 12))
                    Text("✨")
                        .font(.system(size: 10))
                }
                .foregroundColor(.white)
                .padding(.horizontal, 16)
                .padding(.vertical, 6)
                .background(Color.white.opacity(0.2))
                .background(.ultraThinMaterial.opacity(0.5))
                .cornerRadius(15)
                .padding(.bottom, 10)
            }
        }
        .frame(width: 120, height: 160)
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.3), radius: 10, y: 10)
        .rotationEffect(.degrees(rotation))
        .scaleEffect(scale)
        .zIndex(zIndex)
    }
}

// MARK: - 快捷操作
struct QuickActionsView: View {
    let actions: [QuickAction]
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                ForEach(actions) { action in
                    QuickActionChip(action: action)
                }
            }
            .padding(.horizontal, 20)
        }
        .padding(.vertical, 20)
    }
}

// MARK: - 快捷操作标签
struct QuickActionChip: View {
    let action: QuickAction
    
    var body: some View {
        Button(action: {
            AnalyticsManager.shared.trackAction(.clickQuickAction, properties: [
                "action_name": action.name
            ])
        }) {
            Text(action.name)
                .font(.system(size: 14))
                .foregroundColor(.white)
                .padding(.horizontal, 18)
                .padding(.vertical, 10)
                .background(Color.white.opacity(0.08))
                .cornerRadius(20)
        }
    }
}

// MARK: - 上传区域
struct UploadSection: View {
    let onCameraTap: () -> Void
    let onUploadTap: () -> Void
    
    var body: some View {
        HStack(spacing: 12) {
            // 相机按钮
            Button(action: onCameraTap) {
                ZStack {
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color.white.opacity(0.1))
                        .frame(width: 56, height: 56)
                    
                    Image(systemName: "camera")
                        .font(.system(size: 24))
                        .foregroundColor(.white)
                }
            }
            
            // 上传按钮
            Button(action: onUploadTap) {
                HStack(spacing: 10) {
                    Image(systemName: "arrow.up")
                        .font(.system(size: 18, weight: .medium))
                    
                    Text("添加照片")
                        .font(.system(size: 16, weight: .medium))
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 56)
                .background(
                    LinearGradient(
                        colors: [Color(hex: "#a855f7"), Color(hex: "#ec4899")],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .cornerRadius(28)
            }
        }
        .padding(.horizontal, 20)
    }
}

// MARK: - 底部导航
struct CreateBottomNav: View {
    var body: some View {
        HStack {
            // 左侧 - 发现
            VStack(spacing: 4) {
                ZStack {
                    Circle()
                        .stroke(Color(hex: "#666666"), lineWidth: 2)
                        .frame(width: 24, height: 24)
                    
                    Circle()
                        .fill(Color(hex: "#666666"))
                        .frame(width: 6, height: 6)
                        .offset(x: -4, y: -4)
                }
            }
            .foregroundColor(Color(hex: "#666666"))
            .frame(maxWidth: .infinity)
            
            // 中间 - 创作按钮
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
                
                // 图标
                ZStack {
                    RoundedRectangle(cornerRadius: 4)
                        .stroke(Color.white, lineWidth: 2)
                        .frame(width: 20, height: 20)
                    
                    Image(systemName: "plus")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.white)
                }
            }
            .offset(y: -20)
            
            // 右侧 - 我的
            VStack(spacing: 4) {
                Image(systemName: "person")
                    .font(.system(size: 24))
            }
            .foregroundColor(Color(hex: "#666666"))
            .frame(maxWidth: .infinity)
        }
        .padding(.horizontal, 40)
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

// MARK: - 生成中视图
struct GeneratingView: View {
    @ObservedObject var viewModel: CreateViewModel
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ZStack {
            Color(hex: "#0D0D0D")
                .ignoresSafeArea()
            
            VStack(spacing: 30) {
                // 进度环
                ZStack {
                    Circle()
                        .stroke(Color.white.opacity(0.1), lineWidth: 8)
                        .frame(width: 120, height: 120)
                    
                    Circle()
                        .trim(from: 0, to: viewModel.generationProgress)
                        .stroke(
                            LinearGradient(
                                colors: [Color(hex: "#a855f7"), Color(hex: "#ec4899")],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            style: StrokeStyle(lineWidth: 8, lineCap: .round)
                        )
                        .frame(width: 120, height: 120)
                        .rotationEffect(.degrees(-90))
                        .animation(.easeInOut, value: viewModel.generationProgress)
                    
                    Text("\(Int(viewModel.generationProgress * 100))%")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(.white)
                }
                
                VStack(spacing: 10) {
                    Text("AI正在创作中...")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(.white)
                    
                    Text("预计需要10-30秒")
                        .font(.system(size: 14))
                        .foregroundColor(Color(hex: "#888888"))
                }
                
                // 取消按钮
                Button(action: {
                    viewModel.cancelGeneration()
                    dismiss()
                }) {
                    Text("取消")
                        .font(.system(size: 16))
                        .foregroundColor(Color(hex: "#888888"))
                        .padding(.horizontal, 40)
                        .padding(.vertical, 12)
                        .background(Color.white.opacity(0.1))
                        .cornerRadius(25)
                }
                .padding(.top, 20)
            }
        }
        .onAppear {
            viewModel.simulateGeneration()
        }
    }
}

// MARK: - 占位视图
struct CameraPlaceholder: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            VStack(spacing: 20) {
                Image(systemName: "camera.fill")
                    .font(.system(size: 60))
                    .foregroundColor(.white.opacity(0.5))
                
                Text("相机")
                    .font(.title)
                    .foregroundColor(.white)
                
                Text("此处集成系统相机")
                    .foregroundColor(.gray)
                
                Button("关闭") {
                    dismiss()
                }
                .foregroundColor(.white)
                .padding(.top, 20)
            }
        }
    }
}

// MARK: - 数据模型
struct FeaturedTemplate: Identifiable {
    let id = UUID()
    let name: String
    let gradientColors: [Color]
}

struct QuickAction: Identifiable {
    let id = UUID()
    let name: String
    let icon: String
}

// MARK: - ViewModel
class CreateViewModel: ObservableObject {
    @Published var featuredTemplates: [FeaturedTemplate] = []
    @Published var quickActions: [QuickAction] = []
    @Published var showGenerating = false
    @Published var generationProgress: CGFloat = 0
    
    private var generationTimer: Timer?
    
    func loadData() {
        // 加载精选模板
        featuredTemplates = [
            FeaturedTemplate(
                name: "新年红包",
                gradientColors: [Color(hex: "#fecaca"), Color(hex: "#ef4444")]
            ),
            FeaturedTemplate(
                name: "宠物过新年",
                gradientColors: [Color(hex: "#fed7aa"), Color(hex: "#f97316")]
            ),
            FeaturedTemplate(
                name: "手持拍立得",
                gradientColors: [Color(hex: "#bfdbfe"), Color(hex: "#3b82f6")]
            )
        ]
        
        // 加载快捷操作
        quickActions = [
            QuickAction(name: "老照片修复", icon: "photo.on.rectangle"),
            QuickAction(name: "AI一键追色", icon: "paintpalette"),
            QuickAction(name: "毛绒相框", icon: "square.on.square"),
            QuickAction(name: "一张拍立得", icon: "camera"),
            QuickAction(name: "INS边框", icon: "square")
        ]
    }
    
    func startGeneration() {
        showGenerating = true
        generationProgress = 0
    }
    
    func simulateGeneration() {
        generationTimer?.invalidate()
        generationTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] timer in
            guard let self = self else {
                timer.invalidate()
                return
            }
            
            if self.generationProgress < 1.0 {
                self.generationProgress += 0.02
            } else {
                timer.invalidate()
                // 生成完成，跳转到结果页
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    self.showGenerating = false
                }
            }
        }
    }
    
    func cancelGeneration() {
        generationTimer?.invalidate()
        generationProgress = 0
    }
}

// MARK: - 预览
#Preview {
    CreateView()
}
