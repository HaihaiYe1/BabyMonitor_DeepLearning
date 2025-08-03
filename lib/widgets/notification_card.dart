//只提供关于通知卡片的UI

import 'package:flutter/material.dart';
import 'package:my_first_app/models/notification_model.dart';

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
      key: Key(record.id.toString()), // 使用 ID 作为 key
      background: Container(
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        // 判断是否固定，如果是固定，颜色加深
        color: record.pinned ? Colors.blue.shade800 : Colors.blue,
        child: Icon(
          record.pinned ? Icons.remove_circle : Icons.push_pin,
          color: Colors.white,
        ),
      ),
      secondaryBackground: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        color: Colors.red,
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.endToStart) {
          // 显示删除确认对话框
          return await showDialog<bool>(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: const Text('Confirm Deletion'),
                content: const Text('Are you sure you want to delete this notification?'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    child: const Text('Cancel'),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop(true);
                      onDelete(); // 执行删除操作
                    },
                    child: const Text('Delete'),
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
          // 触发置顶
          onTogglePin(); // 执行置顶操作
        } else if (direction == DismissDirection.endToStart) {
          // 触发删除
          onDelete(); // 执行删除操作
        }
      },
      child: Card(
        margin: const EdgeInsets.only(bottom: 10),
        elevation: 4, // 提升效果
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
        color: record.pinned ? Colors.blue.shade100 : Colors.white, // 深色背景
        child: ListTile(
          title: Text(record.message),
          subtitle: Text('Level: ${record.level}'),
          trailing: Text(_formatTimestamp(record.timestamp)),
        ),
      ),
    );
  }

  // 格式化 DateTime 为字符串显示
  String _formatTimestamp(DateTime timestamp) {
    return '${timestamp.day}-${timestamp.month}-${timestamp.year} ${timestamp.hour}:${timestamp.minute}';
  }
}
