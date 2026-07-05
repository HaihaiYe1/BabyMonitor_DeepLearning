import 'dart:async';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../services/api_service.dart';
import '../generated/l10n.dart';
import '../theme/serene_colors.dart';
import '../theme/serene_spacing.dart';
import '../theme/serene_typography.dart';
import '../widgets/glass_widgets.dart';
import '../widgets/serene_widgets.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class MonitoringDashboard extends StatefulWidget {
  const MonitoringDashboard({Key? key}) : super(key: key);

  @override
  _MonitoringDashboardState createState() => _MonitoringDashboardState();
}

class _MonitoringDashboardState extends State<MonitoringDashboard> {
  // 监控数据
  Map<String, dynamic>? _stats;
  List<Map<String, dynamic>> _connections = [];
  Map<String, dynamic>? _audioStats;
  
  // 图表数据
  List<FlSpot> _messageData = [];
  List<FlSpot> _connectionData = [];
  List<FlSpot> _latencyData = [];
  
  // 定时器
  Timer? _refreshTimer;
  bool _isLoading = false;
  
  // 时间范围
  int _timeRange = 3600; // 1小时
  int _currentTime = 0;

  @override
  void initState() {
    super.initState();
    _loadData();
    _startAutoRefresh();
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  void _startAutoRefresh() {
    _refreshTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      _loadData();
    });
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      await Future.wait([
        _loadStats(),
        _loadConnections(),
        _loadAudioStats(),
      ]);
      
