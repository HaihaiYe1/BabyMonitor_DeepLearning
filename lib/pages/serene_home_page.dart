import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_vlc_player/flutter_vlc_player.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

import '../generated/l10n.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';
import '../services/notification_service.dart';
import '../theme/serene_colors.dart';
import '../theme/serene_spacing.dart';
import '../theme/serene_typography.dart';
import '../widgets/glass_widgets.dart';
import '../widgets/serene_widgets.dart';
import '../widgets/video_player.dart';

import 'babysleep_page.dart';
import 'data_analysis_page.dart';
import 'development_milestones.dart';
import 'guidance_page.dart';
import 'history_page.dart';
import 'chat_page.dart';
import 'advice_page.dart';
import 'vaccine_page.dart';

/// Serene Guardian 风格首页
/// 完全还原 stitch 项目的 home_dashboard 设计
class SereneHomePage extends StatefulWidget {
  @override
  _SereneHomePageState createState() => _SereneHomePageState();
}

class _SereneHomePageState extends State<SereneHomePage> {
  int _currentIndex = 0;
  final PageController _pageController = PageController();

  final List<Widget> _pages = [
    _SereneHomeContent(),
    HistoryPage(),
    VaccineSchedulePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      appBar: GlassAppBar(
        leading: Builder(
          builder: (context) => GestureDetector(
            onTap: () => Scaffold.of(context).openDrawer(),
            child: Container(
              margin: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.5),
                  width: 1,
                ),
              ),
              child: CircleAvatar(
                radius: 16,
                backgroundImage: AssetImage('lib/assets/images/v.png'),
                backgroundColor: Colors.transparent,
              ),
            ),
          ),
        ),
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.child_care,
              color: SereneColors.primary,
              size: 24,
            ),
            const SizedBox(width: 8),
            Text(
              'LullabyLink',
              style: SereneTypography.headlineSmall.copyWith(
                color: SereneColors.primary,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {
              // TODO: 打开通知页面
            },
          ),
        ],
      ),
      drawer: GlassDrawer(
        child: _buildDrawerContent(),
      ),
      body: SafeArea(
        bottom: false,
        child: Stack(
          children: [
            // 背景色 - 还原 stitch 的 bg-background
            Container(
              color: SereneColors.surface,
            ),
            // 页面内容
            Padding(
              padding: const EdgeInsets.only(bottom: 70),
              child: PageView(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    _currentIndex = index;
                  });
                },
                children: _pages,
              ),
            ),
            // 快捷操作按钮（仅首页显示）
            if (_currentIndex == 0)
              Positioned(
                bottom: 20,
                left: 0,
                right: 0,
                child: _buildQuickActions(),
              ),
            // FAB浮动按钮（仅首页显示）
            if (_currentIndex == 0)
              Positioned(
                bottom: 90,
                right: 20,
                child: _buildFAB(),
              ),
          ],
        ),
      ),
      bottomNavigationBar: GlassBottomNavBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          _pageController.animateToPage(
            index,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );
        },
        items: [
          GlassBottomNavItem(
            icon: Icons.videocam_outlined,
            activeIcon: Icons.videocam,
            label: S.of(context).monitor,
          ),
          GlassBottomNavItem(
            icon: Icons.history_outlined,
            activeIcon: Icons.history,
            label: S.of(context).history,
          ),
          GlassBottomNavItem(
            icon: Icons.bar_chart_outlined,
            activeIcon: Icons.bar_chart,
            label: S.of(context).arrange,
          ),
        ],
      ),
    );
  }

  /// 构建抽屉内容
  Widget _buildDrawerContent() {
    return Column(
      children: [
        // 用户信息区
        Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: SereneColors.primaryContainer,
                    width: 2,
                  ),
                ),
                child: CircleAvatar(
                  radius: 30,
                  backgroundImage: AssetImage('lib/assets/images/v.png'),
                  backgroundColor: Colors.transparent,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Emily Johnson',
                style: SereneTypography.headlineSmall.copyWith(
                  color: SereneColors.primary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Premium Member',
                style: SereneTypography.bodySmall.copyWith(
                  color: SereneColors.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: SereneColors.surfaceContainer,
                  borderRadius: SereneSpacing.chipRadius,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.child_care,
                      size: 14,
                      color: SereneColors.primary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Baby: Leo (6m)',
                      style: SereneTypography.labelMedium.copyWith(
                        color: SereneColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        // 菜单项
        Expanded(
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            children: [
              _buildDrawerItem(
                icon: Icons.person_outline,
                label: 'Account Settings',
                onTap: () {
                  Navigator.pop(context);
                  // TODO: 导航到账户设置
                },
              ),
              _buildDrawerItem(
                icon: Icons.smart_toy_outlined,
                label: 'Devices',
                onTap: () {
                  Navigator.pop(context);
                  // TODO: 导航到设备管理
                },
              ),
              _buildDrawerItem(
                icon: Icons.shield_outlined,
                label: 'Nursery Safety',
                onTap: () {
                  Navigator.pop(context);
                  // TODO: 导航到安全设置
                },
              ),
              _buildDrawerItem(
                icon: Icons.help_outline,
                label: 'Support',
                onTap: () {
                  Navigator.pop(context);
                  // TODO: 导航到支持页面
                },
              ),
            ],
          ),
        ),
        // 退出登录
        Padding(
          padding: const EdgeInsets.all(8),
          child: Column(
            children: [
              const Divider(),
              _buildDrawerItem(
                icon: Icons.logout,
                label: 'Log Out',
                onTap: () {
                  Navigator.pop(context);
                  // TODO: 退出登录
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// 构建抽屉菜单项
  Widget _buildDrawerItem({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: SereneColors.onSurfaceVariant),
      title: Text(
        label,
        style: SereneTypography.bodyMedium.copyWith(
          color: SereneColors.onSurfaceVariant,
        ),
      ),
      shape: RoundedRectangleBorder(
        borderRadius: SereneSpacing.borderRadiusFull,
      ),
      onTap: onTap,
    );
  }

  /// 构建快捷操作按钮
  Widget _buildQuickActions() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: GlassPanel(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildQuickActionButton(
              icon: Icons.child_care,
              label: S.of(context).milestones,
              color: SereneColors.primary,
              backgroundColor: SereneColors.primaryContainer,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => DevelopmentMilestonesPage(),
                ),
              ),
            ),
            _buildQuickActionButton(
              icon: Icons.lightbulb_outline,
              label: S.of(context).guide,
              color: SereneColors.secondary,
              backgroundColor: SereneColors.secondaryContainer,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => GuidancePage(),
                ),
              ),
            ),
            _buildQuickActionButton(
              icon: Icons.nightlight_outlined,
              label: S.of(context).sleep,
              color: SereneColors.primary,
              backgroundColor: SereneColors.inversePrimary,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SleepPage(),
                ),
              ),
            ),
            _buildQuickActionButton(
              icon: Icons.bar_chart_outlined,
              label: S.of(context).statistics,
              color: SereneColors.tertiary,
              backgroundColor: SereneColors.tertiaryContainer,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => DataAnalysisPage(),
                ),
              ),
            ),
            _buildQuickActionButton(
              icon: Icons.smart_toy_outlined,
              label: 'AI Chat',
              color: SereneColors.primary,
              backgroundColor: SereneColors.primaryContainer,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ChatPage(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 构建FAB浮动按钮 - 还原 stitch 的 FAB
  Widget _buildFAB() {
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: SereneColors.primaryContainer,
        boxShadow: [
          BoxShadow(
            color: SereneColors.primary.withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(28),
          onTap: () {
            // TODO: 实现添加功能
          },
          child: const Icon(
            Icons.add,
            size: 28,
            color: SereneColors.onPrimaryContainer,
          ),
        ),
      ),
    );
  }

  /// 构建单个快捷操作按钮
  Widget _buildQuickActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required Color backgroundColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: backgroundColor.withValues(alpha: 0.3),
            ),
            child: Icon(
              icon,
              size: 28,
              color: color,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: SereneTypography.labelMedium.copyWith(
              color: SereneColors.onSurface,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

/// 首页内容组件
class _SereneHomeContent extends StatefulWidget {
  @override
  _SereneHomeContentState createState() => _SereneHomeContentState();
}

class _SereneHomeContentState extends State<_SereneHomeContent> {
  String? rtspUrl;
  bool isRtspReady = false;
  bool isLoading = true;
  bool detectionEnabled = false;
  bool isConnecting = true;
  final NotificationService _notificationService = NotificationService();
  String localVideo = 'lib/assets/videos/jojo_test.mp4';

  @override
  void initState() {
    super.initState();
    _debugCheckToken();
    _fetchDefaultRtsp();
    _loadDetectionSetting();
    _initializeNotificationService();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    AuthService().fetchDeviceData(context);
  }

  void _initializeNotificationService() async {
    await _notificationService.initialize();
    await _notificationService.initializeWebSocket();
  }

  Future<void> _loadDetectionSetting() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool detectionSetting = prefs.getBool('detection_enabled') ?? false;
    setState(() {
      detectionEnabled = detectionSetting;
    });
  }

  Future<void> _debugCheckToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    print("🔑 [DEBUG] HomeContent.initState() 读取的 Token: $token");

    String? authServiceToken = await AuthService().getToken();
    print("🔑 [DEBUG] 通过 AuthService.getToken() 获取的 Token: $authServiceToken");
  }

  Future<void> _fetchDefaultRtsp() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      if (token == null) return;

      final response = await http.get(
        Uri.parse(ApiService.deviceList),
        headers: {'Authorization': 'Bearer $token'},
      );

      print("服务器响应码: ${response.statusCode}");

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        if (data.isNotEmpty) {
          final deviceId = data[0]['id'].toString();
          await _fetchRtspUrl(deviceId);
        } else {
          setState(() {
            isLoading = false;
            isConnecting = false;
          });
        }
      } else {
        print("❌ 获取设备列表失败: ${response.body}");
      }
    } catch (e) {
      print('🚨 异常发生: $e');
    }
  }

  Future<void> _fetchRtspUrl(String deviceId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null) return;

      final response = await http.get(
        Uri.parse('${ApiService.deviceBase}/$deviceId'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final device = json.decode(response.body);
        setState(() {
          rtspUrl = device['rtsp_url'];
        });
      } else {
        print("❌ 获取设备 RTSP 地址失败: ${response.body}");
      }
    } catch (e) {
      print('🚨 异常发生: $e');
    } finally {
      setState(() {
        isLoading = false;
        isConnecting = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: SereneSpacing.marginMobile),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: SereneSpacing.lg),
          // 视频播放器区域
          _buildVideoSection(),
          const SizedBox(height: SereneSpacing.md),
          // AI 状态指示器
          _buildAIStatusIndicator(),
          const SizedBox(height: SereneSpacing.lg),
        ],
      ),
    );
  }

  /// 构建视频播放器区域 - 还原 stitch 的视频区域
  Widget _buildVideoSection() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: SereneSpacing.borderRadiusXl,
        border: Border.all(
          color: SereneColors.outlineVariant.withValues(alpha: 0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: SereneSpacing.borderRadiusXl,
        child: AspectRatio(
          aspectRatio: 16 / 9,
          child: Stack(
            children: [
              // 视频内容
              if (isLoading)
                Container(
                  color: SereneColors.surfaceContainerHigh,
                  child: const Center(
                    child: CircularProgressIndicator(
                      color: SereneColors.primary,
                    ),
                  ),
                )
              else if (rtspUrl != null && !isConnecting)
                VideoPlayerWidget(videoUrl: rtspUrl!)
              else
                Container(
                  color: SereneColors.surfaceContainerHigh,
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.videocam_off_outlined,
                          size: 48,
                          color: SereneColors.onSurfaceVariant,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '未获取到摄像头地址',
                          style: SereneTypography.bodyMedium.copyWith(
                            color: SereneColors.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 16),
                        SereneSecondaryButton(
                          text: '重试',
                          icon: Icons.refresh,
                          onPressed: () {
                            setState(() {
                              isLoading = true;
                              isConnecting = true;
                            });
                            _fetchDefaultRtsp();
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              // 视频覆盖控制
              if (rtspUrl != null && !isConnecting)
                SereneVideoOverlay(
                  isLive: true,
                  onTalkPressed: () {
                    // TODO: 实现对讲功能
                  },
                  onSnapshotPressed: () {
                    // TODO: 实现截图功能
                  },
                  onFullscreenPressed: () {
                    // TODO: 实现全屏功能
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }

  /// 构建 AI 状态指示器
  Widget _buildAIStatusIndicator() {
    return SereneAIStatusIndicator(
      isActive: detectionEnabled,
      statusText: detectionEnabled
          ? 'AI Detection: Active'
          : 'AI Detection: Inactive',
      temperature: '72°F',
    );
  }
}
