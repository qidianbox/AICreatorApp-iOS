# AI创图App - SwiftUI 开发设计规范

> 本文档为AI编辑器（Cursor、Copilot、Claude等）优化，可直接用于生成Swift/SwiftUI代码。

---

## 1. 项目概述

**应用名称**：AI创图（AI Image Creator）  
**平台**：iOS 16.0+  
**开发语言**：Swift 5.9+  
**UI框架**：SwiftUI  
**设计风格**：暗黑模式 + 紫粉渐变强调色（Cyber Neon Dark）

---

## 2. 设计系统（Design System）

### 2.1 颜色定义（Color Palette）

```swift
import SwiftUI

extension Color {
    // MARK: - 背景色
    static let appBackground = Color(hex: "0D0D0D")           // 主背景
    static let cardBackground = Color(hex: "1A1A1A")          // 卡片背景
    static let surfaceBackground = Color(hex: "1A1A2E")       // 表面背景
    static let inputBackground = Color.white.opacity(0.08)    // 输入框背景
    
    // MARK: - 渐变色
    static let gradientPurple = Color(hex: "A855F7")          // 紫色
    static let gradientPink = Color(hex: "EC4899")            // 粉色
    static let gradientOrange = Color(hex: "F97316")          // 橙色
    
    // MARK: - 主题渐变
    static let primaryGradient = LinearGradient(
        colors: [gradientPurple, gradientPink],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    static let accentGradient = LinearGradient(
        colors: [gradientPurple, gradientPink, gradientOrange],
        startPoint: .leading,
        endPoint: .trailing
    )
    
    // MARK: - 文字颜色
    static let textPrimary = Color.white                      // 主文字
    static let textSecondary = Color(hex: "888888")           // 次要文字
    static let textTertiary = Color(hex: "666666")            // 第三级文字
    
    // MARK: - 功能色
    static let success = Color(hex: "4ADE80")                 // 成功/在线
    static let warning = Color(hex: "F59E0B")                 // 警告
    static let error = Color(hex: "EF4444")                   // 错误
    static let like = Color(hex: "EC4899")                    // 点赞
    
    // MARK: - 边框色
    static let borderDefault = Color.white.opacity(0.1)       // 默认边框
    static let borderActive = Color(hex: "A855F7").opacity(0.5) // 激活边框
}

// MARK: - Hex Color Extension
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
```

### 2.2 字体系统（Typography）

```swift
extension Font {
    // MARK: - 标题字体
    static let largeTitle = Font.system(size: 28, weight: .bold)      // 大标题
    static let title1 = Font.system(size: 24, weight: .bold)          // 标题1
    static let title2 = Font.system(size: 20, weight: .semibold)      // 标题2
    static let title3 = Font.system(size: 18, weight: .semibold)      // 标题3
    
    // MARK: - 正文字体
    static let bodyLarge = Font.system(size: 16, weight: .regular)    // 大正文
    static let bodyMedium = Font.system(size: 15, weight: .regular)   // 中正文
    static let bodySmall = Font.system(size: 14, weight: .regular)    // 小正文
    
    // MARK: - 辅助字体
    static let caption1 = Font.system(size: 13, weight: .regular)     // 说明文字
    static let caption2 = Font.system(size: 12, weight: .regular)     // 小说明
    static let caption3 = Font.system(size: 11, weight: .regular)     // 最小文字
    
    // MARK: - 按钮字体
    static let buttonLarge = Font.system(size: 16, weight: .semibold) // 大按钮
    static let buttonMedium = Font.system(size: 14, weight: .medium)  // 中按钮
    static let buttonSmall = Font.system(size: 12, weight: .medium)   // 小按钮
}
```

### 2.3 间距系统（Spacing）

```swift
enum Spacing {
    static let xxxs: CGFloat = 2
    static let xxs: CGFloat = 4
    static let xs: CGFloat = 8
    static let sm: CGFloat = 12
    static let md: CGFloat = 16
    static let lg: CGFloat = 20
    static let xl: CGFloat = 24
    static let xxl: CGFloat = 32
    static let xxxl: CGFloat = 40
}
```

### 2.4 圆角系统（Corner Radius）

```swift
enum CornerRadius {
    static let xs: CGFloat = 6
    static let sm: CGFloat = 10
    static let md: CGFloat = 12
    static let lg: CGFloat = 16
    static let xl: CGFloat = 20
    static let xxl: CGFloat = 24
    static let full: CGFloat = 9999  // 胶囊形状
}
```

---

## 3. 核心组件（Components）

### 3.1 主按钮（Primary Button）

```swift
struct PrimaryButton: View {
    let title: String
    let icon: String?
    let action: () -> Void
    
    init(_ title: String, icon: String? = nil, action: @escaping () -> Void) {
        self.title = title
        self.icon = icon
        self.action = action
    }
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: Spacing.xs) {
                if let icon = icon {
                    Image(systemName: icon)
                        .font(.system(size: 16, weight: .medium))
                }
                Text(title)
                    .font(.buttonLarge)
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .frame(height: 50)
            .background(Color.primaryGradient)
            .cornerRadius(CornerRadius.xl)
        }
    }
}

// 使用示例
PrimaryButton("微信登录", icon: "message.fill") {
    // 登录逻辑
}
```

### 3.2 次要按钮（Secondary Button）

```swift
struct SecondaryButton: View {
    let title: String
    let icon: String?
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: Spacing.xs) {
                if let icon = icon {
                    Image(systemName: icon)
                        .font(.system(size: 16, weight: .medium))
                }
                Text(title)
                    .font(.buttonMedium)
            }
            .foregroundColor(.textPrimary)
            .frame(maxWidth: .infinity)
            .frame(height: 46)
            .background(Color.inputBackground)
            .cornerRadius(CornerRadius.lg)
            .overlay(
                RoundedRectangle(cornerRadius: CornerRadius.lg)
                    .stroke(Color.borderDefault, lineWidth: 1)
            )
        }
    }
}
```

### 3.3 渐变标签（Gradient Badge）

```swift
struct GradientBadge: View {
    let text: String
    
    var body: some View {
        Text(text)
            .font(.caption2)
            .fontWeight(.medium)
            .foregroundColor(.white)
            .padding(.horizontal, Spacing.sm)
            .padding(.vertical, Spacing.xxs)
            .background(Color.primaryGradient)
            .cornerRadius(CornerRadius.sm)
    }
}

// 使用示例
GradientBadge(text: "核心")
GradientBadge(text: "热门")
```

### 3.4 卡片容器（Card Container）

```swift
struct CardContainer<Content: View>: View {
    let content: Content
    
    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    var body: some View {
        content
            .padding(Spacing.md)
            .background(Color.cardBackground)
            .cornerRadius(CornerRadius.lg)
            .overlay(
                RoundedRectangle(cornerRadius: CornerRadius.lg)
                    .stroke(Color.borderDefault, lineWidth: 1)
            )
    }
}
```

### 3.5 底部导航栏（Tab Bar）

```swift
struct CustomTabBar: View {
    @Binding var selectedTab: Int
    
    var body: some View {
        HStack {
            // 首页
            TabBarItem(
                icon: "house.fill",
                isSelected: selectedTab == 0
            ) {
                selectedTab = 0
            }
            
            Spacer()
            
            // 创作按钮（中间大按钮）
            CreateButton {
                // 打开创作页面
            }
            
            Spacer()
            
            // 个人中心
            TabBarItem(
                icon: "person.fill",
                isSelected: selectedTab == 1
            ) {
                selectedTab = 1
            }
        }
        .padding(.horizontal, Spacing.xxxl)
        .padding(.vertical, Spacing.md)
        .background(
            LinearGradient(
                colors: [Color.clear, Color.appBackground],
                startPoint: .top,
                endPoint: .bottom
            )
        )
    }
}

struct TabBarItem: View {
    let icon: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.system(size: 24))
                .foregroundColor(isSelected ? .white : .textTertiary)
        }
    }
}

struct CreateButton: View {
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Image(systemName: "paintbrush.fill")
                .font(.system(size: 24))
                .foregroundColor(.white)
                .frame(width: 56, height: 56)
                .background(Color.primaryGradient)
                .clipShape(Circle())
                .shadow(color: Color.gradientPurple.opacity(0.4), radius: 10, y: 4)
        }
        .offset(y: -20)
    }
}
```

### 3.6 分类Tab（Category Tabs）

```swift
struct CategoryTabs: View {
    @Binding var selectedIndex: Int
    let categories: [CategoryItem]
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: Spacing.sm) {
                ForEach(categories.indices, id: \.self) { index in
                    CategoryTabItem(
                        item: categories[index],
                        isSelected: selectedIndex == index
                    ) {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            selectedIndex = index
                        }
                    }
                }
            }
            .padding(.horizontal, Spacing.md)
        }
    }
}

struct CategoryItem {
    let icon: String
    let title: String
}

struct CategoryTabItem: View {
    let item: CategoryItem
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: Spacing.xxs) {
                Text(item.icon)
                    .font(.system(size: 14))
                Text(item.title)
                    .font(.caption1)
                    .fontWeight(isSelected ? .semibold : .regular)
            }
            .foregroundColor(isSelected ? .white : .textSecondary)
            .padding(.horizontal, Spacing.sm)
            .padding(.vertical, Spacing.xs)
            .background(
                isSelected ? Color.primaryGradient : Color.inputBackground
            )
            .cornerRadius(CornerRadius.full)
        }
    }
}

// 使用示例
let categories = [
    CategoryItem(icon: "🔥", title: "推荐"),
    CategoryItem(icon: "👤", title: "美颜"),
    CategoryItem(icon: "🏠", title: "生活"),
    CategoryItem(icon: "🎨", title: "艺术"),
    CategoryItem(icon: "👀", title: "新发现")
]
```

### 3.7 作品卡片（Work Card）

```swift
struct WorkCard: View {
    let work: WorkItem
    let onTap: () -> Void
    let onLike: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // 图片区域
            AsyncImage(url: URL(string: work.imageURL)) { image in
                image
                    .resizable()
                    .aspectRatio(3/4, contentMode: .fill)
            } placeholder: {
                Rectangle()
                    .fill(Color.primaryGradient.opacity(0.3))
            }
            .frame(maxWidth: .infinity)
            .aspectRatio(3/4, contentMode: .fit)
            .clipped()
            
            // 信息区域
            VStack(alignment: .leading, spacing: Spacing.xs) {
                Text(work.title)
                    .font(.caption1)
                    .fontWeight(.medium)
                    .foregroundColor(.textPrimary)
                    .lineLimit(1)
                
                HStack {
                    // 作者信息
                    HStack(spacing: Spacing.xxs) {
                        Circle()
                            .fill(Color.primaryGradient)
                            .frame(width: 18, height: 18)
                        
                        Text(work.authorName)
                            .font(.caption3)
                            .foregroundColor(.textSecondary)
                    }
                    
                    Spacer()
                    
                    // 点赞按钮
                    Button(action: onLike) {
                        Image(systemName: work.isLiked ? "heart.fill" : "heart")
                            .font(.system(size: 14))
                            .foregroundColor(work.isLiked ? .like : .textSecondary)
                    }
                }
            }
            .padding(Spacing.sm)
            .background(Color.inputBackground)
        }
        .cornerRadius(CornerRadius.md)
        .onTapGesture(perform: onTap)
    }
}

struct WorkItem: Identifiable {
    let id: String
    let title: String
    let imageURL: String
    let authorName: String
    var isLiked: Bool
    let viewCount: Int
}
```

### 3.8 推荐Banner（Featured Banner）

```swift
struct FeaturedBanner: View {
    let item: BannerItem
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            ZStack(alignment: .bottomLeading) {
                // 背景图片
                AsyncImage(url: URL(string: item.imageURL)) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } placeholder: {
                    Rectangle()
                        .fill(Color.primaryGradient)
                }
                .frame(height: 180)
                .clipped()
                
                // 渐变遮罩
                LinearGradient(
                    colors: [Color.clear, Color.black.opacity(0.7)],
                    startPoint: .top,
                    endPoint: .bottom
                )
                
                // 文字内容
                VStack(alignment: .leading, spacing: Spacing.xxs) {
                    Text(item.title)
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    Text(item.subtitle)
                        .font(.caption1)
                        .foregroundColor(.white.opacity(0.8))
                }
                .padding(Spacing.md)
            }
            .cornerRadius(CornerRadius.lg)
        }
    }
}

struct BannerItem: Identifiable {
    let id: String
    let title: String
    let subtitle: String
    let imageURL: String
}
```

---

## 4. 页面结构（Page Structures）

### 4.1 登录页（LoginView）

```swift
struct LoginView: View {
    var body: some View {
        ZStack {
            // 背景
            Color.appBackground.ignoresSafeArea()
            
            VStack(spacing: Spacing.xl) {
                Spacer()
                
                // 作品预览网格（3x3）
                WorkPreviewGrid()
                
                // Logo和Slogan
                VStack(spacing: Spacing.xs) {
                    Text("AI创图")
                        .font(.title1)
                        .foregroundColor(.white)
                    
                    HStack(spacing: 0) {
                        Text("释放你的")
                            .foregroundColor(.textSecondary)
                        Text("无限")
                            .foregroundStyle(Color.accentGradient)
                        Text("创意")
                            .foregroundColor(.textSecondary)
                    }
                    .font(.bodyMedium)
                }
                
                Spacer()
                
                // 登录按钮组
                VStack(spacing: Spacing.sm) {
                    PrimaryButton("微信登录", icon: "message.fill") {
                        // 微信登录
                    }
                    
                    SecondaryButton("手机验证码登录", icon: "phone.fill") {
                        // 手机登录
                    }
                    
                    SecondaryButton("Apple 账号登录", icon: "apple.logo") {
                        // Apple登录
                    }
                }
                .padding(.horizontal, Spacing.lg)
                
                // 协议文字
                AgreementText()
                    .padding(.bottom, Spacing.xl)
            }
        }
    }
}
```

### 4.2 首页/发现页（HomeView）

```swift
struct HomeView: View {
    @State private var selectedCategory = 0
    @State private var works: [WorkItem] = []
    
    let categories = [
        CategoryItem(icon: "🔥", title: "推荐"),
        CategoryItem(icon: "👤", title: "美颜"),
        CategoryItem(icon: "🏠", title: "生活"),
        CategoryItem(icon: "🎨", title: "艺术"),
        CategoryItem(icon: "👀", title: "新发现")
    ]
    
    var body: some View {
        ZStack {
            Color.appBackground.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // 顶部导航
                HomeHeader()
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: Spacing.lg) {
                        // 分类Tab
                        CategoryTabs(
                            selectedIndex: $selectedCategory,
                            categories: categories
                        )
                        
                        // 推荐Banner
                        FeaturedBanner(item: featuredItem) {
                            // 跳转详情
                        }
                        .padding(.horizontal, Spacing.md)
                        
                        // 热门模板
                        TemplateSection()
                        
                        // 瀑布流作品
                        WaterfallGrid(works: works)
                            .padding(.horizontal, Spacing.md)
                    }
                    .padding(.bottom, 100) // 为TabBar留空间
                }
            }
        }
    }
}

struct HomeHeader: View {
    var body: some View {
        HStack {
            Text("AI创图")
                .font(.title2)
                .foregroundStyle(Color.accentGradient)
            
            Spacer()
            
            // 积分显示
            HStack(spacing: Spacing.xxs) {
                Image(systemName: "bolt.fill")
                    .foregroundColor(.gradientOrange)
                Text("0")
                    .font(.caption1)
                    .fontWeight(.medium)
            }
            .padding(.horizontal, Spacing.sm)
            .padding(.vertical, Spacing.xxs)
            .background(Color.inputBackground)
            .cornerRadius(CornerRadius.full)
        }
        .padding(.horizontal, Spacing.md)
        .padding(.vertical, Spacing.sm)
    }
}
```

### 4.3 创作页（CreateView）

```swift
struct CreateView: View {
    var body: some View {
        ZStack {
            Color.appBackground.ignoresSafeArea()
            
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: Spacing.xl) {
                    // 标题区域
                    VStack(alignment: .leading, spacing: Spacing.xs) {
                        Text("好看、好玩、好有趣")
                            .font(.title2)
                            .foregroundColor(.white)
                        
                        Text("AI绘图，释放你的无限创意")
                            .font(.bodySmall)
                            .foregroundColor(.textSecondary)
                    }
                    .padding(.horizontal, Spacing.md)
                    
                    // 热门模板
                    VStack(alignment: .leading, spacing: Spacing.sm) {
                        Text("热门")
                            .font(.title3)
                            .foregroundColor(.white)
                            .padding(.horizontal, Spacing.md)
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: Spacing.sm) {
                                ForEach(templates) { template in
                                    TemplateCard(template: template)
                                }
                            }
                            .padding(.horizontal, Spacing.md)
                        }
                    }
                    
                    // 快捷功能
                    QuickActions()
                        .padding(.horizontal, Spacing.md)
                    
                    // 上传按钮
                    UploadButton {
                        // 打开相册
                    }
                    .padding(.horizontal, Spacing.md)
                }
                .padding(.top, Spacing.lg)
                .padding(.bottom, 100)
            }
        }
    }
}

struct QuickActions: View {
    let actions = [
        ("老照片修复", "photo.on.rectangle"),
        ("AI一键追色", "paintpalette.fill"),
        ("毛绒相框", "square.on.square")
    ]
    
    var body: some View {
        HStack(spacing: Spacing.sm) {
            ForEach(actions, id: \.0) { action in
                QuickActionButton(title: action.0, icon: action.1)
            }
        }
    }
}

struct QuickActionButton: View {
    let title: String
    let icon: String
    
    var body: some View {
        VStack(spacing: Spacing.xs) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundColor(.textSecondary)
            
            Text(title)
                .font(.caption2)
                .foregroundColor(.textSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, Spacing.md)
        .background(Color.inputBackground)
        .cornerRadius(CornerRadius.md)
    }
}

struct UploadButton: View {
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: Spacing.xs) {
                Image(systemName: "camera.fill")
                Text("添加照片")
            }
            .font(.buttonMedium)
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .frame(height: 50)
            .background(Color.primaryGradient)
            .cornerRadius(CornerRadius.xl)
        }
    }
}
```

### 4.4 作品详情页（DetailView）

