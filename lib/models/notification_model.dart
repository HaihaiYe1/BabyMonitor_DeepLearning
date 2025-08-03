class NotificationModel {
  final int id;
  final int? userId;
  final int? deviceId;
  final String level;
  final String message;
  final DateTime timestamp;
  bool pinned;
  final bool? deleted;

  NotificationModel({
    required this.id,
    this.userId,
    this.deviceId,
    required this.level,
    required this.message,
    required this.timestamp,
    this.pinned = false,  // 默认值为 false，表示不置顶
    this.deleted = false, // 默认 false
  });

  // copyWith 方法，用于创建修改后的通知实例
  NotificationModel copyWith({
    bool? pinned,
  }) {
    return NotificationModel(
      id: this.id,
      userId: this.userId,
      deviceId: this.deviceId,
      level: this.level,
      message: this.message,
      timestamp: this.timestamp,
      pinned: pinned ?? this.pinned,
      deleted: deleted,
    );
  }

  // 从 JSON 创建 NotificationModel 实例
  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'] ?? 0, // 确保 id 至少为 0
      userId: json['user_id'],
      deviceId: json['device_id'],
      level: json['level'] ?? 'default_level', // 默认值处理
      message: json['message'] ?? json['content'] ?? 'No message provided', // 默认值处理
      timestamp: json['timestamp'] != null
        ? DateTime.parse(json['timestamp'])
        : DateTime.now(), // 如果 timestamp 为 null，使用当前时间
      pinned: json['pinned'] ?? false,  // 如果没有传递 pinned，默认为 false
      deleted: json['deleted'] == null ? false : json['deleted'] as bool,
    );
  }

  // 将 NotificationModel 实例转换为 JSON 格式
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'device_id': deviceId,
      'level': level,
      'message': message,
      'timestamp': timestamp.toIso8601String(),
      'pinned': pinned,  // 添加 pinned 字段
      'deleted': deleted, // 包含 deleted
    };
  }

  // 重写 toString() 方法来打印通知的详细内容
  @override
  String toString() {
    return 'NotificationModel(id: $id, userId: $userId, deviceId: $deviceId, level: $level, message: $message, timestamp: $timestamp, pinned: $pinned, deleted: $deleted)';
  }
}
