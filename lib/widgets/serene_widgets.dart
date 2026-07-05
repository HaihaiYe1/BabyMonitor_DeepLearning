import 'dart:ui';
import 'package:flutter/material.dart';
import '../theme/serene_colors.dart';
import '../theme/serene_spacing.dart';
import '../theme/serene_typography.dart';
import 'glass_widgets.dart';

/// Serene Guardian 基础组件库
/// 完全还原 stitch 项目的设计规范

/// 主要按钮
/// 对应 stitch 的 Primary Button: Solid #A8D1E7 with white text. 16px radius.
class SerenePrimaryButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool isLoading;
  final double? width;
  final double? height;

  const SerenePrimaryButton({
    Key? key,
    required this.text,
    this.onPressed,
    this.icon,
    this.isLoading = false,
    this.width,
    this.height,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height ?? 48,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: SereneColors.primaryContainer,
          foregroundColor: SereneColors.onPrimaryContainer,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: SereneSpacing.buttonRadius,
          ),
          padding: SereneSpacing.buttonPadding,
        ),
        child: isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    SereneColors.onPrimaryContainer,
                  ),
                ),
              )
            : Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (icon != null) ...[
                    Icon(icon, size: 20),
                    const SizedBox(width: 8),
                  ],
                  Text(
                    text,
                    style: SereneTypography.button,
                  ),
                ],
              ),
      ),
    );
  }
}

/// 次要按钮（玻璃效果）
/// 对应 stitch 的 Secondary (Glass): 40% white overlay with 20px blur and a 1px white border.
class SereneSecondaryButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool isLoading;
  final double? width;
  final double? height;

  const SereneSecondaryButton({
    Key? key,
    required this.text,
    this.onPressed,
    this.icon,
    this.isLoading = false,
    this.width,
    this.height,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GlassFloat(
      onTap: isLoading ? null : onPressed,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 20, color: SereneColors.primary),
            const SizedBox(width: 8),
          ],
          Text(
            text,
            style: SereneTypography.button.copyWith(
              color: SereneColors.primary,
            ),
          ),
        ],
      ),
    );
  }
}

/// 图标按钮
/// 对应 stitch 的 Icon Buttons: Circular glass containers with centered neutral icons.
class SereneIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final Color? iconColor;
  final double size;
  final String? tooltip;

  const SereneIconButton({
    Key? key,
    required this.icon,
    this.onPressed,
    this.iconColor,
    this.size = 48,
    this.tooltip,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GlassFloat(
      onTap: onPressed,
      padding: const EdgeInsets.all(12),
      child: Icon(
        icon,
        size: size * 0.5,
        color: iconColor ?? SereneColors.onSurface,
      ),
    );
  }
}

/// 状态芯片
/// 用于显示状态信息，如 "LIVE", "SLEEPING", "AWAKE"
class SereneStatusChip extends StatelessWidget {
  final String label;
  final Color? backgroundColor;
  final Color? textColor;
  final IconData? icon;
  final bool isActive;
  final bool showPulse;

