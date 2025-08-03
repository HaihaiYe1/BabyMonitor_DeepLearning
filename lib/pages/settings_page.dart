import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:my_first_app/services/notification_service.dart';
import 'package:my_first_app/providers/language_provider.dart'; // 导入语言管理器
import 'package:my_first_app/generated/l10n.dart';
import 'package:http/http.dart' as http;

import '../services/api_service.dart';

class SettingsPage extends ConsumerStatefulWidget {
  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends ConsumerState<SettingsPage> {
  bool _isNotificationsEnabled = true;
  bool _isDetectionEnabled = false; // 新增：检测开关状态
  String _selectedLanguage = 'English';
  String? _selectedDeviceId;
  List<Map<String, dynamic>> _deviceList = [];

  final NotificationService _notificationService = NotificationService(); // 通知服务实例

  @override
  void initState() {
    super.initState();
    _loadSettings();
    _notificationService.initialize();
    _loadDevices(); // 加载设备列表
  }

  /// 从 SharedPreferences 读取设置
  Future<void> _loadSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      setState(() {
        _isNotificationsEnabled = prefs.getBool('notifications_enabled') ?? true;
        _selectedLanguage = prefs.getString('language') ?? 'English';
        _isDetectionEnabled = prefs.getBool('detection_enabled') ?? false;
        _selectedDeviceId = prefs.getString('selected_device_id');
      });

      ref.read(languageProvider.notifier).state = _selectedLanguage;
    } catch (e) {
      print("Error loading settings: $e");
    }
  }

  /// 更新通知设置
  Future<void> _updateNotificationSetting(bool value) async {
    setState(() => _isNotificationsEnabled = value);
    await _updateSetting('notifications_enabled', value);

    // 更新 NotificationService 的状态
    await _notificationService.updateNotificationSetting(value);

    if (value) {
      // 通知启用时，显示通知
      _notificationService.showNotification(
        id: 1,
        title: '通知已启用',
        body: '你将收到应用的提醒！',
      );
    } else {
      // 通知禁用时，不再显示通知，但保留历史记录
      _notificationService.cancelAllNotifications();
    }
  }

  /// 更新视频检测设置
  Future<void> _updateDetectionSetting(bool value) async {
    setState(() => _isDetectionEnabled = value);
    await _updateSetting('detection_enabled', value);
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token'); // 获取 token

    if (_selectedDeviceId == null) {
      print("请先选择设备！");
      return;
    }

  // 添加设备加载成功的 print
  print("已选择设备 ID: $_selectedDeviceId");

  final url = Uri.parse(ApiService.videoDetectToggle(value, int.parse(_selectedDeviceId!)));

  try {
    final response = await http.post(
      url,
      headers: {
        'Authorization': 'Bearer $token', // 请替换成实际的 token
      },
    );

      if (response.statusCode == 200) {
        print("视频检测已${value ? "启用" : "关闭"}");
      } else {
        print("!!!!!!!!!!后端请求失败：${response.statusCode}");
      }
    } catch (e) {
      print("检测接口调用失败: $e");
    }
  }

  /// 更新设置值
  Future<void> _updateSetting(String key, dynamic value) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (value is bool) {
        await prefs.setBool(key, value);
      } else if (value is String) {
        await prefs.setString(key, value);
      }
    } catch (e) {
      print("Error updating setting [$key]: $e");
    }
  }

