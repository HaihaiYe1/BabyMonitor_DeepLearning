import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vibration/vibration.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:web_socket_channel/web_socket_channel.dart';
import 'dart:async';

import '../models/notification_model.dart';
import 'api_service.dart'; // 引入 Timer

class NotificationService {
  WebSocketChannel? _channel;
  final String _wsUrl = ApiService.alertsWebSocket;  // WebSocket 服务器地址
  final int _reconnectDelay = 5; // 重连延迟（秒）
  bool get isNotificationsEnabled => _isNotificationsEnabled;

  // 定期刷新通知的定时器
  Timer? _timer;
  static const Duration _refreshInterval = Duration(seconds: 10); // 每10s拉取一次通知

  // 单例模式
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notificationsPlugin = FlutterLocalNotificationsPlugin();

  // 数据存储键
  static const String _notificationsKey = 'notifications';
  static const String _notificationsEnabledKey = 'notifications_enabled';
  bool _isNotificationsEnabled = true;

  static const String _userIdKey = 'user_id';  // 当前用户ID的存储键
  static const String _authTokenKey = 'token';  // 认证令牌的存储键

  // 获取当前登录用户的ID
  Future<int?> _getCurrentUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_userIdKey);  // 获取保存的用户ID
  }

  // 获取认证令牌
  Future<String?> _getAuthToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_authTokenKey);  // 获取保存的认证令牌
  }

  // 初始化通知服务
  Future<void> initialize() async {
    try {
      print("Initializing Notification Service...");
      // 请求通知权限
      await requestNotificationPermission();

      // 创建通知频道（仅在 Android 上）
      const AndroidNotificationChannel channel = AndroidNotificationChannel(
        'baby_alerts_channel', // 通道 ID
        'Baby Alerts', // 通道名称
        description: 'This is the default notification channel',
        importance: Importance.max,
      );

      // 获取插件平台实现并创建通道
      await _notificationsPlugin
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(channel);

      // Android 初始化设置
      const AndroidInitializationSettings androidInitializationSettings =
      AndroidInitializationSettings('notification'); // 图标资源文件名

      // 通用初始化设置
      const InitializationSettings initializationSettings =
      InitializationSettings(android: androidInitializationSettings);

      // 初始化插件
      await _notificationsPlugin.initialize(
        initializationSettings,
        onDidReceiveNotificationResponse: (NotificationResponse response) async {
          if (response.payload != null) {
            // 点击通知时的处理逻辑
            print('Notification payload: ${response.payload}');
            // 你可以在此处进行导航或者弹出特定页面
          }
        },
      );

      await _loadNotificationSetting();
      // 启动定期刷新通知
      _startPeriodicRefresh();

      print("Notification Service Initialized Successfully.");
    } catch (e) {
      print("Error initializing Notification Service: $e");
    }
  }

  /// 请求通知权限（兼容 Android 13 和以下版本）
  Future<void> requestNotificationPermission() async {
    try {
      if (Platform.isAndroid) {
        // Android 13 及以上需要显式请求通知权限
        if (await Permission.notification.isGranted) {
          print("Notification permission already granted.");
        } else {
          final status = await Permission.notification.request();
          if (status.isGranted) {
            print("Notification permission granted.");
          } else {
            print("Notification permission denied.");
          }
        }
      } else {
        print("Notification permission request is not applicable on this platform.");
      }
    } catch (e) {
      print("Error requesting notification permission: $e");
    }
  }

  // 定期刷新通知
  void _startPeriodicRefresh() {
    _timer = Timer.periodic(_refreshInterval, (timer) async {
      print("Fetching notifications...");
      await fetchNotificationsFromBackend();
    });
  }

  // 停止定期刷新
  void stopPeriodicRefresh() {
    _timer?.cancel();
    print("Stopped periodic refresh.");
  }

  // 初始化 WebSocket 客户端
  Future<void> initializeWebSocket() async {
    final userId = await _getCurrentUserId();
    if (userId == null) {
      print("No user ID found, unable to establish WebSocket connection.");
      return;
    }

    final authToken = await _getAuthToken();
    if (authToken == null) {
      print("No auth token found, unable to establish WebSocket connection.");
      return;
    }

    // 初次连接 WebSocket
    _connectWebSocket();
  }

  // 连接 WebSocket，并添加自动重连机制
  void _connectWebSocket() {
    try {
      // 尝试连接 WebSocket
      _channel = WebSocketChannel.connect(Uri.parse(_wsUrl));

      // 监听 WebSocket 消息
      _channel?.stream.listen(
        (message) {
          print("Received WebSocket message: $message");
          // 解析 WebSocket 消息并显示通知
          final notification = NotificationModel.fromJson(jsonDecode(message));
          _handleWebSocketMessage(notification);
        },
        onError: (error) {
          print("WebSocket error: $error");
          // 出现错误时重连
          _reconnectWebSocket();
        },
        onDone: () {
          print("WebSocket connection closed.");
          // 连接关闭时自动重连
          _reconnectWebSocket();
        },
      );
    } catch (e) {
      print("Error connecting to WebSocket: $e");
      // 如果连接失败，尝试重新连接
      _reconnectWebSocket();
    }
  }

  // 重新连接 WebSocket
  void _reconnectWebSocket() {
    print("Attempting to reconnect...");
    // 延迟后重试连接
    Future.delayed(Duration(seconds: _reconnectDelay), () {
      _connectWebSocket();  // 尝试重新连接
    });
  }

  // 处理 WebSocket 消息
  void _handleWebSocketMessage(NotificationModel notification) {
    // 显示推送的通知
    showNotification(
      id: notification.id,
      title: notification.level,
      body: notification.message,
    );
  }

  // 显示通知
  Future<void> showNotification({
    required int id,
    required String title,
    required String body,
    String? payload, // 自定义数据
  }) async {
    try {
      // 👇 保证 ID 是 32 位整数（最大为 0x7FFFFFFF = 2147483647）
      final safeId = id % 0x7FFFFFFF;

      // 保存通知到历史记录中，即使通知被禁用
      await saveNotificationToHistory(safeId, title, body);

      if (!_isNotificationsEnabled) {
        print("Notifications are disabled. Skipping notification display.");
        return; // 禁用通知时不显示系统通知
      }

      // 请求权限并显示通知
      if (Platform.isAndroid && !(await Permission.notification.isGranted)) {
        print("Notification permission is not granted. Skipping notification.");
        return;
      }

      // 创建 Android 通知详情
      const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
        'baby_alerts_channel2', // 通知频道 ID
        'baby_alerts2', // 通知频道名称
        channelDescription: 'This is the default notification channel',
        importance: Importance.max,
        priority: Priority.high,
        icon: 'drawable/notification', // 确保设置了小图标
        playSound: true, // 启用声音
        sound: RawResourceAndroidNotificationSound('notification_sound'), // 自定义声音（需要配置到安卓资源中）
      );

      const NotificationDetails notificationDetails = NotificationDetails(android: androidDetails);

      // 显示通知
      await _notificationsPlugin.show(
        safeId, // 通知 ID
        title, // 通知标题
        body, // 通知内容
        notificationDetails, // 通知详情
        payload: payload, // 可选的自定义数据
      );

      // 打印通知的具体内容
      print("Showing Notification -> ID: $safeId, Title: $title, Body: $body");

      // 调用震动
      if (await Vibration.hasVibrator()) {
        Vibration.vibrate(); // 默认震动
      }

      print("Notification shown successfully.");
    } catch (e) {
      print("Error showing notification: $e");
    }
  }

  // 保存通知到历史记录中，即使通知没有显示
  Future<void> saveNotificationToHistory(int id, String title, String body) async {
    final prefs = await SharedPreferences.getInstance();

    final notifications = await getNotifications();

    final newNotification = NotificationModel(
      id: id,
      level: 'low', // Example level
      message: body,
      timestamp: DateTime.now(),
      pinned: false,  // 默认为不置顶
    );

    notifications.insert(0, newNotification);

    try {
      final jsonString = jsonEncode(notifications.map((e) => e.toJson()).toList());
      await prefs.setString(_notificationsKey, jsonString);
      print("Notification saved successfully: $jsonString");
    } catch (e) {
      print("Error saving notification: $e");
    }
  }



  Future<void> updateNotificationSetting(bool isEnabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_notificationsEnabledKey, isEnabled);
    _isNotificationsEnabled = isEnabled;
  }

  Future<void> _loadNotificationSetting() async {
    final prefs = await SharedPreferences.getInstance();
    _isNotificationsEnabled = prefs.getBool(_notificationsEnabledKey) ?? true;
  }

  // 取消特定通知
  Future<void> cancelNotification(int id) async {
    await _notificationsPlugin.cancel(id);
  }

  // 取消所有通知
  Future<void> cancelAllNotifications() async {
    await _notificationsPlugin.cancelAll();
  }

  Future<List<NotificationModel>> getNotifications() async {
    final prefs = await SharedPreferences.getInstance();
    final rawData = prefs.getString(_notificationsKey);
    if (rawData != null) {
      try {
        final decoded = jsonDecode(rawData);
        final List<NotificationModel> list = (decoded as List)
            .map((e) => NotificationModel.fromJson(e))
            .toList();

        list.sort((a, b) {
          final pinA = a.pinned ? 1 : 0;
          final pinB = b.pinned ? 1 : 0;
          final timeA = DateTime.tryParse(a.timestamp.toString()) ?? DateTime(2000);
          final timeB = DateTime.tryParse(b.timestamp.toString()) ?? DateTime(2000);
          return pinB - pinA != 0 ? pinB - pinA : timeB.compareTo(timeA);
        });

        return list;
      } catch (e) {
        print("Error decoding notifications: $e");
      }
    } else {
      print("Unexpected data type for notifications: ${rawData.runtimeType}");
    }
    return [];
  }

  // 更新或添加通知
  Future<void> updateNotification(NotificationModel notification) async {
    print('🔄 Syncing to backend: ${notification.toJson()}');  // 打印通知数据
    final notifications = await getNotifications();
    final index = notifications.indexWhere((n) => n.id == notification.id);

    if (index != -1) {
      notifications[index] = notification;
    } else {
      notifications.add(notification);
    }

    await _saveNotifications(notifications);
    await _syncNotificationToBackend(notification);

    if (_isNotificationsEnabled) {
      await showNotification(
        id: notification.id,
        title: "Danger Level: ${notification.level}",
        body: notification.message,
      );
    }
  }

  // 删除通知
  Future<void> deleteNotification(int id) async {
    final success = await _deleteNotificationFromBackend(id);

    if (success) {
      final notifications = await getNotifications();
      notifications.removeWhere((n) => n.id == id);
      await cancelNotification(id);
      await _saveNotifications(notifications);
      print("Notification deleted locally after backend success.");
    } else {
      print("Skipping local delete because backend delete failed.");
    }
  }

  // 清空所有通知数据
  Future<void> clearNotifications() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_notificationsKey);

    // 清空后端的通知数据
    await _clearNotificationsFromBackend();
  }

  // 保存通知列表
  Future<void> _saveNotifications(List<NotificationModel> notifications) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
        _notificationsKey, jsonEncode(notifications.map((e) => e.toJson()).toList()));
  }

  // 置顶/取消置顶
