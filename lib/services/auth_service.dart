import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:my_first_app/services/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../pages/login_page.dart';

class AuthService {
  final String baseUrl = ApiService.authBase;

  // 用户注册
  Future<bool> register(String email, String password, String username) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/register'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'email': email,
          'password': password,
          'username': username,  // 发送用户名字段
        }),
      );

      if (response.statusCode == 200) {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('email', email);
        await prefs.setString('username', username);
        print("Register successful, email & username saved.");
        return true;
      } else {
        print("Register failed: ${response.body}");
        return false;
      }
    } catch (e) {
      print("Register Error: $e");
      return false;
    }
  }

  // 用户登录
  Future<bool> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/login'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'email': email, 'password': password}),
      );

      // 打印响应状态码和响应体
      print("Response Status: ${response.statusCode}");
      print("Response Body: ${response.body}"); // 检查后端返回的数据

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);

      // 确保 `data` 里有 token
      if (!data.containsKey('token') || data['token'] == null) {
        print("登录失败: 后端未返回 token");
        return false;
      }

      String token = data['token'] ?? data['access_token'];
      String? username = data['username'];
      int? userId = data['id']; // 获取用户的 id

      if (token != null && username != null && token.isNotEmpty) {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', token);
        await prefs.setString('email', email); // 存储 email
        await prefs.setString('username', username); // 存储 username
        await prefs.setInt('user_id', userId ?? 0); // 存储用户的 id
        print("Login successful, token & email & userId saved.");

        // 打印 userId
        print("😀 User ID: $userId");

        // 确保 token 真的存入了
        String? storedToken = prefs.getString('token');
        print("🥹 Token actually saved: $storedToken");

          return true;
        } else {
          print("Login failed: Token or Username is null or empty");
        }
      } else {
        print("Login failed: Invalid credentials");
      }
      return false;
    } catch (e) {
      print("Login Error: $e");
      return false;
    }
  }

  // 修改密码
  Future<bool> changePassword(String oldPassword, String newPassword) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? email = prefs.getString('email');
      String? token = prefs.getString('token');

      if (email == null || token == null) {
        print("Error: User not logged in.");
        return false;
      }

      final response = await http.put(
        Uri.parse('$baseUrl/change-password'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({
          'email': email,
          'old_password': oldPassword,
          'new_password': newPassword,
        }),
      );

      if (response.statusCode == 200) {
        print("Password changed successfully.");
        return true;
      } else {
        print("Failed to change password: ${response.body}");
        return false;
      }
    } catch (e) {
      print("Error changing password: $e");
      return false;
    }
  }

  // 检查 Token 是否过期
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
      print("Error decoding token: $e");
      return true; // 如果解码出错，则认为 token 已过期
    }
  }

  // 请求设备数据的示例（示范如何检测 token 是否过期）
  Future<void> fetchDeviceData(BuildContext context) async {
    String? token = await getToken();
    if (token == null || await isTokenExpired(token)) {
      // 如果 token 已过期或不存在，则提示用户重新登录
      print("Token expired or missing, please log in again.");

      // 弹出提示框
      _showLoginDialog(context);
    } else {
      // 执行正常的 API 请求
      final response = await http.get(
        Uri.parse(ApiService.deviceList),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        // 处理返回的数据
        print("Device data fetched: ${response.body}");
      } else if (response.statusCode == 401) {
        print("Token expired or unauthorized.");
        // 这里可以调用登出方法或重新登录的提示
        _showLoginDialog(context);
      }
    }
  }

  // 弹出重新登录的对话框
  void _showLoginDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false, // 禁止点击背景关闭对话框
      builder: (context) => AlertDialog(
        title: Text("Session Expired"),
        content: Text("Your session has expired. Please log in again."),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              logout(context);
            },
            child: Text("重新登录"),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context); // 只是关闭对话框
            },
            child: Text("取消"),
          ),
        ],
      ),
    );
  }

  // 获取当前存储的 token
  Future<String?> getToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    print("🔍 getToken() 读取到的 Token: $token");
    return prefs.getString('token');
  }

  /// 获取当前存储的用户名
  Future<String?> getUsername() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('username');
  }

  // 获取当前存储的邮箱
  Future<String?> getEmail() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('email');
  }

  /// 更新用户名（同步数据库）
  Future<bool> updateUsername(String newUsername) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? email = prefs.getString('email'); // 获取本地存储的 email
      String? token = prefs.getString('token'); // 认证 Token

      if (email == null || token == null) {
        print("Error: User not logged in.");
        return false;
      }

      final response = await http.put(
        Uri.parse('$baseUrl/update-user?email=$email'), // 传递 email 作为查询参数
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token', // 需要认证
        },
        body: json.encode({'username': newUsername}),
      );

      print("Response Status: ${response.statusCode}");
      print("Response Body: ${response.body}");

      if (response.statusCode == 200) {
        await prefs.setString('username', newUsername); // 更新本地存储
        print("Username updated successfully.");
        return true;
      } else {
        print("Failed to update username: ${response.body}");
        return false;
      }
    } catch (e) {
      print("Error updating username: $e");
      return false;
    }
  }

  /// 检查用户是否已经登录
  Future<bool> isLoggedIn() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.containsKey('token');
  }

  /// 用户登出
  Future<void> logout(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('token'); // 清除 Token
    await prefs.remove('email'); // 清除 email
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => LoginPage()),
          (route) => false, // 清空所有历史记录
    );
  }
}
