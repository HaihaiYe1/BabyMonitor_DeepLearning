import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'api_service.dart';

class AgentService {
  // 单例模式
  static final AgentService _instance = AgentService._internal();
  factory AgentService() => _instance;
  AgentService._internal();

  // 获取认证token
  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  // 获取请求头
  Future<Map<String, String>> _getHeaders() async {
    final token = await _getToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  // 获取Agent状态
  Future<Map<String, dynamic>> getAgentStatus() async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse(ApiService.agentStatus),
        headers: headers,
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        return {'success': false, 'error': '获取Agent状态失败: ${response.statusCode}'};
      }
    } catch (e) {
      return {'success': false, 'error': '获取Agent状态异常: $e'};
    }
  }

  // 初始化Agent
  Future<Map<String, dynamic>> initializeAgent({
    bool useAgentMode = true,
    String modelName = 'MiMo-V2.5-Pro',
  }) async {
    try {
      final headers = await _getHeaders();
      final response = await http.post(
        Uri.parse('${ApiService.agentInitialize}?use_agent_mode=$useAgentMode&model_name=$modelName'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        return {'success': false, 'error': '初始化Agent失败: ${response.statusCode}'};
      }
    } catch (e) {
      return {'success': false, 'error': '初始化Agent异常: $e'};
    }
  }

  // 与Agent对话
  Future<Map<String, dynamic>> chatWithAgent(String message, {int? deviceId}) async {
    try {
      final headers = await _getHeaders();
      String url = '${ApiService.agentChat}?message=${Uri.encodeComponent(message)}';
      if (deviceId != null) {
        url += '&device_id=$deviceId';
      }

      final response = await http.post(
        Uri.parse(url),
        headers: headers,
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        return {'success': false, 'error': '与Agent对话失败: ${response.statusCode}'};
      }
    } catch (e) {
      return {'success': false, 'error': '与Agent对话异常: $e'};
    }
  }

  // 重置Agent记忆
  Future<Map<String, dynamic>> resetAgentMemory() async {
    try {
      final headers = await _getHeaders();
      final response = await http.post(
        Uri.parse(ApiService.agentResetMemory),
        headers: headers,
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        return {'success': false, 'error': '重置记忆失败: ${response.statusCode}'};
      }
    } catch (e) {
      return {'success': false, 'error': '重置记忆异常: $e'};
    }
  }

  // 更新Agent偏好设置
  Future<Map<String, dynamic>> updateAgentPreferences(Map<String, dynamic> preferences) async {
    try {
      final headers = await _getHeaders();
      final response = await http.put(
        Uri.parse(ApiService.agentPreferences),
        headers: headers,
        body: json.encode(preferences),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        return {'success': false, 'error': '更新偏好失败: ${response.statusCode}'};
      }
    } catch (e) {
      return {'success': false, 'error': '更新偏好异常: $e'};
    }
  }

  // 获取Agent记忆摘要
  Future<Map<String, dynamic>> getAgentMemorySummary() async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse(ApiService.agentMemorySummary),
        headers: headers,
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        return {'success': false, 'error': '获取记忆摘要失败: ${response.statusCode}'};
      }
    } catch (e) {
      return {'success': false, 'error': '获取记忆摘要异常: $e'};
    }
  }

  // 启动Agent检测
  Future<Map<String, dynamic>> startAgentDetect(int deviceId, {int maxFrames = 5}) async {
    try {
      final headers = await _getHeaders();
      final response = await http.post(
        Uri.parse(ApiService.agentDetect(deviceId, maxFrames: maxFrames)),
        headers: headers,
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        return {'success': false, 'error': '启动Agent检测失败: ${response.statusCode}'};
      }
    } catch (e) {
      return {'success': false, 'error': '启动Agent检测异常: $e'};
    }
  }

  // 启动VLM检测
  Future<Map<String, dynamic>> startVlmDetect(int deviceId, {int maxFrames = 3}) async {
    try {
      final headers = await _getHeaders();
      final response = await http.post(
        Uri.parse(ApiService.vlmDetect(deviceId, maxFrames: maxFrames)),
        headers: headers,
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        return {'success': false, 'error': '启动VLM检测失败: ${response.statusCode}'};
      }
    } catch (e) {
      return {'success': false, 'error': '启动VLM检测异常: $e'};
    }
  }
}
