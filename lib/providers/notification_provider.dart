import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_first_app/models/notification_model.dart';
import '../services/notification_service.dart';

final notificationProvider =
    StateNotifierProvider<NotificationNotifier, List<NotificationModel>>(
  (ref) => NotificationNotifier(),
);

class NotificationNotifier extends StateNotifier<List<NotificationModel>> {
  NotificationNotifier() : super([]) {
    loadNotifications();
  }

  final _service = NotificationService();

  // 从本地加载通知列表
  Future<void> loadNotifications() async {
    final notifications = await _service.getNotifications();
    state = notifications;
  }

  // 添加或更新通知（同步到后端）
  Future<void> addOrUpdateNotification(NotificationModel notification) async {
    await _service.updateNotification(notification);
    await loadNotifications();  // 重新加载本地数据
  }

  // 删除通知
  Future<void> deleteNotification(int id) async {
    await _service.deleteNotification(id);
    state = state.where((n) => n.id != id).toList();
  }

  // 清空所有通知
  Future<void> clearAllNotifications() async {
    await _service.clearNotifications();
    state = [];
  }

  // 切换置顶状态
  Future<void> togglePin(int id) async {
    await _service.togglePin(id);
    await loadNotifications(); // 置顶状态改变后重新加载排序后的数据
  }

  // 从后端同步通知（例如应用启动时）
  Future<void> syncWithBackend() async {
    final backendNotifications = await _service.fetchNotificationsFromBackend();
    state = backendNotifications;
  }
}
