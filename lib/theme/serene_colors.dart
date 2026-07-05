import 'package:flutter/material.dart';

/// Serene Guardian 设计系统颜色配置
/// 基于 stitch 项目的 DESIGN.md 完全还原
class SereneColors {
  SereneColors._();

  // ==================== 基础表面色 ====================
  static const Color surface = Color(0xFFFAF8FF);
  static const Color surfaceDim = Color(0xFFD6D9EF);
  static const Color surfaceBright = Color(0xFFFAF8FF);
  static const Color surfaceContainerLowest = Color(0xFFFFFFFF);
  static const Color surfaceContainerLow = Color(0xFFF3F2FF);
  static const Color surfaceContainer = Color(0xFFEBEDFF);
  static const Color surfaceContainerHigh = Color(0xFFE4E7FE);
  static const Color surfaceContainerHighest = Color(0xFFDEE1F8);
  static const Color surfaceVariant = Color(0xFFDEE1F8);
  static const Color surfaceTint = Color(0xFF3B6376);

  // ==================== 文字色 ====================
  static const Color onSurface = Color(0xFF171B2B);
  static const Color onSurfaceVariant = Color(0xFF41484C);
  static const Color onBackground = Color(0xFF171B2B);
  static const Color inverseSurface = Color(0xFF2C3041);
  static const Color inverseOnSurface = Color(0xFFEFF0FF);

  // ==================== 主色调 (Gentle Blue) ====================
  static const Color primary = Color(0xFF3B6376);
  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color primaryContainer = Color(0xFFA8D1E7);
  static const Color onPrimaryContainer = Color(0xFF325A6D);
  static const Color inversePrimary = Color(0xFFA3CCE2);
  static const Color primaryFixed = Color(0xFFBFE8FF);
  static const Color primaryFixedDim = Color(0xFFA3CCE2);
  static const Color onPrimaryFixed = Color(0xFF001F2A);
  static const Color onPrimaryFixedVariant = Color(0xFF224C5E);

  // ==================== 次要色 (Warm Peach) ====================
  static const Color secondary = Color(0xFF755844);
  static const Color onSecondary = Color(0xFFFFFFFF);
  static const Color secondaryContainer = Color(0xFFFFD8BE);
  static const Color onSecondaryContainer = Color(0xFF7A5D48);
  static const Color secondaryFixed = Color(0xFFFFDCC5);
  static const Color secondaryFixedDim = Color(0xFFE4BFA6);
  static const Color onSecondaryFixed = Color(0xFF2B1707);
  static const Color onSecondaryFixedVariant = Color(0xFF5B412E);

  // ==================== 第三色 (Natural Green) ====================
  static const Color tertiary = Color(0xFF566246);
  static const Color onTertiary = Color(0xFFFFFFFF);
  static const Color tertiaryContainer = Color(0xFFC2D0AD);
  static const Color onTertiaryContainer = Color(0xFF4D593D);
  static const Color tertiaryFixed = Color(0xFFDAE8C3);
  static const Color tertiaryFixedDim = Color(0xFFBECBA8);
  static const Color onTertiaryFixed = Color(0xFF141F08);
  static const Color onTertiaryFixedVariant = Color(0xFF3F4B30);

  // ==================== 错误色 ====================
  static const Color error = Color(0xFFBA1A1A);
  static const Color onError = Color(0xFFFFFFFF);
  static const Color errorContainer = Color(0xFFFFDAD6);
  static const Color onErrorContainer = Color(0xFF93000A);

  // ==================== 轮廓色 ====================
  static const Color outline = Color(0xFF71787C);
  static const Color outlineVariant = Color(0xFFC1C7CC);

  // ==================== 背景色 ====================
  static const Color background = Color(0xFFFAF8FF);

  // ==================== 特殊用途颜色 ====================
  /// 安全状态指示色
  static const Color safe = Color(0xFF4CAF50);
  static const Color safeContainer = Color(0xFFE8F5E9);

  /// 警告状态指示色
  static const Color warning = Color(0xFFFF9800);
  static const Color warningContainer = Color(0xFFFFF3E0);

  /// 危险状态指示色
  static const Color danger = Color(0xFFF44336);
  static const Color dangerContainer = Color(0xFFFFEBEE);

  /// 睡眠状态色
  static const Color sleepAccent = Color(0xFFFFD8BE);

  /// 活跃状态色
  static const Color activeAccent = Color(0xFFA8D1E7);

  // ==================== 玻璃效果颜色 ====================
  /// 玻璃面板背景色 (70% opacity)
  static const Color glassBackground = Color(0xB3FFFFFF); // rgba(255, 255, 255, 0.7)

  /// 玻璃浮动元素背景色 (80% opacity)
  static const Color glassFloatBackground = Color(0xCCFFFFFF); // rgba(255, 255, 255, 0.8)

  /// 玻璃边框色 (20% opacity)
  static const Color glassBorder = Color(0x33FFFFFF); // rgba(255, 255, 255, 0.2)

  /// 玻璃阴影色
  static const Color glassShadow = Color(0x0D000000); // rgba(0, 0, 0, 0.05)

  /// 抽屉遮罩色
  static const Color drawerOverlay = Color(0x4D000000); // rgba(0, 0, 0, 0.3)

  // ==================== 渐变色 ====================
  /// 主背景渐变
  static const LinearGradient backgroundGradient = LinearGradient(
    colors: [Color(0xFFE3FDFD), Color(0xFFFFE6FA)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// 主色调渐变
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, Color(0xFF4A7D94)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// 次要色渐变
  static const LinearGradient secondaryGradient = LinearGradient(
    colors: [secondary, Color(0xFF8B6B55)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
