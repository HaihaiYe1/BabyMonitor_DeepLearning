import 'dart:ui';
import 'package:flutter/material.dart';
import '../models/notification_model.dart';
import '../theme/serene_colors.dart';
import '../theme/serene_spacing.dart';
import '../theme/serene_typography.dart';

class NotificationCard extends StatelessWidget {
  final NotificationModel record;
  final VoidCallback onTogglePin;
  final VoidCallback onDelete;

  const NotificationCard({
    Key? key,
    required this.record,
    required this.onTogglePin,
    required this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(record.id.toString()),
      background: Container(
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          color: record.pinned ? SereneColors.primary : SereneColors.primaryContainer,
          borderRadius: BorderRadius.circular(SereneSpacing.radiusXl),
        ),
        child: Icon(
          record.pinned ? Icons.remove_circle : Icons.push_pin,
          color: record.pinned ? SereneColors.onPrimary : SereneColors.onPrimaryContainer,
        ),
      ),
      secondaryBackground: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          color: SereneColors.errorContainer,
          borderRadius: BorderRadius.circular(SereneSpacing.radiusXl),
        ),
        child: const Icon(
          Icons.delete,
          color: SereneColors.error,
        ),
      ),
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.endToStart) {
          return await showDialog<bool>(
            context: context,
            builder: (context) {
              return AlertDialog(
                backgroundColor: SereneColors.surfaceContainerLowest,
                shape: RoundedRectangleBorder(
                  borderRadius: SereneSpacing.dialogRadius,
                ),
                title: Text(
                  'Confirm Deletion',
                  style: SereneTypography.headlineSmall.copyWith(
                    color: SereneColors.onSurface,
                  ),
                ),
                content: Text(
                  'Are you sure you want to delete this notification?',
                  style: SereneTypography.bodyMedium.copyWith(
                    color: SereneColors.onSurfaceVariant,
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    child: Text(
                      'Cancel',
                      style: SereneTypography.labelLarge.copyWith(
                        color: SereneColors.onSurfaceVariant,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop(true);
                      onDelete();
                    },
                    child: Text(
                      'Delete',
                      style: SereneTypography.labelLarge.copyWith(
                        color: SereneColors.error,
                      ),
                    ),
                  ),
                ],
              );
            },
          );
        }
        return true;
      },
      onDismissed: (direction) {
        if (direction == DismissDirection.startToEnd) {
          onTogglePin();
        } else if (direction == DismissDirection.endToStart) {
          onDelete();
        }
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: SereneSpacing.sm),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(SereneSpacing.radiusXl),
          color: record.pinned
              ? SereneColors.primaryContainer.withValues(alpha: 0.3)
              : SereneColors.surfaceContainerLowest.withValues(alpha: 0.7),
          border: Border.all(
            color: record.pinned
                ? SereneColors.primaryContainer
                : SereneColors.outlineVariant.withValues(alpha: 0.2),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(SereneSpacing.radiusXl),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: SereneSpacing.cardPadding,
                vertical: SereneSpacing.sm,
              ),
              leading: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _getLevelColor(record.level).withValues(alpha: 0.2),
                ),
                child: Icon(
                  _getLevelIcon(record.level),
                  color: _getLevelColor(record.level),
                  size: 20,
                ),
              ),
              title: Text(
                record.message,
                style: SereneTypography.bodyMedium.copyWith(
                  color: SereneColors.onSurface,
                ),
              ),
              subtitle: Text(
                'Level: ${record.level}',
                style: SereneTypography.bodySmall.copyWith(
                  color: SereneColors.onSurfaceVariant,
                ),
              ),
              trailing: Text(
                _formatTimestamp(record.timestamp),
                style: SereneTypography.labelMedium.copyWith(
                  color: SereneColors.outline,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Color _getLevelColor(String level) {
    switch (level.toLowerCase()) {
      case 'high':
        return SereneColors.error;
      case 'medium':
        return SereneColors.warning;
      case 'low':
        return SereneColors.safe;
      default:
        return SereneColors.primary;
    }
  }

  IconData _getLevelIcon(String level) {
    switch (level.toLowerCase()) {
      case 'high':
        return Icons.error_outline;
      case 'medium':
        return Icons.warning_outlined;
      case 'low':
        return Icons.info_outline;
      default:
        return Icons.notifications_outlined;
    }
  }

  String _formatTimestamp(DateTime timestamp) {
    return '${timestamp.day}-${timestamp.month}-${timestamp.year} ${timestamp.hour}:${timestamp.minute}';
  }
}
