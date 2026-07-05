import 'package:flutter/material.dart';
import '../theme/serene_colors.dart';
import '../theme/serene_spacing.dart';
import '../theme/serene_typography.dart';

/// Serene Guardian 设计系统徽章组件
/// 统一所有徽章的样式
class SereneBadge extends StatelessWidget {
  final String label;
  final Color color;
  final Color? textColor;
  final IconData? icon;
  final double size;

  const SereneBadge({
    Key? key,
    required this.label,
    required this.color,
    this.textColor,
    this.icon,
    this.size = 8,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(SereneSpacing.radiusXl),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.4),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: SereneTypography.labelMedium.copyWith(
              color: textColor ?? SereneColors.onSurfaceVariant,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

/// Serene Guardian 设计系统状态指示器组件
/// 用于显示在线/离线状态
class SereneStatusIndicator extends StatelessWidget {
  final bool isOnline;
  final String label;
  final double dotSize;

  const SereneStatusIndicator({
    Key? key,
    required this.isOnline,
    required this.label,
    this.dotSize = 8,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SereneBadge(
      label: label,
      color: isOnline ? SereneColors.safe : SereneColors.error,
      size: dotSize,
    );
  }
}

/// Serene Guardian 设计系统LIVE徽章组件
/// 用于视频直播状态
class SereneLiveBadge extends StatelessWidget {
  final bool isLive;

  const SereneLiveBadge({
    Key? key,
    required this.isLive,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(SereneSpacing.radiusXl),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isLive ? SereneColors.error : SereneColors.outline,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            isLive ? 'LIVE' : 'OFFLINE',
            style: SereneTypography.labelMedium.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
