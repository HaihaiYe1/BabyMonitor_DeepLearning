import 'dart:ui';
import 'package:flutter/material.dart';
import '../theme/serene_colors.dart';
import '../theme/serene_spacing.dart';

/// Serene Guardian 毛玻璃效果组件库
/// 完全还原 stitch 项目的 Glassmorphism 效果

/// 毛玻璃面板组件
/// 对应 stitch 的 .glass-panel 类
/// background: rgba(255, 255, 255, 0.7);
/// backdrop-filter: blur(30px);
/// border: 1px solid rgba(255, 255, 255, 0.2);
class GlassPanel extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final BorderRadius? borderRadius;
  final double? width;
  final double? height;
  final double opacity;
  final double blur;
  final Color? borderColor;
  final List<BoxShadow>? boxShadow;

  const GlassPanel({
    Key? key,
    required this.child,
    this.padding,
    this.margin,
    this.borderRadius,
    this.width,
    this.height,
    this.opacity = 0.7,
    this.blur = 30.0,
    this.borderColor,
    this.boxShadow,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      margin: margin,
      decoration: BoxDecoration(
        borderRadius: borderRadius ?? SereneSpacing.borderRadiusXl,
        boxShadow: boxShadow ?? [
          BoxShadow(
            color: SereneColors.glassShadow,
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: borderRadius ?? SereneSpacing.borderRadiusXl,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
          child: Container(
            padding: padding ?? const EdgeInsets.all(SereneSpacing.cardPadding),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(opacity),
              borderRadius: borderRadius ?? SereneSpacing.borderRadiusXl,
              border: Border.all(
                color: borderColor ?? SereneColors.glassBorder,
                width: 1,
              ),
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}

/// 毛玻璃浮动组件
/// 对应 stitch 的 .glass-float 类
/// background: rgba(255, 255, 255, 0.8);
/// backdrop-filter: blur(20px);
/// box-shadow: 0 4px 20px rgba(0, 0, 0, 0.05);
class GlassFloat extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final BorderRadius? borderRadius;
  final double? width;
  final double? height;
  final VoidCallback? onTap;

  const GlassFloat({
    Key? key,
    required this.child,
    this.padding,
    this.margin,
    this.borderRadius,
    this.width,
    this.height,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: width,
        height: height,
        margin: margin,
        decoration: BoxDecoration(
          borderRadius: borderRadius ?? SereneSpacing.borderRadiusFull,
          boxShadow: [
            BoxShadow(
              color: SereneColors.glassShadow,
              blurRadius: 20,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: borderRadius ?? SereneSpacing.borderRadiusFull,
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: Container(
              padding: padding ?? const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 8,
              ),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.8),
                borderRadius: borderRadius ?? SereneSpacing.borderRadiusFull,
                border: Border.all(
                  color: SereneColors.glassBorder,
                  width: 1,
                ),
              ),
              child: child,
            ),
          ),
        ),
      ),
    );
  }
}

/// 毛玻璃卡片组件
/// 专门用于内容卡片展示
class GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final BorderRadius? borderRadius;
  final double? width;
  final double? height;
  final VoidCallback? onTap;
  final Color? tintColor;

  const GlassCard({
    Key? key,
    required this.child,
    this.padding,
    this.margin,
    this.borderRadius,
    this.width,
    this.height,
    this.onTap,
    this.tintColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: width,
        height: height,
        margin: margin,
        decoration: BoxDecoration(
          borderRadius: borderRadius ?? SereneSpacing.borderRadiusXl,
          boxShadow: [
            BoxShadow(
              color: SereneColors.glassShadow,
              blurRadius: 15,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: borderRadius ?? SereneSpacing.borderRadiusXl,
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
            child: Container(
              padding: padding ?? const EdgeInsets.all(SereneSpacing.cardPadding),
              decoration: BoxDecoration(
                color: (tintColor ?? Colors.white).withOpacity(0.7),
                borderRadius: borderRadius ?? SereneSpacing.borderRadiusXl,
                border: Border.all(
                  color: SereneColors.glassBorder,
                  width: 1,
                ),
              ),
              child: child,
            ),
          ),
        ),
      ),
    );
  }
}