```swift
struct DetailView: View {
    let work: WorkItem
    @State private var isLiked = false
    @State private var showShareSheet = false
    
    var body: some View {
        ZStack {
            Color.appBackground.ignoresSafeArea()
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    // 作品图片
                    AsyncImage(url: URL(string: work.imageURL)) { image in
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                    } placeholder: {
                        Rectangle()
                            .fill(Color.primaryGradient.opacity(0.3))
                            .aspectRatio(3/4, contentMode: .fit)
                    }
                    .frame(maxWidth: .infinity)
                    
                    VStack(alignment: .leading, spacing: Spacing.lg) {
                        // 作者信息
                        AuthorRow(authorName: work.authorName)
                        
                        // 提示词区域
                        PromptSection(prompt: "使用提示词生成...")
                        
                        // 跟图列表
                        RelatedWorksSection()
                    }
                    .padding(Spacing.md)
                }
            }
            
            // 底部操作栏
            VStack {
                Spacer()
                DetailBottomBar(
                    isLiked: $isLiked,
                    onLike: { isLiked.toggle() },
                    onGenerate: { /* 跟图生成 */ },
                    onShare: { showShareSheet = true }
                )
            }
        }
        .sheet(isPresented: $showShareSheet) {
            ShareSheet()
        }
    }
}

struct PromptSection: View {
    let prompt: String
    @State private var isExpanded = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            HStack {
                Text("提示词")
                    .font(.caption1)
                    .foregroundColor(.textSecondary)
                
                Spacer()
                
                Button(action: { /* 复制 */ }) {
                    Image(systemName: "doc.on.doc")
                        .font(.system(size: 14))
                        .foregroundColor(.textSecondary)
                }
            }
            
            Text(prompt)
                .font(.bodySmall)
                .foregroundColor(.textPrimary)
                .lineLimit(isExpanded ? nil : 3)
            
            Button(action: { isExpanded.toggle() }) {
                Text(isExpanded ? "收起" : "展开")
                    .font(.caption2)
                    .foregroundStyle(Color.primaryGradient)
            }
        }
        .padding(Spacing.md)
        .background(Color.inputBackground)
        .cornerRadius(CornerRadius.md)
    }
}

struct DetailBottomBar: View {
    @Binding var isLiked: Bool
    let onLike: () -> Void
    let onGenerate: () -> Void
    let onShare: () -> Void
    
    var body: some View {
        HStack(spacing: Spacing.md) {
            // 点赞按钮
            Button(action: onLike) {
                Image(systemName: isLiked ? "heart.fill" : "heart")
                    .font(.system(size: 24))
                    .foregroundColor(isLiked ? .like : .white)
            }
            .frame(width: 50, height: 50)
            .background(Color.inputBackground)
            .cornerRadius(CornerRadius.md)
            
            // 跟图生成按钮
            Button(action: onGenerate) {
                HStack(spacing: Spacing.xs) {
                    Image(systemName: "wand.and.stars")
                    Text("生成")
                }
                .font(.buttonLarge)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 50)
                .background(Color.primaryGradient)
                .cornerRadius(CornerRadius.xl)
            }
            
            // 分享按钮
            Button(action: onShare) {
                Image(systemName: "square.and.arrow.up")
                    .font(.system(size: 20))
                    .foregroundColor(.white)
            }
            .frame(width: 50, height: 50)
            .background(Color.inputBackground)
            .cornerRadius(CornerRadius.md)
        }
        .padding(Spacing.md)
        .background(Color.appBackground)
    }
}
```

### 4.5 个人中心页（ProfileView）

```swift
struct ProfileView: View {
    @State private var selectedTab = 0
    let tabs = ["我的", "作品", "点赞"]
    
    var body: some View {
        ZStack {
            Color.appBackground.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // 背景渐变
                ProfileHeader()
                
                // 统计卡片
                StatsRow()
                    .padding(.horizontal, Spacing.md)
                    .offset(y: -20)
                
                // Tab切换
                ProfileTabs(selectedTab: $selectedTab, tabs: tabs)
                
                // 内容区域
                TabView(selection: $selectedTab) {
                    MyContentView().tag(0)
                    MyWorksView().tag(1)
                    MyLikesView().tag(2)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
            }
        }
    }
}

struct ProfileHeader: View {
    var body: some View {
        ZStack {
            // 背景渐变
            LinearGradient(
                colors: [Color.surfaceBackground, Color.appBackground],
                startPoint: .top,
                endPoint: .bottom
            )
            .frame(height: 200)
            
            VStack(spacing: Spacing.sm) {
                // 头像
                Circle()
                    .fill(Color.primaryGradient)
                    .frame(width: 80, height: 80)
                    .overlay(
                        Text("🐚")
                            .font(.system(size: 40))
                    )
                
                // 用户名
                Text("泡泡のred")
                    .font(.title3)
                    .foregroundColor(.white)
            }
            
            // 设置按钮
            VStack {
                HStack {
                    Spacer()
                    Button(action: { /* 设置 */ }) {
                        Image(systemName: "gearshape.fill")
                            .font(.system(size: 18))
                            .foregroundColor(.white)
                            .frame(width: 36, height: 36)
                            .background(Color.inputBackground)
                            .clipShape(Circle())
                    }
                }
                Spacer()
            }
            .padding()
        }
    }
}

struct StatsRow: View {
    var body: some View {
        HStack(spacing: Spacing.sm) {
            // 会员卡片
            StatCard(
                icon: "👑",
                label: "会员套餐",
                value: "免费版",
                action: "GO PRO"
            )
            
            // 积分卡片
            StatCard(
                icon: "⚡",
                label: "积分",
                value: "360",
                showAdd: true
            )
        }
    }
}

struct StatCard: View {
    let icon: String
    let label: String
    let value: String
    var action: String? = nil
    var showAdd: Bool = false
    
    var body: some View {
        HStack {
            HStack(spacing: Spacing.xs) {
                Text(icon)
                    .font(.system(size: 16))
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(label)
                        .font(.caption2)
                        .foregroundColor(.textSecondary)
                    Text(value)
                        .font(.bodySmall)
                        .fontWeight(.medium)
                        .foregroundColor(.white)
                }
            }
            
            Spacer()
            
            if let action = action {
                Text(action)
                    .font(.caption2)
                    .fontWeight(.medium)
                    .foregroundColor(.white)
                    .padding(.horizontal, Spacing.sm)
                    .padding(.vertical, Spacing.xxs)
                    .background(Color.inputBackground)
                    .cornerRadius(CornerRadius.sm)
            }
            
            if showAdd {
                Image(systemName: "plus.circle")
                    .foregroundColor(.textSecondary)
            }
        }
        .padding(Spacing.sm)
        .background(Color.inputBackground)
        .cornerRadius(CornerRadius.md)
    }
}

struct ProfileTabs: View {
    @Binding var selectedTab: Int
    let tabs: [String]
    
    var body: some View {
        HStack(spacing: 0) {
            ForEach(tabs.indices, id: \.self) { index in
                Button(action: {
                    withAnimation { selectedTab = index }
                }) {
                    VStack(spacing: Spacing.xs) {
                        Text(tabs[index])
                            .font(.bodyMedium)
                            .foregroundColor(selectedTab == index ? .white : .textTertiary)
                        
                        Rectangle()
                            .fill(selectedTab == index ? Color.white : Color.clear)
                            .frame(width: 30, height: 3)
                            .cornerRadius(2)
                    }
                }
                .frame(maxWidth: .infinity)
            }
        }
        .padding(.vertical, Spacing.sm)
        .overlay(
            Rectangle()
                .fill(Color.borderDefault)
                .frame(height: 1),
            alignment: .bottom
        )
    }
}
```

### 4.6 会员订阅页（MembershipView）

```swift
struct MembershipView: View {
    @State private var selectedPlan = 1
    @Environment(\.dismiss) var dismiss
    
    let plans = [
        MembershipPlan(id: 0, name: "周会员", price: 18, originalPrice: 28, period: "¥18/每周", isPopular: false),
        MembershipPlan(id: 1, name: "月会员", price: 39, originalPrice: 58, period: "首月¥39/续费¥58", isPopular: true),
        MembershipPlan(id: 2, name: "季会员", price: 98, originalPrice: 168, period: "约¥32/每月", isPopular: false)
    ]
    
    var body: some View {
        ZStack {
            // 背景
            LinearGradient(
                colors: [Color.surfaceBackground, Color.appBackground],
                startPoint: .top,
                endPoint: .center
            )
            .ignoresSafeArea()
            
            VStack(spacing: Spacing.lg) {
                // 顶部导航
                MembershipHeader(onClose: { dismiss() })
                
                // Logo和标题
                VStack(spacing: Spacing.sm) {
                    Text("🐚")
                        .font(.system(size: 50))
                    
                    Text("AI创图")
                        .font(.title2)
                        .foregroundColor(.white)
                    
                    Text("会员套餐")
                        .font(.title3)
                        .foregroundColor(.white)
                }
                
                // 订阅类型切换
                SubscriptionToggle()
                
                // 会员权益
                MembershipBenefits()
                
                // 套餐选择
                VStack(spacing: Spacing.sm) {
                    ForEach(plans) { plan in
                        PlanCard(
                            plan: plan,
                            isSelected: selectedPlan == plan.id
                        ) {
                            selectedPlan = plan.id
                        }
                    }
                }
                .padding(.horizontal, Spacing.md)
                
                Spacer()
                
                // 订阅按钮
                PrimaryButton("立即订阅") {
                    // 订阅逻辑
                }
                .padding(.horizontal, Spacing.md)
                .padding(.bottom, Spacing.xl)
            }
        }
    }
}

struct MembershipPlan: Identifiable {
    let id: Int
    let name: String
    let price: Int
    let originalPrice: Int
    let period: String
    let isPopular: Bool
}

struct PlanCard: View {
    let plan: MembershipPlan
    let isSelected: Bool
    let onSelect: () -> Void
    
    var body: some View {
        Button(action: onSelect) {
            HStack {
                VStack(alignment: .leading, spacing: Spacing.xxs) {
                    HStack(spacing: Spacing.xs) {
                        Text(plan.name)
                            .font(.bodyMedium)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                        
                        if plan.isPopular {
                            Text("热卖")
                                .font(.caption3)
                                .foregroundColor(.white)
                                .padding(.horizontal, Spacing.xs)
                                .padding(.vertical, 2)
                                .background(Color.warning)
                                .cornerRadius(CornerRadius.xs)
                        }
                    }
                    
                    Text(plan.period)
                        .font(.caption2)
                        .foregroundColor(.textSecondary)
                }
                
                Spacer()
                
                HStack(alignment: .firstTextBaseline, spacing: 2) {
                    Text("¥")
                        .font(.caption1)
                    Text("\(plan.price)")
                        .font(.title2)
                        .fontWeight(.bold)
                    Text("/\(plan.originalPrice)")
                        .font(.caption2)
                        .foregroundColor(.textSecondary)
                        .strikethrough()
                }
                .foregroundColor(.white)
            }
            .padding(Spacing.md)
            .background(
                isSelected ? Color.primaryGradient.opacity(0.2) : Color.inputBackground
            )
            .cornerRadius(CornerRadius.md)
            .overlay(
                RoundedRectangle(cornerRadius: CornerRadius.md)
                    .stroke(
                        isSelected ? Color.gradientPurple : Color.borderDefault,
                        lineWidth: isSelected ? 2 : 1
                    )
            )
        }
    }
}
```

---

## 5. 交互规范（Interactions）

### 5.1 动画时长

```swift
enum AnimationDuration {
    static let fast: Double = 0.15      // 快速反馈（按钮点击）
    static let normal: Double = 0.25    // 常规过渡
    static let slow: Double = 0.35      // 页面切换
    static let spring = Animation.spring(response: 0.3, dampingFraction: 0.7)
}
```

### 5.2 触觉反馈

```swift
enum HapticFeedback {
    static func light() {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
    }
    
    static func medium() {
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
    }
    
    static func success() {
        UINotificationFeedbackGenerator().notificationOccurred(.success)
    }
    
    static func error() {
        UINotificationFeedbackGenerator().notificationOccurred(.error)
    }
}
```

### 5.3 按钮状态

```swift
struct ScaleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.96 : 1)
            .opacity(configuration.isPressed ? 0.9 : 1)
            .animation(.easeInOut(duration: AnimationDuration.fast), value: configuration.isPressed)
    }
}

// 使用
Button("点击") { }
    .buttonStyle(ScaleButtonStyle())
```

---

## 6. 项目结构建议

```
AIImageCreator/
├── App/
│   ├── AIImageCreatorApp.swift
│   └── ContentView.swift
├── Core/
│   ├── Design/
│   │   ├── Colors.swift
│   │   ├── Fonts.swift
│   │   ├── Spacing.swift
│   │   └── CornerRadius.swift
│   ├── Components/
│   │   ├── Buttons/
│   │   ├── Cards/
│   │   ├── Navigation/
│   │   └── Inputs/
│   └── Extensions/
│       ├── Color+Hex.swift
│       └── View+Extensions.swift
├── Features/
│   ├── Auth/
│   │   ├── LoginView.swift
│   │   └── PhoneLoginView.swift
│   ├── Home/
│   │   ├── HomeView.swift
│   │   └── Components/
│   ├── Create/
│   │   ├── CreateView.swift
│   │   └── Components/
│   ├── Detail/
│   │   ├── DetailView.swift
│   │   └── Components/
│   ├── Profile/
│   │   ├── ProfileView.swift
│   │   └── Components/
│   └── Membership/
│       ├── MembershipView.swift
│       └── RechargeView.swift
├── Models/
│   ├── User.swift
│   ├── Work.swift
│   └── Template.swift
├── Services/
│   ├── APIService.swift
│   └── AuthService.swift
└── Resources/
    └── Assets.xcassets
```

---

## 7. 开发注意事项

1. **暗黑模式优先**：所有页面默认使用暗黑背景，不需要支持浅色模式切换
2. **渐变色使用**：主要CTA按钮、强调元素使用紫粉渐变，避免过度使用
3. **圆角统一**：按钮使用xl(20)，卡片使用lg(16)，小元素使用md(12)
4. **间距规范**：组件内部间距使用sm(12)，组件之间使用lg(20)或xl(24)
5. **字体层级**：严格遵循字体系统，保持视觉层次清晰
6. **触觉反馈**：所有按钮点击添加轻触觉反馈，重要操作添加成功/错误反馈
7. **动画流畅**：页面切换使用spring动画，状态变化使用easeInOut

---

*文档版本：1.0*  
*最后更新：2026年1月18日*  
*作者：Manus AI*


---

## 8. 数据模型（Data Models）

### 8.1 用户模型（User）

```swift
import Foundation

// MARK: - 用户模型
struct User: Codable, Identifiable {
    let id: String
    var nickname: String
    var avatar: String?                    // 头像URL或emoji
    var phone: String?                     // 手机号（脱敏）
    var membershipType: MembershipType     // 会员类型
    var membershipExpireAt: Date?          // 会员过期时间
    var points: Int                        // 积分余额
    var createdAt: Date
    var updatedAt: Date
    
    // 计算属性
    var isMember: Bool {
        guard let expireAt = membershipExpireAt else { return false }
        return expireAt > Date() && membershipType != .free
    }
    
    var displayName: String {
        nickname.isEmpty ? "用户\(id.prefix(6))" : nickname
    }
}

// MARK: - 会员类型
enum MembershipType: String, Codable, CaseIterable {
    case free = "free"           // 免费版
    case weekly = "weekly"       // 周会员
    case monthly = "monthly"     // 月会员
    case quarterly = "quarterly" // 季会员
    case yearly = "yearly"       // 年会员
    
    var displayName: String {
        switch self {
        case .free: return "免费版"
        case .weekly: return "周会员"
        case .monthly: return "月会员"
        case .quarterly: return "季会员"
        case .yearly: return "年会员"
        }
    }
    
    var badgeColor: Color {
        switch self {
        case .free: return .textSecondary
        default: return .gradientPurple
        }
    }
}

// MARK: - 用户统计
struct UserStats: Codable {
    let userId: String
    var worksCount: Int          // 作品数量
    var likesCount: Int          // 获赞数量
    var likedCount: Int          // 点赞数量
    var followersCount: Int      // 粉丝数量
    var followingCount: Int      // 关注数量
}

// MARK: - 登录凭证
struct AuthCredentials: Codable {
    let accessToken: String
    let refreshToken: String
    let expiresIn: Int           // 过期时间（秒）
    let tokenType: String        // "Bearer"
}

// MARK: - 登录请求
struct LoginRequest: Codable {
    let type: LoginType
    let code: String?            // 微信/Apple授权码
    let phone: String?           // 手机号
    let verifyCode: String?      // 验证码
}

enum LoginType: String, Codable {
    case wechat = "wechat"
    case apple = "apple"
    case phone = "phone"
}
```

### 8.2 作品模型（Work）

```swift
import Foundation

// MARK: - 作品模型
struct Work: Codable, Identifiable {
    let id: String
    let userId: String
    let templateId: String?
    var title: String
    var description: String?
    var imageURL: String                   // 生成的图片URL
    var thumbnailURL: String               // 缩略图URL
    var originalImageURL: String?          // 原始上传图片URL
    var prompt: String                     // 使用的提示词
    var negativePrompt: String?            // 负面提示词
    var style: GenerationStyle             // 生成风格
    var status: WorkStatus                 // 作品状态
    var isPublic: Bool                     // 是否公开
    var likesCount: Int                    // 点赞数
    var viewsCount: Int                    // 浏览数
    var commentsCount: Int                 // 评论数
    var followCount: Int                   // 跟图数
    var createdAt: Date
    var updatedAt: Date
    
    // 关联数据（可选，根据接口返回）
    var author: User?
    var template: Template?
    var isLiked: Bool?                     // 当前用户是否点赞
}

// MARK: - 作品状态
enum WorkStatus: String, Codable {
    case pending = "pending"       // 生成中
    case processing = "processing" // 处理中
    case completed = "completed"   // 已完成
    case failed = "failed"         // 生成失败
    
    var displayName: String {
        switch self {
        case .pending: return "排队中"
        case .processing: return "生成中"
        case .completed: return "已完成"
        case .failed: return "生成失败"
        }
    }
}

// MARK: - 生成风格
enum GenerationStyle: String, Codable, CaseIterable {
    case realistic = "realistic"     // 写实
    case anime = "anime"             // 动漫
    case artistic = "artistic"       // 艺术
    case portrait = "portrait"       // 人像美化
    case vintage = "vintage"         // 复古
    case cyberpunk = "cyberpunk"     // 赛博朋克
    case watercolor = "watercolor"   // 水彩
    case oilPainting = "oil_painting" // 油画
    
    var displayName: String {
        switch self {
        case .realistic: return "写实"
        case .anime: return "动漫"
        case .artistic: return "艺术"
        case .portrait: return "人像美化"
        case .vintage: return "复古"
        case .cyberpunk: return "赛博朋克"
        case .watercolor: return "水彩"
        case .oilPainting: return "油画"
        }
    }
    
    var icon: String {
        switch self {
        case .realistic: return "camera.fill"
        case .anime: return "sparkles"
        case .artistic: return "paintbrush.fill"
        case .portrait: return "person.fill"
        case .vintage: return "clock.fill"
        case .cyberpunk: return "bolt.fill"
        case .watercolor: return "drop.fill"
        case .oilPainting: return "paintpalette.fill"
        }
    }
}

// MARK: - 作品列表项（轻量版，用于列表展示）
struct WorkListItem: Codable, Identifiable {
    let id: String
    let thumbnailURL: String
    let title: String
    let authorName: String
    let authorAvatar: String?
    let likesCount: Int
    let viewsCount: Int
    var isLiked: Bool
}
```

### 8.3 模板模型（Template）

