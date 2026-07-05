import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_vlc_player/flutter_vlc_player.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../generated/l10n.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';
import '../theme/serene_colors.dart';
import '../theme/serene_spacing.dart';
import '../theme/serene_typography.dart';
import '../widgets/glass_widgets.dart';
import '../widgets/serene_widgets.dart';
import '../widgets/video_player.dart';

/// Serene Guardian 风格实时监控页面
/// 完全还原 stitch 项目的 live_monitor_dashboard 设计
class SereneLiveMonitorPage extends StatefulWidget {
  @override
  _SereneLiveMonitorPageState createState() => _SereneLiveMonitorPageState();
}

class _SereneLiveMonitorPageState extends State<SereneLiveMonitorPage> {
  String? rtspUrl;
  bool isLoading = true;
  bool isConnecting = true;
  bool isTalking = false;
  double volume = 0.5;
  bool showStats = false;

  // 流统计信息
  int fps = 30;
  int latency = 120;
  double bitrate = 2.4;
  String signal = 'Excellent';

  @override
  void initState() {
    super.initState();
    _fetchDefaultRtsp();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    AuthService().fetchDeviceData(context);
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
      }
    } catch (e) {
      print('Error: $e');
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
      }
    } catch (e) {
      print('Error: $e');
    } finally {
      setState(() {
        isLoading = false;
        isConnecting = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      appBar: GlassAppBar(
        leading: IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () {
            Scaffold.of(context).openDrawer();
          },
        ),
        title: Text(
          'Live Monitor',
          style: SereneTypography.headlineSmall.copyWith(
            color: SereneColors.primary,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () {
              // TODO: 打开设置
            },
          ),
        ],
      ),
      body: SafeArea(
        bottom: false,
        child: Stack(
          children: [
            // 背景渐变
            Container(
              decoration: const BoxDecoration(
                gradient: SereneColors.backgroundGradient,
              ),
            ),
            // 内容
            SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                horizontal: SereneSpacing.marginMobile,
                vertical: SereneSpacing.lg,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 视频播放器区域
                  _buildVideoSection(),
                  const SizedBox(height: SereneSpacing.lg),
                  // 对讲区域
                  _buildIntercomSection(),
                  const SizedBox(height: SereneSpacing.lg),
                  // 流统计信息
                  _buildStreamStatsSection(),
                  const SizedBox(height: SereneSpacing.xl),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: GlassBottomNavBar(
        currentIndex: 0,
        onTap: (index) {
          // TODO: 处理导航
        },
        items: [
          GlassBottomNavItem(
            icon: Icons.videocam_outlined,
            activeIcon: Icons.videocam,
            label: 'Monitor',
          ),
          GlassBottomNavItem(
            icon: Icons.history_outlined,
            activeIcon: Icons.history,
            label: 'Activity',
          ),
          GlassBottomNavItem(
            icon: Icons.bedtime_outlined,
            activeIcon: Icons.bedtime,
            label: 'Sleep',
          ),
          GlassBottomNavItem(
            icon: Icons.person_outline,
            activeIcon: Icons.person,
            label: 'Profile',
          ),
        ],
      ),
    );
  }

  /// 构建视频播放器区域 - 还原 stitch 的 Video Player Section
  Widget _buildVideoSection() {
    return GlassCard(
      padding: EdgeInsets.zero,
      child: AspectRatio(
        aspectRatio: 16 / 9,
        child: ClipRRect(
          borderRadius: SereneSpacing.borderRadiusXl,
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
                      ],
                    ),
                  ),
                ),
              // 视频覆盖层 - 渐变遮罩
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withValues(alpha: 0.3),
                        Colors.transparent,
                        Colors.black.withValues(alpha: 0.6),
                      ],
                    ),
                  ),
                ),
              ),
              // 顶部徽章 - LIVE 状态
              Positioned(
                top: SereneSpacing.md,
                left: SereneSpacing.md,
                child: GlassFloat(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: SereneColors.error,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'LIVE',
                        style: SereneTypography.labelMedium.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // 底部控制按钮
              Positioned(
                bottom: SereneSpacing.md,
                left: SereneSpacing.md,
                right: SereneSpacing.md,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // 左侧控制
                    Row(
                      children: [
                        // 暂停按钮
                        GlassFloat(
                          onTap: () {
                            // TODO: 实现暂停功能
                          },
                          padding: const EdgeInsets.all(10),
                          child: const Icon(
                            Icons.pause,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 8),
                        // 音量控制
                        GlassFloat(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.volume_up,
                                color: Colors.white,
                                size: 16,
                              ),
                              const SizedBox(width: 8),
                              SizedBox(
                                width: 96,
                                child: Slider(
                                  value: volume,
                                  onChanged: (value) {
                                    setState(() {
                                      volume = value;
                                    });
                                  },
                                  activeColor: Colors.white,
                                  inactiveColor: Colors.white.withValues(alpha: 0.5),
                                  min: 0,
                                  max: 1,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    // 右侧控制
                    Row(
                      children: [
                        // 截图按钮
                        GlassFloat(
                          onTap: () {
                            // TODO: 实现截图功能
                          },
                          padding: const EdgeInsets.all(10),
                          child: const Icon(
                            Icons.photo_camera,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 8),
                        // 全屏按钮
                        GlassFloat(
                          onTap: () {
                            // TODO: 实现全屏功能
                          },
                          padding: const EdgeInsets.all(10),
                          child: const Icon(
                            Icons.fullscreen,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 构建对讲区域 - 还原 stitch 的 Audio & Intercom
  Widget _buildIntercomSection() {
    return GlassCard(
      child: Column(
        children: [
          Text(
            'Intercom',
            style: SereneTypography.headlineSmall.copyWith(
              color: SereneColors.onSurface,
            ),
          ),
          const SizedBox(height: SereneSpacing.sm),
          Text(
            'Hold to speak to the nursery',
            style: SereneTypography.bodySmall.copyWith(
              color: SereneColors.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: SereneSpacing.md),
          // 对讲按钮
          GestureDetector(
            onTapDown: (_) {
              setState(() {
                isTalking = true;
              });
              // TODO: 开始对讲
            },
            onTapUp: (_) {
              setState(() {
                isTalking = false;
              });
              // TODO: 停止对讲
            },
            onTapCancel: () {
              setState(() {
                isTalking = false;
              });
              // TODO: 停止对讲
            },
            child: Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isTalking
                    ? SereneColors.primary.withValues(alpha: 0.2)
                    : SereneColors.primaryContainer,
                boxShadow: [
                  BoxShadow(
                    color: SereneColors.primary.withValues(alpha: 0.2),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Icon(
                Icons.mic,
                size: 48,
                color: isTalking
                    ? SereneColors.primary
                    : SereneColors.onPrimaryContainer,
              ),
            ),
          ),
          const SizedBox(height: SereneSpacing.sm),
          Text(
            'Push to Talk',
            style: SereneTypography.labelLarge.copyWith(
              color: SereneColors.primary,
            ),
          ),
        ],
      ),
    );
  }

  /// 构建流统计信息区域 - 还原 stitch 的 Stream Stats
  Widget _buildStreamStatsSection() {
    return GlassCard(
      child: Column(
        children: [
          // 标题栏
          GestureDetector(
            onTap: () {
              setState(() {
                showStats = !showStats;
              });
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.info_outline,
                      color: SereneColors.onSurfaceVariant,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Stream Statistics',
                      style: SereneTypography.labelLarge.copyWith(
                        color: SereneColors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
                AnimatedRotation(
                  turns: showStats ? 0.5 : 0,
                  duration: const Duration(milliseconds: 300),
                  child: const Icon(
                    Icons.expand_more,
                    color: SereneColors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          // 统计详情
          AnimatedCrossFade(
            firstChild: const SizedBox.shrink(),
            secondChild: Padding(
              padding: const EdgeInsets.only(top: SereneSpacing.md),
              child: GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: SereneSpacing.sm,
                crossAxisSpacing: SereneSpacing.sm,
                childAspectRatio: 2.5,
                children: [
                  _buildStatItem('FPS', '$fps'),
                  _buildStatItem('Latency', '${latency}ms'),
                  _buildStatItem('Bitrate', '$bitrate Mbps'),
                  _buildStatItem('Signal', signal, isPrimary: true),
                ],
              ),
            ),
            crossFadeState: showStats
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 300),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, {bool isPrimary = false}) {
    return Container(
      padding: const EdgeInsets.all(SereneSpacing.sm),
      decoration: BoxDecoration(
        color: SereneColors.surfaceContainerLow,
        borderRadius: SereneSpacing.borderRadiusMd,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: SereneTypography.bodySmall.copyWith(
              color: SereneColors.onSurfaceVariant,
            ),
          ),
          Text(
            value,
            style: SereneTypography.bodySmall.copyWith(
              fontWeight: FontWeight.w500,
              color: isPrimary
                  ? SereneColors.primary
                  : SereneColors.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
