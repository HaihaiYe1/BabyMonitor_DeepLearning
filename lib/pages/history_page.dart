import 'package:flutter/material.dart';
import '../generated/l10n.dart';
import 'trash_page.dart';
import 'package:my_first_app/services/notification_service.dart';
import 'package:my_first_app/widgets/notification_card.dart'; // 引入新的 NotificationCard
import 'package:my_first_app/models/notification_model.dart'; // 引入 NotificationModel
import 'dart:async'; // 导入 Timer

class HistoryPage extends StatefulWidget {
  const HistoryPage({Key? key}) : super(key: key);

  @override
  _HistoryPageState createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> with AutomaticKeepAliveClientMixin {
  final NotificationService _notificationService = NotificationService();

  List<NotificationModel> history = []; // 历史记录列表
  List<NotificationModel> trash = []; // 垃圾桶列表

  Timer? _timer; // 定时器
  final Duration _refreshInterval = const Duration(seconds: 10); // 每10秒刷新一次

  @override
  void initState() {
    super.initState();
    _loadNotifications();
    _startPeriodicRefresh(); // 启动定时刷新
  }

  @override
  void dispose() {
    _stopPeriodicRefresh(); // 页面销毁时停止刷新
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadNotifications();  // 页面显示时刷新通知
  }

  // 使用后端的 fetch 方法加载通知
  void _loadNotifications() async {
    final notifications = await _notificationService.fetchNotificationsFromBackend();
    print("Fetched notifications:");
    // 打印每个通知的详细信息
    notifications.forEach((notification) {
      print(notification.toString());  // 使用 toString 方法打印通知详细内容
    });
    setState(() {
      history = notifications;
    });
  }

  // 定期刷新通知
  void _startPeriodicRefresh() {
    _timer = Timer.periodic(_refreshInterval, (timer) async {
      print("Fetching notifications periodically...");
      _loadNotifications();
    });
  }

  // 停止定时刷新
  void _stopPeriodicRefresh() {
    _timer?.cancel();
    print("Stopped periodic refresh.");
  }

  // 删除通知，直接通过 NotificationService 删除
  void _deleteNotification(int index) {
    final notification = history[index];
    setState(() {
      history.removeAt(index);
      trash.add(notification); // 移动到垃圾桶
    });
    // 通过 NotificationService 删除通知
    _notificationService.deleteNotification(notification.id);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(S.of(context).notification_deleted)),
    );
  }

  void _togglePin(int index) {
    final current = history[index]; // 将当前通知存储为变量
    setState(() {
      current.pinned = !current.pinned; // 切换 pinned 状态

      // 如果置顶，放到列表前面
      if (current.pinned) {
        history.removeAt(index);  // 移除原来位置的通知
        history.insert(0, current);  // 如果置顶，放到列表前面
      } else {
        history.removeAt(index);  // 移除原来位置的通知
        history.add(current);  // 如果取消置顶，放到列表后面
      }
    });

    // 同步到后端
    _notificationService.updateNotification(current).then((_) {
      // 更新成功后再刷新列表，确保 UI 状态与后端数据一致
      _loadNotifications();  // 重新加载通知数据，确保 UI 刷新
      print('同步到后端，通知内容：${current.toString()}');
    });
  }


  void _simulateNotification() async {
    final notification = NotificationModel(
      id: DateTime.now().millisecondsSinceEpoch,
      level: 'High',
      message: 'Baby is crying',
      timestamp: DateTime.now(),
    );

    // 无论通知是否启用，都保存到历史记录
    await _notificationService.saveNotificationToHistory(
      notification.id,
      notification.level,
      notification.message,
    );

    // 如果通知已启用，显示通知
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
      body: Stack(
        children: [
          // 背景渐变
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFFE3FDFD), Color(0xFFFFE6FA)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          // 历史记录列表
          Scrollbar(
            thumbVisibility: false,
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
              itemCount: history.length,
              itemBuilder: (context, index) {
                final record = history[index];
                return NotificationCard(
                  record: record,
                  onDelete: () => _deleteNotification(index),
                  onTogglePin: () => _togglePin(index),
                );
              },
            ),
          ),
          // 浮动按钮
          Positioned(
            bottom: 80, // 确保浮动按钮不被底部导航栏挡住
            right: 16,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                //  TimingPage 按钮
                FloatingActionButton(
                  heroTag: 'timing',
                  onPressed: () {
                    Navigator.pushNamed(context, '/timing');
                  },
                  backgroundColor: Colors.green,
                  child: const Icon(Icons.timer_outlined),
                  tooltip: '检测耗时测试',
                ),
                const SizedBox(height: 16),
                // 🗑 垃圾桶按钮
                FloatingActionButton(
                  heroTag: 'trash',
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

                    // 页面返回后刷新
                    _loadNotifications();
                  },
                  backgroundColor: Colors.redAccent,
                  child: const Icon(Icons.delete),
                  tooltip: S.of(context).trash,
                ),
                const SizedBox(height: 16),
                FloatingActionButton(
                  heroTag: 'simulate',
                  onPressed: _simulateNotification,
                  backgroundColor: Colors.blueAccent,
                  child: const Icon(Icons.notifications),
                  tooltip: S.of(context).simulate_notification, // 长按显示文本框提示
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