```swift
import Foundation

// MARK: - 模板模型
struct Template: Codable, Identifiable {
    let id: String
    var name: String
    var description: String
    var coverURL: String                   // 封面图
    var previewURLs: [String]              // 预览图列表
    var category: TemplateCategory         // 分类
    var style: GenerationStyle             // 对应风格
    var prompt: String                     // 默认提示词
    var negativePrompt: String?            // 默认负面提示词
    var pointsCost: Int                    // 消耗积分
    var isFree: Bool                       // 是否免费
    var isHot: Bool                        // 是否热门
    var isNew: Bool                        // 是否新品
    var usageCount: Int                    // 使用次数
    var sortOrder: Int                     // 排序权重
    var createdAt: Date
}

// MARK: - 模板分类
enum TemplateCategory: String, Codable, CaseIterable {
    case recommend = "recommend"   // 推荐
    case beauty = "beauty"         // 美颜
    case life = "life"             // 生活
    case art = "art"               // 艺术
    case portrait = "portrait"     // 人像
    case scene = "scene"           // 场景
    case creative = "creative"     // 创意
    case festival = "festival"     // 节日
    
    var displayName: String {
        switch self {
        case .recommend: return "推荐"
        case .beauty: return "美颜"
        case .life: return "生活"
        case .art: return "艺术"
        case .portrait: return "人像"
        case .scene: return "场景"
        case .creative: return "创意"
        case .festival: return "节日"
        }
    }
    
    var icon: String {
        switch self {
        case .recommend: return "🔥"
        case .beauty: return "👤"
        case .life: return "🏠"
        case .art: return "🎨"
        case .portrait: return "📷"
        case .scene: return "🌄"
        case .creative: return "✨"
        case .festival: return "🎉"
        }
    }
}

// MARK: - 模板列表项
struct TemplateListItem: Codable, Identifiable {
    let id: String
    let name: String
    let coverURL: String
    let category: TemplateCategory
    let pointsCost: Int
    let isHot: Bool
    let isNew: Bool
}
```

### 8.4 订单与支付模型（Order & Payment）

```swift
import Foundation

// MARK: - 会员套餐
struct MembershipPlan: Codable, Identifiable {
    let id: String
    let type: MembershipType
    var name: String
    var description: String
    var price: Decimal                     // 当前价格
    var originalPrice: Decimal             // 原价
    var duration: Int                      // 时长（天）
    var pointsGift: Int                    // 赠送积分
    var features: [String]                 // 权益列表
    var isPopular: Bool                    // 是否热门
    var discount: String?                  // 折扣标签
}

// MARK: - 积分套餐
struct PointsPackage: Codable, Identifiable {
    let id: String
    var points: Int                        // 积分数量
    var price: Decimal                     // 价格
    var bonusPoints: Int                   // 赠送积分
    var isPopular: Bool                    // 是否热门
    var validDays: Int                     // 有效期（天）
    
    var totalPoints: Int {
        points + bonusPoints
    }
    
    var unitPrice: Decimal {
        price / Decimal(totalPoints)
    }
}

// MARK: - 订单模型
struct Order: Codable, Identifiable {
    let id: String
    let userId: String
    let orderNo: String                    // 订单号
    var orderType: OrderType               // 订单类型
    var productId: String                  // 商品ID
    var productName: String                // 商品名称
    var amount: Decimal                    // 订单金额
    var paymentMethod: PaymentMethod?      // 支付方式
    var status: OrderStatus                // 订单状态
    var paidAt: Date?                      // 支付时间
    var createdAt: Date
    var expiredAt: Date                    // 过期时间
}

enum OrderType: String, Codable {
    case membership = "membership"  // 会员订阅
    case points = "points"          // 积分充值
}

enum PaymentMethod: String, Codable {
    case wechat = "wechat"          // 微信支付
    case alipay = "alipay"          // 支付宝
    case apple = "apple"            // Apple Pay
}

enum OrderStatus: String, Codable {
    case pending = "pending"        // 待支付
    case paid = "paid"              // 已支付
    case cancelled = "cancelled"    // 已取消
    case refunded = "refunded"      // 已退款
    case expired = "expired"        // 已过期
}

// MARK: - 支付请求
struct PaymentRequest: Codable {
    let orderId: String
    let paymentMethod: PaymentMethod
}

// MARK: - 支付结果
struct PaymentResult: Codable {
    let orderId: String
    let success: Bool
    let message: String?
    let transactionId: String?
}
```

### 8.5 通用模型（Common）

```swift
import Foundation

// MARK: - 分页请求
struct PageRequest: Codable {
    var page: Int = 1
    var pageSize: Int = 20
    var sortBy: String?
    var sortOrder: SortOrder = .desc
}

enum SortOrder: String, Codable {
    case asc = "asc"
    case desc = "desc"
}

// MARK: - 分页响应
struct PageResponse<T: Codable>: Codable {
    let items: [T]
    let total: Int
    let page: Int
    let pageSize: Int
    let hasMore: Bool
}

// MARK: - API响应包装
struct APIResponse<T: Codable>: Codable {
    let code: Int                          // 状态码：0成功，其他失败
    let message: String                    // 提示信息
    let data: T?                           // 数据
    let timestamp: Int64                   // 时间戳
    
    var isSuccess: Bool {
        code == 0
    }
}

// MARK: - 错误响应
struct APIError: Codable, Error {
    let code: Int
    let message: String
    let details: String?
}

// MARK: - 上传结果
struct UploadResult: Codable {
    let url: String                        // 文件URL
    let thumbnailURL: String?              // 缩略图URL
    let fileId: String                     // 文件ID
    let fileName: String                   // 文件名
    let fileSize: Int64                    // 文件大小
    let mimeType: String                   // MIME类型
}

// MARK: - 生成任务
struct GenerationTask: Codable, Identifiable {
    let id: String
    let userId: String
    var status: TaskStatus
    var progress: Int                      // 进度 0-100
    var estimatedTime: Int?                // 预计剩余时间（秒）
    var resultURL: String?                 // 结果图片URL
    var errorMessage: String?              // 错误信息
    var createdAt: Date
    var completedAt: Date?
}

enum TaskStatus: String, Codable {
    case queued = "queued"           // 排队中
    case processing = "processing"   // 处理中
    case completed = "completed"     // 已完成
    case failed = "failed"           // 失败
    case cancelled = "cancelled"     // 已取消
}

// MARK: - 通知消息
struct NotificationItem: Codable, Identifiable {
    let id: String
    var type: NotificationType
    var title: String
    var content: String
    var imageURL: String?
    var targetId: String?                  // 跳转目标ID
    var targetType: String?                // 跳转目标类型
    var isRead: Bool
    var createdAt: Date
}

enum NotificationType: String, Codable {
    case system = "system"           // 系统通知
    case like = "like"               // 点赞通知
    case comment = "comment"         // 评论通知
    case follow = "follow"           // 关注通知
    case generation = "generation"   // 生成完成通知
    case membership = "membership"   // 会员通知
}

// MARK: - 举报
struct ReportRequest: Codable {
    let targetId: String
    let targetType: ReportTargetType
    let reason: ReportReason
    let description: String?
}

enum ReportTargetType: String, Codable {
    case work = "work"
    case user = "user"
    case comment = "comment"
}

enum ReportReason: String, Codable {
    case spam = "spam"                     // 垃圾内容
    case inappropriate = "inappropriate"   // 不当内容
    case copyright = "copyright"           // 侵权
    case other = "other"                   // 其他
}
```



---

## 9. API接口规范（API Specification）

### 9.1 基础配置

```swift
import Foundation

// MARK: - API配置
enum APIConfig {
    static let baseURL = "https://api.aichuangtu.com/v1"
    static let timeout: TimeInterval = 30
    static let uploadTimeout: TimeInterval = 120
    
    enum Headers {
        static let contentType = "Content-Type"
        static let authorization = "Authorization"
        static let platform = "X-Platform"
        static let version = "X-App-Version"
        static let deviceId = "X-Device-Id"
    }
}

// MARK: - API端点
enum APIEndpoint {
    // 认证
    case login
    case logout
    case refreshToken
    case sendVerifyCode
    
    // 用户
    case getUserInfo
    case updateUserInfo
    case getUserStats
    
    // 作品
    case getWorkList
    case getWorkDetail(id: String)
    case createWork
    case deleteWork(id: String)
    case likeWork(id: String)
    case unlikeWork(id: String)
    
    // 模板
    case getTemplateList
    case getTemplateDetail(id: String)
    
    // 生成
    case createGeneration
    case getGenerationStatus(id: String)
    case cancelGeneration(id: String)
    
    // 会员
    case getMembershipPlans
    case createMembershipOrder
    
    // 积分
    case getPointsPackages
    case createPointsOrder
    case getPointsHistory
    
    // 上传
    case uploadImage
    
    // 其他
    case getNotifications
    case markNotificationRead
    case report
    
    var path: String {
        switch self {
        case .login: return "/auth/login"
        case .logout: return "/auth/logout"
        case .refreshToken: return "/auth/refresh"
        case .sendVerifyCode: return "/auth/verify-code"
        case .getUserInfo: return "/user/info"
        case .updateUserInfo: return "/user/info"
        case .getUserStats: return "/user/stats"
        case .getWorkList: return "/works"
        case .getWorkDetail(let id): return "/works/\(id)"
        case .createWork: return "/works"
        case .deleteWork(let id): return "/works/\(id)"
        case .likeWork(let id): return "/works/\(id)/like"
        case .unlikeWork(let id): return "/works/\(id)/like"
        case .getTemplateList: return "/templates"
        case .getTemplateDetail(let id): return "/templates/\(id)"
        case .createGeneration: return "/generations"
        case .getGenerationStatus(let id): return "/generations/\(id)"
        case .cancelGeneration(let id): return "/generations/\(id)/cancel"
        case .getMembershipPlans: return "/membership/plans"
        case .createMembershipOrder: return "/membership/orders"
        case .getPointsPackages: return "/points/packages"
        case .createPointsOrder: return "/points/orders"
        case .getPointsHistory: return "/points/history"
        case .uploadImage: return "/upload/image"
        case .getNotifications: return "/notifications"
        case .markNotificationRead: return "/notifications/read"
        case .report: return "/reports"
        }
    }
    
    var method: HTTPMethod {
        switch self {
        case .login, .sendVerifyCode, .createWork, .likeWork,
             .createGeneration, .createMembershipOrder, .createPointsOrder,
             .uploadImage, .markNotificationRead, .report:
            return .post
        case .logout, .deleteWork, .unlikeWork, .cancelGeneration:
            return .delete
        case .updateUserInfo:
            return .put
        default:
            return .get
        }
    }
}

enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case delete = "DELETE"
}
```

### 9.2 接口详细定义

#### 9.2.1 认证接口

| 接口 | 方法 | 路径 | 说明 |
|------|------|------|------|
| 登录 | POST | /auth/login | 微信/Apple/手机登录 |
| 登出 | DELETE | /auth/logout | 退出登录 |
| 刷新Token | POST | /auth/refresh | 刷新访问令牌 |
| 发送验证码 | POST | /auth/verify-code | 发送手机验证码 |

```swift
// MARK: - 登录请求
struct LoginRequest: Codable {
    let type: String           // "wechat" | "apple" | "phone"
    let code: String?          // 微信/Apple授权码
    let phone: String?         // 手机号
    let verifyCode: String?    // 验证码
}

// 登录响应
struct LoginResponse: Codable {
    let user: User
    let credentials: AuthCredentials
}

// MARK: - 发送验证码请求
struct SendVerifyCodeRequest: Codable {
    let phone: String
    let type: String           // "login" | "bind"
}

// 发送验证码响应
struct SendVerifyCodeResponse: Codable {
    let expireIn: Int          // 验证码有效期（秒）
}

// MARK: - 刷新Token请求
struct RefreshTokenRequest: Codable {
    let refreshToken: String
}
```

#### 9.2.2 用户接口

| 接口 | 方法 | 路径 | 说明 |
|------|------|------|------|
| 获取用户信息 | GET | /user/info | 获取当前用户信息 |
| 更新用户信息 | PUT | /user/info | 更新昵称、头像等 |
| 获取用户统计 | GET | /user/stats | 获取作品数、点赞数等 |

```swift
// MARK: - 更新用户信息请求
struct UpdateUserInfoRequest: Codable {
    let nickname: String?
    let avatar: String?
}

// MARK: - 用户信息响应
struct UserInfoResponse: Codable {
    let user: User
    let stats: UserStats
}
```

#### 9.2.3 作品接口

| 接口 | 方法 | 路径 | 说明 |
|------|------|------|------|
| 获取作品列表 | GET | /works | 分页获取作品列表 |
| 获取作品详情 | GET | /works/:id | 获取单个作品详情 |
| 创建作品 | POST | /works | 保存生成的作品 |
| 删除作品 | DELETE | /works/:id | 删除作品 |
| 点赞作品 | POST | /works/:id/like | 点赞 |
| 取消点赞 | DELETE | /works/:id/like | 取消点赞 |

```swift
// MARK: - 获取作品列表请求
struct GetWorksRequest: Codable {
    let page: Int
    let pageSize: Int
    let category: String?      // 分类筛选
    let userId: String?        // 用户筛选
    let type: String?          // "recommend" | "latest" | "hot" | "following"
}

// 作品列表响应
typealias GetWorksResponse = PageResponse<WorkListItem>

// MARK: - 作品详情响应
struct WorkDetailResponse: Codable {
    let work: Work
    let author: User
    let template: Template?
    let relatedWorks: [WorkListItem]   // 相关作品/跟图列表
}

// MARK: - 创建作品请求
struct CreateWorkRequest: Codable {
    let generationId: String   // 生成任务ID
    let title: String
    let description: String?
    let isPublic: Bool
}
```

#### 9.2.4 模板接口

| 接口 | 方法 | 路径 | 说明 |
|------|------|------|------|
| 获取模板列表 | GET | /templates | 分页获取模板列表 |
| 获取模板详情 | GET | /templates/:id | 获取单个模板详情 |

```swift
// MARK: - 获取模板列表请求
struct GetTemplatesRequest: Codable {
    let page: Int
    let pageSize: Int
    let category: String?      // 分类筛选
    let isHot: Bool?           // 热门筛选
}

// 模板列表响应
typealias GetTemplatesResponse = PageResponse<TemplateListItem>

// MARK: - 模板详情响应
struct TemplateDetailResponse: Codable {
    let template: Template
    let sampleWorks: [WorkListItem]    // 示例作品
}
```

#### 9.2.5 AI生成接口

| 接口 | 方法 | 路径 | 说明 |
|------|------|------|------|
| 创建生成任务 | POST | /generations | 提交AI生成请求 |
| 获取生成状态 | GET | /generations/:id | 轮询生成进度 |
| 取消生成 | DELETE | /generations/:id/cancel | 取消生成任务 |

```swift
// MARK: - 创建生成任务请求
struct CreateGenerationRequest: Codable {
    let templateId: String?            // 模板ID（可选）
    let imageURL: String               // 上传的原图URL
    let prompt: String?                // 自定义提示词
    let negativePrompt: String?        // 负面提示词
    let style: String                  // 生成风格
    let referenceWorkId: String?       // 跟图参考作品ID
}

// 创建生成任务响应
struct CreateGenerationResponse: Codable {
    let taskId: String
    let estimatedTime: Int             // 预计等待时间（秒）
    let queuePosition: Int             // 队列位置
    let pointsCost: Int                // 消耗积分
}

// MARK: - 生成状态响应
struct GenerationStatusResponse: Codable {
    let task: GenerationTask
}
```

#### 9.2.6 支付接口

| 接口 | 方法 | 路径 | 说明 |
|------|------|------|------|
| 获取会员套餐 | GET | /membership/plans | 获取会员套餐列表 |
| 创建会员订单 | POST | /membership/orders | 创建会员订阅订单 |
| 获取积分套餐 | GET | /points/packages | 获取积分充值套餐 |
| 创建积分订单 | POST | /points/orders | 创建积分充值订单 |
| 获取积分记录 | GET | /points/history | 获取积分变动记录 |

```swift
// MARK: - 会员套餐列表响应
struct MembershipPlansResponse: Codable {
    let plans: [MembershipPlan]
}

// MARK: - 创建订单请求
struct CreateOrderRequest: Codable {
    let productId: String              // 套餐ID
    let paymentMethod: String          // "wechat" | "alipay" | "apple"
}

// 创建订单响应
struct CreateOrderResponse: Codable {
    let order: Order
    let paymentParams: PaymentParams   // 支付参数
}

// 支付参数（根据支付方式不同）
struct PaymentParams: Codable {
    let wechatParams: WechatPayParams?
    let alipayParams: AlipayParams?
    let appleProductId: String?
}

struct WechatPayParams: Codable {
    let appId: String
    let partnerId: String
    let prepayId: String
    let nonceStr: String
    let timeStamp: String
    let sign: String
}

struct AlipayParams: Codable {
    let orderString: String
}

// MARK: - 积分记录
struct PointsHistoryItem: Codable, Identifiable {
    let id: String
    let type: String                   // "recharge" | "consume" | "gift" | "refund"
    let amount: Int                    // 变动数量（正负）
    let balance: Int                   // 变动后余额
    let description: String            // 描述
    let createdAt: Date
}

typealias PointsHistoryResponse = PageResponse<PointsHistoryItem>
```

#### 9.2.7 上传接口

| 接口 | 方法 | 路径 | 说明 |
|------|------|------|------|
| 上传图片 | POST | /upload/image | 上传图片文件 |

```swift
// MARK: - 上传图片
// Content-Type: multipart/form-data

// 上传响应
struct UploadImageResponse: Codable {
    let url: String                    // 图片URL
    let thumbnailURL: String           // 缩略图URL
    let fileId: String                 // 文件ID
}
```

### 9.3 网络服务实现

