import 'package:flutter/material.dart';

/// 应用常量
class AppConstants {
  AppConstants._();
  
  // 渐变颜色
  static const LinearGradient backgroundGradient = LinearGradient(
    colors: [Color(0xFFE3FDFD), Color(0xFFFFE6FA)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient drawerGradient = LinearGradient(
    colors: [Color(0xFF89F7FE), Color(0xFF66A6FF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  // 常用颜色
  static const Color primaryBlue = Colors.blue;
  static const Color primaryGreen = Colors.green;
  static const Color primaryRed = Colors.red;
  static const Color primaryOrange = Colors.orange;
  static const Color primaryPurple = Colors.purple;
  
  // 卡片颜色
  static const Color cardColor = Colors.white;
  static const Color cardShadowColor = Colors.black12;
  
  // 文字颜色
  static const Color textPrimary = Colors.black87;
  static const Color textSecondary = Colors.grey;
  
  // 圆角半径
  static const double borderRadiusSmall = 8.0;
  static const double borderRadiusMedium = 12.0;
  static const double borderRadiusLarge = 16.0;
  static const double borderRadiusXLarge = 20.0;
  
  // 间距
  static const double spacingXSmall = 4.0;
  static const double spacingSmall = 8.0;
  static const double spacingMedium = 16.0;
  static const double spacingLarge = 24.0;
  static const double spacingXLarge = 32.0;
}

/// 通用卡片组件
class AppCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final double? borderRadius;
  final Color? color;
  final List<BoxShadow>? boxShadow;

  const AppCard({
    Key? key,
    required this.child,
    this.padding,
    this.margin,
    this.borderRadius,
    this.color,
    this.boxShadow,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin ?? const EdgeInsets.symmetric(vertical: 6.0),
      decoration: BoxDecoration(
        color: color ?? AppConstants.cardColor,
        borderRadius: BorderRadius.circular(borderRadius ?? AppConstants.borderRadiusMedium),
        boxShadow: boxShadow ?? [
          BoxShadow(
            color: AppConstants.cardShadowColor,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: child,
    );
  }
}

/// 渐变背景容器
class GradientBackground extends StatelessWidget {
  final Widget child;
  final LinearGradient? gradient;

  const GradientBackground({
    Key? key,
    required this.child,
    this.gradient,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: gradient ?? AppConstants.backgroundGradient,
      ),
      child: child,
    );
  }
}

/// 状态指示器
class StatusIndicator extends StatelessWidget {
  final String label;
  final bool isActive;
  final Color? activeColor;
  final Color? inactiveColor;

  const StatusIndicator({
    Key? key,
    required this.label,
    required this.isActive,
    this.activeColor,
    this.inactiveColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: (isActive ? activeColor ?? Colors.green : inactiveColor ?? Colors.red)
            .withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppConstants.borderRadiusSmall),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          color: isActive ? activeColor ?? Colors.green : inactiveColor ?? Colors.red,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

/// 加载按钮
class LoadingButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback? onPressed;
  final bool isLoading;
  final Color? color;
  final Color? textColor;

  const LoadingButton({
    Key? key,
    required this.label,
    required this.icon,
    this.onPressed,
    this.isLoading = false,
    this.color,
    this.textColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: isLoading ? null : onPressed,
      icon: isLoading
          ? const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : Icon(icon),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: color ?? AppConstants.primaryBlue,
        foregroundColor: textColor ?? Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
        ),
      ),
    );
  }
}

/// 空状态占位符
class EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final double iconSize;

  const EmptyState({
    Key? key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.iconSize = 64,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: iconSize, color: Colors.grey[400]),
          const SizedBox(height: AppConstants.spacingMedium),
          Text(
            title,
            style: TextStyle(fontSize: 18, color: Colors.grey[600]),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: AppConstants.spacingSmall),
            Text(
              subtitle!,
              style: TextStyle(fontSize: 14, color: Colors.grey[500]),
            ),
          ],
        ],
      ),
    );
  }
}

/// 统计卡片
class StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const StatCard({
    Key? key,
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.spacingMedium),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: AppConstants.spacingSmall),
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: AppConstants.spacingXSmall),
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 表单项
class FormField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final String? hintText;
  final int maxLines;
  final TextInputType? keyboardType;
  final bool obscureText;
  final Widget? suffixIcon;

  const FormField({
    Key? key,
    required this.label,
    required this.controller,
    this.hintText,
    this.maxLines = 1,
    this.keyboardType,
    this.obscureText = false,
    this.suffixIcon,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: AppConstants.textPrimary,
          ),
        ),
        const SizedBox(height: AppConstants.spacingSmall),
        TextField(
          controller: controller,
          maxLines: maxLines,
          keyboardType: keyboardType,
          obscureText: obscureText,
          decoration: InputDecoration(
            hintText: hintText,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
            ),
            filled: true,
            fillColor: Colors.grey[50],
            suffixIcon: suffixIcon,
          ),
        ),
      ],
    );
  }
}
