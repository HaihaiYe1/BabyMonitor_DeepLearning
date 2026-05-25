import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'api_service.dart';

class SmartHomeService {
  // 单例模式
  static final SmartHomeService _instance = SmartHomeService._internal();
  factory SmartHomeService() => _instance;
  SmartHomeService._internal();

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

  // 获取智能家居系统状态
  Future<Map<String, dynamic>> getSmartHomeStatus() async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse(ApiService.smartHomeStatus),
        headers: headers,
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        return {'success': false, 'error': '获取状态失败: ${response.statusCode}'};
      }
    } catch (e) {
      return {'success': false, 'error': '获取状态异常: $e'};
    }
  }

  // 控制智能音箱
  Future<Map<String, dynamic>> controlSpeaker({
    required String action,
    String? content,
    int? volume,
    int? duration,
  }) async {
    try {
      final headers = await _getHeaders();
      String url = '${ApiService.speakerControl}?action=$action';
      if (content != null) url += '&content=$content';
      if (volume != null) url += '&volume=$volume';
      if (duration != null) url += '&duration=$duration';

      final response = await http.post(
        Uri.parse(url),
        headers: headers,
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        return {'success': false, 'error': '音箱控制失败: ${response.statusCode}'};
      }
    } catch (e) {
      return {'success': false, 'error': '音箱控制异常: $e'};
    }
  }

  // 控制灯光
  Future<Map<String, dynamic>> controlLight({
    required String action,
    int? brightness,
    String? color,
    String? mode,
  }) async {
    try {
      final headers = await _getHeaders();
      String url = '${ApiService.lightControl}?action=$action';
      if (brightness != null) url += '&brightness=$brightness';
      if (color != null) url += '&color=$color';
      if (mode != null) url += '&mode=$mode';

      final response = await http.post(
        Uri.parse(url),
        headers: headers,
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        return {'success': false, 'error': '灯光控制失败: ${response.statusCode}'};
      }
    } catch (e) {
      return {'success': false, 'error': '灯光控制异常: $e'};
    }
  }

  // 激活场景模式
  Future<Map<String, dynamic>> activateScene({
    required String scene,
    int? duration,
    String? intensity,
  }) async {
    try {
      final headers = await _getHeaders();
      String url = '${ApiService.sceneActivate}?scene=$scene';
      if (duration != null) url += '&duration=$duration';
      if (intensity != null) url += '&intensity=$intensity';

      final response = await http.post(
        Uri.parse(url),
        headers: headers,
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        return {'success': false, 'error': '场景激活失败: ${response.statusCode}'};
      }
    } catch (e) {
      return {'success': false, 'error': '场景激活异常: $e'};
    }
  }

  // 获取可用场景列表
  Future<Map<String, dynamic>> getAvailableScenes() async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse(ApiService.smartHomeScenes),
        headers: headers,
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        return {'success': false, 'error': '获取场景列表失败: ${response.statusCode}'};
      }
    } catch (e) {
      return {'success': false, 'error': '获取场景列表异常: $e'};
    }
  }

  // 快速启动睡眠模式
  Future<Map<String, dynamic>> quickSleepMode({int duration = 60}) async {
    try {
      final headers = await _getHeaders();
      final response = await http.post(
        Uri.parse('${ApiService.quickSleep}?duration=$duration'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        return {'success': false, 'error': '启动睡眠模式失败: ${response.statusCode}'};
      }
    } catch (e) {
      return {'success': false, 'error': '启动睡眠模式异常: $e'};
    }
  }

  // 快速启动安抚模式
  Future<Map<String, dynamic>> quickComfortMode({String intensity = 'medium'}) async {
    try {
      final headers = await _getHeaders();
      final response = await http.post(
        Uri.parse('${ApiService.quickComfort}?intensity=$intensity'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        return {'success': false, 'error': '启动安抚模式失败: ${response.statusCode}'};
      }
    } catch (e) {
      return {'success': false, 'error': '启动安抚模式异常: $e'};
    }
  }

  // 快速启动警报模式
  Future<Map<String, dynamic>> quickAlertMode() async {
    try {
      final headers = await _getHeaders();
      final response = await http.post(
        Uri.parse(ApiService.quickAlert),
        headers: headers,
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        return {'success': false, 'error': '启动警报模式失败: ${response.statusCode}'};
      }
    } catch (e) {
      return {'success': false, 'error': '启动警报模式异常: $e'};
    }
  }

  // 获取MQTT消息历史
  Future<Map<String, dynamic>> getMqttHistory({String? topic, int limit = 50}) async {
    try {
      final headers = await _getHeaders();
      String url = '${ApiService.smartHomeBase}/mqtt/history?limit=$limit';
      if (topic != null) url += '&topic=$topic';

      final response = await http.get(
        Uri.parse(url),
        headers: headers,
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        return {'success': false, 'error': '获取MQTT历史失败: ${response.statusCode}'};
      }
    } catch (e) {
      return {'success': false, 'error': '获取MQTT历史异常: $e'};
    }
  }
}