```swift
import Foundation

// MARK: - 网络服务
class APIService {
    static let shared = APIService()
    
    private let session: URLSession
    private var accessToken: String?
    
    private init() {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = APIConfig.timeout
        self.session = URLSession(configuration: config)
    }
    
    // MARK: - 设置Token
    func setAccessToken(_ token: String?) {
        self.accessToken = token
    }
    
    // MARK: - 通用请求方法
    func request<T: Codable, R: Codable>(
        endpoint: APIEndpoint,
        body: T? = nil as Empty?,
        queryItems: [URLQueryItem]? = nil
    ) async throws -> APIResponse<R> {
        var urlComponents = URLComponents(string: APIConfig.baseURL + endpoint.path)!
        urlComponents.queryItems = queryItems
        
        var request = URLRequest(url: urlComponents.url!)
        request.httpMethod = endpoint.method.rawValue
        request.setValue("application/json", forHTTPHeaderField: APIConfig.Headers.contentType)
        request.setValue("iOS", forHTTPHeaderField: APIConfig.Headers.platform)
        request.setValue(Bundle.main.appVersion, forHTTPHeaderField: APIConfig.Headers.version)
        
        if let token = accessToken {
            request.setValue("Bearer \(token)", forHTTPHeaderField: APIConfig.Headers.authorization)
        }
        
        if let body = body {
            request.httpBody = try JSONEncoder().encode(body)
        }
        
        let (data, response) = try await session.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError(code: -1, message: "Invalid response", details: nil)
        }
        
        if httpResponse.statusCode == 401 {
            // Token过期，尝试刷新
            throw APIError(code: 401, message: "Unauthorized", details: nil)
        }
        
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        
        return try decoder.decode(APIResponse<R>.self, from: data)
    }
    
    // MARK: - 上传图片
    func uploadImage(_ imageData: Data, fileName: String = "image.jpg") async throws -> UploadImageResponse {
        let boundary = UUID().uuidString
        var request = URLRequest(url: URL(string: APIConfig.baseURL + "/upload/image")!)
        request.httpMethod = "POST"
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        request.timeoutInterval = APIConfig.uploadTimeout
        
        if let token = accessToken {
            request.setValue("Bearer \(token)", forHTTPHeaderField: APIConfig.Headers.authorization)
        }
        
        var body = Data()
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"file\"; filename=\"\(fileName)\"\r\n".data(using: .utf8)!)
        body.append("Content-Type: image/jpeg\r\n\r\n".data(using: .utf8)!)
        body.append(imageData)
        body.append("\r\n--\(boundary)--\r\n".data(using: .utf8)!)
        
        request.httpBody = body
        
        let (data, _) = try await session.data(for: request)
        let response = try JSONDecoder().decode(APIResponse<UploadImageResponse>.self, from: data)
        
        guard let result = response.data else {
            throw APIError(code: response.code, message: response.message, details: nil)
        }
        
        return result
    }
}

// 空请求体占位
struct Empty: Codable {}

// Bundle扩展
extension Bundle {
    var appVersion: String {
        infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0.0"
    }
}
```

### 9.4 使用示例

```swift
// MARK: - 使用示例

// 1. 登录
func login(phone: String, code: String) async throws -> User {
    let request = LoginRequest(type: "phone", code: nil, phone: phone, verifyCode: code)
    let response: APIResponse<LoginResponse> = try await APIService.shared.request(
        endpoint: .login,
        body: request
    )
    
    guard let data = response.data else {
        throw APIError(code: response.code, message: response.message, details: nil)
    }
    
    // 保存Token
    APIService.shared.setAccessToken(data.credentials.accessToken)
    
    return data.user
}

// 2. 获取作品列表
func getWorks(page: Int, category: String?) async throws -> [WorkListItem] {
    let queryItems = [
        URLQueryItem(name: "page", value: "\(page)"),
        URLQueryItem(name: "pageSize", value: "20"),
        category.map { URLQueryItem(name: "category", value: $0) }
    ].compactMap { $0 }
    
    let response: APIResponse<GetWorksResponse> = try await APIService.shared.request(
        endpoint: .getWorkList,
        body: nil as Empty?,
        queryItems: queryItems
    )
    
    return response.data?.items ?? []
}

// 3. 创建AI生成任务
func createGeneration(imageURL: String, templateId: String, style: GenerationStyle) async throws -> String {
    let request = CreateGenerationRequest(
        templateId: templateId,
        imageURL: imageURL,
        prompt: nil,
        negativePrompt: nil,
        style: style.rawValue,
        referenceWorkId: nil
    )
    
    let response: APIResponse<CreateGenerationResponse> = try await APIService.shared.request(
        endpoint: .createGeneration,
        body: request
    )
    
    guard let data = response.data else {
        throw APIError(code: response.code, message: response.message, details: nil)
    }
    
    return data.taskId
}

// 4. 轮询生成状态
func pollGenerationStatus(taskId: String) async throws -> GenerationTask {
    let response: APIResponse<GenerationStatusResponse> = try await APIService.shared.request(
        endpoint: .getGenerationStatus(id: taskId)
    )
    
    guard let data = response.data else {
        throw APIError(code: response.code, message: response.message, details: nil)
    }
    
    return data.task
}
```



---

## 10. 补充页面规范（Additional Pages）

### 10.1 AI生成流程页（GenerationFlowView）

AI生成流程是App的核心功能，包含以下步骤：选择模板 → 上传照片 → 生成中 → 生成完成。

#### 10.1.1 模板选择页

```swift
struct TemplateSelectView: View {
    @State private var selectedCategory = 0
    @State private var templates: [TemplateListItem] = []
    @State private var selectedTemplate: TemplateListItem?
    @Environment(\.dismiss) var dismiss
    
    let categories = TemplateCategory.allCases
    
    var body: some View {
        ZStack {
            Color.appBackground.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // 顶部导航
                NavigationHeader(
                    title: "选择模板",
                    onBack: { dismiss() }
                )
                
                // 分类Tab
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: Spacing.sm) {
                        ForEach(categories.indices, id: \.self) { index in
                            CategoryChip(
                                icon: categories[index].icon,
                                title: categories[index].displayName,
                                isSelected: selectedCategory == index
                            ) {
                                selectedCategory = index
                            }
                        }
                    }
                    .padding(.horizontal, Spacing.md)
                }
                .padding(.vertical, Spacing.sm)
                
                // 模板网格
                ScrollView(showsIndicators: false) {
                    LazyVGrid(
                        columns: [
                            GridItem(.flexible(), spacing: Spacing.sm),
                            GridItem(.flexible(), spacing: Spacing.sm)
                        ],
                        spacing: Spacing.sm
                    ) {
                        ForEach(templates) { template in
                            TemplateGridItem(
                                template: template,
                                isSelected: selectedTemplate?.id == template.id
                            ) {
                                selectedTemplate = template
                            }
                        }
                    }
                    .padding(Spacing.md)
                }
            }
            
            // 底部确认按钮
            VStack {
                Spacer()
                if selectedTemplate != nil {
                    PrimaryButton("使用此模板") {
                        // 跳转到上传页面
                    }
                    .padding(Spacing.md)
                    .background(Color.appBackground)
                }
            }
        }
    }
}

struct TemplateGridItem: View {
    let template: TemplateListItem
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: Spacing.xs) {
                // 封面图
                ZStack(alignment: .topTrailing) {
                    AsyncImage(url: URL(string: template.coverURL)) { image in
                        image
                            .resizable()
                            .aspectRatio(3/4, contentMode: .fill)
                    } placeholder: {
                        Rectangle()
                            .fill(Color.primaryGradient.opacity(0.3))
                    }
                    .frame(maxWidth: .infinity)
                    .aspectRatio(3/4, contentMode: .fit)
                    .clipped()
                    
                    // 标签
                    HStack(spacing: Spacing.xxs) {
                        if template.isHot {
                            BadgeTag(text: "热门", color: .warning)
                        }
                        if template.isNew {
                            BadgeTag(text: "新", color: .success)
                        }
                    }
                    .padding(Spacing.xs)
                }
                
                // 名称和积分
                HStack {
                    Text(template.name)
                        .font(.caption1)
                        .foregroundColor(.textPrimary)
                        .lineLimit(1)
                    
                    Spacer()
                    
                    HStack(spacing: 2) {
                        Image(systemName: "bolt.fill")
                            .font(.system(size: 10))
                        Text("\(template.pointsCost)")
                            .font(.caption2)
                    }
                    .foregroundColor(.gradientOrange)
                }
                .padding(.horizontal, Spacing.xs)
                .padding(.bottom, Spacing.xs)
            }
            .background(Color.cardBackground)
            .cornerRadius(CornerRadius.md)
            .overlay(
                RoundedRectangle(cornerRadius: CornerRadius.md)
                    .stroke(
                        isSelected ? Color.gradientPurple : Color.borderDefault,
                        lineWidth: isSelected ? 2 : 1
                    )
            )
        }
    }
}

struct BadgeTag: View {
    let text: String
    let color: Color
    
    var body: some View {
        Text(text)
            .font(.caption3)
            .fontWeight(.medium)
            .foregroundColor(.white)
            .padding(.horizontal, Spacing.xs)
            .padding(.vertical, 2)
            .background(color)
            .cornerRadius(CornerRadius.xs)
    }
}
```

#### 10.1.2 照片上传页

```swift
struct PhotoUploadView: View {
    let template: TemplateListItem
    @State private var selectedImage: UIImage?
    @State private var isShowingImagePicker = false
    @State private var isUploading = false
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        ZStack {
            Color.appBackground.ignoresSafeArea()
            
            VStack(spacing: Spacing.xl) {
                // 顶部导航
                NavigationHeader(
                    title: "上传照片",
                    onBack: { dismiss() }
                )
                
                // 模板预览
                HStack(spacing: Spacing.md) {
                    AsyncImage(url: URL(string: template.coverURL)) { image in
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    } placeholder: {
                        Rectangle()
                            .fill(Color.primaryGradient.opacity(0.3))
                    }
                    .frame(width: 60, height: 80)
                    .cornerRadius(CornerRadius.sm)
                    
                    VStack(alignment: .leading, spacing: Spacing.xxs) {
                        Text("当前模板")
                            .font(.caption2)
                            .foregroundColor(.textSecondary)
                        Text(template.name)
                            .font(.bodyMedium)
                            .fontWeight(.medium)
                            .foregroundColor(.textPrimary)
                    }
                    
                    Spacer()
                    
                    Button(action: { dismiss() }) {
                        Text("更换")
                            .font(.caption1)
                            .foregroundStyle(Color.primaryGradient)
                    }
                }
                .padding(Spacing.md)
                .background(Color.cardBackground)
                .cornerRadius(CornerRadius.md)
                .padding(.horizontal, Spacing.md)
                
                Spacer()
                
                // 上传区域
                Button(action: { isShowingImagePicker = true }) {
                    if let image = selectedImage {
                        // 已选择图片
                        Image(uiImage: image)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(maxWidth: 280, maxHeight: 350)
                            .cornerRadius(CornerRadius.lg)
                            .overlay(
                                // 重新选择按钮
                                VStack {
                                    Spacer()
                                    HStack {
                                        Spacer()
                                        Image(systemName: "arrow.triangle.2.circlepath")
                                            .font(.system(size: 20))
                                            .foregroundColor(.white)
                                            .frame(width: 40, height: 40)
                                            .background(Color.black.opacity(0.5))
                                            .clipShape(Circle())
                                            .padding(Spacing.sm)
                                    }
                                }
                            )
                    } else {
                        // 上传占位
                        VStack(spacing: Spacing.md) {
                            Image(systemName: "photo.badge.plus")
                                .font(.system(size: 48))
                                .foregroundColor(.textSecondary)
                            
                            Text("点击上传照片")
                                .font(.bodyMedium)
                                .foregroundColor(.textSecondary)
                            
                            Text("支持 JPG、PNG 格式")
                                .font(.caption2)
                                .foregroundColor(.textTertiary)
                        }
                        .frame(width: 280, height: 350)
                        .background(Color.inputBackground)
                        .cornerRadius(CornerRadius.lg)
                        .overlay(
                            RoundedRectangle(cornerRadius: CornerRadius.lg)
                                .stroke(Color.borderDefault, style: StrokeStyle(lineWidth: 2, dash: [8]))
                        )
                    }
                }
                
                Spacer()
                
                // 提示文字
                VStack(spacing: Spacing.xs) {
                    HStack(spacing: Spacing.xs) {
                        Image(systemName: "lightbulb.fill")
                            .foregroundColor(.gradientOrange)
                        Text("小贴士")
                            .fontWeight(.medium)
                    }
                    .font(.caption1)
                    .foregroundColor(.textPrimary)
                    
                    Text("请上传清晰的正面照片，效果更佳")
                        .font(.caption2)
                        .foregroundColor(.textSecondary)
                }
                .padding(Spacing.md)
                .frame(maxWidth: .infinity)
                .background(Color.inputBackground)
                .cornerRadius(CornerRadius.md)
                .padding(.horizontal, Spacing.md)
                
                // 生成按钮
                VStack(spacing: Spacing.xs) {
                    PrimaryButton("开始生成") {
                        startGeneration()
                    }
                    .disabled(selectedImage == nil || isUploading)
                    .opacity(selectedImage == nil ? 0.5 : 1)
                    
                    HStack(spacing: Spacing.xxs) {
                        Image(systemName: "bolt.fill")
                            .foregroundColor(.gradientOrange)
                        Text("消耗 \(template.pointsCost) 积分")
                            .foregroundColor(.textSecondary)
                    }
                    .font(.caption2)
                }
                .padding(.horizontal, Spacing.md)
                .padding(.bottom, Spacing.xl)
            }
        }
        .sheet(isPresented: $isShowingImagePicker) {
            ImagePicker(image: $selectedImage)
        }
    }
    
    private func startGeneration() {
        // 上传图片并开始生成
    }
}

// MARK: - 图片选择器
struct ImagePicker: UIViewControllerRepresentable {
    @Binding var image: UIImage?
    @Environment(\.dismiss) var dismiss
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        picker.sourceType = .photoLibrary
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: ImagePicker
        
        init(_ parent: ImagePicker) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let image = info[.originalImage] as? UIImage {
                parent.image = image
            }
            parent.dismiss()
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.dismiss()
        }
    }
}
```

#### 10.1.3 生成中页面

```swift
struct GeneratingView: View {
    let taskId: String
    @State private var task: GenerationTask?
    @State private var progress: CGFloat = 0
    @State private var statusText = "排队中..."
    @State private var timer: Timer?
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        ZStack {
            Color.appBackground.ignoresSafeArea()
            
            VStack(spacing: Spacing.xxl) {
                Spacer()
                
                // 动画效果
                ZStack {
                    // 外圈旋转
                    Circle()
                        .stroke(
                            AngularGradient(
                                colors: [.gradientPurple, .gradientPink, .gradientPurple],
                                center: .center
                            ),
                            lineWidth: 4
                        )
                        .frame(width: 160, height: 160)
                        .rotationEffect(.degrees(progress * 360))
                        .animation(.linear(duration: 2).repeatForever(autoreverses: false), value: progress)
                    
                    // 内圈进度
                    Circle()
                        .stroke(Color.inputBackground, lineWidth: 8)
                        .frame(width: 140, height: 140)
                    
                    Circle()
                        .trim(from: 0, to: CGFloat(task?.progress ?? 0) / 100)
                        .stroke(Color.primaryGradient, lineWidth: 8)
                        .frame(width: 140, height: 140)
                        .rotationEffect(.degrees(-90))
                    
                    // 中心图标
                    VStack(spacing: Spacing.xs) {
                        Image(systemName: "wand.and.stars")
                            .font(.system(size: 32))
                            .foregroundStyle(Color.primaryGradient)
                        
                        Text("\(task?.progress ?? 0)%")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                    }
                }
                
                // 状态文字
                VStack(spacing: Spacing.sm) {
                    Text(statusText)
                        .font(.title3)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                    
                    if let estimatedTime = task?.estimatedTime {
                        Text("预计还需 \(estimatedTime) 秒")
                            .font(.bodySmall)
                            .foregroundColor(.textSecondary)
                    }
                }
                
                Spacer()
                
                // 提示信息
                VStack(spacing: Spacing.md) {
                    HStack(spacing: Spacing.sm) {
                        FeatureItem(icon: "sparkles", text: "AI智能优化")
                        FeatureItem(icon: "photo.stack", text: "高清输出")
                        FeatureItem(icon: "lock.shield", text: "隐私保护")
                    }
                }
                .padding(.horizontal, Spacing.md)
                
                // 取消按钮
                Button(action: cancelGeneration) {
                    Text("取消生成")
                        .font(.buttonMedium)
                        .foregroundColor(.textSecondary)
                }
                .padding(.bottom, Spacing.xxl)
            }
        }
        .onAppear {
            startPolling()
            withAnimation {
                progress = 1
            }
        }
        .onDisappear {
            timer?.invalidate()
        }
    }
    
    private func startPolling() {
        timer = Timer.scheduledTimer(withTimeInterval: 2, repeats: true) { _ in
            Task {
                await checkStatus()
            }
        }
    }
    
    private func checkStatus() async {
        // 轮询生成状态
        // 当状态为completed时跳转到结果页
    }
    
    private func cancelGeneration() {
        timer?.invalidate()
        // 调用取消接口
        dismiss()
    }
}

struct FeatureItem: View {
    let icon: String
    let text: String
    
    var body: some View {
        VStack(spacing: Spacing.xs) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundStyle(Color.primaryGradient)
            
            Text(text)
                .font(.caption2)
                .foregroundColor(.textSecondary)
        }
        .frame(maxWidth: .infinity)
    }
}
```

#### 10.1.4 生成完成页

```swift
struct GenerationResultView: View {
    let task: GenerationTask
    @State private var showShareSheet = false
    @State private var isSaving = false
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        ZStack {
            Color.appBackground.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // 顶部导航
                HStack {
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark")
                            .font(.system(size: 18))
                            .foregroundColor(.white)
                    }
                    
                    Spacer()
                    
                    Text("生成完成")
                        .font(.title3)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    Button(action: { showShareSheet = true }) {
                        Image(systemName: "square.and.arrow.up")
                            .font(.system(size: 18))
                            .foregroundColor(.white)
                    }
                }
                .padding(Spacing.md)
                
                // 结果图片
                ScrollView(showsIndicators: false) {
                    VStack(spacing: Spacing.lg) {
                        if let resultURL = task.resultURL {
                            AsyncImage(url: URL(string: resultURL)) { image in
                                image
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                            } placeholder: {
                                Rectangle()
                                    .fill(Color.primaryGradient.opacity(0.3))
                                    .aspectRatio(3/4, contentMode: .fit)
                            }
                            .cornerRadius(CornerRadius.lg)
                            .padding(.horizontal, Spacing.md)
                        }
                        
                        // 操作按钮组
                        HStack(spacing: Spacing.md) {
                            ActionButton(
                                icon: "arrow.down.circle",
                                title: "保存",
                                action: saveToAlbum
                            )
                            
                            ActionButton(
                                icon: "arrow.triangle.2.circlepath",
                                title: "重新生成",
                                action: regenerate
                            )
                            
                            ActionButton(
                                icon: "square.on.square",
                                title: "对比",
                                action: showComparison
                            )
                        }
                        .padding(.horizontal, Spacing.md)
                    }
                    .padding(.bottom, 120)
                }
                
                // 底部按钮
                VStack(spacing: Spacing.sm) {
                    PrimaryButton("发布到社区") {
                        publishWork()
                    }
                    
                    Button(action: { dismiss() }) {
                        Text("返回首页")
                            .font(.buttonMedium)
                            .foregroundColor(.textSecondary)
                    }
                }
                .padding(Spacing.md)
                .background(Color.appBackground)
            }
        }
        .sheet(isPresented: $showShareSheet) {
            ShareSheet()
        }
    }
    
    private func saveToAlbum() {
        // 保存到相册
    }
    
    private func regenerate() {
        // 重新生成
    }
    
    private func showComparison() {
        // 显示对比
    }
    
    private func publishWork() {
        // 发布到社区
    }
}

struct ActionButton: View {
    let icon: String
    let title: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: Spacing.xs) {
                Image(systemName: icon)
                    .font(.system(size: 24))
                Text(title)
                    .font(.caption1)
            }
            .foregroundColor(.textPrimary)
            .frame(maxWidth: .infinity)
            .padding(.vertical, Spacing.md)
            .background(Color.inputBackground)
            .cornerRadius(CornerRadius.md)
        }
    }
}
```

