import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'routes/app_routes.dart';
import 'services/notification_service.dart';
import 'services/auth_service.dart';
import 'providers/language_provider.dart';
import 'generated/l10n.dart';
import 'utils/platform_adapter.dart';

void main() async {
  // 确保 Flutter 框架已经初始化
  WidgetsFlutterBinding.ensureInitialized();

  // 设置系统UI样式
  PlatformAdapter.setSystemUIStyle(
    statusBarBrightness: Brightness.light,
    statusBarIconBrightness: Brightness.dark,
    statusBarColor: Colors.transparent,
  );

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
    Locale appLocale = selectedLanguage == 'English' 
        ? const Locale('en', 'US') 
        : const Locale('zh', 'CN');

    return MaterialApp(
      title: 'Baby Monitor',
      debugShowCheckedModeBanner: false,
      theme: _buildPlatformTheme(context, Brightness.light),
      darkTheme: _buildPlatformTheme(context, Brightness.dark),
      themeMode: ThemeMode.system,
      initialRoute: initialRoute,
      routes: AppRoutes.routes,
      locale: appLocale,
      supportedLocales: const [
        Locale('en', 'US'),
        Locale('zh', 'CN'),
      ],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        S.delegate,
      ],
      // 平台特定的滚动行为
      scrollBehavior: _getPlatformScrollBehavior(),
    );
  }

  /// 构建平台适配的主题
  ThemeData _buildPlatformTheme(BuildContext context, Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    final platform = defaultTargetPlatform;

    // 基础颜色方案
    final colorScheme = ColorScheme.fromSeed(
      seedColor: Colors.blue,
      brightness: brightness,
    );

    // 根据平台调整字体
    String? fontFamily;
    switch (platform) {
      case TargetPlatform.iOS:
      case TargetPlatform.macOS:
        fontFamily = 'SF Pro Display';
        break;
      case TargetPlatform.windows:
        fontFamily = 'Segoe UI';
        break;
      case TargetPlatform.android:
        fontFamily = 'Roboto';
        break;
      default:
        fontFamily = 'Roboto';
    }

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      fontFamily: fontFamily,
      brightness: brightness,
      
      // 脚手架背景
      scaffoldBackgroundColor: isDark 
          ? const Color(0xFF121212)
          : Colors.transparent,
      
      // 视觉密度自适应平台
      visualDensity: VisualDensity.adaptivePlatformDensity,
      
      // 文字主题
      textTheme: TextTheme(
        bodyMedium: TextStyle(
          color: isDark ? Colors.white70 : Colors.black87,
          fontSize: 16,
        ),
        bodyLarge: TextStyle(
          color: isDark ? Colors.white70 : Colors.black87,
          fontSize: 18,
        ),
        titleLarge: TextStyle(
          color: isDark ? Colors.white : Colors.black,
          fontWeight: FontWeight.bold,
          fontSize: 20,
        ),
        titleMedium: TextStyle(
          color: isDark ? Colors.white : Colors.black,
          fontWeight: FontWeight.w600,
          fontSize: 16,
        ),
        labelLarge: TextStyle(
          color: isDark ? Colors.white : Colors.black87,
          fontSize: 14,
        ),
      ),
      
      // AppBar主题
      appBarTheme: AppBarTheme(
        backgroundColor: isDark 
            ? const Color(0xFF1E1E1E)
            : Colors.white.withOpacity(0.8),
        elevation: 0,
        centerTitle: platform == TargetPlatform.iOS || platform == TargetPlatform.macOS,
        iconTheme: IconThemeData(
          color: isDark ? Colors.white : Colors.black,
        ),
        titleTextStyle: TextStyle(
          color: isDark ? Colors.white : Colors.black,
          fontSize: 20,
          fontWeight: FontWeight.bold,
          fontFamily: fontFamily,
        ),
      ),
      
      // 卡片主题
      cardTheme: CardThemeData(
        color: isDark 
            ? const Color(0xFF2C2C2C)
            : Colors.white.withOpacity(0.7),
        elevation: isDark ? 0 : 5,
        shape: RoundedRectangleBorder(
          borderRadius: _getPlatformBorderRadius(platform),
          side: isDark 
              ? BorderSide(color: Colors.white.withOpacity(0.1))
              : BorderSide.none,
        ),
      ),
      
      // 输入框主题
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: isDark 
            ? const Color(0xFF2C2C2C)
            : Colors.grey.withOpacity(0.1),
        border: OutlineInputBorder(
          borderRadius: _getPlatformBorderRadius(platform),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: _getPlatformBorderRadius(platform),
          borderSide: BorderSide(
            color: isDark ? Colors.white24 : Colors.grey.shade300,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: _getPlatformBorderRadius(platform),
          borderSide: const BorderSide(color: Colors.blue),
        ),
      ),
      
      // 按钮主题
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: _getPlatformBorderRadius(platform),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        ),
      ),
      
      // 底部导航栏主题
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: isDark 
            ? const Color(0xFF1E1E1E)
            : Colors.white,
        selectedItemColor: Colors.blue,
        unselectedItemColor: isDark ? Colors.white54 : Colors.grey,
      ),
      
      // 对话框主题
      dialogTheme: DialogThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: _getPlatformDialogRadius(platform),
        ),
        backgroundColor: isDark 
            ? const Color(0xFF2C2C2C)
            : Colors.white,
      ),
      
      // 底部表单主题
      bottomSheetTheme: BottomSheetThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(platform == TargetPlatform.android ? 28 : 16),
          ),
        ),
        backgroundColor: isDark 
            ? const Color(0xFF2C2C2C)
            : Colors.white,
      ),
      
      // 分隔线主题
      dividerTheme: DividerThemeData(
        color: isDark ? Colors.white24 : Colors.grey.shade300,
        thickness: 1,
      ),
    );
  }

  /// 获取平台特定的圆角半径
  BorderRadius _getPlatformBorderRadius(TargetPlatform platform) {
    switch (platform) {
      case TargetPlatform.iOS:
      case TargetPlatform.macOS:
        return BorderRadius.circular(12);
      case TargetPlatform.android:
        return BorderRadius.circular(8);
      case TargetPlatform.windows:
        return BorderRadius.circular(4);
      default:
        return BorderRadius.circular(8);
    }
  }

  /// 获取平台特定的对话框圆角半径
  BorderRadius _getPlatformDialogRadius(TargetPlatform platform) {
    switch (platform) {
      case TargetPlatform.iOS:
      case TargetPlatform.macOS:
        return BorderRadius.circular(14);
      case TargetPlatform.android:
        return BorderRadius.circular(28);
      case TargetPlatform.windows:
        return BorderRadius.circular(8);
      default:
        return BorderRadius.circular(12);
    }
  }

  /// 获取平台特定的滚动行为
  ScrollBehavior _getPlatformScrollBehavior() {
    return MaterialScrollBehavior().copyWith(
      dragDevices: {
        PointerDeviceKind.mouse,
        PointerDeviceKind.touch,
        PointerDeviceKind.trackpad,
      },
    );
  }
}

/// 读取本地存储的 Token，决定初始页面
Future<String> _getInitialRoute() async {
  AuthService authService = AuthService();
  bool isLoggedIn = await authService.isLoggedIn();
  return isLoggedIn ? '/home' : '/login';
}
