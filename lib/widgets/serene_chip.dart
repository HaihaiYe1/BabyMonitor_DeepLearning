import 'package:flutter/material.dart';
import '../theme/serene_colors.dart';
import '../theme/serene_spacing.dart';
import '../theme/serene_typography.dart';

/// Serene Guardian 设计系统芯片组件
/// 统一所有芯片的样式
class SereneChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback? onTap;
  final IconData? icon;
  final Color? selectedColor;
  final Color? unselectedColor;
  final Color? selectedTextColor;
  final Color? unselectedTextColor;

  const SereneChip({
    Key? key,
    required this.label,
    this.isSelected = false,
    this.onTap,
    this.icon,
    this.selectedColor,
    this.unselectedColor,
    this.selectedTextColor,
    this.unselectedTextColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: SereneSpacing.md,
          vertical: SereneSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? (selectedColor ?? SereneColors.primaryContainer)
              : (unselectedColor ?? SereneColors.surfaceContainerHigh),
          borderRadius: BorderRadius.circular(SereneSpacing.radiusXl),
          border: Border.all(
            color: isSelected
                ? Colors.transparent
                : SereneColors.outlineVariant.withValues(alpha: 0.2),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                size: 16,
                color: isSelected
                    ? (selectedTextColor ?? SereneColors.onPrimaryContainer)
                    : (unselectedTextColor ?? SereneColors.onSurfaceVariant),
              ),
              const SizedBox(width: 4),
            ],
            Text(
              label,
              style: SereneTypography.labelMedium.copyWith(
                color: isSelected
                    ? (selectedTextColor ?? SereneColors.onPrimaryContainer)
                    : (unselectedTextColor ?? SereneColors.onSurfaceVariant),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Serene Guardian 设计系统筛选芯片组件
/// 用于水平滚动的筛选 chips
class SereneFilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback? onTap;
  final IconData? icon;

  const SereneFilterChip({
    Key? key,
    required this.label,
    this.isSelected = false,
    this.onTap,
    this.icon,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SereneChip(
      label: label,
      isSelected: isSelected,
      onTap: onTap,
      icon: icon,
      selectedColor: SereneColors.primaryContainer,
      unselectedColor: SereneColors.surfaceContainerHigh,
      selectedTextColor: SereneColors.onPrimaryContainer,
      unselectedTextColor: SereneColors.onSurfaceVariant,
    );
  }
}

/// Serene Guardian 设计系统状态芯片组件
/// 用于显示状态信息
class SereneStatusChip extends StatelessWidget {
  final String label;
  final Color statusColor;
  final IconData? icon;

  const SereneStatusChip({
    Key? key,
    required this.label,
    required this.statusColor,
    this.icon,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: statusColor.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(SereneSpacing.radiusXl),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(
              icon,
              size: 14,
              color: statusColor,
            ),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: SereneTypography.labelMedium.copyWith(
              color: statusColor,
            ),
          ),
        ],
      ),
    );
  }
}