### 10.2 设置页（SettingsView）

```swift
struct SettingsView: View {
    @Environment(\.dismiss) var dismiss
    @State private var showLogoutAlert = false
    
    var body: some View {
        ZStack {
            Color.appBackground.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // 顶部导航
                NavigationHeader(
                    title: "设置",
                    onBack: { dismiss() }
                )
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: Spacing.lg) {
                        // 账号设置
                        SettingsSection(title: "账号设置") {
                            SettingsRow(icon: "person.circle", title: "个人资料", showArrow: true) {
                                // 跳转个人资料编辑
                            }
                            
                            SettingsRow(icon: "phone.circle", title: "绑定手机", value: "138****8888", showArrow: true) {
                                // 跳转绑定手机
                            }
                            
                            SettingsRow(icon: "message.circle", title: "绑定微信", value: "已绑定", showArrow: true) {
                                // 跳转绑定微信
                            }
                        }
                        
                        // 通用设置
                        SettingsSection(title: "通用设置") {
                            SettingsToggleRow(icon: "bell.circle", title: "消息通知", isOn: .constant(true))
                            
                            SettingsToggleRow(icon: "wifi", title: "仅WiFi下载", isOn: .constant(false))
                            
                            SettingsRow(icon: "trash.circle", title: "清除缓存", value: "23.5 MB", showArrow: true) {
                                // 清除缓存
                            }
                        }
                        
                        // 关于
                        SettingsSection(title: "关于") {
                            SettingsRow(icon: "doc.text", title: "用户协议", showArrow: true) {
                                // 跳转用户协议
                            }
                            
                            SettingsRow(icon: "hand.raised", title: "隐私政策", showArrow: true) {
                                // 跳转隐私政策
                            }
                            
                            SettingsRow(icon: "info.circle", title: "关于我们", showArrow: true) {
                                // 跳转关于我们
                            }
                            
                            SettingsRow(icon: "star.circle", title: "给个好评", showArrow: true) {
                                // 跳转App Store
                            }
                            
                            SettingsRow(icon: "app.badge", title: "当前版本", value: "1.0.0", showArrow: false) {}
                        }
                        
                        // 退出登录
                        Button(action: { showLogoutAlert = true }) {
                            Text("退出登录")
                                .font(.buttonMedium)
                                .foregroundColor(.error)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, Spacing.md)
                                .background(Color.inputBackground)
                                .cornerRadius(CornerRadius.md)
                        }
                        .padding(.horizontal, Spacing.md)
                        .padding(.top, Spacing.lg)
                    }
                    .padding(.vertical, Spacing.md)
                }
            }
        }
        .alert("确认退出", isPresented: $showLogoutAlert) {
            Button("取消", role: .cancel) {}
            Button("退出", role: .destructive) {
                logout()
            }
        } message: {
            Text("确定要退出当前账号吗？")
        }
    }
    
    private func logout() {
        // 退出登录逻辑
    }
}

struct SettingsSection<Content: View>: View {
    let title: String
    let content: Content
    
    init(title: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            Text(title)
                .font(.caption1)
                .foregroundColor(.textSecondary)
                .padding(.horizontal, Spacing.md)
            
            VStack(spacing: 0) {
                content
            }
            .background(Color.cardBackground)
            .cornerRadius(CornerRadius.md)
            .padding(.horizontal, Spacing.md)
        }
    }
}

struct SettingsRow: View {
    let icon: String
    let title: String
    var value: String? = nil
    let showArrow: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: Spacing.sm) {
                Image(systemName: icon)
                    .font(.system(size: 20))
                    .foregroundColor(.textSecondary)
                    .frame(width: 28)
                
                Text(title)
                    .font(.bodyMedium)
                    .foregroundColor(.textPrimary)
                
                Spacer()
                
                if let value = value {
                    Text(value)
                        .font(.bodySmall)
                        .foregroundColor(.textSecondary)
                }
                
                if showArrow {
                    Image(systemName: "chevron.right")
                        .font(.system(size: 14))
                        .foregroundColor(.textTertiary)
                }
            }
            .padding(Spacing.md)
        }
    }
}

struct SettingsToggleRow: View {
    let icon: String
    let title: String
    @Binding var isOn: Bool
    
    var body: some View {
        HStack(spacing: Spacing.sm) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundColor(.textSecondary)
                .frame(width: 28)
            
            Text(title)
                .font(.bodyMedium)
                .foregroundColor(.textPrimary)
            
            Spacer()
            
            Toggle("", isOn: $isOn)
                .labelsHidden()
                .tint(Color.gradientPurple)
        }
        .padding(Spacing.md)
    }
}
```

### 10.3 积分充值页（RechargeView）

```swift
struct RechargeView: View {
    @State private var selectedPackage: Int = 1
    @State private var packages: [PointsPackage] = []
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        ZStack {
            // 背景渐变
            LinearGradient(
                colors: [Color.surfaceBackground, Color.appBackground],
                startPoint: .top,
                endPoint: .center
            )
            .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // 顶部导航
                HStack {
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark")
                            .font(.system(size: 18))
                            .foregroundColor(.white)
                    }
                    
                    Spacer()
                    
                    Text("积分充值")
                        .font(.title3)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    Button(action: { /* 充值记录 */ }) {
                        Text("记录")
                            .font(.bodySmall)
                            .foregroundColor(.textSecondary)
                    }
                }
                .padding(Spacing.md)
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: Spacing.xl) {
                        // 当前积分
                        CurrentPointsCard()
                        
                        // 积分套餐
                        VStack(alignment: .leading, spacing: Spacing.sm) {
                            Text("选择充值套餐")
                                .font(.title3)
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                                .padding(.horizontal, Spacing.md)
                            
                            VStack(spacing: Spacing.sm) {
                                ForEach(packages.indices, id: \.self) { index in
                                    PointsPackageCard(
                                        package: packages[index],
                                        isSelected: selectedPackage == index
                                    ) {
                                        selectedPackage = index
                                    }
                                }
                            }
                            .padding(.horizontal, Spacing.md)
                        }
                        
                        // 积分说明
                        PointsInfoSection()
                    }
                    .padding(.bottom, 120)
                }
                
                // 底部支付按钮
                VStack(spacing: Spacing.xs) {
                    if !packages.isEmpty {
                        let selected = packages[selectedPackage]
                        HStack {
                            Text("应付金额")
                                .font(.bodySmall)
                                .foregroundColor(.textSecondary)
                            
                            Spacer()
                            
                            HStack(alignment: .firstTextBaseline, spacing: 2) {
                                Text("¥")
                                    .font(.bodySmall)
                                Text("\(selected.price)")
                                    .font(.title2)
                                    .fontWeight(.bold)
                            }
                            .foregroundColor(.white)
                        }
                        .padding(.horizontal, Spacing.md)
                    }
                    
                    PrimaryButton("立即充值") {
                        // 发起支付
                    }
                    .padding(.horizontal, Spacing.md)
                }
                .padding(.vertical, Spacing.md)
                .background(Color.appBackground)
            }
        }
        .onAppear {
            loadPackages()
        }
    }
    
    private func loadPackages() {
        // 加载积分套餐
        packages = [
            PointsPackage(id: "1", points: 100, price: 6, bonusPoints: 0, isPopular: false, validDays: 365),
            PointsPackage(id: "2", points: 300, price: 18, bonusPoints: 30, isPopular: true, validDays: 365),
            PointsPackage(id: "3", points: 500, price: 28, bonusPoints: 80, isPopular: false, validDays: 365),
            PointsPackage(id: "4", points: 1000, price: 50, bonusPoints: 200, isPopular: false, validDays: 365)
        ]
    }
}

struct CurrentPointsCard: View {
    var body: some View {
        VStack(spacing: Spacing.md) {
            HStack {
                VStack(alignment: .leading, spacing: Spacing.xxs) {
                    Text("当前积分")
                        .font(.caption1)
                        .foregroundColor(.textSecondary)
                    
                    HStack(alignment: .firstTextBaseline, spacing: Spacing.xs) {
                        Image(systemName: "bolt.fill")
                            .font(.system(size: 24))
                            .foregroundColor(.gradientOrange)
                        
                        Text("360")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                    }
                }
                
                Spacer()
                
                // 积分图标动画
                ZStack {
                    Circle()
                        .fill(Color.gradientOrange.opacity(0.2))
                        .frame(width: 80, height: 80)
                    
                    Image(systemName: "bolt.fill")
                        .font(.system(size: 36))
                        .foregroundColor(.gradientOrange)
                }
            }
            
            // 积分有效期提示
            HStack(spacing: Spacing.xs) {
                Image(systemName: "info.circle")
                    .font(.system(size: 12))
                Text("积分有效期365天，请及时使用")
                    .font(.caption2)
            }
            .foregroundColor(.textSecondary)
        }
        .padding(Spacing.lg)
        .background(
            LinearGradient(
                colors: [Color.cardBackground, Color.cardBackground.opacity(0.8)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .cornerRadius(CornerRadius.lg)
        .overlay(
            RoundedRectangle(cornerRadius: CornerRadius.lg)
                .stroke(Color.borderDefault, lineWidth: 1)
        )
        .padding(.horizontal, Spacing.md)
    }
}

struct PointsPackageCard: View {
    let package: PointsPackage
    let isSelected: Bool
    let onSelect: () -> Void
    
    var body: some View {
        Button(action: onSelect) {
            HStack {
                // 积分信息
                VStack(alignment: .leading, spacing: Spacing.xxs) {
                    HStack(spacing: Spacing.xs) {
                        HStack(spacing: 2) {
                            Image(systemName: "bolt.fill")
                                .font(.system(size: 14))
                                .foregroundColor(.gradientOrange)
                            Text("\(package.points)")
                                .font(.title3)
                                .fontWeight(.bold)
                        }
                        .foregroundColor(.white)
                        
                        if package.bonusPoints > 0 {
                            Text("+\(package.bonusPoints)")
                                .font(.caption1)
                                .fontWeight(.medium)
                                .foregroundColor(.success)
                        }
                        
                        if package.isPopular {
                            Text("热卖")
                                .font(.caption3)
                                .foregroundColor(.white)
                                .padding(.horizontal, Spacing.xs)
                                .padding(.vertical, 2)
                                .background(Color.warning)
                                .cornerRadius(CornerRadius.xs)
                        }
                    }
                    
                    if package.bonusPoints > 0 {
                        Text("赠送\(package.bonusPoints)积分")
                            .font(.caption2)
                            .foregroundColor(.textSecondary)
                    }
                }
                
                Spacer()
                
                // 价格
                HStack(alignment: .firstTextBaseline, spacing: 2) {
                    Text("¥")
                        .font(.caption1)
                    Text("\(package.price)")
                        .font(.title2)
                        .fontWeight(.bold)
                }
                .foregroundColor(.white)
            }
            .padding(Spacing.md)
            .background(
                isSelected ? Color.primaryGradient.opacity(0.2) : Color.cardBackground
            )
            .cornerRadius(CornerRadius.md)
            .overlay(
                RoundedRectangle(cornerRadius: CornerRadius.md)
                    .stroke(
                        isSelected ? Color.gradientPurple : Color.borderDefault,
                        lineWidth: isSelected ? 2 : 1
                    )
            )
        }
    }
}

struct PointsInfoSection: View {
    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            Text("积分说明")
                .font(.bodyMedium)
                .fontWeight(.medium)
                .foregroundColor(.white)
            
            VStack(alignment: .leading, spacing: Spacing.xs) {
                InfoRow(text: "1积分 = 1次AI生成")
                InfoRow(text: "充值积分有效期365天")
                InfoRow(text: "会员用户享受积分折扣")
                InfoRow(text: "积分不支持退款，请谨慎充值")
            }
        }
        .padding(Spacing.md)
        .background(Color.inputBackground)
        .cornerRadius(CornerRadius.md)
        .padding(.horizontal, Spacing.md)
    }
}

struct InfoRow: View {
    let text: String
    
    var body: some View {
        HStack(alignment: .top, spacing: Spacing.xs) {
            Circle()
                .fill(Color.textSecondary)
                .frame(width: 4, height: 4)
                .offset(y: 6)
            
            Text(text)
                .font(.caption1)
                .foregroundColor(.textSecondary)
        }
    }
}
```

### 10.4 分享弹窗（ShareSheet）

```swift
struct ShareSheet: View {
    @Environment(\.dismiss) var dismiss
    
    let shareOptions = [
        ShareOption(icon: "message.fill", title: "微信好友", color: .green),
        ShareOption(icon: "person.2.fill", title: "朋友圈", color: .green),
        ShareOption(icon: "bubble.left.fill", title: "QQ好友", color: .blue),
        ShareOption(icon: "globe", title: "QQ空间", color: .yellow),
        ShareOption(icon: "link", title: "复制链接", color: .gray),
        ShareOption(icon: "square.and.arrow.down", title: "保存图片", color: .purple)
    ]
    
    var body: some View {
        VStack(spacing: 0) {
            // 拖拽指示器
            RoundedRectangle(cornerRadius: 2)
                .fill(Color.textTertiary)
                .frame(width: 36, height: 4)
                .padding(.top, Spacing.sm)
            
            // 标题
            Text("分享到")
                .font(.title3)
                .fontWeight(.semibold)
                .foregroundColor(.white)
                .padding(.vertical, Spacing.lg)
            
            // 分享选项
            LazyVGrid(
                columns: [
                    GridItem(.flexible()),
                    GridItem(.flexible()),
                    GridItem(.flexible()),
                    GridItem(.flexible())
                ],
                spacing: Spacing.lg
            ) {
                ForEach(shareOptions) { option in
                    ShareOptionButton(option: option) {
                        handleShare(option)
                    }
                }
            }
            .padding(.horizontal, Spacing.lg)
            .padding(.bottom, Spacing.xl)
            
            // 取消按钮
            Button(action: { dismiss() }) {
                Text("取消")
                    .font(.buttonMedium)
                    .foregroundColor(.textPrimary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, Spacing.md)
                    .background(Color.inputBackground)
                    .cornerRadius(CornerRadius.md)
            }
            .padding(.horizontal, Spacing.md)
            .padding(.bottom, Spacing.xl)
        }
        .background(Color.cardBackground)
        .cornerRadius(CornerRadius.xl, corners: [.topLeft, .topRight])
        .presentationDetents([.height(320)])
        .presentationDragIndicator(.hidden)
    }
    
    private func handleShare(_ option: ShareOption) {
        // 处理分享逻辑
        dismiss()
    }
}

struct ShareOption: Identifiable {
    let id = UUID()
    let icon: String
    let title: String
    let color: Color
}

struct ShareOptionButton: View {
    let option: ShareOption
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: Spacing.xs) {
                Image(systemName: option.icon)
                    .font(.system(size: 24))
                    .foregroundColor(.white)
                    .frame(width: 50, height: 50)
                    .background(option.color)
                    .cornerRadius(CornerRadius.md)
                
                Text(option.title)
                    .font(.caption2)
                    .foregroundColor(.textSecondary)
            }
        }
    }
}

// 圆角扩展
extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}

struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners
    
    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}
```

### 10.5 通用导航组件

```swift
// MARK: - 导航头部
struct NavigationHeader: View {
    let title: String
    var rightButton: AnyView? = nil
    let onBack: () -> Void
    
    var body: some View {
        HStack {
            Button(action: onBack) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(.white)
            }
            .frame(width: 44, height: 44)
            
            Spacer()
            
            Text(title)
                .font(.title3)
                .fontWeight(.semibold)
                .foregroundColor(.white)
            
            Spacer()
            
            if let rightButton = rightButton {
                rightButton
                    .frame(width: 44, height: 44)
            } else {
                Color.clear
                    .frame(width: 44, height: 44)
            }
        }
        .padding(.horizontal, Spacing.xs)
    }
}

// MARK: - 空状态视图
struct EmptyStateView: View {
    let icon: String
    let title: String
    let description: String
    var actionTitle: String? = nil
    var action: (() -> Void)? = nil
    
    var body: some View {
        VStack(spacing: Spacing.lg) {
            Image(systemName: icon)
                .font(.system(size: 60))
                .foregroundColor(.textTertiary)
            
            VStack(spacing: Spacing.xs) {
                Text(title)
                    .font(.title3)
                    .fontWeight(.medium)
                    .foregroundColor(.textPrimary)
                
                Text(description)
                    .font(.bodySmall)
                    .foregroundColor(.textSecondary)
                    .multilineTextAlignment(.center)
            }
            
            if let actionTitle = actionTitle, let action = action {
                Button(action: action) {
                    Text(actionTitle)
                        .font(.buttonMedium)
                        .foregroundStyle(Color.primaryGradient)
                }
            }
        }
        .padding(Spacing.xxl)
    }
}

// MARK: - 加载状态视图
struct LoadingView: View {
    let message: String
    
    var body: some View {
        VStack(spacing: Spacing.md) {
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle(tint: .gradientPurple))
                .scaleEffect(1.5)
            
            Text(message)
                .font(.bodySmall)
                .foregroundColor(.textSecondary)
        }
    }
}

// MARK: - Toast提示
struct ToastView: View {
    let message: String
    let type: ToastType
    
    enum ToastType {
        case success, error, info
        
        var icon: String {
            switch self {
            case .success: return "checkmark.circle.fill"
            case .error: return "xmark.circle.fill"
            case .info: return "info.circle.fill"
            }
        }
        
        var color: Color {
            switch self {
            case .success: return .success
            case .error: return .error
            case .info: return .gradientPurple
            }
        }
    }
    
    var body: some View {
        HStack(spacing: Spacing.sm) {
            Image(systemName: type.icon)
                .foregroundColor(type.color)
            
            Text(message)
                .font(.bodySmall)
                .foregroundColor(.white)
        }
        .padding(.horizontal, Spacing.lg)
        .padding(.vertical, Spacing.sm)
        .background(Color.cardBackground)
        .cornerRadius(CornerRadius.full)
        .shadow(color: Color.black.opacity(0.3), radius: 10, y: 4)
    }
}
```

---

## 11. 开发清单（Development Checklist）

### 11.1 核心功能

| 功能模块 | 页面 | 优先级 | 状态 |
|---------|------|--------|------|
| 用户认证 | 登录页、手机登录页 | P0 | ⬜ |
| 首页 | 首页/发现页 | P0 | ⬜ |
| AI生成 | 模板选择、上传照片、生成中、生成完成 | P0 | ⬜ |
| 作品详情 | 详情页、分享弹窗 | P0 | ⬜ |
| 个人中心 | 个人中心页 | P1 | ⬜ |
| 会员系统 | 会员订阅页 | P1 | ⬜ |
| 积分系统 | 积分充值页 | P1 | ⬜ |
| 设置 | 设置页 | P2 | ⬜ |

### 11.2 技术实现

