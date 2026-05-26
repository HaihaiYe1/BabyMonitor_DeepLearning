import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// 响应式布局工具类
class ResponsiveLayout {
  // 断点定义
  static const double mobileBreakpoint = 600;
  static const double tabletBreakpoint = 900;
  static const double desktopBreakpoint = 1200;
  static const double largeDesktopBreakpoint = 1800;

  /// 获取设备类型
  static DeviceType getDeviceType(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width < mobileBreakpoint) {
      return DeviceType.mobile;
    } else if (width < tabletBreakpoint) {
      return DeviceType.tablet;
    } else if (width < desktopBreakpoint) {
      return DeviceType.desktop;
    } else {
      return DeviceType.largeDesktop;
    }
  }

  /// 是否是移动端
  static bool isMobile(BuildContext context) {
    return getDeviceType(context) == DeviceType.mobile;
  }

  /// 是否是平板
  static bool isTablet(BuildContext context) {
    return getDeviceType(context) == DeviceType.tablet;
  }

  /// 是否是桌面端
  static bool isDesktop(BuildContext context) {
    final deviceType = getDeviceType(context);
    return deviceType == DeviceType.desktop || deviceType == DeviceType.largeDesktop;
  }

  /// 是否是Web平台
  static bool isWeb() {
    return kIsWeb;
  }

  /// 获取当前平台
  static AppPlatform getCurrentPlatform() {
    if (kIsWeb) return AppPlatform.web;
    
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return AppPlatform.android;
      case TargetPlatform.iOS:
        return AppPlatform.ios;
      case TargetPlatform.macOS:
        return AppPlatform.macos;
      case TargetPlatform.windows:
        return AppPlatform.windows;
      case TargetPlatform.linux:
        return AppPlatform.linux;
      case TargetPlatform.fuchsia:
        return AppPlatform.fuchsia;
    }
  }

  /// 获取响应式值
  static T getResponsiveValue<T>(
    BuildContext context, {
    required T mobile,
    T? tablet,
    T? desktop,
    T? largeDesktop,
  }) {
    final deviceType = getDeviceType(context);
    switch (deviceType) {
      case DeviceType.mobile:
        return mobile;
      case DeviceType.tablet:
        return tablet ?? mobile;
      case DeviceType.desktop:
        return desktop ?? tablet ?? mobile;
      case DeviceType.largeDesktop:
        return largeDesktop ?? desktop ?? tablet ?? mobile;
    }
  }

  /// 获取响应式字体大小
  static double getResponsiveFontSize(
    BuildContext context, {
    required double mobile,
    double? tablet,
    double? desktop,
  }) {
    return getResponsiveValue(
      context,
      mobile: mobile,
      tablet: tablet,
      desktop: desktop,
    );
  }

  /// 获取响应式内边距
  static EdgeInsets getResponsivePadding(BuildContext context) {
    return getResponsiveValue(
      context,
      mobile: const EdgeInsets.all(16),
      tablet: const EdgeInsets.all(24),
      desktop: const EdgeInsets.all(32),
    );
  }

  /// 获取响应式网格列数
  static int getResponsiveGridColumns(BuildContext context) {
    return getResponsiveValue(
      context,
      mobile: 1,
      tablet: 2,
      desktop: 3,
      largeDesktop: 4,
    );
  }

  /// 获取响应式卡片宽度
  static double getResponsiveCardWidth(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    return getResponsiveValue(
      context,
      mobile: screenWidth - 32,
      tablet: (screenWidth - 72) / 2,
      desktop: (screenWidth - 112) / 3,
    );
  }

  /// 获取响应式容器高度
  static double getResponsiveContainerHeight(BuildContext context) {
    return getResponsiveValue(
      context,
      mobile: 200,
      tablet: 250,
      desktop: 300,
    );
  }

  /// 获取平台特定的圆角半径
  static BorderRadius getPlatformBorderRadius(BuildContext context) {
    final platform = getCurrentPlatform();
    switch (platform) {
      case AppPlatform.ios:
      case AppPlatform.macos:
        return BorderRadius.circular(12);
      case AppPlatform.android:
        return BorderRadius.circular(8);
      case AppPlatform.windows:
        return BorderRadius.circular(4);
      default:
        return BorderRadius.circular(8);
    }
  }

  /// 获取平台特定的阴影
  static List<BoxShadow> getPlatformShadow(BuildContext context) {
    final platform = getCurrentPlatform();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    switch (platform) {
      case AppPlatform.ios:
      case AppPlatform.macos:
        return [
          BoxShadow(
            color: isDark ? Colors.black54 : Colors.black12,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ];
      case AppPlatform.android:
        return [
          BoxShadow(
            color: isDark ? Colors.black54 : Colors.black26,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ];
      case AppPlatform.windows:
        return [
          BoxShadow(
            color: isDark ? Colors.black54 : Colors.black12,
            blurRadius: 6,
            offset: const Offset(0, 1),
          ),
        ];
      default:
        return [
          BoxShadow(
            color: isDark ? Colors.black54 : Colors.black12,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ];
    }
  }

  /// 获取平台特定的导航栏高度
  static double getPlatformNavBarHeight(BuildContext context) {
    final platform = getCurrentPlatform();
    switch (platform) {
      case AppPlatform.ios:
        return 44;
      case AppPlatform.android:
        return 56;
      case AppPlatform.macos:
        return 52;
      case AppPlatform.windows:
        return 48;
      default:
        return 56;
    }
  }

  /// 获取平台特定的状态栏高度
  static double getPlatformStatusBarHeight(BuildContext context) {
    return MediaQuery.of(context).padding.top;
  }

  /// 获取响应式侧边栏宽度
  static double getResponsiveDrawerWidth(BuildContext context) {
    return getResponsiveValue(
      context,
      mobile: MediaQuery.of(context).size.width * 0.85,
      tablet: 320,
      desktop: 360,
    );
  }

  /// 构建响应式布局
  static Widget buildResponsiveLayout({
    required BuildContext context,
    required Widget mobile,
    Widget? tablet,
    Widget? desktop,
  }) {
    final deviceType = getDeviceType(context);
    switch (deviceType) {
      case DeviceType.mobile:
        return mobile;
      case DeviceType.tablet:
        return tablet ?? mobile;
      case DeviceType.desktop:
      case DeviceType.largeDesktop:
        return desktop ?? tablet ?? mobile;
    }
  }
}

/// 设备类型枚举
enum DeviceType {
  mobile,
  tablet,
  desktop,
  largeDesktop,
}

/// 应用平台枚举
enum AppPlatform {
  android,
  ios,
  web,
  windows,
  macos,
  linux,
  fuchsia,
}