      _updateChartData();
    } catch (e) {
      print('Failed to load monitoring data: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _loadStats() async {
    try {
      final response = await http.get(
        Uri.parse(ApiService.monitoringStats),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        setState(() {
          _stats = json.decode(response.body);
        });
      }
    } catch (e) {
      print('Failed to load stats: $e');
    }
  }

  Future<void> _loadConnections() async {
    try {
      final response = await http.get(
        Uri.parse(ApiService.monitoringConnections),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _connections = List<Map<String, dynamic>>.from(data['connections'] ?? []);
        });
      }
    } catch (e) {
      print('Failed to load connections: $e');
    }
  }

  Future<void> _loadAudioStats() async {
    try {
      final response = await http.get(
        Uri.parse(ApiService.monitoringAudioStats),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        setState(() {
          _audioStats = json.decode(response.body);
        });
      }
    } catch (e) {
      print('Failed to load audio stats: $e');
    }
  }

  void _updateChartData() {
    setState(() {
      _currentTime++;
      
      // 更新消息数据
      if (_stats != null) {
        final messagesSent = _stats!['messages_sent'] ?? 0;
        final messagesReceived = _stats!['messages_received'] ?? 0;
        _messageData.add(FlSpot(_currentTime.toDouble(), (messagesSent + messagesReceived).toDouble()));
        
        // 保持数据点在合理范围内
        if (_messageData.length > 100) {
          _messageData.removeAt(0);
        }
      }
      
      // 更新连接数据
      if (_stats != null) {
        final activeConnections = _stats!['active_connections'] ?? 0;
        _connectionData.add(FlSpot(_currentTime.toDouble(), activeConnections.toDouble()));
        
        if (_connectionData.length > 100) {
          _connectionData.removeAt(0);
        }
      }
      
      // 更新延迟数据（模拟）
      _latencyData.add(FlSpot(_currentTime.toDouble(), 50 + (_currentTime % 20).toDouble()));
      
      if (_latencyData.length > 100) {
        _latencyData.removeAt(0);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      backgroundColor: SereneColors.surface,
      appBar: GlassAppBar(
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            margin: const EdgeInsets.all(8),
            child: const Icon(
              Icons.menu,
              color: SereneColors.onSurfaceVariant,
            ),
          ),
        ),
        title: Text(
          'Live Monitor',
          style: SereneTypography.headlineSmall.copyWith(
            color: SereneColors.primary,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: SereneSpacing.sm),
            child: _isLoading
                ? SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: SereneColors.primary,
                    ),
                  )
                : SereneIconButton(
                    icon: Icons.settings_outlined,
                    iconColor: SereneColors.onSurfaceVariant,
                    size: 40,
                    tooltip: 'Settings',
                    onPressed: () {
                      // TODO: 打开设置
                    },
                  ),
          ),
        ],
      ),
      body: SafeArea(
        bottom: false,
        child: Stack(
          children: [
            // 背景色
            Container(
              color: SereneColors.surface,
            ),
            // 主内容
            SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(
                SereneSpacing.marginMobile,
                SereneSpacing.lg,
                SereneSpacing.marginMobile,
                SereneSpacing.xl,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 视频播放器
                  _buildVideoPlayer(),
                  const SizedBox(height: SereneSpacing.lg),
                  // 对讲区域
                  _buildIntercomSection(),
                  const SizedBox(height: SereneSpacing.lg),
                  // 流统计
                  _buildStreamStats(),
                  const SizedBox(height: SereneSpacing.lg),
                  // 统计卡片
                  _buildStatsCards(),
                  const SizedBox(height: SereneSpacing.lg),
                  // 图表区域
                  _buildChartsSection(),
                  const SizedBox(height: SereneSpacing.lg),
                  // 连接列表
                  _buildConnectionsList(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 构建视频播放器
  Widget _buildVideoPlayer() {
    return AspectRatio(
      aspectRatio: 16 / 9,
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(SereneSpacing.radiusXl),
          color: SereneColors.surfaceContainerHigh,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 20,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(SereneSpacing.radiusXl),
          child: Stack(
            children: [
              // 视频占位符
              Center(
                child: Icon(
                  Icons.videocam_outlined,
                  size: 64,
                  color: SereneColors.onSurfaceVariant,
                ),
              ),
              // 渐变遮罩
              Container(
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
              // 顶部徽章
              Positioned(
                top: SereneSpacing.md,
                left: SereneSpacing.md,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(SereneSpacing.radiusXl),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.2),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: SereneColors.error,
                        ),
                      ),
                      const SizedBox(width: 6),
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
              // 底部控制
              Positioned(
                bottom: SereneSpacing.md,
                left: SereneSpacing.md,
                right: SereneSpacing.md,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        _buildVideoControlButton(Icons.pause),
                        const SizedBox(width: 8),
                        _buildVolumeControl(),
                      ],
                    ),
                    Row(
                      children: [
                        _buildVideoControlButton(Icons.photo_camera_outlined),
                        const SizedBox(width: 8),
                        _buildVideoControlButton(Icons.fullscreen),
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

  /// 构建视频控制按钮
  Widget _buildVideoControlButton(IconData icon) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withValues(alpha: 0.2),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Icon(
        icon,
        color: Colors.white,
        size: 20,
      ),
    );
  }

  /// 构建音量控制
  Widget _buildVolumeControl() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 8,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(SereneSpacing.radiusXl),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.volume_up,
            color: Colors.white,
            size: 16,
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 80,
            child: SliderTheme(
              data: SliderThemeData(
                activeTrackColor: Colors.white,
                inactiveTrackColor: Colors.white.withValues(alpha: 0.3),
                thumbColor: Colors.white,
                thumbShape: const RoundSliderThumbShape(
                  enabledThumbRadius: 6,
                ),
                overlayShape: const RoundSliderOverlayShape(
                  overlayRadius: 12,
                ),
              ),
              child: Slider(
                value: 0.7,
                onChanged: (value) {
                  // TODO: 控制音量
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 构建对讲区域
  Widget _buildIntercomSection() {
    return GlassCard(
      padding: const EdgeInsets.all(SereneSpacing.xl),
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
            style: SereneTypography.bodyMedium.copyWith(
              color: SereneColors.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: SereneSpacing.lg),
          // 麦克风按钮
          GestureDetector(
            onTapDown: (_) {
              // TODO: 开始录音
            },
            onTapUp: (_) {
              // TODO: 停止录音
            },
            child: Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: SereneColors.primaryContainer,
                boxShadow: [
                  BoxShadow(
                    color: SereneColors.primary.withValues(alpha: 0.2),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Icon(
                Icons.mic,
                size: 48,
                color: SereneColors.onPrimaryContainer,
              ),
            ),
          ),
          const SizedBox(height: SereneSpacing.md),
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

  /// 构建流统计
  Widget _buildStreamStats() {
    return GlassCard(
      padding: const EdgeInsets.all(SereneSpacing.cardPadding),
      child: ExpansionTile(
        title: Row(
          children: [
            Icon(
              Icons.info_outline,
              color: SereneColors.onSurfaceVariant,
              size: 20,
            ),
            const SizedBox(width: SereneSpacing.sm),
            Text(
              'Stream Statistics',
              style: SereneTypography.labelLarge.copyWith(
                color: SereneColors.onSurfaceVariant,
              ),
            ),
          ],
        ),
        children: [
          Padding(
            padding: const EdgeInsets.only(top: SereneSpacing.md),
            child: GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: SereneSpacing.sm,
              mainAxisSpacing: SereneSpacing.sm,
              childAspectRatio: 2.5,
              children: [
                _buildStatItem('FPS', '30'),
                _buildStatItem('Latency', '120ms'),
                _buildStatItem('Bitrate', '2.4 Mbps'),
                _buildStatItem('Signal', 'Excellent'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 构建统计项
  Widget _buildStatItem(String label, String value) {
    return Container(
      padding: const EdgeInsets.all(SereneSpacing.sm),
      decoration: BoxDecoration(
        color: SereneColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(SereneSpacing.radiusDefault),
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
              color: SereneColors.onSurface,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  /// 构建统计卡片
  Widget _buildStatsCards() {
    final ws = _stats?['websocket'] ?? {};
    final audio = _stats?['audio'] ?? {};
    
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            'Active Connections',
            '${ws['active_connections'] ?? 0}',
            Icons.devices,
            SereneColors.primary,
          ),
        ),
        const SizedBox(width: SereneSpacing.sm),
        Expanded(
          child: _buildStatCard(
            'Messages Sent',
            '${ws['messages_sent'] ?? 0}',
            Icons.send,
            SereneColors.safe,
          ),
        ),
        const SizedBox(width: SereneSpacing.sm),
        Expanded(
          child: _buildStatCard(
            'Messages Received',
            '${ws['messages_received'] ?? 0}',
            Icons.call_received,
            SereneColors.warning,
          ),
        ),
        const SizedBox(width: SereneSpacing.sm),
        Expanded(
          child: _buildStatCard(
            'Audio Devices',
            '${audio['active_devices'] ?? 0}',
            Icons.mic,
            SereneColors.tertiary,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return GlassCard(
      padding: const EdgeInsets.all(SereneSpacing.md),
      child: Column(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: SereneSpacing.sm),
          Text(
            value,
            style: SereneTypography.headlineSmall.copyWith(
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: SereneTypography.labelMedium.copyWith(
              color: SereneColors.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  /// 构建图表区域
  Widget _buildChartsSection() {
    return Column(
      children: [
        _buildMessageChart(),
        const SizedBox(height: SereneSpacing.lg),
        _buildConnectionChart(),
        const SizedBox(height: SereneSpacing.lg),
        _buildLatencyChart(),
      ],
    );
  }

  Widget _buildMessageChart() {
    return GlassCard(
      padding: const EdgeInsets.all(SereneSpacing.cardPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.message, color: SereneColors.primary, size: 20),
              const SizedBox(width: SereneSpacing.sm),
              Text(
                'Message Traffic',
                style: SereneTypography.headlineSmall.copyWith(
                  color: SereneColors.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: SereneSpacing.md),
          SizedBox(
            height: 200,
            child: _messageData.isEmpty
              ? Center(
                  child: Text(
                    'No data',
                    style: SereneTypography.bodyMedium.copyWith(
                      color: SereneColors.onSurfaceVariant,
                    ),
                  ),
                )
              : LineChart(
                  LineChartData(
                    gridData: FlGridData(show: true),
                    titlesData: FlTitlesData(show: false),
                    borderData: FlBorderData(show: false),
                    lineBarsData: [
                      LineChartBarData(
                        spots: _messageData,
                        isCurved: true,
                        color: SereneColors.primary,
                        barWidth: 2,
                        dotData: FlDotData(show: false),
                        belowBarData: BarAreaData(
                          show: true,
                          color: SereneColors.primary.withValues(alpha: 0.1),
                        ),
                      ),
                    ],
                  ),
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildConnectionChart() {
    return GlassCard(
      padding: const EdgeInsets.all(SereneSpacing.cardPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.device_hub, color: SereneColors.safe, size: 20),
              const SizedBox(width: SereneSpacing.sm),
              Text(
                'Connections',
                style: SereneTypography.headlineSmall.copyWith(
                  color: SereneColors.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: SereneSpacing.md),
          SizedBox(
            height: 200,
            child: _connectionData.isEmpty
              ? Center(
                  child: Text(
                    'No data',
                    style: SereneTypography.bodyMedium.copyWith(
                      color: SereneColors.onSurfaceVariant,
                    ),
                  ),
                )
              : LineChart(
                  LineChartData(
                    gridData: FlGridData(show: true),
                    titlesData: FlTitlesData(show: false),
                    borderData: FlBorderData(show: false),
                    lineBarsData: [
                      LineChartBarData(
                        spots: _connectionData,
                        isCurved: true,
                        color: SereneColors.safe,
                        barWidth: 2,
                        dotData: FlDotData(show: false),
                        belowBarData: BarAreaData(
                          show: true,
                          color: SereneColors.safe.withValues(alpha: 0.1),
                        ),
                      ),
                    ],
                  ),
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildLatencyChart() {
    return GlassCard(
      padding: const EdgeInsets.all(SereneSpacing.cardPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.speed, color: SereneColors.warning, size: 20),
              const SizedBox(width: SereneSpacing.sm),
              Text(
                'Latency (ms)',
                style: SereneTypography.headlineSmall.copyWith(
                  color: SereneColors.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: SereneSpacing.md),
          SizedBox(
            height: 200,
            child: _latencyData.isEmpty
              ? Center(
                  child: Text(
                    'No data',
                    style: SereneTypography.bodyMedium.copyWith(
                      color: SereneColors.onSurfaceVariant,
                    ),
                  ),
                )
              : LineChart(
                  LineChartData(
                    gridData: FlGridData(show: true),
                    titlesData: FlTitlesData(show: false),
                    borderData: FlBorderData(show: false),
                    lineBarsData: [
                      LineChartBarData(
                        spots: _latencyData,
                        isCurved: true,
                        color: SereneColors.warning,
                        barWidth: 2,
                        dotData: FlDotData(show: false),
                        belowBarData: BarAreaData(
                          show: true,
                          color: SereneColors.warning.withValues(alpha: 0.1),
                        ),
                      ),
                    ],
                  ),
                ),
          ),
        ],
      ),
    );
  }

  /// 构建连接列表
  Widget _buildConnectionsList() {
    return GlassCard(
      padding: const EdgeInsets.all(SereneSpacing.cardPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.list, color: SereneColors.primary, size: 20),
              const SizedBox(width: SereneSpacing.sm),
              Text(
                'Active Connections',
                style: SereneTypography.headlineSmall.copyWith(
                  color: SereneColors.onSurface,
                ),
              ),
              const Spacer(),
              Text(
                '${_connections.length} connections',
                style: SereneTypography.bodySmall.copyWith(
                  color: SereneColors.onSurfaceVariant,
                ),
              ),
            ],
          ),
          const SizedBox(height: SereneSpacing.md),
          if (_connections.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(SereneSpacing.xl),
                child: Text(
                  'No active connections',
                  style: SereneTypography.bodyMedium.copyWith(
                    color: SereneColors.onSurfaceVariant,
                  ),
                ),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _connections.length,
              separatorBuilder: (context, index) => Divider(
                color: SereneColors.outlineVariant.withValues(alpha: 0.2),
              ),
              itemBuilder: (context, index) {
                final conn = _connections[index];
                return _buildConnectionItem(conn);
              },
            ),
        ],
      ),
    );
  }

  Widget _buildConnectionItem(Map<String, dynamic> connection) {
    final clientId = connection['client_id'] ?? 'unknown';
    final clientType = connection['client_type'] ?? 'unknown';
    final deviceId = connection['device_id'];
    final connectedAt = connection['connected_at'] ?? 0;
    
    // 计算连接时长
    final now = DateTime.now().millisecondsSinceEpoch / 1000;
    final duration = now - connectedAt;
    final durationStr = duration < 60 
      ? '${duration.round()}s'
      : duration < 3600 
        ? '${(duration / 60).round()}m'
        : '${(duration / 3600).round()}h';
    
    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: _getClientTypeColor(clientType).withValues(alpha: 0.2),
        ),
        child: Icon(
          _getClientTypeIcon(clientType),
          color: _getClientTypeColor(clientType),
          size: 20,
        ),
      ),
      title: Text(
        clientId,
        style: SereneTypography.labelLarge.copyWith(
          color: SereneColors.onSurface,
        ),
      ),
      subtitle: Text(
        '$clientType • Duration: $durationStr',
        style: SereneTypography.bodySmall.copyWith(
          color: SereneColors.onSurfaceVariant,
        ),
      ),
      trailing: deviceId != null 
        ? Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 8,
              vertical: 4,
            ),
            decoration: BoxDecoration(
              color: SereneColors.primaryContainer.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(SereneSpacing.radiusDefault),
            ),
            child: Text(
              'Device $deviceId',
              style: SereneTypography.labelMedium.copyWith(
                color: SereneColors.primary,
              ),
            ),
          )
        : null,
    );
  }

  Color _getClientTypeColor(String type) {
    switch (type) {
      case 'video_viewer': return SereneColors.primary;
      case 'audio_device': return SereneColors.safe;
      case 'agent_viewer': return SereneColors.tertiary;
      case 'intercom_speaker': return SereneColors.warning;
      case 'intercom_listener': return SereneColors.secondary;
      default: return SereneColors.outline;
    }
  }

  IconData _getClientTypeIcon(String type) {
    switch (type) {
      case 'video_viewer': return Icons.videocam;
      case 'audio_device': return Icons.mic;
      case 'agent_viewer': return Icons.smart_toy;
      case 'intercom_speaker': return Icons.phone_in_talk;
      case 'intercom_listener': return Icons.hearing;
      default: return Icons.device_unknown;
    }
  }
}
