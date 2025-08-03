import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import '../services/auth_service.dart';
import '../services/notification_service.dart';
import '../providers/language_provider.dart';
import '../generated/l10n.dart';

class CustomDrawer extends ConsumerStatefulWidget {
  const CustomDrawer({Key? key}) : super(key: key);

  @override
  _CustomDrawerState createState() => _CustomDrawerState();
}

class _CustomDrawerState extends ConsumerState<CustomDrawer> {
  String _username = 'Guest';
  String _email = '';
  String? _avatarPath;

  bool _isNotificationsEnabled = true;
  bool _isDetectionEnabled = false;
  String _selectedLanguage = 'English';
  String? _selectedDeviceId;
  List<Map<String, dynamic>> _deviceList = [];

  final NotificationService _notificationService = NotificationService();

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
    _loadSettings();
    _notificationService.initialize();
    _loadDevices();
  }

  Future<void> _loadUserInfo() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _username = prefs.getString('username') ?? 'Guest';
      _email = prefs.getString('email') ?? '';
      _avatarPath = prefs.getString('avatar');
    });
  }

  Future<void> _loadSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      setState(() {
        _isNotificationsEnabled = prefs.getBool('notifications_enabled') ?? true;
        _selectedLanguage = prefs.getString('language') ?? '中文';
        _isDetectionEnabled = prefs.getBool('detection_enabled') ?? false;
        _selectedDeviceId = prefs.getString('selected_device_id');
      });
      ref.read(languageProvider.notifier).state = _selectedLanguage;
    } catch (e) {
      print("Error loading settings: $e");
    }
  }

  Future<void> _updateNotificationSetting(bool value) async {
    setState(() => _isNotificationsEnabled = value);
    await _updateSetting('notifications_enabled', value);
    await _notificationService.updateNotificationSetting(value);
    if (value) {
      _notificationService.showNotification(
        id: 1,
        title: '通知已启用',
        body: '你将收到应用的提醒！',
      );
    } else {
      _notificationService.cancelAllNotifications();
    }
  }

  Future<void> _updateDetectionSetting(bool value) async {
    setState(() => _isDetectionEnabled = value);
    await _updateSetting('detection_enabled', value);
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (_selectedDeviceId == null) {
      print("请先选择设备！");
      return;
    }

    print("已选择设备 ID: $_selectedDeviceId");

    final url = Uri.parse(
        'http://10.0.2.2:8000/video/${value ? "start" : "stop"}-detect?device_id=${int.parse(_selectedDeviceId!)}');

    try {
      final response = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer $token',
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
      final token = prefs.getString('token');
      if (token == null) {
        print("请先登录！");
        return;
      }

      final response = await http.get(
        Uri.parse('http://10.0.2.2:8000/device/list'),
        headers: {
          'Authorization': 'Bearer $token',
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
    return Drawer(
      child: Column(
        children: [
          UserAccountsDrawerHeader(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF89F7FE), Color(0xFF66A6FF)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            accountName: Text(
              _username,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            accountEmail: Text(
              _email.isNotEmpty ? _email : '',
              style: const TextStyle(fontSize: 16),
            ),
            currentAccountPicture: CircleAvatar(
              backgroundImage: _avatarPath != null && _avatarPath!.isNotEmpty
                  ? FileImage(File(_avatarPath!))
                  : const AssetImage('lib/assets/images/v.png') as ImageProvider,
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              children: [
                const SizedBox(height: 8),
                _buildSectionTitle('账户管理'),
                _buildInfoTile(
                  title: S.of(context).manage_account,
                  icon: Icons.person,
                  onTap: () {
                    Navigator.pushNamed(context, '/account');
                  },
                ),
                const SizedBox(height: 8),
                _buildSectionTitle('设备管理'),
                _buildInfoTile(
                  title: S.of(context).manage_devices,
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
                const SizedBox(height: 8),
                _buildSectionTitle('偏好设置'),
                _buildSwitchTile(
                  title: S.of(context).enable_notifications,
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
                  title: S.of(context).language,
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
                const SizedBox(height: 8),
                _buildSectionTitle('支持与帮助'),
                _buildInfoTile(
                  title: S.of(context).customer_support,
                  icon: Icons.headset_mic,
                  onTap: () {
                    Navigator.pushNamed(context, '/support');
                  },
                ),
                _buildInfoTile(
                  title: S.of(context).faq,
                  icon: Icons.help,
                  onTap: () {
                    Navigator.pushNamed(context, '/faq');
                  },
                ),
                const SizedBox(height: 8),
                _buildSectionTitle('关于'),
                _buildInfoTile(
                  title: S.of(context).app_version,
                  icon: Icons.info,
                  value: '1.0.0',
                ),
              ],
            ),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text('Logout', style: TextStyle(color: Colors.red)),
            onTap: () async {
              Navigator.of(context).pop();
              await AuthService().logout(context);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text(
        title,
        style: const TextStyle(
            fontSize: 18.0, fontWeight: FontWeight.bold, color: Colors.black87),
      ),
    );
  }

  Widget _buildSwitchTile({
    required String title,
    required IconData icon,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      child: ListTile(
        leading: Icon(icon, color: Colors.blue),
        title: Text(title),
        trailing: Switch(value: value, onChanged: onChanged),
      ),
    );
  }

  Widget _buildDropdownTile({
    required String title,
    required IconData icon,
    required String? value,
    required List<String> options,
    required List<String> displayNames,
    required ValueChanged<String?> onChanged,
  }) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6.0),
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

  Widget _buildInfoTile({
    required String title,
    required IconData icon,
    String? value,
    VoidCallback? onTap,
  }) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6.0),
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
