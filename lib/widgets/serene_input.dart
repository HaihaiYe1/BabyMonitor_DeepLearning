import 'package:flutter/material.dart';
import '../theme/serene_colors.dart';
import '../theme/serene_spacing.dart';
import '../theme/serene_typography.dart';

/// Serene Guardian 设计系统输入框组件
/// 统一所有输入框的样式
class SereneInput extends StatelessWidget {
  final TextEditingController? controller;
  final String? labelText;
  final String? hintText;
  final IconData? prefixIcon;
  final Widget? suffix;
  final bool obscureText;
  final TextInputType? keyboardType;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final FormFieldValidator<String>? validator;
  final int maxLines;
  final bool enabled;
  final FocusNode? focusNode;

  const SereneInput({
    Key? key,
    this.controller,
    this.labelText,
    this.hintText,
    this.prefixIcon,
    this.suffix,
    this.obscureText = false,
    this.keyboardType,
    this.onChanged,
    this.onSubmitted,
    this.validator,
    this.maxLines = 1,
    this.enabled = true,
    this.focusNode,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: SereneSpacing.inputRadius,
        color: SereneColors.primary.withValues(alpha: 0.05),
        border: Border.all(
          color: SereneColors.outline.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          if (prefixIcon != null)
            Padding(
              padding: const EdgeInsets.only(left: SereneSpacing.md),
              child: Icon(
                prefixIcon,
                color: SereneColors.outline,
                size: 20,
              ),
            ),
          Expanded(
            child: TextFormField(
              controller: controller,
              obscureText: obscureText,
              keyboardType: keyboardType,
              onChanged: onChanged,
              onFieldSubmitted: onSubmitted,
              validator: validator,
              maxLines: maxLines,
              enabled: enabled,
              focusNode: focusNode,
              style: SereneTypography.bodyMedium.copyWith(
                color: SereneColors.onSurface,
              ),
              decoration: InputDecoration(
                labelText: labelText,
                hintText: hintText,
                hintStyle: SereneTypography.bodyMedium.copyWith(
                  color: SereneColors.outlineVariant,
                ),
                labelStyle: SereneTypography.bodySmall.copyWith(
                  color: SereneColors.onSurfaceVariant,
                ),
                border: InputBorder.none,
                focusedBorder: InputBorder.none,
                errorBorder: InputBorder.none,
                focusedErrorBorder: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: prefixIcon != null ? SereneSpacing.sm : SereneSpacing.md,
                  vertical: SereneSpacing.md,
                ),
              ),
            ),
          ),
          if (suffix != null)
            Padding(
              padding: const EdgeInsets.only(right: SereneSpacing.md),
              child: suffix,
            ),
        ],
      ),
    );
  }
}

/// Serene Guardian 设计系统对话框输入框组件
/// 用于对话框中的输入框
class SereneDialogInput extends StatelessWidget {
  final TextEditingController? controller;
  final String hintText;
  final IconData icon;
  final TextInputType? keyboardType;
  final bool obscureText;

  const SereneDialogInput({
    Key? key,
    this.controller,
    required this.hintText,
    required this.icon,
    this.keyboardType,
    this.obscureText = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: SereneSpacing.inputRadius,
        color: SereneColors.primary.withValues(alpha: 0.05),
        border: Border.all(
          color: SereneColors.outline.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Padding(
            padding: const EdgeInsets.only(left: SereneSpacing.md),
            child: Icon(
              icon,
              color: SereneColors.outline,
              size: 20,
            ),
          ),
          Expanded(
            child: TextField(
              controller: controller,
              keyboardType: keyboardType,
              obscureText: obscureText,
              style: SereneTypography.bodyMedium.copyWith(
                color: SereneColors.onSurface,
              ),
              decoration: InputDecoration(
                hintText: hintText,
                hintStyle: SereneTypography.bodyMedium.copyWith(
                  color: SereneColors.outlineVariant,
                ),
                border: InputBorder.none,
                focusedBorder: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: SereneSpacing.sm,
                  vertical: SereneSpacing.md,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
