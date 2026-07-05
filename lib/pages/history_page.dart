import 'package:flutter/material.dart';
import '../generated/l10n.dart';
import 'trash_page.dart';
import '../services/notification_service.dart';
import '../widgets/notification_card.dart';
import '../models/notification_model.dart';
import 'dart:async';
import '../theme/serene_colors.dart';
import '../theme/serene_spacing.dart';
import '../theme/serene_typography.dart';
import '../widgets/glass_widgets.dart';
import '../widgets/serene_widgets.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({Key? key}) : super(key: key);

  @override
  _HistoryPageState createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> with AutomaticKeepAliveClientMixin {
  final NotificationService _notificationService = NotificationService();

  List<NotificationModel> history = [];
  List<NotificationModel> trash = [];

  Timer? _timer;
  final Duration _refreshInterval = const Duration(seconds: 10);

  @override
  void initState() {
    super.initState();
    _loadNotifications();
    _startPeriodicRefresh();
  }

  @override
  void dispose() {
    _stopPeriodicRefresh();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadNotifications();
  }

  void _loadNotifications() async {
    final notifications = await _notificationService.fetchNotificationsFromBackend();
    setState(() {
      history = notifications;
    });
  }

  void _startPeriodicRefresh() {
    _timer = Timer.periodic(_refreshInterval, (timer) async {
      _loadNotifications();
    });
  }

  void _stopPeriodicRefresh() {
    _timer?.cancel();
  }

  void _deleteNotification(int index) {
    final notification = history[index];
    setState(() {
      history.removeAt(index);
      trash.add(notification);
    });
    _notificationService.deleteNotification(notification.id);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(S.of(context).notification_deleted),
        backgroundColor: SereneColors.primary,
      ),
    );
  }

  void _togglePin(int index) {
    final current = history[index];
    setState(() {
      current.pinned = !current.pinned;

      if (current.pinned) {
        history.removeAt(index);
        history.insert(0, current);
      } else {
        history.removeAt(index);
        history.add(current);
      }
    });

    _notificationService.updateNotification(current).then((_) {
      _loadNotifications();
    });
  }

  void _simulateNotification() async {
    final notification = NotificationModel(
      id: DateTime.now().millisecondsSinceEpoch,
      level: 'High',
      message: 'Baby is crying',
      timestamp: DateTime.now(),
    );

    await _notificationService.saveNotificationToHistory(
      notification.id,
      notification.level,
      notification.message,
    );

    if (_notificationService.isNotificationsEnabled) {
      await _notificationService.showNotification(
        id: notification.id,
        title: notification.level,
        body: notification.message,
      );
    }

    setState(() {
      history.insert(0, notification);
    });
  }

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      backgroundColor: SereneColors.surface,
      body: SafeArea(
        bottom: false,
        child: Stack(
          children: [
            // 背景色
            Container(
              color: SereneColors.surface,
            ),
            // 历史记录列表
            history.isEmpty
                ? _buildEmptyState()
                : _buildHistoryList(),
            // 浮动按钮
            Positioned(
              bottom: 20,
              right: 20,
              child: _buildFABs(),
            ),
          ],
        ),
      ),
    );
  }

  /// 构建空状态
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: SereneColors.primaryContainer.withValues(alpha: 0.3),
            ),
            child: const Icon(
              Icons.notifications_outlined,
              size: 40,
              color: SereneColors.primary,
            ),
          ),
          const SizedBox(height: SereneSpacing.md),
          Text(
            'No notifications yet',
            style: SereneTypography.headlineSmall.copyWith(
              color: SereneColors.onSurface,
            ),
          ),
          const SizedBox(height: SereneSpacing.sm),
          Text(
            'Notifications will appear here',
            style: SereneTypography.bodyMedium.copyWith(
              color: SereneColors.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  /// 构建历史记录列表
  Widget _buildHistoryList() {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(
        SereneSpacing.marginMobile,
        SereneSpacing.md,
        SereneSpacing.marginMobile,
        100, // 为FAB预留空间
      ),
      itemCount: history.length,
      itemBuilder: (context, index) {
        final record = history[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: SereneSpacing.sm),
          child: NotificationCard(
            record: record,
            onDelete: () => _deleteNotification(index),
            onTogglePin: () => _togglePin(index),
          ),
        );
      },
    );
  }

  /// 构建浮动按钮
  Widget _buildFABs() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        // TimingPage 按钮
        _buildFAB(
          icon: Icons.timer_outlined,
          color: SereneColors.safe,
          backgroundColor: SereneColors.safe.withValues(alpha: 0.2),
          tooltip: 'Detection timing test',
          onPressed: () {
            Navigator.pushNamed(context, '/timing');
          },
        ),
        const SizedBox(height: SereneSpacing.md),
        // 垃圾桶按钮
        _buildFAB(
          icon: Icons.delete_outline,
          color: SereneColors.error,
          backgroundColor: SereneColors.errorContainer,
          tooltip: S.of(context).trash,
          onPressed: () async {
            await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => TrashPage(
                  trash: trash,
                  restoreCallback: (notification) {
                    setState(() {
                      trash.remove(notification);
                      history.add(notification);
                    });
                    _notificationService.updateNotification(notification);
                  },
                ),
              ),
            );
            _loadNotifications();
          },
        ),
        const SizedBox(height: SereneSpacing.md),
        // 模拟通知按钮
        _buildFAB(
          icon: Icons.notifications_outlined,
          color: SereneColors.primary,
          backgroundColor: SereneColors.primaryContainer,
          tooltip: S.of(context).simulate_notification,
          onPressed: _simulateNotification,
        ),
      ],
    );
  }

  /// 构建单个FAB
  Widget _buildFAB({
    required IconData icon,
    required Color color,
    required Color backgroundColor,
    required String tooltip,
    required VoidCallback onPressed,
  }) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: backgroundColor,
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.2),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(24),
          onTap: onPressed,
          child: Icon(
            icon,
            size: 24,
            color: color,
          ),
        ),
      ),
    );
  }
}