  const SereneStatusChip({
    Key? key,
    required this.label,
    this.backgroundColor,
    this.textColor,
    this.icon,
    this.isActive = false,
    this.showPulse = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GlassFloat(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showPulse) ...[
            PulseDot(
              color: backgroundColor ?? SereneColors.error,
              size: 8,
            ),
            const SizedBox(width: 8),
          ],
          if (icon != null) ...[
            Icon(
              icon,
              size: 14,
              color: textColor ?? SereneColors.onSurface,
            ),
            const SizedBox(width: 4),
          ],
          Text(
            label.toUpperCase(),
            style: SereneTypography.statusLabel.copyWith(
              color: textColor ?? SereneColors.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}

/// 脉冲点动画组件
/// 用于实时状态指示
class PulseDot extends StatefulWidget {
  final Color color;
  final double size;

  const PulseDot({
    Key? key,
    this.color = SereneColors.primary,
    this.size = 12,
  }) : super(key: key);

  @override
  State<PulseDot> createState() => _PulseDotState();
}

class _PulseDotState extends State<PulseDot>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();
    _animation = Tween<double>(begin: 0.8, end: 2.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOut,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.size * 2,
      height: widget.size * 2,
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          return Stack(
            alignment: Alignment.center,
            children: [
              Transform.scale(
                scale: _animation.value,
                child: Container(
                  width: widget.size,
                  height: widget.size,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: widget.color.withOpacity(
                      1.0 - (_animation.value - 0.8) / 1.2,
                    ),
                  ),
                ),
              ),
              Container(
                width: widget.size,
                height: widget.size,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: widget.color,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

/// 数据展示卡片
/// 用于显示关键数据，如心率、温度等
class SereneDataCard extends StatelessWidget {
  final String title;
  final String value;
  final String? unit;
  final IconData icon;
  final Color? iconColor;
  final String? subtitle;
  final VoidCallback? onTap;

  const SereneDataCard({
    Key? key,
    required this.title,
    required this.value,
    this.unit,
    required this.icon,
    this.iconColor,
    this.subtitle,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: SereneTypography.dataLabel.copyWith(
                  color: SereneColors.onSurfaceVariant,
                ),
              ),
              Icon(
                icon,
                size: 20,
                color: iconColor ?? SereneColors.primary,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                value,
                style: SereneTypography.dataDisplay.copyWith(
                  color: SereneColors.onSurface,
                ),
              ),
              if (unit != null) ...[
                const SizedBox(width: 4),
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text(
                    unit!,
                    style: SereneTypography.bodySmall.copyWith(
                      color: SereneColors.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
            ],
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 4),
            Text(
              subtitle!,
              style: SereneTypography.bodySmall.copyWith(
                color: SereneColors.onSurfaceVariant,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// 快捷操作按钮
/// 用于首页的功能入口
class SereneQuickActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color iconBackgroundColor;
  final Color iconColor;
  final VoidCallback? onTap;

  const SereneQuickActionButton({
    Key? key,
    required this.label,
    required this.icon,
    required this.iconBackgroundColor,
    required this.iconColor,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      onTap: onTap,
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: iconBackgroundColor.withOpacity(0.3),
            ),
            child: Icon(
              icon,
              size: 28,
              color: iconColor,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            label,
            style: SereneTypography.labelLarge.copyWith(
              color: SereneColors.onSurface,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

/// 视频播放器覆盖控制组件
class SereneVideoOverlay extends StatelessWidget {
  final bool isLive;
  final VoidCallback? onTalkPressed;
  final VoidCallback? onSnapshotPressed;
  final VoidCallback? onFullscreenPressed;
  final VoidCallback? onMicPressed;

  const SereneVideoOverlay({
    Key? key,
    this.isLive = true,
    this.onTalkPressed,
    this.onSnapshotPressed,
    this.onFullscreenPressed,
    this.onMicPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // 顶部状态栏
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (isLive)
                  const SereneStatusChip(
                    label: 'LIVE',
                    backgroundColor: SereneColors.error,
                    textColor: Colors.white,
                    showPulse: true,
                  ),
                SereneIconButton(
                  icon: Icons.fullscreen,
                  onPressed: onFullscreenPressed,
                  iconColor: Colors.white,
                ),
              ],
            ),
            // 底部控制栏
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                GlassFloat(
                  onTap: onTalkPressed,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.mic,
                        color: SereneColors.primary,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Talk',
                        style: SereneTypography.labelLarge.copyWith(
                          color: SereneColors.onSurface,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                GlassFloat(
                  onTap: onSnapshotPressed,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.photo_camera,
                        color: SereneColors.primary,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Snapshot',
                        style: SereneTypography.labelLarge.copyWith(
                          color: SereneColors.onSurface,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// AI 状态指示器
class SereneAIStatusIndicator extends StatelessWidget {
  final bool isActive;
  final String statusText;
  final String? temperature;

  const SereneAIStatusIndicator({
    Key? key,
    this.isActive = true,
    required this.statusText,
    this.temperature,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GlassPanel(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              PulseDot(
                color: isActive ? SereneColors.primary : SereneColors.outline,
                size: 12,
              ),
              const SizedBox(width: 12),
              Text(
                statusText,
                style: SereneTypography.bodyMedium.copyWith(
                  fontWeight: FontWeight.w500,
                  color: SereneColors.onSurface,
                ),
              ),
            ],
          ),
          if (temperature != null)
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  'Room Temp',
                  style: SereneTypography.bodySmall.copyWith(
                    color: SereneColors.onSurfaceVariant,
                  ),
                ),
                Row(
                  children: [
                    Text(
                      temperature!,
                      style: SereneTypography.labelLarge.copyWith(
                        color: SereneColors.primary,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(
                      Icons.thermostat,
                      size: 16,
                      color: SereneColors.primary,
                    ),
                  ],
                ),
              ],
            ),
        ],
      ),
    );
  }
}
