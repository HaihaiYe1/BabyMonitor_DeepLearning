lib/
├── pages/               # 页面
│   ├── home_page.dart      # 主页面
│   ├── login_page.dart     # 登录页面
│   ├── register_page.dart  # 注册页面
│   ├── history_page.dart   # 历史记录页面
│   └── settings_page.dart  # 用户设置页面
│
├── widgets/            # 自定义组件
│   ├── video_player.dart   # 视频播放组件
│   ├── notification_card.dart # 异常行为通知组件
│   └── custom_button.dart     # 通用按钮组件
│
├── models/             # 数据模型
│   └── alert_model.dart    # 异常行为数据模型
│
├── services/           # 服务层
│   ├── api_service.dart    # API 请求封装
│   ├── auth_service.dart   # 用户认证相关服务
│   └── notification_service.dart # 异常行为通知服务
│
├── utils/              # 工具类
│   ├── constants.dart      # 常量（如颜色、字体大小等）
│   ├── helpers.dart        # 帮助函数
│   └── logger.dart         # 日志工具
│
├── routes/             # 路由
│   └── app_routes.dart     # 应用路由管理
│
├── main.dart           # 应用入口