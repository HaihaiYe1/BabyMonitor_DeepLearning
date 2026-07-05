import 'package:flutter/material.dart';

/// Serene Guardian 设计系统间距配置
/// 基于 stitch 项目的 DESIGN.md 完全还原
class SereneSpacing {
  SereneSpacing._();

  // ==================== 基础间距 ====================
  /// 4px - 最小间距
  static const double xs = 4.0;

  /// 8px - 小间距
  static const double sm = 8.0;

  /// 16px - 中间距
  static const double md = 16.0;

  /// 24px - 大间距
  static const double lg = 24.0;

  /// 32px - 超大间距
  static const double xl = 32.0;

  /// 16px - 内容间距
  static const double gutter = 16.0;

  /// 20px - 移动端边距
  static const double marginMobile = 20.0;

  /// 40px - 桌面端边距
  static const double marginDesktop = 40.0;

  // ==================== 组件间距 ====================
  /// 卡片内边距
  static const double cardPadding = 20.0;

  /// 列表项间距
  static const double listItemGap = 12.0;

  /// 按钮内边距
  static const EdgeInsets buttonPadding = EdgeInsets.symmetric(
    horizontal: 24,
    vertical: 12,
  );

  /// 图标按钮内边距
  static const EdgeInsets iconButtonPadding = EdgeInsets.all(8);

  /// 输入框内边距
  static const EdgeInsets inputPadding = EdgeInsets.symmetric(
    horizontal: 16,
    vertical: 14,
  );

  // ==================== 圆角配置 ====================
  /// 小圆角 - 4px
  static const double radiusSm = 4.0;

  /// 默认圆角 - 8px
  static const double radiusDefault = 8.0;

  /// 中圆角 - 12px
  static const double radiusMd = 12.0;

  /// 大圆角 - 16px
  static const double radiusLg = 16.0;

  /// 超大圆角 - 24px
  static const double radiusXl = 24.0;

  /// 全圆角
  static const double radiusFull = 9999.0;

  // ==================== BorderRadius 预设 ====================
  /// 小圆角 BorderRadius
  static final BorderRadius borderRadiusSm = BorderRadius.circular(radiusSm);

  /// 默认圆角 BorderRadius
  static final BorderRadius borderRadiusDefault = BorderRadius.circular(radiusDefault);

  /// 中圆角 BorderRadius
  static final BorderRadius borderRadiusMd = BorderRadius.circular(radiusMd);

  /// 大圆角 BorderRadius
  static final BorderRadius borderRadiusLg = BorderRadius.circular(radiusLg);

  /// 超大圆角 BorderRadius
  static final BorderRadius borderRadiusXl = BorderRadius.circular(radiusXl);

  /// 全圆角 BorderRadius
  static final BorderRadius borderRadiusFull = BorderRadius.circular(radiusFull);

  // ==================== 组件特定圆角 ====================
  /// 卡片圆角
  static final BorderRadius cardRadius = BorderRadius.circular(radiusXl);

  /// 按钮圆角
  static final BorderRadius buttonRadius = BorderRadius.circular(radiusLg);

  /// 输入框圆角
  static final BorderRadius inputRadius = BorderRadius.circular(radiusMd);

  /// 底部导航栏圆角
  static final BorderRadius bottomNavRadius = const BorderRadius.vertical(
    top: Radius.circular(radiusXl),
  );

  /// 抽屉圆角
  static final BorderRadius drawerRadius = const BorderRadius.horizontal(
    right: Radius.circular(radiusXl),
  );

  /// 芯片圆角
  static final BorderRadius chipRadius = BorderRadius.circular(radiusFull);

  /// 对话框圆角
  static final BorderRadius dialogRadius = BorderRadius.circular(radiusXl);

  /// 底部表单圆角
  static final BorderRadius bottomSheetRadius = const BorderRadius.vertical(
    top: Radius.circular(radiusXl),
  );
}
