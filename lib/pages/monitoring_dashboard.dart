import 'dart:async';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../services/api_service.dart';
import '../generated/l10n.dart';
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
      print('加载监控数据失败: $e');
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
      print('加载统计数据失败: $e');
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
      print('加载连接数据失败: $e');
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
      print('加载音频数据失败: $e');
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
      appBar: AppBar(
        title: Text(S.of(context).monitoring_dashboard ?? '监控仪表盘'),
        backgroundColor: Colors.white.withOpacity(0.8),
        elevation: 0,
        actions: [
          IconButton(
            icon: _isLoading 
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.refresh),
            onPressed: _isLoading ? null : _loadData,
            tooltip: '刷新数据',
          ),
          PopupMenuButton<int>(
            icon: const Icon(Icons.timer),
            onSelected: (value) {
              setState(() {
                _timeRange = value;
              });
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 300, child: Text('5分钟')),
              const PopupMenuItem(value: 900, child: Text('15分钟')),
              const PopupMenuItem(value: 1800, child: Text('30分钟')),
              const PopupMenuItem(value: 3600, child: Text('1小时')),
            ],
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFE3FDFD), Color(0xFFFFE6FA)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildStatsCards(),
              const SizedBox(height: 24),
              _buildMessageChart(),
              const SizedBox(height: 24),
              _buildConnectionChart(),
              const SizedBox(height: 24),
              _buildLatencyChart(),
              const SizedBox(height: 24),
              _buildConnectionsList(),
              const SizedBox(height: 24),
              _buildAudioStats(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatsCards() {
    final ws = _stats?['websocket'] ?? {};
    final audio = _stats?['audio'] ?? {};
    
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            '活跃连接',
            '${ws['active_connections'] ?? 0}',
            Icons.devices,
            Colors.blue,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            '消息发送',
            '${ws['messages_sent'] ?? 0}',
            Icons.send,
            Colors.green,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            '消息接收',
            '${ws['messages_received'] ?? 0}',
            Icons.call_received,
            Colors.orange,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            '音频设备',
            '${audio['active_devices'] ?? 0}',
            Icons.mic,
            Colors.purple,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageChart() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.message, color: Colors.blue[700]),
                const SizedBox(width: 8),
                Text(
                  '消息流量',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: _messageData.isEmpty
                ? const Center(child: Text('暂无数据'))
                : LineChart(
                    LineChartData(
                      gridData: FlGridData(show: true),
                      titlesData: FlTitlesData(show: false),
                      borderData: FlBorderData(show: false),
                      lineBarsData: [
                        LineChartBarData(
                          spots: _messageData,
                          isCurved: true,
                          color: Colors.blue,
                          barWidth: 2,
                          dotData: FlDotData(show: false),
                          belowBarData: BarAreaData(
                            show: true,
                            color: Colors.blue.withOpacity(0.1),
                          ),
                        ),
                      ],
                    ),
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConnectionChart() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.device_hub, color: Colors.green[700]),
                const SizedBox(width: 8),
                Text(
                  '连接数',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: _connectionData.isEmpty
                ? const Center(child: Text('暂无数据'))
                : LineChart(
                    LineChartData(
                      gridData: FlGridData(show: true),
                      titlesData: FlTitlesData(show: false),
                      borderData: FlBorderData(show: false),
                      lineBarsData: [
                        LineChartBarData(
                          spots: _connectionData,
                          isCurved: true,
                          color: Colors.green,
                          barWidth: 2,
                          dotData: FlDotData(show: false),
                          belowBarData: BarAreaData(
                            show: true,
                            color: Colors.green.withOpacity(0.1),
                          ),
                        ),
                      ],
                    ),
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLatencyChart() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.speed, color: Colors.orange[700]),
                const SizedBox(width: 8),
                Text(
                  '延迟 (ms)',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: _latencyData.isEmpty
                ? const Center(child: Text('暂无数据'))
                : LineChart(
                    LineChartData(
                      gridData: FlGridData(show: true),
                      titlesData: FlTitlesData(show: false),
                      borderData: FlBorderData(show: false),
                      lineBarsData: [
                        LineChartBarData(
                          spots: _latencyData,
                          isCurved: true,
                          color: Colors.orange,
                          barWidth: 2,
                          dotData: FlDotData(show: false),
                          belowBarData: BarAreaData(
                            show: true,
                            color: Colors.orange.withOpacity(0.1),
                          ),
                        ),
                      ],
                    ),
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConnectionsList() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.list, color: Colors.purple[700]),
                const SizedBox(width: 8),
                Text(
                  '活跃连接',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                ),
                const Spacer(),
                Text(
                  '${_connections.length} 个连接',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (_connections.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(32),
                  child: Text(
                    '暂无活跃连接',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _connections.length,
                separatorBuilder: (context, index) => const Divider(),
                itemBuilder: (context, index) {
                  final conn = _connections[index];
                  return _buildConnectionItem(conn);
                },
              ),
          ],
        ),
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
      ? '${duration.round()}秒'
      : duration < 3600 
        ? '${(duration / 60).round()}分钟'
        : '${(duration / 3600).round()}小时';
    
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: _getClientTypeColor(clientType).withOpacity(0.2),
        child: Icon(
          _getClientTypeIcon(clientType),
          color: _getClientTypeColor(clientType),
        ),
      ),
      title: Text(
        clientId,
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      subtitle: Text('$clientType • 连接时长: $durationStr'),
      trailing: deviceId != null 
        ? Chip(
            label: Text('设备 $deviceId'),
            backgroundColor: Colors.blue[100],
          )
        : null,
    );
  }

  Color _getClientTypeColor(String type) {
    switch (type) {
      case 'video_viewer': return Colors.blue;
      case 'audio_device': return Colors.green;
      case 'agent_viewer': return Colors.purple;
      case 'intercom_speaker': return Colors.orange;
      case 'intercom_listener': return Colors.teal;
      default: return Colors.grey;
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

  Widget _buildAudioStats() {
    final audio = _audioStats?['audio_stats'] ?? {};
    final bufferSizes = audio['buffer_sizes'] as Map<String, dynamic>? ?? {};
    
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.audiotrack, color: Colors.teal[700]),
                const SizedBox(width: 8),
                Text(
                  '音频统计',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildStatRow('活跃设备', '${audio['active_devices'] ?? 0}'),
            _buildStatRow('流式传输设备', '${audio['streaming_devices'] ?? 0}'),
            if (bufferSizes.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                '缓冲区状态',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[700],
                ),
              ),
              const SizedBox(height: 8),
              ...bufferSizes.entries.map((entry) {
                return _buildStatRow('设备 ${entry.key}', '${entry.value} 块');
              }).toList(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
        ],
      ),
    );
  }
}
