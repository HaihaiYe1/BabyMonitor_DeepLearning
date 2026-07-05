import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'api_service.dart';

class AuthService {
  // 单例模式
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  final String baseUrl = ApiService.authBase;

  /// 用户注册
  Future<bool> register(String email, String password, String username) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/register'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'email': email,
          'password': password,
          'username': username,
        }),
      );

      if (response.statusCode == 200) {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('email', email);
        await prefs.setString('username', username);
        return true;
      } else {
        debugPrint("注册失败: ${response.body}");
        return false;
      }
    } catch (e) {
      debugPrint("注册错误: $e");
      return false;
    }
  }

  /// 用户登录
  Future<bool> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/login'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'email': email, 'password': password}),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);

        if (!data.containsKey('token') || data['token'] == null) {
          debugPrint("登录失败: 后端未返回 token");
          return false;
        }

        String token = data['token'] ?? data['access_token'];
        String? username = data['username'];
        int? userId = data['id'];

        if (token.isNotEmpty && username != null) {
          SharedPreferences prefs = await SharedPreferences.getInstance();
          await prefs.setString('token', token);
          await prefs.setString('email', email);
          await prefs.setString('username', username);
          await prefs.setInt('user_id', userId ?? 0);
          return true;
        }
      }
      debugPrint("登录失败: 无效凭证");
      return false;
    } catch (e) {
      debugPrint("登录错误: $e");
      return false;
    }
  }

  /// 修改密码
  Future<bool> changePassword(String oldPassword, String newPassword) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('token');

      if (token == null) {
        debugPrint("错误: 用户未登录");
        return false;
      }

      final response = await http.put(
        Uri.parse('$baseUrl/change-password'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({
          'old_password': oldPassword,
          'new_password': newPassword,
        }),
      );

      return response.statusCode == 200;
    } catch (e) {
      debugPrint("修改密码错误: $e");
      return false;
    }
  }

  /// 检查 Token 是否过期
  Future<bool> isTokenExpired(String token) async {
    try {
      final parts = token.split('.');
      if (parts.length != 3) return true;

      final payload = utf8.decode(base64Url.decode(base64Url.normalize(parts[1])));
      final Map<String, dynamic> decodedToken = jsonDecode(payload);

      final exp = decodedToken['exp'];
      if (exp == null) return true;

      final expirationDate = DateTime.fromMillisecondsSinceEpoch(exp * 1000);
      return DateTime.now().isAfter(expirationDate);
    } catch (e) {
      debugPrint("解码token错误: $e");
      return true;
    }
  }

  /// 请求设备数据
  Future<void> fetchDeviceData(BuildContext context) async {
    String? token = await getToken();
    if (token == null || await isTokenExpired(token)) {
      debugPrint("Token已过期或缺失，请重新登录");
      if (context.mounted) {
        _showLoginDialog(context);
      }
    } else {
      final response = await http.get(
        Uri.parse(ApiService.deviceList),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 401) {
        debugPrint("Token已过期或未授权");
        if (context.mounted) {
          _showLoginDialog(context);
        }
      }
    }
  }

  /// 弹出重新登录的对话框
  void _showLoginDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text("会话已过期"),
        content: const Text("您的会话已过期，请重新登录"),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              logout(context);
            },
            child: const Text("重新登录"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("取消"),
          ),
        ],
      ),
    );
  }

  /// 获取当前存储的 token
  Future<String?> getToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  /// 获取当前存储的用户名
  Future<String?> getUsername() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('username');
  }

  /// 获取当前存储的邮箱
  Future<String?> getEmail() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('email');
  }

  /// 更新用户名
  Future<bool> updateUsername(String newUsername) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('token');

      if (token == null) {
        debugPrint("错误: 用户未登录");
        return false;
      }

      final response = await http.put(
        Uri.parse(ApiService.updateUser),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({'username': newUsername}),
      );

      if (response.statusCode == 200) {
        await prefs.setString('username', newUsername);
        return true;
      } else {
        debugPrint("更新用户名失败: ${response.body}");
        return false;
      }
    } catch (e) {
      debugPrint("更新用户名错误: $e");
      return false;
    }
  }

  /// 检查用户是否已经登录
  Future<bool> isLoggedIn() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    if (token == null || token.isEmpty) return false;
    return !await isTokenExpired(token);
  }

  /// 用户登出
  Future<void> logout(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    await prefs.remove('email');
    await prefs.remove('username');
    await prefs.remove('user_id');
    
    if (context.mounted) {
      Navigator.pushNamedAndRemoveUntil(
        context,
        '/login',
        (route) => false,
      );
    }
  }
}