Future<void> togglePin(int id) async {
  final notifications = await getNotifications();
  final index = notifications.indexWhere((n) => n.id == id);
  if (index == -1) return;

  final current = notifications[index];

  // 调用后端，切换 pinned 状态，并获取后端返回的新状态
  final newPinned = await _togglePinOnBackend(id);

  if (newPinned != null) {
    final updated = current.copyWith(pinned: newPinned); // ✅ 用后端返回的新状态
    notifications[index] = updated;
    await _saveNotifications(notifications);
    print("Pin state toggled after backend success for ID: $id -> ${updated.pinned}");
  } else {
    print("Pin toggle failed on backend, skipping local update.");
  }
}
  // ========================= 与后端交互部分 =========================

Future<void> _syncNotificationToBackend(NotificationModel notification) async {
  final userId = await _getCurrentUserId();
  final authToken = await _getAuthToken();
  if (userId == null || authToken == null) {
    print("User ID or Auth Token is missing.");
    return;
  }

  final notificationPayload = {
    'message': notification.message,
    'level': notification.level,
    'pinned': notification.pinned,
    'device_id': notification.deviceId, // 确保你有这个字段并正确赋值
    'deleted': notification.deleted, // ✅ 必须加上这个字段！
  };

  try {
    http.Response response;

    if (notification.id == -1) {
      // 新建通知（不带 ID，由后端生成）
      response = await http.post(
        Uri.parse(ApiService.notificationBase),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $authToken',
        },
        body: jsonEncode(notificationPayload),
      );

      if (response.statusCode == 201) {
        // 从返回体中获取新建通知（带 id）
        final responseData = jsonDecode(response.body);
        final newNotification = NotificationModel.fromJson(responseData);

        // 用新 ID 替换旧通知，更新本地存储
        final notifications = await getNotifications();
        notifications.removeWhere((n) => n.id == -1);
        notifications.insert(0, newNotification);
        await _saveNotifications(notifications);

        print("Notification created and saved with ID: ${newNotification.id}");
      } else {
        print("Failed to create notification. Status: ${response.statusCode}");
      }
    } else {
      // 更新已有通知
      response = await http.put(
        Uri.parse(ApiService.notificationDetail(notification.id)),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $authToken',
        },
        body: jsonEncode(notificationPayload),
      );

      if (response.statusCode == 200) {
        print("Notification updated successfully on backend.");
      } else {
        print("Failed to update notification. Status: ${response.statusCode}");
        print("Response body: ${response.body}"); // 打印错误的详细信息
      }
    }
  } catch (e) {
    print("Error syncing notification to backend: $e");
  }

  print("Syncing notification payload: ${jsonEncode(notificationPayload)}");
}


  // 置顶后端通知