Future<void> _loadDevices() async {
  try {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token'); // 获取 token

    // 如果没有 token，提示用户登录
    if (token == null) {
      print("请先登录！");
      return;
    }

    final response = await http.get(
      Uri.parse(ApiService.deviceList),
      headers: {
        'Authorization': 'Bearer $token', // 将 token 添加到请求头中
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      setState(() {
        _deviceList = data.map((d) => {
              'id': d['id'].toString(),
              'name': d['name'] ?? '设备 ${d['id']}',
            }).toList();
      });
    } else {
      print("加载设备失败：${response.statusCode}");
    }
  } catch (e) {
    print("设备列表请求失败: $e");
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // 背景渐变
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFFE3FDFD),
                  Color(0xFFFFE6FA),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          // 设置列表
          ListView(
            padding: const EdgeInsets.only(
                top: 40, left: 16, right: 16, bottom: 16),
            children: [
              _buildSectionTitle('Account Management'),
              _buildInfoTile(
                title: S
                    .of(context)
                    .manage_account, // 本地化文本
                icon: Icons.person,
                onTap: () {
                  Navigator.pushNamed(context, '/account');
                },
              ),
              const SizedBox(height: 20),
              _buildSectionTitle(S
                  .of(context)
                  .device_management), // 本地化文本
              _buildInfoTile(
                title: S
                    .of(context)
                    .manage_devices, // 本地化文本
                icon: Icons.devices,
                onTap: () {
                  Navigator.pushNamed(context, '/devices');
                },
              ),
              _buildDropdownTile(
                title: '选择设备',
                icon: Icons.device_hub,
                value: _selectedDeviceId,
                options: _deviceList.map((d) => d['id'] as String).toList(),
                displayNames: _deviceList.map((d) => d['name'] as String).toList(),
                onChanged: (value) async {
                  setState(() => _selectedDeviceId = value);
                  await _updateSetting('selected_device_id', value ?? '');
                },
              ),
              const SizedBox(height: 20),
              _buildSectionTitle(S
                  .of(context)
                  .preferences), // 本地化文本
              _buildSwitchTile(
                title: S
                    .of(context)
                    .enable_notifications, // 本地化文本
                icon: Icons.notifications,
                value: _isNotificationsEnabled,
                onChanged: _updateNotificationSetting,
              ),
              _buildSwitchTile(
                title: '启用视频检测',
                icon: Icons.visibility,
                value: _isDetectionEnabled,
                onChanged: _updateDetectionSetting,
              ),
              _buildDropdownTile(
                title: S
                    .of(context)
                    .language,
                // 本地化文本
                icon: Icons.language,
                value: _selectedLanguage,
                options: ['English', '中文'],
                displayNames: ['English', '中文'],
                onChanged: (value) async {
                  if (value != null) {
                    setState(() => _selectedLanguage = value);
                    _updateSetting('language', value);
                    ref.read(languageProvider.notifier).state = value;
                  }
                },
              ),
              const SizedBox(height: 20),
              _buildSectionTitle(S
                  .of(context)
                  .support_help), // 本地化文本
              _buildInfoTile(
                title: S
                    .of(context)
                    .customer_support, // 本地化文本
                icon: Icons.headset_mic,
                onTap: () {
                  Navigator.pushNamed(context, '/support');
                },
              ),
              _buildInfoTile(
                title: S
                    .of(context)
                    .faq, // 本地化文本
                icon: Icons.help,
                onTap: () {
                  Navigator.pushNamed(context, '/faq');
                },
              ),
              const SizedBox(height: 20),
              _buildSectionTitle(S
                  .of(context)
                  .about), // 本地化文本
              _buildInfoTile(
                title: S
                    .of(context)
                    .app_version, // 本地化文本
                icon: Icons.info,
                value: '1.0.0',
              ),
            ],
          ),
        ],
      ),
    );
  }

  // 构建分组标题
  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18.0,
          fontWeight: FontWeight.bold,
          color: Colors.black87,
        ),
      ),
    );
  }

  // 构建开关列表项
  Widget _buildSwitchTile({
    required String title,
    required IconData icon,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      child: ListTile(
        leading: Icon(icon, color: Colors.blue),
        title: Text(title),
        trailing: Switch(value: value, onChanged: onChanged),
      ),
    );
  }

  // 构建下拉选择列表项
  Widget _buildDropdownTile({
    required String title,
    required IconData icon,
    required String? value,
    required List<String> options,
    required List<String> displayNames,
    required ValueChanged<String?> onChanged,
  }) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      child: ListTile(
        leading: Icon(icon, color: Colors.green),
        title: Text(title),
        trailing: DropdownButton<String>(
          value: options.contains(value) ? value : null,
          hint: const Text("请选择"),
          underline: const SizedBox(),
          items: List.generate(options.length, (index) {
            return DropdownMenuItem<String>(
              value: options[index],
              child: Text(displayNames[index]),
            );
          }),
          onChanged: onChanged,
        ),
      ),
    );
  }

  // 构建信息展示列表项
  Widget _buildInfoTile({
    required String title,
    required IconData icon,
    String? value,
    VoidCallback? onTap,
  }) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      child: ListTile(
        leading: Icon(icon, color: Colors.purple),
        title: Text(title),
        trailing: value != null
            ? Text(value, style: const TextStyle(color: Colors.grey))
            : const Icon(Icons.arrow_forward_ios, size: 16.0),
        onTap: () {
          // 如果点击的是"app_version"，弹出提示框
          if (title == S
              .of(context)
              .app_version) {
            _showAppVersionDialog(context);
          } else {
            onTap?.call();
          }
        },
      ),
    );
  }

// 显示app版本的提示框
  void _showAppVersionDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('提示'),
          content: const Text('疯狂星期四，V我50！'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('确定'),
            ),
          ],
        );
      },
    );
  }
}
