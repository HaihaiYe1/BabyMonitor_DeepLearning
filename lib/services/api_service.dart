import 'package:flutter/foundation.dart';

/// API服务配置
/// 
/// 使用 --dart-define 注入环境变量：
/// flutter run --dart-define=API_BASE_URL=https://api.example.com
/// flutter run --dart-define=LOCAL_IP=192.168.1.24
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
  
  // 局域网IP配置（mac桌面测试用）
  static const String _localIp = String.fromEnvironment(
    'LOCAL_IP',
    defaultValue: 'localhost',
  );

  // 基础 HTTP 地址
  static String get baseHttpUrl {
    if (_envBaseUrl.isNotEmpty) return _envBaseUrl;
    // 开发环境默认值（使用配置的IP）
    return kDebugMode ? 'http://$_localIp:8000' : 'https://api.babymonitor.com';
  }

  // 基础 WebSocket 地址
  static String get baseWsUrl {
    if (_envWsUrl.isNotEmpty) return _envWsUrl;
    // 开发环境默认值（使用配置的IP）
    return kDebugMode ? 'ws://$_localIp:8000' : 'wss://api.babymonitor.com';
  }

  // ==================== 设备相关接口 ====================
  static final String deviceList = '$baseHttpUrl/device/list';
  static final String deviceBase = '$baseHttpUrl/device';
  static final String deviceAdd = '$baseHttpUrl/device/add';
  static final String deviceGetRtspUrl = '$baseHttpUrl/device/get_rtsp_url';
  static String deviceDelete(int deviceId) => '$baseHttpUrl/device/delete?device_id=$deviceId';
  static String deviceDetail(int deviceId) => '$baseHttpUrl/device/$deviceId';
  static String videoDetectToggle(bool start, int deviceId) =>
      '$baseHttpUrl/video/${start ? "start" : "stop"}-detect?device_id=$deviceId';

  // ==================== 认证相关接口 ====================
  static final String authBase = '$baseHttpUrl/auth';
  static final String login = '$authBase/login';
  static final String register = '$authBase/register';
  static final String updatePassword = '$authBase/change-password';
  static final String updateUser = '$authBase/update-user';
  static final String userInfo = '$authBase/me';

  // ==================== 通知相关接口 ====================
  static final String notificationBase = '$baseHttpUrl/notification';
  static final String notificationList = '$notificationBase';
  static String notificationDetail(int id) => '$notificationBase/$id';
  static String pinNotification(int id) => '$notificationBase/$id/pin';
  static String notificationByUser(int userId) => '$notificationBase?user_id=$userId';

  // ==================== Agent相关接口 ====================
  static final String agentBase = '$baseHttpUrl/agent';
  static final String agentStatus = '$agentBase/status';
  static final String agentInitialize = '$agentBase/initialize';
  static final String agentChat = '$agentBase/chat';
  static final String agentResetMemory = '$agentBase/reset-memory';
  static final String agentPreferences = '$agentBase/preferences';
  static final String agentMemorySummary = '$agentBase/memory-summary';
  static final String agentAllAgents = '$agentBase/all-agents';
  static final String agentRemove = '$agentBase/remove';

  // ==================== RAG育儿知识库接口 ====================
  static final String ragBase = '$baseHttpUrl/rag';
  static final String ragAdvice = '$ragBase/advice';
  static final String ragEmergencyAdvice = '$ragBase/emergency-advice';
  static final String ragKnowledgeStats = '$ragBase/knowledge-stats';
  static final String ragSearchKnowledge = '$ragBase/search-knowledge';
  static final String ragAddKnowledge = '$ragBase/add-knowledge';

  // ==================== 智能家居控制接口 ====================
  static final String smartHomeBase = '$baseHttpUrl/smart-home';
  static final String smartHomeStatus = '$smartHomeBase/status';
  static final String speakerControl = '$smartHomeBase/speaker/control';
  static final String lightControl = '$smartHomeBase/light/control';
  static final String sceneActivate = '$smartHomeBase/scene/activate';
  static final String smartHomeScenes = '$smartHomeBase/scenes';
  static final String quickSleep = '$smartHomeBase/quick/sleep';
  static final String quickComfort = '$smartHomeBase/quick/comfort';
  static final String quickAlert = '$smartHomeBase/quick/alert';

  // ==================== 视频检测接口 ====================
  static String agentDetect(int deviceId, {int maxFrames = 5, bool useAgent = true}) =>
      '$baseHttpUrl/video/agent-detect?device_id=$deviceId&max_frames=$maxFrames&use_agent=$useAgent';
  static String vlmDetect(int deviceId, {int maxFrames = 3, bool useVlm = true}) =>
      '$baseHttpUrl/video/vlm-detect?device_id=$deviceId&max_frames=$maxFrames&use_vlm=$useVlm';
  static String startDetect(int deviceId) =>
      '$baseHttpUrl/video/start-detect?device_id=$deviceId';
  static String stopDetect(int deviceId) =>
      '$baseHttpUrl/video/stop-detect?device_id=$deviceId';
  static final String videoAgentStatus = '$baseHttpUrl/video/agent-status';
  static final String videoAgentPreferences = '$baseHttpUrl/video/agent-preferences';
  static String videoDetect({int? deviceId, String? videoPath, int maxFrames = 10}) {
    String url = '$baseHttpUrl/video/detect?max_frames=$maxFrames';
    if (deviceId != null) url += '&device_id=$deviceId';
    if (videoPath != null) url += '&video_path=${Uri.encodeComponent(videoPath)}';
    return url;
  }

  // ==================== 性能监控接口 ====================
  static final String monitoringBase = '$baseHttpUrl/monitoring';
  static final String monitoringStats = '$monitoringBase/stats';
  static final String monitoringConnections = '$monitoringBase/connections';
  static final String monitoringDeviceSubscriptions = '$monitoringBase/device-subscriptions';
  static final String monitoringAudioStats = '$monitoringBase/audio-stats';
  static String monitoringConnection(String clientId) => '$monitoringBase/connection/$clientId';
  static final String monitoringBroadcast = '$monitoringBase/broadcast';
  static String monitoringSendToDevice(int deviceId) => '$monitoringBase/send-to-device/$deviceId';
  static final String monitoringResetStats = '$monitoringBase/reset-stats';

  // ==================== 测试接口 ====================
  static final String timingBase = '$baseHttpUrl/timing';
  static final String timingTest = '$timingBase/timing';

  // ==================== WebSocket流地址 ====================
  static String videoStreamWs(int deviceId, String clientId) =>
      '$baseWsUrl/ws/stream/video-stream/$deviceId?client_id=$clientId';
  static String audioStreamWs(int deviceId, String clientId, {int sampleRate = 16000}) =>
      '$baseWsUrl/ws/stream/audio-stream/$deviceId?client_id=$clientId&sample_rate=$sampleRate';
  static String intercomWs(int deviceId, String clientId, {String role = 'speaker'}) =>
      '$baseWsUrl/ws/stream/intercom/$deviceId?client_id=$clientId&role=$role';
  static String agentStreamWs(String clientId, int userId) =>
      '$baseWsUrl/ws/stream/agent-stream?client_id=$clientId&user_id=$userId';
  static final String alertsWebSocket = '$baseWsUrl/ws/alerts';
}
