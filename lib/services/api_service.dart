// lib/services/api_service.dart

class ApiService {
  // 基础 HTTP 地址
  static const String baseHttpUrl = 'http://10.0.2.2:8000';
  // static const String baseHttpUrl = 'http://localhost:8000';

  // 基础 WebSocket 地址
  static const String baseWsUrl = 'ws://10.0.2.2:8000';
  // static const String baseWsUrl = 'ws://localhost:8000';

  // 设备相关接口
  static const String deviceList = '$baseHttpUrl/device/list';
  static const String deviceBase = '$baseHttpUrl/device';
  static String videoDetectToggle(bool start, int deviceId) =>
      '$baseHttpUrl/video/${start ? "start" : "stop"}-detect?device_id=$deviceId';

  // 认证相关接口
  static const String authBase = '$baseHttpUrl/auth';
  static const String login = '$authBase/login';
  static const String register = '$authBase/register';

  // 通知相关接口
  static const String notificationBase = '$baseHttpUrl/notification';
  static const String notificationList = '$notificationBase';
  static String notificationDetail(int id) => '$notificationBase/$id';
  static String pinNotification(int id) => '$notificationBase/$id/pin';
  static String notificationByUser(int userId) => '$notificationBase?user_id=$userId';

  // WebSocket 地址
  static const String alertsWebSocket = '$baseWsUrl/ws/alerts';
  static const String notificationWebSocket = '$baseWsUrl/ws/notifications';
}
