/// 摄像头设备数据模型
class Device {
  final String id;         // 设备唯一标识符
  final String name;       // 设备名称
  final String ip;         // 设备IP地址
  final String status;     // 设备状态（正常 / 异常）
  final String rtspUrl;    // RTSP流地址 (如: rtsp://admin:password@192.168.1.1/stream)
  final String email;      // 绑定的用户邮箱
  bool isConnected;        // 连接状态
  DateTime lastActive;     // 最后活动时间 (对应数据库的 created_at)

  Device({
    required this.id,
    required this.name,
    required this.ip,
    required this.status,
    required this.rtspUrl,
    required this.email,
    this.isConnected = false,
    required this.lastActive,
  });

  // copyWith 方法，方便更新某些字段
  Device copyWith({
    String? id,
    String? name,
    String? ip,
    String? status,
    String? rtspUrl,
    String? email,
    bool? isConnected,
    DateTime? lastActive,
  }) {
    return Device(
      id: id ?? this.id,
      name: name ?? this.name,
      ip: ip ?? this.ip,
      status: status ?? this.status,
      rtspUrl: rtspUrl ?? this.rtspUrl,
      email: email ?? this.email,
      isConnected: isConnected ?? this.isConnected,
      lastActive: lastActive ?? this.lastActive,
    );
  }

  /// 从 JSON 解析设备数据
  factory Device.fromJson(Map<String, dynamic> json) {
    return Device(
      id: json['id'].toString() ?? '',  // 强制转换 id 为 String
      name: json['name'] ?? 'unknown_device',
      ip: json['ip'] ?? 'unknown_ip',
      status: json['status'] ?? 'unknown_status',
      rtspUrl: json['rtsp_url'] ?? 'unknown_rtsp',  // 数据库中的 `rtsp` 对应 `rtspUrl`
      email: json['email'] ?? 'unknown_email',
      isConnected: json['isConnected'] ?? false,
      lastActive: json['created_at'] != null ? DateTime.parse(json['created_at']) : DateTime.now(),  // `created_at` 作为 `lastActive`
    );
  }

  /// 转换为 JSON 格式
  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'ip': ip,
        'status': status,
        'rtsp_url': rtspUrl,
        'email': email,
        'isConnected': isConnected,
        'created_at': lastActive.toIso8601String(),
      };
}