# AI创图 - SwiftUI iOS App

基于SwiftUI开发的AI图片生成应用，支持iOS 17+。参考丸拍AI/WanSnap设计风格。

## 文档说明

| 文档 | 说明 |
|------|------|
| [设计规范](docs/AI创图App_SwiftUI_设计规范.md) | 完整的SwiftUI设计规范，包含颜色、字体、组件、API、埋点等 |
| [功能分析](docs/feature_analysis.md) | 对标App功能分析 |
| [功能需求](docs/functional_requirements.md) | 详细功能需求文档 |
| [UI原型图](docs/ui-prototype/) | HTML版本的UI原型图 |

## 项目结构

```
AICreatorApp/
├── AICreatorApp.xcodeproj/     # Xcode项目文件
├── AICreatorApp/
│   ├── Sources/
│   │   ├── App/
│   │   │   └── Router.swift           # 路由管理、导航
│   │   ├── Views/
│   │   │   ├── HomeView.swift         # 首页/发现页
│   │   │   ├── LoginView.swift        # 登录页
│   │   │   ├── CreateView.swift       # 创作页
│   │   │   ├── DetailView.swift       # 作品详情页
│   │   │   └── ProfileView.swift      # 个人中心页
│   │   ├── ViewModels/                # 视图模型（已内置于Views中）
│   │   ├── Models/
│   │   │   └── Models.swift           # 数据模型
│   │   ├── Services/
│   │   │   ├── APIService.swift       # API网络服务
│   │   │   ├── Analytics.swift        # 埋点和错误处理
│   │   │   └── ThirdPartySDK.swift    # 第三方SDK集成
│   │   ├── Components/                # 可复用UI组件
│   │   └── Utils/
│   │       └── DesignSystem.swift     # 设计系统
│   ├── Resources/
│   │   └── Assets.xcassets/           # 图片资源
│   ├── Preview Content/               # SwiftUI预览资源
│   ├── Info.plist                     # App配置
│   └── AICreatorApp.entitlements      # 权限配置
└── README.md
```

## 功能特性

### 核心功能
- **AI图片生成**：选择模板、上传照片、一键生成
- **作品发现**：瀑布流展示、分类浏览、热门推荐
- **社交互动**：点赞、分享、跟图生成
- **会员系统**：订阅会员、积分充值

### 技术特性
- **SwiftUI**：纯SwiftUI开发，支持iOS 17+
- **MVVM架构**：清晰的代码分层
- **NavigationStack**：现代化导航管理
- **StoreKit 2**：内购和订阅
- **async/await**：异步编程

## 快速开始

### 环境要求
- macOS 14.0+
- Xcode 15.0+
- iOS 17.0+ 模拟器或真机

### 运行步骤

1. **打开项目**
   ```bash
   open AICreatorApp.xcodeproj
   ```

2. **配置签名**
   - 在Xcode中选择项目
   - 选择"Signing & Capabilities"
   - 配置你的开发团队

3. **运行项目**
   - 选择目标设备（模拟器或真机）
   - 点击运行按钮或按 `Cmd + R`

## 配置说明

### 微信SDK配置

1. 在[微信开放平台](https://open.weixin.qq.com/)注册应用
2. 修改 `ThirdPartySDK.swift` 中的配置：
   ```swift
   struct WeChatConfig {
       static let appId = "你的微信AppID"
       static let universalLink = "你的Universal Link"
   }
   ```
3. 修改 `Info.plist` 中的URL Schemes

### Apple登录配置

1. 在Xcode中启用"Sign in with Apple"能力
2. 在Apple Developer后台配置App ID

### 内购配置

1. 在App Store Connect创建内购产品
2. 修改 `ThirdPartySDK.swift` 中的产品ID：
   ```swift
   struct ProductID {
       static let weeklyMembership = "你的产品ID"
       // ...
   }
   ```

### API配置

修改 `APIService.swift` 中的服务器地址：
```swift
struct AppConfig {
    static let apiBaseURL = "https://your-api-server.com/api/v1"
}
```

## 设计规范

项目遵循统一的设计系统，定义在 `DesignSystem.swift` 中：

### 颜色
- 主色调：紫粉渐变 (#9B59FC → #FC59A3)
- 背景色：深色模式 (#0D0D12)
- 文字色：白色系列

### 字体
- 标题：SF Pro Display Bold
- 正文：SF Pro Text Regular
- 按钮：SF Pro Text Medium

### 间距
- xxs: 4pt
- xs: 8pt
- sm: 12pt
- md: 16pt
- lg: 24pt
- xl: 32pt

## 注意事项

1. **iOS版本**：项目使用了iOS 17的新API（如sensoryFeedback），请确保目标设备支持
2. **第三方SDK**：微信SDK需要单独集成，项目中提供了封装但未包含实际SDK
3. **Mock数据**：部分功能使用Mock数据，正式使用需替换为真实API

## 版本历史

- **v1.0.0** (2025-01-18)
  - 初始版本
  - 完成所有核心页面
  - 集成微信登录、Apple登录、StoreKit支付

## 许可证

MIT License

## 联系方式

如有问题，请提交Issue或联系开发团队。
