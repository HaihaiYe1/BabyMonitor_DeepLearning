import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'api_service.dart';

class RagService {
  // 单例模式
  static final RagService _instance = RagService._internal();
  factory RagService() => _instance;
  RagService._internal();

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

  // 获取育儿建议
  Future<Map<String, dynamic>> getAdvice({
    required String situation,
    int? babyAgeMonths,
    String? context,
  }) async {
    try {
      final headers = await _getHeaders();
      String url = '${ApiService.ragAdvice}?situation=${Uri.encodeComponent(situation)}';
      if (babyAgeMonths != null) {
        url += '&baby_age_months=$babyAgeMonths';
      }
      if (context != null) {
        url += '&context=${Uri.encodeComponent(context)}';
      }

      final response = await http.post(
        Uri.parse(url),
        headers: headers,
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        return {'success': false, 'error': '获取建议失败: ${response.statusCode}'};
      }
    } catch (e) {
      return {'success': false, 'error': '获取建议异常: $e'};
    }
  }

  // 获取紧急建议
  Future<Map<String, dynamic>> getEmergencyAdvice({
    required String emergencyType,
    required String details,
  }) async {
    try {
      final headers = await _getHeaders();
      final url = '${ApiService.ragEmergencyAdvice}?emergency_type=${Uri.encodeComponent(emergencyType)}&details=${Uri.encodeComponent(details)}';

      final response = await http.post(
        Uri.parse(url),
        headers: headers,
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        return {'success': false, 'error': '获取紧急建议失败: ${response.statusCode}'};
      }
    } catch (e) {
      return {'success': false, 'error': '获取紧急建议异常: $e'};
    }
  }

  // 获取知识库统计
  Future<Map<String, dynamic>> getKnowledgeStats() async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse(ApiService.ragKnowledgeStats),
        headers: headers,
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        return {'success': false, 'error': '获取统计失败: ${response.statusCode}'};
      }
    } catch (e) {
      return {'success': false, 'error': '获取统计异常: $e'};
    }
  }

  // 搜索知识库
  Future<Map<String, dynamic>> searchKnowledge({
    required String query,
    int nResults = 5,
    String? category,
  }) async {
    try {
      final headers = await _getHeaders();
      String url = '${ApiService.ragSearchKnowledge}?query=${Uri.encodeComponent(query)}&n_results=$nResults';
      if (category != null) {
        url += '&category=${Uri.encodeComponent(category)}';
      }

      final response = await http.post(
        Uri.parse(url),
        headers: headers,
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        return {'success': false, 'error': '搜索失败: ${response.statusCode}'};
      }
    } catch (e) {
      return {'success': false, 'error': '搜索异常: $e'};
    }
  }

  // 添加知识
  Future<Map<String, dynamic>> addKnowledge({
    required String content,
    String category = 'general',
    String? source,
  }) async {
    try {
      final headers = await _getHeaders();
      String url = '${ApiService.ragAddKnowledge}?content=${Uri.encodeComponent(content)}&category=$category';
      if (source != null) {
        url += '&source=${Uri.encodeComponent(source)}';
      }

      final response = await http.post(
        Uri.parse(url),
        headers: headers,
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        return {'success': false, 'error': '添加知识失败: ${response.statusCode}'};
      }
    } catch (e) {
      return {'success': false, 'error': '添加知识异常: $e'};
    }
  }
}
