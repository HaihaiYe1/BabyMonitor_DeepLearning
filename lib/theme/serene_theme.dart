import 'package:flutter/material.dart';
import 'serene_colors.dart';
import 'serene_typography.dart';
import 'serene_spacing.dart';
import '../widgets/glass_widgets.dart';

/// Serene Guardian 完整主题配置
/// 基于 stitch 项目的 DESIGN.md 完全还原
class SereneTheme {
  SereneTheme._();

  /// 构建完整的 ThemeData
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      fontFamily: SereneTypography.fontFamily,

      // 颜色方案
      colorScheme: const ColorScheme.light(
        primary: SereneColors.primary,
        onPrimary: SereneColors.onPrimary,
        primaryContainer: SereneColors.primaryContainer,
        onPrimaryContainer: SereneColors.onPrimaryContainer,
        secondary: SereneColors.secondary,
        onSecondary: SereneColors.onSecondary,
        secondaryContainer: SereneColors.secondaryContainer,
        onSecondaryContainer: SereneColors.onSecondaryContainer,
        tertiary: SereneColors.tertiary,
        onTertiary: SereneColors.onTertiary,
        tertiaryContainer: SereneColors.tertiaryContainer,
        onTertiaryContainer: SereneColors.onTertiaryContainer,
        error: SereneColors.error,
        onError: SereneColors.onError,
        errorContainer: SereneColors.errorContainer,
        onErrorContainer: SereneColors.onErrorContainer,
        surface: SereneColors.surface,
        onSurface: SereneColors.onSurface,
        onSurfaceVariant: SereneColors.onSurfaceVariant,
        outline: SereneColors.outline,
        outlineVariant: SereneColors.outlineVariant,
        inverseSurface: SereneColors.inverseSurface,
        onInverseSurface: SereneColors.inverseOnSurface,
        inversePrimary: SereneColors.inversePrimary,
        surfaceTint: SereneColors.surfaceTint,
      ),

      // 脚手架背景
      scaffoldBackgroundColor: SereneColors.surface,

      // 文字主题
      textTheme: const TextTheme(
        displayLarge: SereneTypography.headlineLarge,
        displayMedium: SereneTypography.headlineMedium,
        displaySmall: SereneTypography.headlineSmall,
        headlineLarge: SereneTypography.headlineLarge,
        headlineMedium: SereneTypography.headlineMedium,
        headlineSmall: SereneTypography.headlineSmall,
        titleLarge: SereneTypography.headlineSmall,
        titleMedium: SereneTypography.bodyLarge,
        titleSmall: SereneTypography.bodyMedium,
        bodyLarge: SereneTypography.bodyLarge,
        bodyMedium: SereneTypography.bodyMedium,
        bodySmall: SereneTypography.bodySmall,
        labelLarge: SereneTypography.labelLarge,
        labelMedium: SereneTypography.labelMedium,
        labelSmall: SereneTypography.labelMedium,
      ),

      // AppBar 主题
      appBarTheme: AppBarTheme(
        backgroundColor: SereneColors.surface.withOpacity(0.7),
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(
          color: SereneColors.primary,
        ),
        titleTextStyle: SereneTypography.headlineSmall.copyWith(
          color: SereneColors.primary,
        ),
      ),

      // 卡片主题
      cardTheme: CardThemeData(
        color: Colors.white.withOpacity(0.7),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: SereneSpacing.cardRadius,
          side: BorderSide(
            color: SereneColors.glassBorder,
            width: 1,
          ),
        ),
        margin: const EdgeInsets.all(SereneSpacing.sm),
      ),

      // 输入框主题
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: SereneColors.primary.withOpacity(0.05),
        border: OutlineInputBorder(
          borderRadius: SereneSpacing.inputRadius,
          borderSide: BorderSide(
            color: SereneColors.outlineVariant,
            width: 1,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: SereneSpacing.inputRadius,
          borderSide: BorderSide(
            color: SereneColors.outlineVariant,
            width: 1,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: SereneSpacing.inputRadius,
          borderSide: const BorderSide(
            color: SereneColors.primary,
            width: 2,
          ),
        ),
        contentPadding: SereneSpacing.inputPadding,
      ),

      // 按钮主题
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: SereneColors.primaryContainer,
          foregroundColor: SereneColors.onPrimaryContainer,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: SereneSpacing.buttonRadius,
          ),
          padding: SereneSpacing.buttonPadding,
        ),
      ),

      // 底部导航栏主题
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Colors.transparent,
        elevation: 0,
        selectedItemColor: SereneColors.primary,
        unselectedItemColor: SereneColors.onSurfaceVariant,
        type: BottomNavigationBarType.fixed,
      ),

      // 对话框主题
      dialogTheme: DialogThemeData(
        backgroundColor: SereneColors.surfaceContainerLowest,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: SereneSpacing.dialogRadius,
          side: BorderSide(
            color: SereneColors.glassBorder,
            width: 1,
          ),
        ),
      ),

      // 底部表单主题
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: SereneColors.surfaceContainerLowest,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: SereneSpacing.bottomSheetRadius,
          side: BorderSide(
            color: SereneColors.glassBorder,
            width: 1,
          ),
        ),
      ),

      // 芯片主题
      chipTheme: ChipThemeData(
        backgroundColor: Colors.white.withOpacity(0.7),
        selectedColor: SereneColors.primaryContainer,
        disabledColor: SereneColors.surfaceContainer,
        labelStyle: SereneTypography.labelMedium,
        shape: RoundedRectangleBorder(
          borderRadius: SereneSpacing.chipRadius,
          side: BorderSide(
            color: SereneColors.glassBorder,
            width: 1,
          ),
        ),
      ),

      // 分隔线主题
      dividerTheme: const DividerThemeData(
        color: SereneColors.outlineVariant,
        thickness: 1,
        space: 1,
      ),

      // 图标主题
      iconTheme: const IconThemeData(
        color: SereneColors.onSurface,
        size: 24,
      ),

      // 列表瓦片主题
      listTileTheme: const ListTileThemeData(
        contentPadding: EdgeInsets.symmetric(
          horizontal: SereneSpacing.md,
          vertical: SereneSpacing.sm,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(SereneSpacing.radiusMd),
          ),
        ),
      ),
    );
  }

  /// 暗色主题（可选）
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      fontFamily: SereneTypography.fontFamily,
      // 暗色主题配置可以根据需要扩展
    );
  }
}
