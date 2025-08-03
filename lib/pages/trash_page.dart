import 'package:flutter/material.dart';
import 'package:my_first_app/models/notification_model.dart';

class TrashPage extends StatelessWidget {
  final List<NotificationModel> trash; // 使用 NotificationModel
  final Function(NotificationModel) restoreCallback;

  const TrashPage({
    Key? key,
    required this.trash,
    required this.restoreCallback,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Trash'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
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
          // 主体内容
          trash.isEmpty
              ? Center(
                  child: Text(
                    'No deleted notifications.',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                  itemCount: trash.length,
                  itemBuilder: (context, index) {
                    final record = trash[index];
                    return Dismissible(
                      key: Key(record.id.toString()),
                      background: Container(
                        alignment: Alignment.centerLeft,
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        color: Colors.green,
                        child: const Icon(Icons.restore, color: Colors.white),
                      ),
                      secondaryBackground: Container(
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        color: Colors.red,
                        child: const Icon(Icons.delete_forever, color: Colors.white),
                      ),
                      confirmDismiss: (direction) async {
                        if (direction == DismissDirection.endToStart) {
                          return await showDialog<bool>(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('Confirm Deletion'),
                              content: const Text(
                                'Are you sure you want to permanently delete this notification?',
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.of(context).pop(false),
                                  child: const Text('Cancel'),
                                ),
                                TextButton(
                                  onPressed: () => Navigator.of(context).pop(true),
                                  child: const Text('Delete'),
                                ),
                              ],
                            ),
                          );
                        }
                        return true;
                      },
                      onDismissed: (direction) {
                        if (direction == DismissDirection.startToEnd) {
                          restoreCallback(record);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Notification restored')),
                          );
                        } else if (direction == DismissDirection.endToStart) {
                          trash.remove(record);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Notification permanently deleted')),
                          );
                        }
                      },
                      child: Card(
                        margin: const EdgeInsets.only(bottom: 10),
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        child: ListTile(
                          title: Text(record.message),
                          subtitle: Text('Level: ${record.level}'),
                          trailing: Text(
                            '${record.timestamp.hour.toString().padLeft(2, '0')}:${record.timestamp.minute.toString().padLeft(2, '0')}',
                          ),
                        ),
                      ),
                    );
                  },
                ),
        ],
      ),
    );
  }
}
