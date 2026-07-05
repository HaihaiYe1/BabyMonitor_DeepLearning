import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import '../services/auth_service.dart';
import '../services/api_service.dart';
import '../services/notification_service.dart';
import '../providers/language_provider.dart';
import '../generated/l10n.dart';
import '../theme/serene_colors.dart';
import '../theme/serene_spacing.dart';
import '../theme/serene_typography.dart';
import 'serene_toggle.dart';

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
    if (mounted) {
      setState(() {
        _username = prefs.getString('username') ?? 'Guest';
        _email = prefs.getString('email') ?? '';
        _avatarPath = prefs.getString('avatar');
      });
    }
  }

  Future<void> _loadSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (mounted) {
        setState(() {
          _isNotificationsEnabled = prefs.getBool('notifications_enabled') ?? true;
          _selectedLanguage = prefs.getString('language') ?? '中文';
          _isDetectionEnabled = prefs.getBool('detection_enabled') ?? false;
          _selectedDeviceId = prefs.getString('selected_device_id');
        });
        ref.read(languageProvider.notifier).state = _selectedLanguage;
      }
    } catch (e) {
      debugPrint("Error loading settings: $e");
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
    
    if (_selectedDeviceId == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('请先选择设备'),
            backgroundColor: SereneColors.primary,
          ),
        );
      }
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    try {
      final url = Uri.parse(ApiService.videoDetectToggle(value, int.parse(_selectedDeviceId!)));
      final response = await http.post(
        url,
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        debugPrint("视频检测已${value ? "启用" : "关闭"}");
      } else {
        debugPrint("后端请求失败：${response.statusCode}");
      }
    } catch (e) {
      debugPrint("检测接口调用失败: $e");
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
      debugPrint("Error updating setting [$key]: $e");
    }
  }

  Future<void> _loadDevices() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      if (token == null) return;

      final response = await http.get(
        Uri.parse(ApiService.deviceList),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        if (mounted) {
          setState(() {
            _deviceList = data.map((d) => {
              'id': d['id'].toString(),
              'name': d['name'] ?? '设备 ${d['id']}',
            }).toList();
          });
        }
      }
    } catch (e) {
      debugPrint("设备列表请求失败: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      width: 320,
      backgroundColor: Colors.transparent,
      child: Container(
        decoration: BoxDecoration(
          color: SereneColors.surfaceContainerLowest,
          border: Border(
            right: BorderSide(
              color: SereneColors.outlineVariant.withValues(alpha: 0.3),
              width: 1,
            ),
          ),
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.only(
            topRight: Radius.circular(SereneSpacing.radiusXl),
            bottomRight: Radius.circular(SereneSpacing.radiusXl),
          ),
          child: Column(
            children: [
              // 用户头像区域
              _buildHeader(),
              // 语言选择器
              _buildLanguageSelector(),
              // 菜单内容
              Expanded(
                child: ListView(
                  padding: EdgeInsets.zero,
                  children: [
                    // AI功能
                    _buildSection('AI Functions', [
                      _buildNavItem(
                        icon: Icons.chat_bubble_outline,
                        iconColor: const Color(0xFF8b5cf6),
                        title: 'AI Agent Chat',
                        onTap: () => Navigator.pushNamed(context, '/chat'),
                      ),
                      _buildNavItem(
                        icon: Icons.lightbulb_outline,
                        iconColor: const Color(0xFF8b5cf6),
                        title: 'Parenting Advice',
                        onTap: () => Navigator.pushNamed(context, '/advice'),
                      ),
                    ]),
                    // 账户与设备
                    _buildSection('Account & Device', [
                      _buildNavItem(
                        icon: Icons.person_outline,
                        title: S.of(context).manage_account,
                        onTap: () => Navigator.pushNamed(context, '/account'),
                      ),
                      _buildNavItem(
                        icon: Icons.devices,
                        title: S.of(context).manage_devices,
                        subtitle: 'Select Device',
                        onTap: () => Navigator.pushNamed(context, '/devices'),
                      ),
                      _buildNavItem(
                        icon: Icons.done_outline,
                        title: 'Smart Home Control',
                        onTap: () => Navigator.pushNamed(context, '/smart-home'),
                      ),
                      _buildNavItem(
                        icon: Icons.dashboard_customize,
                        title: 'Monitoring Dashboard',
                        onTap: () => Navigator.pushNamed(context, '/monitoring'),
                      ),
                    ]),
                    // 偏好设置
                    _buildSection('Preferences', [
                      _buildSwitchItem(
                        icon: Icons.notifications_outlined,
                        iconColor: SereneColors.primary,
                        title: S.of(context).enable_notifications,
                        value: _isNotificationsEnabled,
                        onChanged: _updateNotificationSetting,
                      ),
                      _buildSwitchItem(
                        icon: Icons.visibility_outlined,
                        iconColor: SereneColors.primary,
                        title: 'Enable Video Detection',
                        value: _isDetectionEnabled,
                        onChanged: _updateDetectionSetting,
                      ),
                    ]),
                    // 支持与帮助
                    _buildSection('Support & Help', [
                      _buildNavItem(
                        icon: Icons.headset_mic_outlined,
                        title: S.of(context).customer_support,
                        onTap: () => Navigator.pushNamed(context, '/support'),
                      ),
                      _buildNavItem(
                        icon: Icons.help_outline,
                        title: S.of(context).faq,
                        onTap: () => Navigator.pushNamed(context, '/faq'),
                      ),
                      _buildInfoItem(
                        title: S.of(context).app_version,
                        value: '1.0.0',
                      ),
                    ]),
                  ],
                ),
              ),
              // 退出登录
              _buildLogoutButton(),
            ],
          ),
        ),
      ),
    );
  }

  /// 构建头部
  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.fromLTRB(
        SereneSpacing.marginMobile,
        MediaQuery.of(context).padding.top + SereneSpacing.lg,
        SereneSpacing.marginMobile,
        SereneSpacing.md,
      ),
      child: Row(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: SereneColors.surfaceContainerHighest,
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: CircleAvatar(
              radius: 30,
              backgroundImage: _avatarPath != null && _avatarPath!.isNotEmpty
                  ? FileImage(File(_avatarPath!))
                  : const AssetImage('lib/assets/images/v.png') as ImageProvider,
            ),
          ),
          const SizedBox(width: SereneSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _username,
                  style: SereneTypography.headlineSmall.copyWith(
                    color: SereneColors.onSurface,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _email.isNotEmpty ? _email : '',
                  style: SereneTypography.bodySmall.copyWith(
                    color: SereneColors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 构建语言选择器
  Widget _buildLanguageSelector() {
    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: SereneSpacing.marginMobile,
        vertical: SereneSpacing.sm,
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: SereneSpacing.md,
        vertical: SereneSpacing.sm,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(SereneSpacing.radiusDefault),
        color: SereneColors.surfaceContainerHigh.withValues(alpha: 0.5),
      ),
      child: Row(
        children: [
          Icon(
            Icons.language,
            size: 20,
            color: SereneColors.onSurfaceVariant,
          ),
          const SizedBox(width: SereneSpacing.sm),
          Expanded(
            child: Text(
              'Language: $_selectedLanguage',
              style: SereneTypography.bodyMedium.copyWith(
                color: SereneColors.onSurface,
              ),
            ),
          ),
          Icon(
            Icons.arrow_drop_down,
            color: SereneColors.onSurfaceVariant,
          ),
        ],
      ),
    );
  }

  /// 构建分区
  Widget _buildSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
            SereneSpacing.marginMobile,
            SereneSpacing.md,
            SereneSpacing.marginMobile,
            SereneSpacing.sm,
          ),
          child: Text(
            title,
            style: SereneTypography.labelMedium.copyWith(
              color: SereneColors.onSurfaceVariant,
              letterSpacing: 1.2,
            ),
          ),
        ),
        ...children,
        Divider(
          height: 1,
          indent: SereneSpacing.marginMobile,
          endIndent: SereneSpacing.marginMobile,
          color: SereneColors.outlineVariant.withValues(alpha: 0.1),
        ),
      ],
    );
  }

  /// 构建导航项
  Widget _buildNavItem({
    required IconData icon,
    Color? iconColor,
    required String title,
    String? subtitle,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(SereneSpacing.radiusXl),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: SereneSpacing.marginMobile,
          vertical: SereneSpacing.md,
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 24,
              color: iconColor ?? SereneColors.onSurfaceVariant,
            ),
            const SizedBox(width: SereneSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: SereneTypography.bodyMedium.copyWith(
                      color: SereneColors.onSurface,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: SereneTypography.labelMedium.copyWith(
                        color: SereneColors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 构建开关项
  Widget _buildSwitchItem({
    required IconData icon,
    Color? iconColor,
    required String title,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: SereneSpacing.marginMobile,
        vertical: SereneSpacing.md,
      ),
      child: Row(
        children: [
          Icon(
            icon,
            size: 24,
            color: iconColor ?? SereneColors.primary,
          ),
          const SizedBox(width: SereneSpacing.md),
          Expanded(
            child: Text(
              title,
              style: SereneTypography.bodyMedium.copyWith(
                color: SereneColors.onSurface,
              ),
            ),
          ),
          SereneToggle(
            value: value,
            onChanged: onChanged,
            activeColor: SereneColors.secondaryContainer,
            inactiveColor: SereneColors.outlineVariant,
          ),
        ],
      ),
    );
  }

  /// 构建信息项
  Widget _buildInfoItem({
    required String title,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: SereneSpacing.marginMobile,
        vertical: SereneSpacing.md,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: SereneTypography.bodyMedium.copyWith(
              color: SereneColors.onSurfaceVariant,
            ),
          ),
          Text(
            value,
            style: SereneTypography.labelMedium.copyWith(
              color: SereneColors.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  /// 构建退出登录按钮
  Widget _buildLogoutButton() {
    return Container(
      padding: EdgeInsets.fromLTRB(
        SereneSpacing.marginMobile,
        SereneSpacing.md,
        SereneSpacing.marginMobile,
        MediaQuery.of(context).padding.bottom + SereneSpacing.md,
      ),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: SereneColors.outlineVariant.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
      ),
      child: InkWell(
        onTap: () async {
          Navigator.of(context).pop();
          await AuthService().logout(context);
        },
        borderRadius: BorderRadius.circular(SereneSpacing.radiusXl),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: SereneSpacing.md,
            vertical: SereneSpacing.md,
          ),
          child: Row(
            children: [
              const Icon(
                Icons.logout,
                size: 24,
                color: SereneColors.error,
              ),
              const SizedBox(width: SereneSpacing.md),
              Text(
                'Log Out',
                style: SereneTypography.labelLarge.copyWith(
                  color: SereneColors.error,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showAppVersionDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: SereneColors.surfaceContainerLowest,
          shape: RoundedRectangleBorder(
            borderRadius: SereneSpacing.dialogRadius,
          ),
          title: Text(
            '提示',
            style: SereneTypography.headlineSmall.copyWith(
              color: SereneColors.onSurface,
            ),
          ),
          content: Text(
            '疯狂星期四，V我50！',
            style: SereneTypography.bodyMedium.copyWith(
              color: SereneColors.onSurfaceVariant,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                '确定',
                style: SereneTypography.labelLarge.copyWith(
                  color: SereneColors.primary,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