/// 毛玻璃底部导航栏
class GlassBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final List<GlassBottomNavItem> items;

  const GlassBottomNavBar({
    Key? key,
    required this.currentIndex,
    required this.onTap,
    required this.items,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: SereneSpacing.bottomNavRadius,
        border: Border.all(
          color: Colors.white.withOpacity(0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: SereneSpacing.bottomNavRadius,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: BottomNavigationBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            currentIndex: currentIndex,
            onTap: onTap,
            selectedItemColor: SereneColors.primary,
            unselectedItemColor: SereneColors.onSurfaceVariant,
            type: BottomNavigationBarType.fixed,
            selectedLabelStyle: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
            unselectedLabelStyle: const TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 12,
            ),
            items: items.map((item) => BottomNavigationBarItem(
              icon: Icon(item.icon),
              activeIcon: Icon(item.activeIcon ?? item.icon),
              label: item.label,
            )).toList(),
          ),
        ),
      ),
    );
  }
}

/// 底部导航栏项目
class GlassBottomNavItem {
  final IconData icon;
  final IconData? activeIcon;
  final String label;

  const GlassBottomNavItem({
    required this.icon,
    this.activeIcon,
    required this.label,
  });
}

/// 毛玻璃应用栏
class GlassAppBar extends StatelessWidget implements PreferredSizeWidget {
  final Widget? title;
  final Widget? leading;
  final List<Widget>? actions;
  final bool centerTitle;
  final double elevation;
  final Color? backgroundColor;

  const GlassAppBar({
    Key? key,
    this.title,
    this.leading,
    this.actions,
    this.centerTitle = true,
    this.elevation = 0,
    this.backgroundColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: title,
      centerTitle: centerTitle,
      elevation: elevation,
      backgroundColor: backgroundColor ?? SereneColors.surface.withOpacity(0.7),
      leading: leading,
      actions: actions,
      flexibleSpace: ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
          child: Container(
            color: Colors.transparent,
          ),
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

/// 毛玻璃抽屉
class GlassDrawer extends StatelessWidget {
  final Widget child;
  final double? width;

  const GlassDrawer({
    Key? key,
    required this.child,
    this.width,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      width: width ?? 320,
      backgroundColor: Colors.transparent,
      child: ClipRRect(
        borderRadius: const BorderRadius.only(
          topRight: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
          child: Container(
            decoration: BoxDecoration(
              color: SereneColors.surfaceContainerLowest,
              border: Border(
                right: BorderSide(
                  color: SereneColors.outlineVariant.withOpacity(0.3),
                  width: 1,
                ),
              ),
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}

/// 毛玻璃输入框
class GlassTextField extends StatelessWidget {
  final TextEditingController? controller;
  final String? hintText;
  final String? labelText;
  final IconData? prefixIcon;
  final Widget? suffix;
  final bool obscureText;
  final TextInputType? keyboardType;
  final ValueChanged<String>? onChanged;
  final FormFieldValidator<String>? validator;
  final int maxLines;

  const GlassTextField({
    Key? key,
    this.controller,
    this.hintText,
    this.labelText,
    this.prefixIcon,
    this.suffix,
    this.obscureText = false,
    this.keyboardType,
    this.onChanged,
    this.validator,
    this.maxLines = 1,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: SereneSpacing.inputRadius,
        boxShadow: [
          BoxShadow(
            color: SereneColors.glassShadow,
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: SereneSpacing.inputRadius,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: TextFormField(
            controller: controller,
            obscureText: obscureText,
            keyboardType: keyboardType,
            onChanged: onChanged,
            validator: validator,
            maxLines: maxLines,
            style: const TextStyle(
              color: SereneColors.onSurface,
              fontSize: 16,
            ),
            decoration: InputDecoration(
              hintText: hintText,
              labelText: labelText,
              prefixIcon: prefixIcon != null ? Icon(prefixIcon) : null,
              suffix: suffix,
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
          ),
        ),
      ),
    );
  }
}
