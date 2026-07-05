import 'package:flutter/material.dart';
import '../theme/serene_colors.dart';
import '../theme/serene_spacing.dart';
import '../theme/serene_typography.dart';
import 'glass_widgets.dart';
import 'serene_widgets.dart';

/// Serene Guardian 页面包装器
/// 为现有页面提供统一的 Serene 风格外观
class SerenePageWrapper extends StatelessWidget {
  final Widget child;
  final String? title;
  final Widget? leading;
  final List<Widget>? actions;
  final bool showAppBar;
  final bool showBottomNav;
  final int currentNavIndex;
  final ValueChanged<int>? onNavTap;
  final List<GlassBottomNavItem>? navItems;
  final Widget? floatingActionButton;
  final Widget? drawer;

  const SerenePageWrapper({
    Key? key,
    required this.child,
    this.title,
    this.leading,
    this.actions,
    this.showAppBar = true,
    this.showBottomNav = false,
    this.currentNavIndex = 0,
    this.onNavTap,
    this.navItems,
    this.floatingActionButton,
    this.drawer,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      appBar: showAppBar
          ? GlassAppBar(
              leading: leading,
              title: title != null
                  ? Text(
                      title!,
                      style: SereneTypography.headlineSmall.copyWith(
                        color: SereneColors.primary,
                      ),
                    )
                  : null,
              actions: actions,
            )
          : null,
      drawer: drawer,
      body: SafeArea(
        bottom: false,
        child: Stack(
          children: [
            // 背景渐变
            Container(
              decoration: const BoxDecoration(
                gradient: SereneColors.backgroundGradient,
              ),
            ),
            // 内容
            child,
          ],
        ),
      ),
      floatingActionButton: floatingActionButton,
      bottomNavigationBar: showBottomNav && navItems != null
          ? GlassBottomNavBar(
              currentIndex: currentNavIndex,
              onTap: onNavTap ?? (_) {},
              items: navItems!,
            )
          : null,
    );
  }
}

/// Serene 列表项包装器
class SereneListItemWrapper extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsets? padding;
  final EdgeInsets? margin;

  const SereneListItemWrapper({
    Key? key,
    required this.child,
    this.onTap,
    this.padding,
    this.margin,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: margin ?? const EdgeInsets.only(bottom: SereneSpacing.listItemGap),
      child: GlassCard(
        onTap: onTap,
        padding: padding ?? const EdgeInsets.all(SereneSpacing.cardPadding),
        child: child,
      ),
    );
  }
}

/// Serene 分组标题
class SereneSectionHeader extends StatelessWidget {
  final String title;
  final Widget? trailing;

  const SereneSectionHeader({
    Key? key,
    required this.title,
    this.trailing,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        bottom: SereneSpacing.sm,
        left: SereneSpacing.xs,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title.toUpperCase(),
            style: SereneTypography.labelLarge.copyWith(
              color: SereneColors.outline,
              letterSpacing: 0.08,
            ),
          ),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}

/// Serene 空状态
class SereneEmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget? action;

  const SereneEmptyState({
    Key? key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.action,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(SereneSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 64,
              color: SereneColors.outlineVariant,
            ),
            const SizedBox(height: SereneSpacing.md),
            Text(
              title,
              style: SereneTypography.headlineSmall.copyWith(
                color: SereneColors.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            if (subtitle != null) ...[
              const SizedBox(height: SereneSpacing.sm),
              Text(
                subtitle!,
                style: SereneTypography.bodyMedium.copyWith(
                  color: SereneColors.outline,
                ),
                textAlign: TextAlign.center,
              ),
            ],
            if (action != null) ...[
              const SizedBox(height: SereneSpacing.lg),
              action!,
            ],
          ],
        ),
      ),
    );
  }
}

/// Serene 加载状态
class SereneLoadingState extends StatelessWidget {
  final String? message;

  const SereneLoadingState({
    Key? key,
    this.message,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(
            width: 32,
            height: 32,
            child: CircularProgressIndicator(
              strokeWidth: 3,
              color: SereneColors.primary,
            ),
          ),
          if (message != null) ...[
            const SizedBox(height: SereneSpacing.md),
            Text(
              message!,
              style: SereneTypography.bodyMedium.copyWith(
                color: SereneColors.onSurfaceVariant,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Serene 错误状态
class SereneErrorState extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;

  const SereneErrorState({
    Key? key,
    required this.message,
    this.onRetry,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(SereneSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: SereneColors.error,
            ),
            const SizedBox(height: SereneSpacing.md),
            Text(
              'Oops!',
              style: SereneTypography.headlineMedium.copyWith(
                color: SereneColors.onSurface,
              ),
            ),
            const SizedBox(height: SereneSpacing.sm),
            Text(
              message,
              style: SereneTypography.bodyMedium.copyWith(
                color: SereneColors.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            if (onRetry != null) ...[
              const SizedBox(height: SereneSpacing.lg),
              SereneSecondaryButton(
                text: 'Try Again',
                icon: Icons.refresh,
                onPressed: onRetry,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
