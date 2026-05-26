# 🍼 Baby Monitor Frontend

基于 Flutter 的婴儿智能看护系统前端应用，支持 iOS、Android 和 Web 平台。

## 🚀 技术栈

| 技术 | 版本 | 用途 |
|------|------|------|
| Flutter | 3.0+ | 跨平台 UI 框架 |
| Riverpod | 2.6+ | 状态管理 |
| WebSocket | - | 实时通信 |
| VLC Player | 7.4+ | 视频播放 |
| fl_chart | 0.70+ | 图表可视化 |

## 📁 项目结构

```
frontend/
├── lib/
│   ├── pages/                    # 页面
│   │   ├── home_page.dart        # 主页面
│   │   ├── login_page.dart       # 登录页面
│   │   ├── register_page.dart    # 注册页面
│   │   ├── chat_page.dart        # AI Agent 对话
│   │   ├── advice_page.dart      # 育儿建议
│   │   ├── smart_home_page.dart  # 智能家居控制
│   │   ├── live_monitor_page.dart # 实时监控
│   │   ├── monitoring_dashboard.dart # 监控仪表盘
│   │   ├── history_page.dart     # 历史记录
│   │   └── settings_page.dart    # 设置页面
│   │
│   ├── services/                 # 服务层
│   │   ├── api_service.dart      # API 配置
│   │   ├── auth_service.dart     # 认证服务
│   │   ├── agent_service.dart    # Agent 服务
│   │   ├── rag_service.dart      # RAG 服务
│   │   ├── smart_home_service.dart # 智能家居服务
│   │   └── notification_service.dart # 通知服务
│   │
│   ├── providers/                # 状态管理
│   │   ├── agent_provider.dart   # Agent 状态
│   │   ├── rag_provider.dart     # RAG 状态
│   │   ├── smart_home_provider.dart # 智能家居状态
│   │   ├── device_provider.dart  # 设备状态
│   │   └── language_provider.dart # 语言设置
│   │
│   ├── widgets/                  # 组件
│   │   ├── video_player.dart     # 视频播放器
│   │   ├── notification_card.dart # 通知卡片
│   │   ├── custom_drawer.dart    # 侧边栏
│   │   └── card_widgets.dart     # 卡片组件
│   │
│   ├── models/                   # 数据模型
│   │   ├── notification_model.dart # 通知模型
│   │   └── alert_model.dart      # 警报模型
│   │
│   ├── routes/                   # 路由
│   │   └── app_routes.dart       # 路由配置
│   │
│   ├── utils/                    # 工具类
│   │   ├── constants.dart        # 常量
│   │   ├── helpers.dart          # 帮助函数
│   │   └── logger.dart           # 日志工具
│   │
│   ├── assets/                   # 资源文件
│   │   ├── images/
│   │   ├── icons/
│   │   ├── videos/
│   │   └── audios/
│   │
│   ├── generated/                # 自动生成
│   │   └── l10n.dart             # 国际化
│   │
│   └── main.dart                 # 应用入口
│
├── android/                      # Android 配置
├── ios/                          # iOS 配置
├── web/                          # Web 配置
├── linux/                        # Linux 配置
├── macos/                        # macOS 配置
├── windows/                      # Windows 配置
├── test/                         # 测试文件
├── pubspec.yaml                  # 依赖配置
├── Dockerfile                    # Docker 配置
├── nginx.conf                    # Nginx 配置
└── README.md                     # 项目说明
```

## 🛠️ 安装与运行

### 1. 环境要求

- Flutter SDK 3.0+
- Dart SDK 3.6+
- Android Studio / Xcode (移动端开发)

### 2. 安装依赖

```bash
# 获取依赖
flutter pub get

# 生成国际化文件
flutter pub run intl_utils:generate
```

### 3. 配置环境变量

创建 `.env` 文件：

```env
API_BASE_URL=http://localhost:8000
WS_BASE_URL=ws://localhost:8000
```

### 4. 运行应用

```bash
# Web 平台
flutter run -d chrome

# Android 平台
flutter run -d android

# iOS 平台
flutter run -d ios

# macOS 平台
flutter run -d macos
```

### 5. 构建发布

```bash
# Web 平台
flutter build web --release

# Android 平台
flutter build apk --release

# iOS 平台
flutter build ios --release
```

### 6. Docker 部署 (Web)

```bash
# 构建镜像
docker build -t baby-monitor-frontend .

# 运行容器
docker run -d -p 8080:80 baby-monitor-frontend
```

## 📱 功能模块

### 🏠 主页

- 实时视频监控
- 设备状态显示
- 快捷功能入口

### 🤖 AI Agent 对话

- 多轮对话
- 育儿问题解答
- 智能建议生成

### 📚 育儿建议

- RAG 知识库查询
- 紧急情况处理
- 知识搜索

### 🏠 智能家居控制

- 音箱控制（白噪音、摇篮曲）
- 灯光控制（亮度、颜色、模式）
- 场景模式（睡眠、安抚、警报）

### 📹 实时监控

- WebSocket 视频流
- 音频流接收
- 双向语音对讲

### 📊 监控仪表盘

- 实时统计图表
- 连接状态监控
- 消息流量分析
- 延迟监控

### 📋 历史记录

- 通知历史
- 检测记录
- 置顶/删除功能

## 🎨 UI 设计

### 设计风格

- 玻璃拟态 (GlassMorphism)
- 渐变背景
- 圆角卡片
- 半透明效果

### 主题色彩

```dart
primaryColor: Colors.blue
gradientColors: [Color(0xFFE3FDFD), Color(0xFFFFE6FA)]
```

### 国际化

支持语言：
- 中文 (zh_CN)
- 英文 (en_US)

## 🧪 运行测试

```bash
# 运行所有测试
flutter test

# 运行特定测试
flutter test test/widget_test.dart

# 生成覆盖率报告
flutter test --coverage
genhtml coverage/lcov.info -o coverage/html
```

## 📦 依赖说明

### 核心依赖

| 依赖 | 用途 |
|------|------|
| `flutter_riverpod` | 状态管理 |
| `web_socket_channel` | WebSocket 通信 |
| `flutter_vlc_player` | 视频播放 |
| `fl_chart` | 图表可视化 |
| `flutter_local_notifications` | 本地通知 |
| `shared_preferences` | 本地存储 |
| `http` | HTTP 请求 |

### 开发依赖

| 依赖 | 用途 |
|------|------|
| `flutter_test` | 测试框架 |
| `flutter_lints` | 代码规范 |
| `intl_utils` | 国际化工具 |

## 🔧 配置说明

### API 配置

在 `lib/services/api_service.dart` 中配置：

```dart
static const String baseHttpUrl = 'http://localhost:8000';
static const String baseWsUrl = 'ws://localhost:8000';
```

### 主题配置

在 `lib/main.dart` 中自定义主题：

```dart
ThemeData(
  primarySwatch: Colors.blue,
  scaffoldBackgroundColor: Colors.transparent,
  // ...
)
```

## 🤝 贡献指南

1. Fork 项目
2. 创建特性分支 (`git checkout -b feature/AmazingFeature`)
3. 提交更改 (`git commit -m 'Add some AmazingFeature'`)
4. 推送到分支 (`git push origin feature/AmazingFeature`)
5. 创建 Pull Request

## 📄 许可证

MIT License

---

<p align="center">
  Made with ❤️ for baby safety
</p>
