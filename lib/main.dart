import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'routes/app_routes.dart';
import 'services/notification_service.dart';
import 'services/auth_service.dart';
import 'providers/language_provider.dart'; // 引入语言管理器
import 'generated/l10n.dart'; // 导入生成的 l10n.dart 文件


void main() async {
  // 确保 Flutter 框架已经初始化
  WidgetsFlutterBinding.ensureInitialized();

  // 初始化通知服务
  await NotificationService().initialize();

  // 读取本地存储的 token 以判断用户是否已登录
  String initialRoute = await _getInitialRoute();

  runApp(ProviderScope(child: MyApp(initialRoute: initialRoute)));
}

class MyApp extends ConsumerWidget {
  final String initialRoute;

  const MyApp({Key? key, required this.initialRoute}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 获取当前语言设置
    final selectedLanguage = ref.watch(languageProvider);

    // 根据语言设置动态选择 Locale
    Locale appLocale = selectedLanguage == 'English' ? Locale('en', 'US') : Locale('zh', 'CN');

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: _buildGlassMorphismTheme(),
      initialRoute: initialRoute, // 动态设置初始路由
      routes: AppRoutes.routes,
      locale: appLocale, // 动态设置 Locale
      supportedLocales: [
        Locale('en', 'US'),
        Locale('zh', 'CN'),
      ],
      localizationsDelegates: [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        // 需要加入AppLocalizations.delegate
        S.delegate,
      ],
    );
  }

  /// 构建玻璃拟态主题
  ThemeData _buildGlassMorphismTheme() {
    return ThemeData(
      primarySwatch: Colors.blue,
      scaffoldBackgroundColor: Colors.transparent, // 背景透明以支持渐变
      visualDensity: VisualDensity.adaptivePlatformDensity,
      textTheme: const TextTheme(
        bodyMedium: TextStyle(
          color: Colors.black87, // 默认字体颜色
          fontSize: 16,
        ),
        titleLarge: TextStyle(
          color: Colors.black,
          fontWeight: FontWeight.bold,
          fontSize: 20,
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.white.withOpacity(0.8), // 半透明背景
        elevation: 0, // 无阴影
        iconTheme: const IconThemeData(color: Colors.black), // 图标颜色
        titleTextStyle: const TextStyle(
          color: Colors.black,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      cardTheme: CardTheme(
        color: Colors.white.withOpacity(0.7), // 半透明卡片
        elevation: 5, // 阴影
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15), // 圆角边框
        ),
      ),
    );
  }
}

/// 读取本地存储的 Token，决定初始页面
Future<String> _getInitialRoute() async {
  AuthService authService = AuthService();
  bool isLoggedIn = await authService.isLoggedIn();
  return isLoggedIn ? '/home' : '/login';
}
