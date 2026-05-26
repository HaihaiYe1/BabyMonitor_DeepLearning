import 'package:flutter/foundation.dart';

/// API服务配置
/// 
/// 使用 --dart-define 注入环境变量：
/// flutter run --dart-define=API_BASE_URL=https://api.example.com
class ApiService {
  // 从环境变量读取，或使用默认值
  static const String _envBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: '',
  );
  
  static const String _envWsUrl = String.fromEnvironment(
    'WS_BASE_URL',
    defaultValue: '',
  );

  // 基础 HTTP 地址
  static String get baseHttpUrl {
    if (_envBaseUrl.isNotEmpty) return _envBaseUrl;
    // 开发环境默认值
    return kDebugMode ? 'http://localhost:8000' : 'https://api.babymonitor.com';
  }

  // 基础 WebSocket 地址
  static String get baseWsUrl {
    if (_envWsUrl.isNotEmpty) return _envWsUrl;
    return kDebugMode ? 'ws://localhost:8000' : 'wss://api.babymonitor.com';
  }

  // ==================== 设备相关接口 ====================
  static const String deviceList = '$baseHttpUrl/device/list';
  static const String deviceBase = '$baseHttpUrl/device';
  static String videoDetectToggle(bool start, int deviceId) =>
      '$baseHttpUrl/video/${start ? "start" : "stop"}-detect?device_id=$deviceId';

  // ==================== 认证相关接口 ====================
  static const String authBase = '$baseHttpUrl/auth';
  static const String login = '$authBase/login';
  static const String register = '$authBase/register';
  static const String updatePassword = '$authBase/change-password';
  static const String updateUser = '$authBase/update-user';
  static const String userInfo = '$authBase/me';

  // ==================== 通知相关接口 ====================
  static const String notificationBase = '$baseHttpUrl/notification';
  static const String notificationList = '$notificationBase';
  static String notificationDetail(int id) => '$notificationBase/$id';
  static String pinNotification(int id) => '$notificationBase/$id/pin';
  static String notificationByUser(int userId) => '$notificationBase?user_id=$userId';

  // ==================== Agent相关接口 ====================
  static const String agentBase = '$baseHttpUrl/agent';
  static const String agentStatus = '$agentBase/status';
  static const String agentInitialize = '$agentBase/initialize';
  static const String agentChat = '$agentBase/chat';
  static const String agentResetMemory = '$agentBase/reset-memory';
  static const String agentPreferences = '$agentBase/preferences';
  static const String agentMemorySummary = '$agentBase/memory-summary';

  // ==================== RAG育儿知识库接口 ====================
  static const String ragBase = '$baseHttpUrl/rag';
  static const String ragAdvice = '$ragBase/advice';
  static const String ragEmergencyAdvice = '$ragBase/emergency-advice';
  static const String ragKnowledgeStats = '$ragBase/knowledge-stats';
  static const String ragSearchKnowledge = '$ragBase/search-knowledge';
  static const String ragAddKnowledge = '$ragBase/add-knowledge';

  // ==================== 智能家居控制接口 ====================
  static const String smartHomeBase = '$baseHttpUrl/smart-home';
  static const String smartHomeStatus = '$smartHomeBase/status';
  static const String speakerControl = '$smartHomeBase/speaker/control';
  static const String lightControl = '$smartHomeBase/light/control';
  static const String sceneActivate = '$smartHomeBase/scene/activate';
  static const String smartHomeScenes = '$smartHomeBase/scenes';
  static const String quickSleep = '$smartHomeBase/quick/sleep';
  static const String quickComfort = '$smartHomeBase/quick/comfort';
  static const String quickAlert = '$smartHomeBase/quick/alert';

  // ==================== 视频检测接口 ====================
  static String agentDetect(int deviceId, {int maxFrames = 5, bool useAgent = true}) =>
      '$baseHttpUrl/video/agent-detect?device_id=$deviceId&max_frames=$maxFrames&use_agent=$useAgent';
  static String vlmDetect(int deviceId, {int maxFrames = 3, bool useVlm = true}) =>
      '$baseHttpUrl/video/vlm-detect?device_id=$deviceId&max_frames=$maxFrames&use_vlm=$useVlm';
  static String startDetect(int deviceId) =>
      '$baseHttpUrl/video/start-detect?device_id=$deviceId';
  static String stopDetect(int deviceId) =>
      '$baseHttpUrl/video/stop-detect?device_id=$deviceId';

  // ==================== 性能监控接口 ====================
  static const String monitoringBase = '$baseHttpUrl/monitoring';
  static const String monitoringStats = '$monitoringBase/stats';
  static const String monitoringConnections = '$monitoringBase/connections';
  static const String monitoringDeviceSubscriptions = '$monitoringBase/device-subscriptions';
  static const String monitoringAudioStats = '$monitoringBase/audio-stats';

  // ==================== 测试接口 ====================
  static const String timingBase = '$baseHttpUrl/timing';
  static const String timingTest = '$timingBase/timing';

  // ==================== WebSocket流地址 ====================
  static String videoStreamWs(int deviceId, String clientId) =>
      '$baseWsUrl/ws/stream/video-stream/$deviceId?client_id=$clientId';
  static String audioStreamWs(int deviceId, String clientId, {int sampleRate = 16000}) =>
      '$baseWsUrl/ws/stream/audio-stream/$deviceId?client_id=$clientId&sample_rate=$sampleRate';
  static String intercomWs(int deviceId, String clientId, {String role = 'speaker'}) =>
      '$baseWsUrl/ws/stream/intercom/$deviceId?client_id=$clientId&role=$role';
  static String agentStreamWs(String clientId, int userId) =>
      '$baseWsUrl/ws/stream/agent-stream?client_id=$clientId&user_id=$userId';
  static const String alertsWebSocket = '$baseWsUrl/ws/alerts';
}