| 技术点 | 说明 | 状态 |
|--------|------|------|
| 设计系统 | 颜色、字体、间距、圆角 | ⬜ |
| 网络层 | APIService、请求/响应模型 | ⬜ |
| 状态管理 | @State、@StateObject、@EnvironmentObject | ⬜ |
| 图片加载 | AsyncImage、缓存 | ⬜ |
| 支付集成 | 微信支付、支付宝、Apple Pay | ⬜ |
| 推送通知 | APNs集成 | ⬜ |
| 数据持久化 | UserDefaults、Keychain | ⬜ |

---

*文档版本：2.0*  
*最后更新：2026年1月18日*  
*作者：Manus AI*


---

## 12. 单元测试规范（Unit Testing Specification）

### 12.1 测试框架配置

本项目使用 **XCTest** 作为主要测试框架，配合 **Swift Testing**（iOS 16+）进行现代化测试。

```swift
// Package.swift 或 Xcode 项目配置
// 测试目标：AICreatorAppTests

import XCTest
@testable import AICreatorApp

// MARK: - 测试基类
class BaseTestCase: XCTestCase {
    
    var mockAPIService: MockAPIService!
    var mockUserDefaults: UserDefaults!
    
    override func setUp() {
        super.setUp()
        mockAPIService = MockAPIService()
        mockUserDefaults = UserDefaults(suiteName: "TestDefaults")
        mockUserDefaults.removePersistentDomain(forName: "TestDefaults")
    }
    
    override func tearDown() {
        mockAPIService = nil
        mockUserDefaults = nil
        super.tearDown()
    }
}
```

### 12.2 Mock服务实现

```swift
// MARK: - Mock API Service
class MockAPIService: APIServiceProtocol {
    
    // 控制返回结果
    var shouldSucceed = true
    var mockError: APIError?
    var mockDelay: TimeInterval = 0
    
    // 记录调用
    var loginCallCount = 0
    var getWorksCallCount = 0
    var createGenerationCallCount = 0
    
    // Mock数据
    var mockUser: User?
    var mockWorks: [WorkListItem] = []
    var mockTemplates: [TemplateListItem] = []
    var mockGenerationTask: GenerationTask?
    
    // MARK: - 认证接口
    func login(request: LoginRequest) async throws -> LoginResponse {
        loginCallCount += 1
        
        if let delay = mockDelay > 0 ? mockDelay : nil {
            try await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
        }
        
        if !shouldSucceed {
            throw mockError ?? APIError(code: -1, message: "Mock Error", details: nil)
        }
        
        let user = mockUser ?? User.mock()
        return LoginResponse(
            user: user,
            credentials: AuthCredentials(
                accessToken: "mock_access_token",
                refreshToken: "mock_refresh_token",
                expiresIn: 3600
            )
        )
    }
    
    // MARK: - 作品接口
    func getWorks(page: Int, pageSize: Int, category: String?) async throws -> PageResponse<WorkListItem> {
        getWorksCallCount += 1
        
        if !shouldSucceed {
            throw mockError ?? APIError(code: -1, message: "Mock Error", details: nil)
        }
        
        return PageResponse(
            items: mockWorks,
            total: mockWorks.count,
            page: page,
            pageSize: pageSize,
            hasMore: false
        )
    }
    
    // MARK: - 生成接口
    func createGeneration(request: CreateGenerationRequest) async throws -> CreateGenerationResponse {
        createGenerationCallCount += 1
        
        if !shouldSucceed {
            throw mockError ?? APIError(code: -1, message: "Mock Error", details: nil)
        }
        
        return CreateGenerationResponse(
            taskId: "mock_task_id",
            estimatedTime: 30,
            queuePosition: 1,
            pointsCost: 10
        )
    }
    
    func getGenerationStatus(taskId: String) async throws -> GenerationStatusResponse {
        if !shouldSucceed {
            throw mockError ?? APIError(code: -1, message: "Mock Error", details: nil)
        }
        
        let task = mockGenerationTask ?? GenerationTask(
            id: taskId,
            status: .completed,
            progress: 100,
            resultURL: "https://example.com/result.jpg",
            thumbnailURL: "https://example.com/thumb.jpg",
            originalURL: "https://example.com/original.jpg",
            templateId: "template_1",
            style: .portrait,
            pointsCost: 10,
            estimatedTime: nil,
            createdAt: Date(),
            completedAt: Date()
        )
        
        return GenerationStatusResponse(task: task)
    }
}

// MARK: - Mock数据工厂
extension User {
    static func mock(
        id: String = "user_1",
        nickname: String = "测试用户",
        points: Int = 100
    ) -> User {
        User(
            id: id,
            nickname: nickname,
            avatar: "https://example.com/avatar.jpg",
            phone: "138****8888",
            membership: nil,
            points: points,
            createdAt: Date()
        )
    }
}

extension WorkListItem {
    static func mock(
        id: String = "work_1",
        title: String = "测试作品"
    ) -> WorkListItem {
        WorkListItem(
            id: id,
            title: title,
            coverURL: "https://example.com/cover.jpg",
            thumbnailURL: "https://example.com/thumb.jpg",
            authorId: "user_1",
            authorName: "测试用户",
            authorAvatar: "https://example.com/avatar.jpg",
            likeCount: 10,
            viewCount: 100,
            isLiked: false,
            createdAt: Date()
        )
    }
}

extension TemplateListItem {
    static func mock(
        id: String = "template_1",
        name: String = "测试模板"
    ) -> TemplateListItem {
        TemplateListItem(
            id: id,
            name: name,
            coverURL: "https://example.com/template.jpg",
            category: .portrait,
            pointsCost: 10,
            usageCount: 1000,
            isHot: true,
            isNew: false
        )
    }
}
```

### 12.3 API层测试用例

```swift
// MARK: - API Service Tests
class APIServiceTests: BaseTestCase {
    
    // MARK: - 登录测试
    func testLoginWithPhone_Success() async throws {
        // Given
        mockAPIService.shouldSucceed = true
        mockAPIService.mockUser = User.mock(nickname: "手机用户")
        
        let request = LoginRequest(type: "phone", code: nil, phone: "13800138000", verifyCode: "123456")
        
        // When
        let response = try await mockAPIService.login(request: request)
        
        // Then
        XCTAssertEqual(response.user.nickname, "手机用户")
        XCTAssertNotNil(response.credentials.accessToken)
        XCTAssertEqual(mockAPIService.loginCallCount, 1)
    }
    
    func testLoginWithPhone_InvalidCode() async {
        // Given
        mockAPIService.shouldSucceed = false
        mockAPIService.mockError = APIError(code: 1001, message: "验证码错误", details: nil)
        
        let request = LoginRequest(type: "phone", code: nil, phone: "13800138000", verifyCode: "000000")
        
        // When & Then
        do {
            _ = try await mockAPIService.login(request: request)
            XCTFail("Should throw error")
        } catch let error as APIError {
            XCTAssertEqual(error.code, 1001)
            XCTAssertEqual(error.message, "验证码错误")
        } catch {
            XCTFail("Unexpected error type")
        }
    }
    
    // MARK: - 作品列表测试
    func testGetWorks_Success() async throws {
        // Given
        mockAPIService.shouldSucceed = true
        mockAPIService.mockWorks = [
            WorkListItem.mock(id: "1", title: "作品1"),
            WorkListItem.mock(id: "2", title: "作品2"),
            WorkListItem.mock(id: "3", title: "作品3")
        ]
        
        // When
        let response = try await mockAPIService.getWorks(page: 1, pageSize: 20, category: nil)
        
        // Then
        XCTAssertEqual(response.items.count, 3)
        XCTAssertEqual(response.items[0].title, "作品1")
        XCTAssertEqual(mockAPIService.getWorksCallCount, 1)
    }
    
    func testGetWorks_EmptyResult() async throws {
        // Given
        mockAPIService.shouldSucceed = true
        mockAPIService.mockWorks = []
        
        // When
        let response = try await mockAPIService.getWorks(page: 1, pageSize: 20, category: nil)
        
        // Then
        XCTAssertTrue(response.items.isEmpty)
        XCTAssertFalse(response.hasMore)
    }
    
    // MARK: - AI生成测试
    func testCreateGeneration_Success() async throws {
        // Given
        mockAPIService.shouldSucceed = true
        
        let request = CreateGenerationRequest(
            templateId: "template_1",
            imageURL: "https://example.com/image.jpg",
            prompt: nil,
            negativePrompt: nil,
            style: "portrait",
            referenceWorkId: nil
        )
        
        // When
        let response = try await mockAPIService.createGeneration(request: request)
        
        // Then
        XCTAssertNotNil(response.taskId)
        XCTAssertGreaterThan(response.estimatedTime, 0)
        XCTAssertEqual(mockAPIService.createGenerationCallCount, 1)
    }
    
    func testCreateGeneration_InsufficientPoints() async {
        // Given
        mockAPIService.shouldSucceed = false
        mockAPIService.mockError = APIError(code: 2001, message: "积分不足", details: nil)
        
        let request = CreateGenerationRequest(
            templateId: "template_1",
            imageURL: "https://example.com/image.jpg",
            prompt: nil,
            negativePrompt: nil,
            style: "portrait",
            referenceWorkId: nil
        )
        
        // When & Then
        do {
            _ = try await mockAPIService.createGeneration(request: request)
            XCTFail("Should throw error")
        } catch let error as APIError {
            XCTAssertEqual(error.code, 2001)
        } catch {
            XCTFail("Unexpected error type")
        }
    }
    
    func testGetGenerationStatus_Completed() async throws {
        // Given
        mockAPIService.shouldSucceed = true
        mockAPIService.mockGenerationTask = GenerationTask(
            id: "task_1",
            status: .completed,
            progress: 100,
            resultURL: "https://example.com/result.jpg",
            thumbnailURL: "https://example.com/thumb.jpg",
            originalURL: "https://example.com/original.jpg",
            templateId: "template_1",
            style: .portrait,
            pointsCost: 10,
            estimatedTime: nil,
            createdAt: Date(),
            completedAt: Date()
        )
        
        // When
        let response = try await mockAPIService.getGenerationStatus(taskId: "task_1")
        
        // Then
        XCTAssertEqual(response.task.status, .completed)
        XCTAssertEqual(response.task.progress, 100)
        XCTAssertNotNil(response.task.resultURL)
    }
}
```

### 12.4 ViewModel测试用例

```swift
// MARK: - Home ViewModel Tests
class HomeViewModelTests: BaseTestCase {
    
    var viewModel: HomeViewModel!
    
    override func setUp() {
        super.setUp()
        viewModel = HomeViewModel(apiService: mockAPIService)
    }
    
    override func tearDown() {
        viewModel = nil
        super.tearDown()
    }
    
    func testLoadWorks_Success() async {
        // Given
        mockAPIService.shouldSucceed = true
        mockAPIService.mockWorks = [
            WorkListItem.mock(id: "1"),
            WorkListItem.mock(id: "2")
        ]
        
        // When
        await viewModel.loadWorks()
        
        // Then
        XCTAssertEqual(viewModel.works.count, 2)
        XCTAssertFalse(viewModel.isLoading)
        XCTAssertNil(viewModel.errorMessage)
    }
    
    func testLoadWorks_Failure() async {
        // Given
        mockAPIService.shouldSucceed = false
        mockAPIService.mockError = APIError(code: -1, message: "网络错误", details: nil)
        
        // When
        await viewModel.loadWorks()
        
        // Then
        XCTAssertTrue(viewModel.works.isEmpty)
        XCTAssertFalse(viewModel.isLoading)
        XCTAssertNotNil(viewModel.errorMessage)
    }
    
    func testLoadMoreWorks_AppendsToExisting() async {
        // Given
        mockAPIService.shouldSucceed = true
        mockAPIService.mockWorks = [WorkListItem.mock(id: "1")]
        await viewModel.loadWorks()
        
        mockAPIService.mockWorks = [WorkListItem.mock(id: "2")]
        
        // When
        await viewModel.loadMoreWorks()
        
        // Then
        XCTAssertEqual(viewModel.works.count, 2)
    }
    
    func testRefreshWorks_ClearsAndReloads() async {
        // Given
        mockAPIService.shouldSucceed = true
        mockAPIService.mockWorks = [WorkListItem.mock(id: "1")]
        await viewModel.loadWorks()
        
        mockAPIService.mockWorks = [WorkListItem.mock(id: "2"), WorkListItem.mock(id: "3")]
        
        // When
        await viewModel.refreshWorks()
        
        // Then
        XCTAssertEqual(viewModel.works.count, 2)
        XCTAssertEqual(viewModel.works[0].id, "2")
    }
    
    func testSelectCategory_FiltersWorks() async {
        // Given
        mockAPIService.shouldSucceed = true
        
        // When
        viewModel.selectCategory(.portrait)
        await viewModel.loadWorks()
        
        // Then
        XCTAssertEqual(viewModel.selectedCategory, .portrait)
        XCTAssertEqual(mockAPIService.getWorksCallCount, 1)
    }
}

// MARK: - Generation ViewModel Tests
class GenerationViewModelTests: BaseTestCase {
    
    var viewModel: GenerationViewModel!
    
    override func setUp() {
        super.setUp()
        viewModel = GenerationViewModel(apiService: mockAPIService)
    }
    
    func testStartGeneration_Success() async {
        // Given
        mockAPIService.shouldSucceed = true
        viewModel.selectedTemplate = TemplateListItem.mock()
        viewModel.uploadedImageURL = "https://example.com/image.jpg"
        
        // When
        await viewModel.startGeneration()
        
        // Then
        XCTAssertNotNil(viewModel.currentTaskId)
        XCTAssertEqual(viewModel.generationState, .generating)
    }
    
    func testStartGeneration_NoTemplate() async {
        // Given
        viewModel.selectedTemplate = nil
        viewModel.uploadedImageURL = "https://example.com/image.jpg"
        
        // When
        await viewModel.startGeneration()
        
        // Then
        XCTAssertNil(viewModel.currentTaskId)
        XCTAssertEqual(viewModel.errorMessage, "请先选择模板")
    }
    
    func testStartGeneration_NoImage() async {
        // Given
        viewModel.selectedTemplate = TemplateListItem.mock()
        viewModel.uploadedImageURL = nil
        
        // When
        await viewModel.startGeneration()
        
        // Then
        XCTAssertNil(viewModel.currentTaskId)
        XCTAssertEqual(viewModel.errorMessage, "请先上传图片")
    }
    
    func testPollStatus_CompletesSuccessfully() async {
        // Given
        mockAPIService.shouldSucceed = true
        mockAPIService.mockGenerationTask = GenerationTask(
            id: "task_1",
            status: .completed,
            progress: 100,
            resultURL: "https://example.com/result.jpg",
            thumbnailURL: nil,
            originalURL: nil,
            templateId: "template_1",
            style: .portrait,
            pointsCost: 10,
            estimatedTime: nil,
            createdAt: Date(),
            completedAt: Date()
        )
        viewModel.currentTaskId = "task_1"
        
        // When
        await viewModel.checkGenerationStatus()
        
        // Then
        XCTAssertEqual(viewModel.generationState, .completed)
        XCTAssertNotNil(viewModel.resultTask)
    }
    
    func testCancelGeneration_StopsPolling() async {
        // Given
        viewModel.currentTaskId = "task_1"
        viewModel.generationState = .generating
        
        // When
        await viewModel.cancelGeneration()
        
        // Then
        XCTAssertEqual(viewModel.generationState, .idle)
        XCTAssertNil(viewModel.currentTaskId)
    }
}

// MARK: - Profile ViewModel Tests
class ProfileViewModelTests: BaseTestCase {
    
    var viewModel: ProfileViewModel!
    
    override func setUp() {
        super.setUp()
        viewModel = ProfileViewModel(apiService: mockAPIService)
    }
    
    func testLoadUserInfo_Success() async {
        // Given
        mockAPIService.shouldSucceed = true
        mockAPIService.mockUser = User.mock(nickname: "测试用户", points: 500)
        
        // When
        await viewModel.loadUserInfo()
        
        // Then
        XCTAssertEqual(viewModel.user?.nickname, "测试用户")
        XCTAssertEqual(viewModel.user?.points, 500)
    }
    
    func testLoadUserWorks_Success() async {
        // Given
        mockAPIService.shouldSucceed = true
        mockAPIService.mockWorks = [
            WorkListItem.mock(id: "1"),
            WorkListItem.mock(id: "2")
        ]
        
        // When
        await viewModel.loadUserWorks()
        
        // Then
        XCTAssertEqual(viewModel.userWorks.count, 2)
    }
    
    func testLogout_ClearsUserData() async {
        // Given
        mockAPIService.mockUser = User.mock()
        await viewModel.loadUserInfo()
        
        // When
        await viewModel.logout()
        
        // Then
        XCTAssertNil(viewModel.user)
        XCTAssertTrue(viewModel.userWorks.isEmpty)
    }
}
```

### 12.5 UI测试用例

```swift
// MARK: - UI Tests
import XCTest

class AICreatorAppUITests: XCTestCase {
    
    var app: XCUIApplication!
    
    override func setUp() {
        super.setUp()
        continueAfterFailure = false
        app = XCUIApplication()
        app.launchArguments = ["--uitesting"]
        app.launch()
    }
    
    // MARK: - 登录流程测试
    func testLoginFlow_PhoneLogin() {
        // 点击手机登录
        app.buttons["手机号登录"].tap()
        
        // 输入手机号
        let phoneField = app.textFields["phoneInput"]
        phoneField.tap()
        phoneField.typeText("13800138000")
        
        // 获取验证码
        app.buttons["获取验证码"].tap()
        
        // 等待验证码输入框出现
        let codeField = app.textFields["codeInput"]
        XCTAssertTrue(codeField.waitForExistence(timeout: 2))
        
        // 输入验证码
        codeField.tap()
        codeField.typeText("123456")
        
        // 点击登录
        app.buttons["登录"].tap()
        
        // 验证跳转到首页
        XCTAssertTrue(app.tabBars.buttons["首页"].waitForExistence(timeout: 5))
    }
    
    // MARK: - 首页测试
    func testHomePage_CategorySwitch() {
        // 等待首页加载
        XCTAssertTrue(app.tabBars.buttons["首页"].waitForExistence(timeout: 5))
        
        // 切换分类
        app.buttons["人像"].tap()
        
        // 验证分类选中状态
        let portraitButton = app.buttons["人像"]
        XCTAssertTrue(portraitButton.isSelected)
    }
    
    func testHomePage_WorkCardTap() {
        // 等待作品加载
        let workCard = app.cells.firstMatch
        XCTAssertTrue(workCard.waitForExistence(timeout: 5))
        
        // 点击作品
        workCard.tap()
        
        // 验证跳转到详情页
        XCTAssertTrue(app.navigationBars["作品详情"].waitForExistence(timeout: 2))
    }
    
    // MARK: - 创作流程测试
    func testCreationFlow_SelectTemplate() {
        // 点击创作Tab
        app.tabBars.buttons["创作"].tap()
        
        // 选择模板
        let templateCard = app.cells["template_1"]
        XCTAssertTrue(templateCard.waitForExistence(timeout: 5))
        templateCard.tap()
        
        // 验证跳转到上传页
        XCTAssertTrue(app.staticTexts["上传照片"].waitForExistence(timeout: 2))
    }
    
    func testCreationFlow_UploadAndGenerate() {
        // 导航到上传页
        app.tabBars.buttons["创作"].tap()
        app.cells.firstMatch.tap()
        
        // 点击上传区域
        app.buttons["uploadArea"].tap()
        
        // 选择图片（模拟）
        // 在UI测试中，需要使用预置的测试图片
        
        // 点击生成
        app.buttons["开始生成"].tap()
        
        // 验证进入生成中状态
        XCTAssertTrue(app.staticTexts["生成中"].waitForExistence(timeout: 2))
    }
    
    // MARK: - 个人中心测试
    func testProfilePage_Navigation() {
        // 点击我的Tab
        app.tabBars.buttons["我的"].tap()
        
        // 验证页面元素
        XCTAssertTrue(app.staticTexts["我的作品"].exists)
        XCTAssertTrue(app.staticTexts["我的点赞"].exists)
    }
    
    func testProfilePage_MembershipEntry() {
        // 点击我的Tab
        app.tabBars.buttons["我的"].tap()
        
        // 点击会员卡片
        app.buttons["membershipCard"].tap()
        
        // 验证跳转到会员页
        XCTAssertTrue(app.staticTexts["开通会员"].waitForExistence(timeout: 2))
    }
}
```

