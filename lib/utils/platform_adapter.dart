import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// 平台适配工具类
class PlatformAdapter {
  /// 获取平台特定的主题
  static ThemeData getPlatformTheme(BuildContext context) {
    final platform = defaultTargetPlatform;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    switch (platform) {
      case TargetPlatform.iOS:
      case TargetPlatform.macOS:
        return _getCupertinoTheme(isDark);
      case TargetPlatform.android:
        return _getMaterialTheme(isDark);
      case TargetPlatform.windows:
        return _getWindowsTheme(isDark);
      default:
        return _getMaterialTheme(isDark);
    }
  }

  /// 获取Cupertino主题
  static ThemeData _getCupertinoTheme(bool isDark) {
    return ThemeData(
      useMaterial3: true,
      colorSchemeSeed: Colors.blue,
      brightness: isDark ? Brightness.dark : Brightness.light,
      fontFamily: 'SF Pro Display',
      cardTheme: CardTheme(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: isDark ? Colors.white24 : Colors.grey.shade200,
          ),
        ),
      ),
      appBarTheme: AppBarTheme(
        elevation: 0,
        centerTitle: true,
        backgroundColor: isDark ? Colors.black : Colors.white,
        foregroundColor: isDark ? Colors.white : Colors.black,
      ),
    );
  }

  /// 获取Material主题
  static ThemeData _getMaterialTheme(bool isDark) {
    return ThemeData(
      useMaterial3: true,
      colorSchemeSeed: Colors.blue,
      brightness: isDark ? Brightness.dark : Brightness.light,
      fontFamily: 'Roboto',
      cardTheme: CardTheme(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      appBarTheme: AppBarTheme(
        elevation: 0,
        centerTitle: false,
        backgroundColor: isDark ? Colors.black : Colors.white,
        foregroundColor: isDark ? Colors.white : Colors.black,
      ),
    );
  }

  /// 获取Windows主题
  static ThemeData _getWindowsTheme(bool isDark) {
    return ThemeData(
      useMaterial3: true,
      colorSchemeSeed: Colors.blue,
      brightness: isDark ? Brightness.dark : Brightness.light,
      fontFamily: 'Segoe UI',
      cardTheme: CardTheme(
        elevation: 1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4),
        ),
      ),
      appBarTheme: AppBarTheme(
        elevation: 0,
        centerTitle: false,
        backgroundColor: isDark ? const Color(0xFF202020) : Colors.white,
        foregroundColor: isDark ? Colors.white : Colors.black,
      ),
    );
  }

  /// 设置系统UI样式
  static void setSystemUIStyle({
    Brightness? statusBarBrightness,
    Brightness? statusBarIconBrightness,
    Color? statusBarColor,
    Color? systemNavigationBarColor,
  }) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarBrightness: statusBarBrightness ?? Brightness.light,
      statusBarIconBrightness: statusBarIconBrightness ?? Brightness.dark,
      statusBarColor: statusBarColor ?? Colors.transparent,
      systemNavigationBarColor: systemNavigationBarColor ?? Colors.white,
    ));
  }

  /// 获取平台特定的页面过渡动画
  static Widget getPlatformPageTransition({
    required Widget child,
    required Animation<double> animation,
    required Animation<double> secondaryAnimation,
  }) {
    final platform = defaultTargetPlatform;
    
    switch (platform) {
      case TargetPlatform.iOS:
      case TargetPlatform.macOS:
        return CupertinoPageTransition(
          primaryRouteAnimation: animation,
          secondaryRouteAnimation: secondaryAnimation,
          linearTransition: false,
          child: child,
        );
      case TargetPlatform.android:
      case TargetPlatform.windows:
      case TargetPlatform.linux:
        return FadeTransition(
          opacity: animation,
          child: child,
        );
      default:
        return FadeTransition(
          opacity: animation,
          child: child,
        );
    }
  }

  /// 获取平台特定的返回按钮图标
  static IconData getPlatformBackIcon() {
    final platform = defaultTargetPlatform;
    switch (platform) {
      case TargetPlatform.iOS:
      case TargetPlatform.macOS:
        return Icons.arrow_back_ios;
      case TargetPlatform.android:
      case TargetPlatform.windows:
      case TargetPlatform.linux:
        return Icons.arrow_back;
      default:
        return Icons.arrow_back;
    }
  }

  /// 获取平台特定的菜单图标
  static IconData getPlatformMenuIcon() {
    final platform = defaultTargetPlatform;
    switch (platform) {
      case TargetPlatform.iOS:
      case TargetPlatform.macOS:
        return Icons.menu;
      case TargetPlatform.android:
        return Icons.menu;
      case TargetPlatform.windows:
        return Icons.menu;
      default:
        return Icons.menu;
    }
  }

  /// 获取平台特定的更多选项图标
  static IconData getPlatformMoreIcon() {
    final platform = defaultTargetPlatform;
    switch (platform) {
      case TargetPlatform.iOS:
      case TargetPlatform.macOS:
        return Icons.more_horiz;
      case TargetPlatform.android:
        return Icons.more_vert;
      case TargetPlatform.windows:
        return Icons.more_vert;
      default:
        return Icons.more_vert;
    }
  }

  /// 获取平台特定的搜索图标
  static IconData getPlatformSearchIcon() {
    return Icons.search;
  }

  /// 获取平台特定的设置图标
  static IconData getPlatformSettingsIcon() {
    final platform = defaultTargetPlatform;
    switch (platform) {
      case TargetPlatform.iOS:
      case TargetPlatform.macOS:
        return Icons.settings;
      case TargetPlatform.android:
        return Icons.settings;
      case TargetPlatform.windows:
        return Icons.settings;
      default:
        return Icons.settings;
    }
  }

  /// 平台特定的震动反馈
  static void hapticFeedback() {
    final platform = defaultTargetPlatform;
    switch (platform) {
      case TargetPlatform.iOS:
      case TargetPlatform.android:
        HapticFeedback.lightImpact();
        break;
      default:
        break;
    }
  }

  /// 平台特定的选择反馈
  static void selectionFeedback() {
    final platform = defaultTargetPlatform;
    switch (platform) {
      case TargetPlatform.iOS:
      case TargetPlatform.android:
        HapticFeedback.selectionClick();
        break;
      default:
        break;
    }
  }

  /// 获取平台特定的对话框样式
  static ShapeBorder getPlatformDialogShape() {
    final platform = defaultTargetPlatform;
    switch (platform) {
      case TargetPlatform.iOS:
      case TargetPlatform.macOS:
        return RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        );
      case TargetPlatform.android:
        return RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(28),
        );
      case TargetPlatform.windows:
        return RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        );
      default:
        return RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        );
    }
  }

  /// 获取平台特定的底部表单样式
  static ShapeBorder getPlatformBottomSheetShape() {
    final platform = defaultTargetPlatform;
    switch (platform) {
      case TargetPlatform.iOS:
      case TargetPlatform.macOS:
        return const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(12),
          ),
        );
      case TargetPlatform.android:
        return const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(28),
          ),
        );
      default:
        return const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(16),
          ),
        );
    }
  }
}