Future<bool?> _togglePinOnBackend(int id) async {
  final authToken = await _getAuthToken();

  try {
    final response = await http.post(
      Uri.parse(ApiService.pinNotification(id)),
      headers: {
        'Authorization': 'Bearer $authToken',
        'Content-Type': 'application/json',
      },
    );

    // 检查响应状态码
    if (response.statusCode == 200) {
      // 解析响应体
      final responseData = jsonDecode(response.body);
      final newPinned = responseData['pinned']; // 获取后端返回的 pinned 状态
      print("✅ Pin status updated on backend. New state: $newPinned");
      return newPinned; // 返回新的 pinned 状态
    } else {
      // 请求失败的情况
      print("❌ Failed to update pin status on backend. Status: ${response.statusCode}");
      print("Response body: ${response.body}");
      return null;
    }
  } catch (e) {
    // 捕获异常并打印错误
    print("❌ Error updating pin status on backend: $e");
    return null;
  }
}


  // 删除后端通知
  Future<bool> _deleteNotificationFromBackend(int id) async {
    final authToken = await _getAuthToken();
    if (authToken == null) {
      print("Auth token missing.");
      return false;
    }

    try {
      final response = await http.delete(
        Uri.parse(ApiService.notificationDetail(id)),
        headers: {
          'Authorization': 'Bearer $authToken',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        print("Notification deleted from backend successfully.");
        return true;
      } else {
        print("Failed to delete notification from backend.");
        return false;
      }
    } catch (e) {
      print("Error deleting notification from backend: $e");
      return false;
    }
  }

  // 清空后端通知
  Future<void> _clearNotificationsFromBackend() async {
    final authToken = await _getAuthToken();
    if (authToken == null) {
      print("Auth token missing.");
      return;
    }

    try {
      final response = await http.delete(
        Uri.parse(ApiService.notificationList),
        headers: {
          'Authorization': 'Bearer $authToken',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        print("Notifications cleared from backend successfully.");
      } else {
        print("Failed to clear notifications from backend.");
      }
    } catch (e) {
      print("Error clearing notifications from backend: $e");
    }
  }
  // 从后端拉取通知并更新本地缓存
  Future<List<NotificationModel>> fetchNotificationsFromBackend() async {
    final userId = await _getCurrentUserId();
    final authToken = await _getAuthToken();
    if (userId == null || authToken == null) {
      print("No user ID or auth token found. Cannot fetch notifications.");
      return [];
    }

    try {
      final response = await http.get(
        Uri.parse(ApiService.notificationByUser(userId)),  // 使用封装好的 URL
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $authToken', // 添加 Authorization 头部
        },
      );

      if (response.statusCode == 200) {
        final decodedBody = utf8.decode(response.bodyBytes);
        final List<dynamic> jsonResponse = jsonDecode(decodedBody);
        final notifications = jsonResponse.map((json) => NotificationModel.fromJson(json)).toList();

        // 更新本地缓存
        await _saveNotifications(notifications);

        print("Fetched and saved ${notifications.length} notifications from backend.");
        return notifications.cast<NotificationModel>();
      } else {
        print("Failed to fetch notifications from backend. Status code: ${response.statusCode}");
        return [];
      }
    } catch (e) {
      print("Error fetching notifications from backend: $e");
      return [];
    }
  }
}
