import 'package:flutter/material.dart';

/// Serene Guardian 设计系统字体配置
/// 基于 stitch 项目的 DESIGN.md 完全还原
class SereneTypography {
  SereneTypography._();

  /// 字体族
  static const String fontFamily = 'Inter';

  // ==================== 标题样式 ====================
  /// 大标题 - 32px, Bold, -0.02em letter spacing
  static const TextStyle headlineLarge = TextStyle(
    fontFamily: fontFamily,
    fontSize: 32,
    fontWeight: FontWeight.w700,
    height: 40 / 32, // lineHeight / fontSize
    letterSpacing: -0.02,
  );

  /// 中标题 - 24px, Semi-bold, -0.01em letter spacing
  static const TextStyle headlineMedium = TextStyle(
    fontFamily: fontFamily,
    fontSize: 24,
    fontWeight: FontWeight.w600,
    height: 32 / 24,
    letterSpacing: -0.01,
  );

  /// 小标题 - 20px, Semi-bold
  static const TextStyle headlineSmall = TextStyle(
    fontFamily: fontFamily,
    fontSize: 20,
    fontWeight: FontWeight.w600,
    height: 28 / 20,
    letterSpacing: 0,
  );

  /// 移动端大标题 - 28px, Bold
  static const TextStyle headlineLargeMobile = TextStyle(
    fontFamily: fontFamily,
    fontSize: 28,
    fontWeight: FontWeight.w700,
    height: 36 / 28,
    letterSpacing: 0,
  );

  // ==================== 正文样式 ====================
  /// 大正文 - 18px, Regular
  static const TextStyle bodyLarge = TextStyle(
    fontFamily: fontFamily,
    fontSize: 18,
    fontWeight: FontWeight.w400,
    height: 28 / 18,
    letterSpacing: 0,
  );

  /// 中正文 - 16px, Regular
  static const TextStyle bodyMedium = TextStyle(
    fontFamily: fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w400,
    height: 24 / 16,
    letterSpacing: 0,
  );

  /// 小正文 - 14px, Regular
  static const TextStyle bodySmall = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 20 / 14,
    letterSpacing: 0,
  );

  // ==================== 标签样式 ====================
  /// 大标签 - 14px, Semi-bold, 0.01em letter spacing
  static const TextStyle labelLarge = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w600,
    height: 20 / 14,
    letterSpacing: 0.01,
  );

  /// 中标签 - 12px, Medium, 0.04em letter spacing
  static const TextStyle labelMedium = TextStyle(
    fontFamily: fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w500,
    height: 16 / 12,
    letterSpacing: 0.04,
  );

  // ==================== 特殊用途样式 ====================
  /// 状态标签样式（大写显示）
  static const TextStyle statusLabel = TextStyle(
    fontFamily: fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w600,
    height: 16 / 12,
    letterSpacing: 0.08,
  );

  /// 数据展示样式（用于心率、温度等）
  static const TextStyle dataDisplay = TextStyle(
    fontFamily: fontFamily,
    fontSize: 36,
    fontWeight: FontWeight.w700,
    height: 44 / 36,
    letterSpacing: -0.02,
  );

  /// 数据标签样式
  static const TextStyle dataLabel = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w500,
    height: 20 / 14,
    letterSpacing: 0.01,
  );

  /// 按钮文字样式
  static const TextStyle button = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w600,
    height: 20 / 14,
    letterSpacing: 0.01,
  );

  /// 导航标签样式
  static const TextStyle navigationLabel = TextStyle(
    fontFamily: fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w500,
    height: 16 / 12,
    letterSpacing: 0.04,
  );
}