### 12.6 测试覆盖率要求

| 模块 | 最低覆盖率 | 说明 |
|------|-----------|------|
| API层 | 90% | 所有接口必须有成功和失败用例 |
| ViewModel | 85% | 核心业务逻辑必须覆盖 |
| 工具类 | 80% | 公共方法必须测试 |
| UI组件 | 70% | 关键交互路径必须覆盖 |



---

## 13. 错误处理规范（Error Handling Specification）

### 13.1 错误码定义

#### 13.1.1 错误码分类

| 错误码范围 | 分类 | 说明 |
|-----------|------|------|
| 0 | 成功 | 请求成功 |
| 1000-1999 | 认证错误 | 登录、Token相关 |
| 2000-2999 | 业务错误 | 积分、会员、生成相关 |
| 3000-3999 | 资源错误 | 作品、模板、用户相关 |
| 4000-4999 | 参数错误 | 请求参数校验失败 |
| 5000-5999 | 系统错误 | 服务器内部错误 |
| -1 ~ -999 | 客户端错误 | 网络、本地存储等 |

#### 13.1.2 详细错误码表

```swift
// MARK: - 错误码枚举
enum ErrorCode: Int, CaseIterable {
    
    // MARK: - 成功
    case success = 0
    
    // MARK: - 认证错误 (1000-1999)
    case tokenExpired = 1001
    case tokenInvalid = 1002
    case refreshTokenExpired = 1003
    case loginFailed = 1004
    case verifyCodeInvalid = 1005
    case verifyCodeExpired = 1006
    case verifyCodeTooFrequent = 1007
    case accountDisabled = 1008
    case accountNotFound = 1009
    case wechatAuthFailed = 1010
    case appleAuthFailed = 1011
    case phoneAlreadyBound = 1012
    case wechatAlreadyBound = 1013
    
    // MARK: - 业务错误 (2000-2999)
    case insufficientPoints = 2001
    case pointsDeductFailed = 2002
    case membershipExpired = 2003
    case membershipNotFound = 2004
    case orderCreateFailed = 2005
    case orderPayFailed = 2006
    case orderNotFound = 2007
    case orderAlreadyPaid = 2008
    case generationFailed = 2009
    case generationTimeout = 2010
    case generationCancelled = 2011
    case generationQueueFull = 2012
    case dailyLimitExceeded = 2013
    case contentViolation = 2014
    case imageTooLarge = 2015
    case imageFormatInvalid = 2016
    case faceNotDetected = 2017
    case multipleFacesDetected = 2018
    
    // MARK: - 资源错误 (3000-3999)
    case workNotFound = 3001
    case workDeleted = 3002
    case workAccessDenied = 3003
    case templateNotFound = 3004
    case templateDisabled = 3005
    case userNotFound = 3006
    case userBlocked = 3007
    case resourceNotFound = 3008
    
    // MARK: - 参数错误 (4000-4999)
    case parameterMissing = 4001
    case parameterInvalid = 4002
    case phoneInvalid = 4003
    case emailInvalid = 4004
    case nicknameInvalid = 4005
    case nicknameTooLong = 4006
    case contentTooLong = 4007
    case fileTooLarge = 4008
    
    // MARK: - 系统错误 (5000-5999)
    case serverError = 5001
    case serverMaintenance = 5002
    case serverBusy = 5003
    case databaseError = 5004
    case storageError = 5005
    case thirdPartyError = 5006
    
    // MARK: - 客户端错误 (负数)
    case networkError = -1
    case networkTimeout = -2
    case networkNoConnection = -3
    case parseError = -4
    case localStorageError = -5
    case unknownError = -999
    
    // MARK: - 用户提示文案
    var userMessage: String {
        switch self {
        // 成功
        case .success:
            return "操作成功"
            
        // 认证错误
        case .tokenExpired, .tokenInvalid, .refreshTokenExpired:
            return "登录已过期，请重新登录"
        case .loginFailed:
            return "登录失败，请稍后重试"
        case .verifyCodeInvalid:
            return "验证码错误，请重新输入"
        case .verifyCodeExpired:
            return "验证码已过期，请重新获取"
        case .verifyCodeTooFrequent:
            return "验证码发送太频繁，请稍后再试"
        case .accountDisabled:
            return "账号已被禁用，请联系客服"
        case .accountNotFound:
            return "账号不存在"
        case .wechatAuthFailed:
            return "微信授权失败，请重试"
        case .appleAuthFailed:
            return "Apple登录失败，请重试"
        case .phoneAlreadyBound:
            return "该手机号已绑定其他账号"
        case .wechatAlreadyBound:
            return "该微信已绑定其他账号"
            
        // 业务错误
        case .insufficientPoints:
            return "积分不足，请先充值"
        case .pointsDeductFailed:
            return "积分扣除失败，请重试"
        case .membershipExpired:
            return "会员已过期，请续费"
        case .membershipNotFound:
            return "会员信息不存在"
        case .orderCreateFailed:
            return "订单创建失败，请重试"
        case .orderPayFailed:
            return "支付失败，请重试"
        case .orderNotFound:
            return "订单不存在"
        case .orderAlreadyPaid:
            return "订单已支付"
        case .generationFailed:
            return "生成失败，积分已退还"
        case .generationTimeout:
            return "生成超时，积分已退还"
        case .generationCancelled:
            return "生成已取消"
        case .generationQueueFull:
            return "当前排队人数较多，请稍后再试"
        case .dailyLimitExceeded:
            return "今日生成次数已达上限"
        case .contentViolation:
            return "内容违规，请更换图片"
        case .imageTooLarge:
            return "图片太大，请压缩后重试"
        case .imageFormatInvalid:
            return "图片格式不支持"
        case .faceNotDetected:
            return "未检测到人脸，请更换照片"
        case .multipleFacesDetected:
            return "检测到多张人脸，请上传单人照片"
            
        // 资源错误
        case .workNotFound, .workDeleted:
            return "作品不存在或已删除"
        case .workAccessDenied:
            return "无权访问该作品"
        case .templateNotFound, .templateDisabled:
            return "模板不可用"
        case .userNotFound:
            return "用户不存在"
        case .userBlocked:
            return "用户已被拉黑"
        case .resourceNotFound:
            return "资源不存在"
            
        // 参数错误
        case .parameterMissing:
            return "请填写完整信息"
        case .parameterInvalid:
            return "参数格式错误"
        case .phoneInvalid:
            return "请输入正确的手机号"
        case .emailInvalid:
            return "请输入正确的邮箱"
        case .nicknameInvalid:
            return "昵称包含违规内容"
        case .nicknameTooLong:
            return "昵称不能超过20个字符"
        case .contentTooLong:
            return "内容长度超出限制"
        case .fileTooLarge:
            return "文件大小超出限制"
            
        // 系统错误
        case .serverError:
            return "服务器开小差了，请稍后重试"
        case .serverMaintenance:
            return "系统维护中，请稍后再来"
        case .serverBusy:
            return "服务器繁忙，请稍后重试"
        case .databaseError, .storageError:
            return "数据处理失败，请重试"
        case .thirdPartyError:
            return "第三方服务异常，请稍后重试"
            
        // 客户端错误
        case .networkError:
            return "网络异常，请检查网络连接"
        case .networkTimeout:
            return "网络超时，请重试"
        case .networkNoConnection:
            return "无网络连接，请检查网络设置"
        case .parseError:
            return "数据解析失败"
        case .localStorageError:
            return "本地存储失败"
        case .unknownError:
            return "未知错误，请稍后重试"
        }
    }
    
    // MARK: - 是否需要重新登录
    var requiresRelogin: Bool {
        switch self {
        case .tokenExpired, .tokenInvalid, .refreshTokenExpired, .accountDisabled:
            return true
        default:
            return false
        }
    }
    
    // MARK: - 是否可重试
    var isRetryable: Bool {
        switch self {
        case .networkError, .networkTimeout, .serverBusy, .serverError,
             .generationQueueFull, .thirdPartyError:
            return true
        default:
            return false
        }
    }
    
    // MARK: - 是否需要跳转
    var redirectAction: RedirectAction? {
        switch self {
        case .tokenExpired, .tokenInvalid, .refreshTokenExpired:
            return .login
        case .insufficientPoints:
            return .recharge
        case .membershipExpired:
            return .membership
        default:
            return nil
        }
    }
}

enum RedirectAction {
    case login
    case recharge
    case membership
}
```

### 13.2 错误处理实现

```swift
// MARK: - API错误模型
struct APIError: Error, Codable {
    let code: Int
    let message: String
    let details: String?
    
    var errorCode: ErrorCode {
        ErrorCode(rawValue: code) ?? .unknownError
    }
    
    var userMessage: String {
        errorCode.userMessage
    }
    
    var requiresRelogin: Bool {
        errorCode.requiresRelogin
    }
    
    var isRetryable: Bool {
        errorCode.isRetryable
    }
}

// MARK: - 错误处理器
class ErrorHandler {
    static let shared = ErrorHandler()
    
    private init() {}
    
    // MARK: - 处理API错误
    func handleAPIError(_ error: APIError, context: ErrorContext = .general) {
        // 1. 记录错误日志
        logError(error, context: context)
        
        // 2. 检查是否需要重新登录
        if error.requiresRelogin {
            handleReloginRequired()
            return
        }
        
        // 3. 检查是否需要跳转
        if let action = error.errorCode.redirectAction {
            handleRedirect(action)
            return
        }
        
        // 4. 显示错误提示
        showErrorToast(error.userMessage)
    }
    
    // MARK: - 处理网络错误
    func handleNetworkError(_ error: Error) -> APIError {
        let nsError = error as NSError
        
        switch nsError.code {
        case NSURLErrorNotConnectedToInternet:
            return APIError(code: ErrorCode.networkNoConnection.rawValue, message: "No network", details: nil)
        case NSURLErrorTimedOut:
            return APIError(code: ErrorCode.networkTimeout.rawValue, message: "Timeout", details: nil)
        default:
            return APIError(code: ErrorCode.networkError.rawValue, message: error.localizedDescription, details: nil)
        }
    }
    
    // MARK: - 显示错误Toast
    func showErrorToast(_ message: String) {
        DispatchQueue.main.async {
            NotificationCenter.default.post(
                name: .showToast,
                object: nil,
                userInfo: ["message": message, "type": ToastType.error]
            )
        }
    }
    
    // MARK: - 显示成功Toast
    func showSuccessToast(_ message: String) {
        DispatchQueue.main.async {
            NotificationCenter.default.post(
                name: .showToast,
                object: nil,
                userInfo: ["message": message, "type": ToastType.success]
            )
        }
    }
    
    // MARK: - 处理重新登录
    private func handleReloginRequired() {
        // 清除本地Token
        TokenManager.shared.clearTokens()
        
        // 发送登出通知
        DispatchQueue.main.async {
            NotificationCenter.default.post(name: .userDidLogout, object: nil)
        }
        
        // 显示提示
        showErrorToast("登录已过期，请重新登录")
    }
    
    // MARK: - 处理跳转
    private func handleRedirect(_ action: RedirectAction) {
        DispatchQueue.main.async {
            switch action {
            case .login:
                NotificationCenter.default.post(name: .navigateToLogin, object: nil)
            case .recharge:
                NotificationCenter.default.post(name: .navigateToRecharge, object: nil)
            case .membership:
                NotificationCenter.default.post(name: .navigateToMembership, object: nil)
            }
        }
    }
    
    // MARK: - 记录错误日志
    private func logError(_ error: APIError, context: ErrorContext) {
        let logEntry = ErrorLogEntry(
            code: error.code,
            message: error.message,
            details: error.details,
            context: context.rawValue,
            timestamp: Date(),
            userId: UserManager.shared.currentUser?.id,
            deviceInfo: DeviceInfo.current
        )
        
        // 本地记录
        ErrorLogger.shared.log(logEntry)
        
        // 上报到服务器（非敏感错误）
        if shouldReportToServer(error) {
            ErrorReporter.shared.report(logEntry)
        }
    }
    
    private func shouldReportToServer(_ error: APIError) -> Bool {
        // 客户端错误和常见业务错误不上报
        switch error.errorCode {
        case .networkError, .networkTimeout, .networkNoConnection,
             .insufficientPoints, .verifyCodeInvalid, .verifyCodeExpired:
            return false
        default:
            return true
        }
    }
}

// MARK: - 错误上下文
enum ErrorContext: String {
    case general = "general"
    case login = "login"
    case generation = "generation"
    case payment = "payment"
    case upload = "upload"
    case profile = "profile"
}

// MARK: - 错误日志条目
struct ErrorLogEntry: Codable {
    let code: Int
    let message: String
    let details: String?
    let context: String
    let timestamp: Date
    let userId: String?
    let deviceInfo: DeviceInfo
}

// MARK: - 设备信息
struct DeviceInfo: Codable {
    let model: String
    let systemVersion: String
    let appVersion: String
    let buildNumber: String
    
    static var current: DeviceInfo {
        DeviceInfo(
            model: UIDevice.current.model,
            systemVersion: UIDevice.current.systemVersion,
            appVersion: Bundle.main.appVersion,
            buildNumber: Bundle.main.buildNumber
        )
    }
}

extension Bundle {
    var buildNumber: String {
        infoDictionary?["CFBundleVersion"] as? String ?? "1"
    }
}

// MARK: - 通知名称
extension Notification.Name {
    static let showToast = Notification.Name("showToast")
    static let userDidLogout = Notification.Name("userDidLogout")
    static let navigateToLogin = Notification.Name("navigateToLogin")
    static let navigateToRecharge = Notification.Name("navigateToRecharge")
    static let navigateToMembership = Notification.Name("navigateToMembership")
}
```

### 13.3 错误UI组件

```swift
// MARK: - 错误提示弹窗
struct ErrorAlertView: View {
    let error: APIError
    let onRetry: (() -> Void)?
    let onDismiss: () -> Void
    
    var body: some View {
        VStack(spacing: Spacing.lg) {
            // 错误图标
            Image(systemName: iconName)
                .font(.system(size: 48))
                .foregroundColor(iconColor)
            
            // 错误信息
            VStack(spacing: Spacing.xs) {
                Text("操作失败")
                    .font(.title3)
                    .fontWeight(.semibold)
                    .foregroundColor(.textPrimary)
                
                Text(error.userMessage)
                    .font(.bodySmall)
                    .foregroundColor(.textSecondary)
                    .multilineTextAlignment(.center)
            }
            
            // 操作按钮
            HStack(spacing: Spacing.md) {
                if error.isRetryable, let onRetry = onRetry {
                    SecondaryButton("重试") {
                        onRetry()
                    }
                }
                
                PrimaryButton(buttonTitle) {
                    handleButtonTap()
                }
            }
        }
        .padding(Spacing.xl)
        .background(Color.cardBackground)
        .cornerRadius(CornerRadius.lg)
        .padding(.horizontal, Spacing.xl)
    }
    
    private var iconName: String {
        switch error.errorCode {
        case .networkError, .networkTimeout, .networkNoConnection:
            return "wifi.slash"
        case .insufficientPoints:
            return "bolt.slash"
        case .contentViolation:
            return "exclamationmark.triangle"
        default:
            return "xmark.circle"
        }
    }
    
    private var iconColor: Color {
        switch error.errorCode {
        case .contentViolation:
            return .warning
        default:
            return .error
        }
    }
    
    private var buttonTitle: String {
        if let action = error.errorCode.redirectAction {
            switch action {
            case .login:
                return "去登录"
            case .recharge:
                return "去充值"
            case .membership:
                return "开通会员"
            }
        }
        return "我知道了"
    }
    
    private func handleButtonTap() {
        if let action = error.errorCode.redirectAction {
            switch action {
            case .login:
                NotificationCenter.default.post(name: .navigateToLogin, object: nil)
            case .recharge:
                NotificationCenter.default.post(name: .navigateToRecharge, object: nil)
            case .membership:
                NotificationCenter.default.post(name: .navigateToMembership, object: nil)
            }
        }
        onDismiss()
    }
}

// MARK: - 网络错误视图
struct NetworkErrorView: View {
    let onRetry: () -> Void
    
    var body: some View {
        VStack(spacing: Spacing.lg) {
            Image(systemName: "wifi.slash")
                .font(.system(size: 60))
                .foregroundColor(.textTertiary)
            
            VStack(spacing: Spacing.xs) {
                Text("网络连接失败")
                    .font(.title3)
                    .fontWeight(.medium)
                    .foregroundColor(.textPrimary)
                
                Text("请检查网络设置后重试")
                    .font(.bodySmall)
                    .foregroundColor(.textSecondary)
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

// MARK: - 服务器错误视图
struct ServerErrorView: View {
    let onRetry: () -> Void
    
    var body: some View {
        VStack(spacing: Spacing.lg) {
            Image(systemName: "server.rack")
                .font(.system(size: 60))
                .foregroundColor(.textTertiary)
            
            VStack(spacing: Spacing.xs) {
                Text("服务器开小差了")
                    .font(.title3)
                    .fontWeight(.medium)
                    .foregroundColor(.textPrimary)
                
                Text("工程师正在紧急修复中")
                    .font(.bodySmall)
                    .foregroundColor(.textSecondary)
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
```

### 13.4 错误处理最佳实践

| 场景 | 处理方式 | 用户反馈 |
|------|---------|---------|
| 网络超时 | 自动重试1次，失败后提示 | Toast + 重试按钮 |
| Token过期 | 尝试刷新Token，失败跳转登录 | Toast + 跳转登录页 |
| 积分不足 | 直接提示，引导充值 | 弹窗 + 跳转充值页 |
| 参数错误 | 直接提示，不重试 | Toast |
| 服务器错误 | 记录日志，提示用户 | 错误页面 + 重试按钮 |
| 内容违规 | 直接提示，引导更换 | 弹窗 + 说明 |



---

## 14. 埋点规范（Analytics & Tracking Specification）

### 14.1 埋点框架设计

#### 14.1.1 埋点分类

| 类型 | 说明 | 触发时机 | 示例 |
|------|------|---------|------|
| **页面浏览（PV）** | 页面曝光 | 页面进入时 | 首页曝光、详情页曝光 |
| **用户行为（Event）** | 用户主动操作 | 点击、滑动等 | 点击生成、点击分享 |
| **业务转化（Conversion）** | 关键业务节点 | 完成关键动作 | 登录成功、支付成功 |
| **性能监控（Performance）** | 性能指标 | 自动采集 | 页面加载时间、接口耗时 |
| **异常监控（Error）** | 错误信息 | 错误发生时 | 接口报错、崩溃 |

#### 14.1.2 埋点数据结构

```swift
// MARK: - 埋点事件模型
struct AnalyticsEvent: Codable {
    let eventId: String              // 事件唯一ID
    let eventName: String            // 事件名称
    let eventType: EventType         // 事件类型
    let timestamp: Date              // 事件时间
    let userId: String?              // 用户ID（未登录为nil）
    let sessionId: String            // 会话ID
    let pageId: String?              // 页面ID
    let properties: [String: AnyCodable]  // 自定义属性
    let deviceInfo: DeviceInfo       // 设备信息
    let networkInfo: NetworkInfo     // 网络信息
}

enum EventType: String, Codable {
    case pageView = "page_view"
    case userAction = "user_action"
    case conversion = "conversion"
    case performance = "performance"
    case error = "error"
}

// MARK: - 网络信息
struct NetworkInfo: Codable {
    let type: String                 // wifi/4g/5g
    let carrier: String?             // 运营商
}

// MARK: - 通用属性包装
struct AnyCodable: Codable {
    let value: Any
    
    init(_ value: Any) {
        self.value = value
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let intValue = try? container.decode(Int.self) {
            value = intValue
        } else if let doubleValue = try? container.decode(Double.self) {
            value = doubleValue
        } else if let stringValue = try? container.decode(String.self) {
            value = stringValue
        } else if let boolValue = try? container.decode(Bool.self) {
            value = boolValue
        } else {
            value = ""
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        if let intValue = value as? Int {
            try container.encode(intValue)
        } else if let doubleValue = value as? Double {
            try container.encode(doubleValue)
        } else if let stringValue = value as? String {
            try container.encode(stringValue)
        } else if let boolValue = value as? Bool {
            try container.encode(boolValue)
        }
    }
}
```

### 14.2 埋点事件定义

#### 14.2.1 页面浏览事件

| 事件名 | 页面 | 必传属性 | 可选属性 |
|--------|------|---------|---------|
| `page_splash` | 启动页 | - | launch_type |
| `page_login` | 登录页 | - | source |
| `page_home` | 首页 | tab_name | category |
| `page_create` | 创作页 | - | - |
| `page_template_select` | 模板选择页 | - | category |
| `page_upload` | 上传页 | template_id | - |
| `page_generating` | 生成中页 | task_id | - |
| `page_result` | 生成结果页 | task_id | is_success |
| `page_detail` | 作品详情页 | work_id | source |
| `page_profile` | 个人中心 | - | - |
| `page_membership` | 会员页 | - | source |
| `page_recharge` | 充值页 | - | source |
| `page_settings` | 设置页 | - | - |

```swift
// MARK: - 页面埋点枚举
enum PageEvent: String {
    case splash = "page_splash"
    case login = "page_login"
    case home = "page_home"
    case create = "page_create"
    case templateSelect = "page_template_select"
    case upload = "page_upload"
    case generating = "page_generating"
    case result = "page_result"
    case detail = "page_detail"
    case profile = "page_profile"
    case membership = "page_membership"
    case recharge = "page_recharge"
    case settings = "page_settings"
    
    var pageId: String {
        rawValue
    }
}
```

#### 14.2.2 用户行为事件

| 事件名 | 说明 | 必传属性 | 可选属性 |
|--------|------|---------|---------|
| `click_login_wechat` | 点击微信登录 | - | - |
| `click_login_apple` | 点击Apple登录 | - | - |
| `click_login_phone` | 点击手机登录 | - | - |
| `click_get_verify_code` | 点击获取验证码 | phone | - |
| `click_submit_login` | 点击登录提交 | login_type | - |
| `click_category_tab` | 点击分类Tab | category | page |
| `click_work_card` | 点击作品卡片 | work_id | position, source |
| `click_template_card` | 点击模板卡片 | template_id | position, category |
| `click_upload_image` | 点击上传图片 | - | source |
| `click_start_generate` | 点击开始生成 | template_id | points_cost |
| `click_cancel_generate` | 点击取消生成 | task_id | progress |
| `click_save_image` | 点击保存图片 | work_id | - |
| `click_share` | 点击分享 | work_id | share_type |
| `click_like` | 点击点赞 | work_id | is_like |
| `click_follow_generate` | 点击跟图生成 | work_id | - |
| `click_buy_membership` | 点击购买会员 | plan_id | price |
| `click_buy_points` | 点击购买积分 | package_id | price |
| `click_pay` | 点击支付 | order_id | pay_method, amount |
| `click_banner` | 点击Banner | banner_id | position |
| `click_notification` | 点击通知 | notification_id | type |
| `scroll_work_list` | 滚动作品列表 | page | category |
| `pull_refresh` | 下拉刷新 | page | - |

```swift
// MARK: - 用户行为事件枚举
enum UserActionEvent: String {
    // 登录相关
    case clickLoginWechat = "click_login_wechat"
    case clickLoginApple = "click_login_apple"
    case clickLoginPhone = "click_login_phone"
    case clickGetVerifyCode = "click_get_verify_code"
    case clickSubmitLogin = "click_submit_login"
    
    // 浏览相关
    case clickCategoryTab = "click_category_tab"
    case clickWorkCard = "click_work_card"
    case clickTemplateCard = "click_template_card"
    case clickBanner = "click_banner"
    case scrollWorkList = "scroll_work_list"
    case pullRefresh = "pull_refresh"
    
    // 创作相关
    case clickUploadImage = "click_upload_image"
    case clickStartGenerate = "click_start_generate"
    case clickCancelGenerate = "click_cancel_generate"
    case clickFollowGenerate = "click_follow_generate"
    
    // 互动相关
    case clickSaveImage = "click_save_image"
    case clickShare = "click_share"
    case clickLike = "click_like"
    
    // 付费相关
    case clickBuyMembership = "click_buy_membership"
    case clickBuyPoints = "click_buy_points"
    case clickPay = "click_pay"
    
    // 其他
    case clickNotification = "click_notification"
}
```

#### 14.2.3 业务转化事件

| 事件名 | 说明 | 必传属性 | 可选属性 |
|--------|------|---------|---------|
| `login_success` | 登录成功 | login_type | is_new_user |
| `login_fail` | 登录失败 | login_type | error_code |
| `register_success` | 注册成功 | register_type | channel |
| `upload_success` | 上传成功 | file_size | duration |
| `upload_fail` | 上传失败 | error_code | file_size |
| `generate_start` | 开始生成 | template_id | points_cost |
| `generate_success` | 生成成功 | task_id | duration, template_id |
| `generate_fail` | 生成失败 | task_id | error_code |
| `generate_cancel` | 取消生成 | task_id | progress |
| `publish_success` | 发布成功 | work_id | - |
| `share_success` | 分享成功 | work_id | share_type |
| `pay_start` | 发起支付 | order_id | amount, pay_method |
| `pay_success` | 支付成功 | order_id | amount, pay_method |
| `pay_fail` | 支付失败 | order_id | error_code |
| `pay_cancel` | 取消支付 | order_id | - |
| `membership_activate` | 会员激活 | plan_id | price |
| `points_recharge` | 积分充值 | package_id | points, price |

```swift
// MARK: - 转化事件枚举
enum ConversionEvent: String {
    // 登录注册
    case loginSuccess = "login_success"
    case loginFail = "login_fail"
    case registerSuccess = "register_success"
    
    // 上传
    case uploadSuccess = "upload_success"
    case uploadFail = "upload_fail"
    
    // 生成
    case generateStart = "generate_start"
    case generateSuccess = "generate_success"
    case generateFail = "generate_fail"
    case generateCancel = "generate_cancel"
    
    // 发布分享
    case publishSuccess = "publish_success"
    case shareSuccess = "share_success"
    
    // 支付
    case payStart = "pay_start"
    case paySuccess = "pay_success"
    case payFail = "pay_fail"
    case payCancel = "pay_cancel"
    
    // 会员积分
    case membershipActivate = "membership_activate"
    case pointsRecharge = "points_recharge"
}
```

### 14.3 埋点SDK实现

```swift
// MARK: - 埋点管理器
class AnalyticsManager {
    static let shared = AnalyticsManager()
    
    private var sessionId: String
    private var eventQueue: [AnalyticsEvent] = []
    private let maxQueueSize = 50
    private let uploadInterval: TimeInterval = 30
    private var uploadTimer: Timer?
    
    private init() {
        sessionId = UUID().uuidString
        startUploadTimer()
        setupAppLifecycleObservers()
    }
    
    // MARK: - 页面浏览
    func trackPageView(_ page: PageEvent, properties: [String: Any] = [:]) {
        var props = properties
        props["page_id"] = page.pageId
        
        let event = createEvent(
            name: page.rawValue,
            type: .pageView,
            pageId: page.pageId,
            properties: props
        )
        
        enqueueEvent(event)
    }
    
    // MARK: - 用户行为
    func trackAction(_ action: UserActionEvent, properties: [String: Any] = [:]) {
        let event = createEvent(
            name: action.rawValue,
            type: .userAction,
            pageId: currentPageId,
            properties: properties
        )
        
        enqueueEvent(event)
    }
    
    // MARK: - 业务转化
    func trackConversion(_ conversion: ConversionEvent, properties: [String: Any] = [:]) {
        let event = createEvent(
            name: conversion.rawValue,
            type: .conversion,
            pageId: currentPageId,
            properties: properties
        )
        
        // 转化事件立即上报
        uploadEvents([event])
    }
    
    // MARK: - 性能监控
    func trackPerformance(name: String, duration: TimeInterval, properties: [String: Any] = [:]) {
        var props = properties
        props["duration"] = duration
        
        let event = createEvent(
            name: name,
            type: .performance,
            pageId: currentPageId,
            properties: props
        )
        
        enqueueEvent(event)
    }
    
    // MARK: - 错误监控
    func trackError(name: String, error: Error, properties: [String: Any] = [:]) {
        var props = properties
        props["error_message"] = error.localizedDescription
        if let apiError = error as? APIError {
            props["error_code"] = apiError.code
        }
        
        let event = createEvent(
            name: name,
            type: .error,
            pageId: currentPageId,
            properties: props
        )
        
        // 错误事件立即上报
        uploadEvents([event])
    }
    
    // MARK: - 设置用户ID
    func setUserId(_ userId: String?) {
        UserDefaults.standard.set(userId, forKey: "analytics_user_id")
    }
    
    // MARK: - 重置会话
    func resetSession() {
        sessionId = UUID().uuidString
    }
    
    // MARK: - 私有方法
    private var currentPageId: String? {
        // 从页面栈获取当前页面ID
        return PageTracker.shared.currentPageId
    }
    
    private var currentUserId: String? {
        return UserDefaults.standard.string(forKey: "analytics_user_id")
    }
    
    private func createEvent(
        name: String,
        type: EventType,
        pageId: String?,
        properties: [String: Any]
    ) -> AnalyticsEvent {
        let codableProperties = properties.mapValues { AnyCodable($0) }
        
        return AnalyticsEvent(
            eventId: UUID().uuidString,
            eventName: name,
            eventType: type,
            timestamp: Date(),
            userId: currentUserId,
            sessionId: sessionId,
            pageId: pageId,
            properties: codableProperties,
            deviceInfo: DeviceInfo.current,
            networkInfo: NetworkInfo.current
        )
    }
    
    private func enqueueEvent(_ event: AnalyticsEvent) {
        eventQueue.append(event)
        
        if eventQueue.count >= maxQueueSize {
            flushEvents()
        }
    }
    
    private func flushEvents() {
        guard !eventQueue.isEmpty else { return }
        
        let eventsToUpload = eventQueue
        eventQueue.removeAll()
        
        uploadEvents(eventsToUpload)
    }
    
    private func uploadEvents(_ events: [AnalyticsEvent]) {
        Task {
            do {
                try await AnalyticsAPI.upload(events: events)
            } catch {
                // 上传失败，重新入队
                eventQueue.insert(contentsOf: events, at: 0)
            }
        }
    }
    
    private func startUploadTimer() {
        uploadTimer = Timer.scheduledTimer(withTimeInterval: uploadInterval, repeats: true) { [weak self] _ in
            self?.flushEvents()
        }
    }
    
    private func setupAppLifecycleObservers() {
        NotificationCenter.default.addObserver(
            forName: UIApplication.willResignActiveNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.flushEvents()
        }
        
        NotificationCenter.default.addObserver(
            forName: UIApplication.didBecomeActiveNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.resetSession()
        }
    }
}

// MARK: - 网络信息扩展
extension NetworkInfo {
    static var current: NetworkInfo {
        // 实际实现需要使用 Network.framework 或 Reachability
        return NetworkInfo(type: "wifi", carrier: nil)
    }
}

// MARK: - 页面追踪器
class PageTracker {
    static let shared = PageTracker()
    
    private var pageStack: [String] = []
    
    var currentPageId: String? {
        pageStack.last
    }
    
    func pushPage(_ pageId: String) {
        pageStack.append(pageId)
    }
    
    func popPage() {
        _ = pageStack.popLast()
    }
}
```

### 14.4 埋点使用示例

```swift
// MARK: - 页面埋点示例
struct HomeView: View {
    var body: some View {
        ScrollView {
            // 内容
        }
        .onAppear {
            // 页面曝光埋点
            AnalyticsManager.shared.trackPageView(.home, properties: [
                "tab_name": "recommend",
                "category": "all"
            ])
        }
    }
}

// MARK: - 用户行为埋点示例
struct WorkCardView: View {
    let work: WorkListItem
    let position: Int
    
    var body: some View {
        Button(action: {
            // 点击埋点
            AnalyticsManager.shared.trackAction(.clickWorkCard, properties: [
                "work_id": work.id,
                "position": position,
                "source": "home_recommend"
            ])
            
            // 跳转逻辑
        }) {
            // 卡片内容
        }
    }
}

// MARK: - 转化埋点示例
class GenerationViewModel: ObservableObject {
    
    func startGeneration() async {
        guard let template = selectedTemplate,
              let imageURL = uploadedImageURL else { return }
        
        // 开始生成埋点
        AnalyticsManager.shared.trackConversion(.generateStart, properties: [
            "template_id": template.id,
            "template_name": template.name,
            "points_cost": template.pointsCost
        ])
        
        let startTime = Date()
        
        do {
            let response = try await apiService.createGeneration(request: request)
            currentTaskId = response.taskId
            
            // 等待生成完成...
            let task = try await waitForCompletion(taskId: response.taskId)
            
            let duration = Date().timeIntervalSince(startTime)
            
            // 生成成功埋点
            AnalyticsManager.shared.trackConversion(.generateSuccess, properties: [
                "task_id": response.taskId,
                "template_id": template.id,
                "duration": duration,
                "points_cost": template.pointsCost
            ])
            
        } catch {
            // 生成失败埋点
            AnalyticsManager.shared.trackConversion(.generateFail, properties: [
                "template_id": template.id,
                "error_code": (error as? APIError)?.code ?? -1,
                "error_message": error.localizedDescription
            ])
        }
    }
}

// MARK: - 支付埋点示例
class PaymentViewModel: ObservableObject {
    
    func pay(order: Order, method: PaymentMethod) async {
        // 发起支付埋点
        AnalyticsManager.shared.trackConversion(.payStart, properties: [
            "order_id": order.id,
            "order_type": order.type.rawValue,
            "amount": order.amount,
            "pay_method": method.rawValue
        ])
        
        do {
            let result = try await PaymentService.shared.pay(order: order, method: method)
            
            if result.isSuccess {
                // 支付成功埋点
                AnalyticsManager.shared.trackConversion(.paySuccess, properties: [
                    "order_id": order.id,
                    "order_type": order.type.rawValue,
                    "amount": order.amount,
                    "pay_method": method.rawValue,
                    "transaction_id": result.transactionId ?? ""
                ])
            } else {
                // 支付失败埋点
                AnalyticsManager.shared.trackConversion(.payFail, properties: [
                    "order_id": order.id,
                    "error_code": result.errorCode ?? -1
                ])
            }
            
        } catch {
            // 支付异常埋点
            AnalyticsManager.shared.trackError("payment_exception", error: error, properties: [
                "order_id": order.id
            ])
        }
    }
}

// MARK: - 性能埋点示例
class ImageUploader {
    
    func upload(image: UIImage) async throws -> String {
        let startTime = Date()
        
        defer {
            let duration = Date().timeIntervalSince(startTime)
            AnalyticsManager.shared.trackPerformance(name: "image_upload", duration: duration, properties: [
                "file_size": image.jpegData(compressionQuality: 0.8)?.count ?? 0
            ])
        }
        
        // 上传逻辑
        let result = try await APIService.shared.uploadImage(image.jpegData(compressionQuality: 0.8)!)
        return result.url
    }
}
```

### 14.5 关键指标定义

| 指标名称 | 计算方式 | 说明 |
|---------|---------|------|
| **DAU** | 日活跃用户数 | 当日有任意行为的去重用户数 |
| **新增用户** | register_success事件数 | 当日完成注册的用户数 |
| **登录转化率** | login_success / page_login | 登录页到登录成功的转化 |
| **生成转化率** | generate_success / click_start_generate | 点击生成到生成成功的转化 |
| **付费转化率** | pay_success / click_pay | 点击支付到支付成功的转化 |
| **ARPU** | 总收入 / DAU | 每用户平均收入 |
| **ARPPU** | 总收入 / 付费用户数 | 每付费用户平均收入 |
| **生成成功率** | generate_success / generate_start | 生成任务成功率 |
| **平均生成时长** | sum(duration) / generate_success | 生成任务平均耗时 |
| **分享率** | share_success / generate_success | 生成后分享的比例 |

### 14.6 埋点验证清单

| 检查项 | 验证方法 | 通过标准 |
|--------|---------|---------|
| 事件名称正确 | 日志检查 | 与定义一致 |
| 必传属性完整 | 日志检查 | 无缺失 |
| 属性值类型正确 | 日志检查 | 类型匹配 |
| 触发时机正确 | 手动测试 | 符合预期 |
| 无重复上报 | 日志检查 | 无重复 |
| 性能无影响 | 性能测试 | 无明显卡顿 |

---

*文档版本：3.0*  
*最后更新：2026年1月19日*  
*作者：Manus AI*
