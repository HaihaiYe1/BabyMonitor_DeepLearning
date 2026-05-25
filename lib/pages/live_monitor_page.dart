import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../services/api_service.dart';
import '../generated/l10n.dart';

class LiveMonitorPage extends StatefulWidget {
  final int deviceId;
  final String deviceName;

  const LiveMonitorPage({
    Key? key,
    required this.deviceId,
    required this.deviceName,
  }) : super(key: key);

  @override
  _LiveMonitorPageState createState() => _LiveMonitorPageState();
}

class _LiveMonitorPageState extends State<LiveMonitorPage> {
  // WebSocket连接
  WebSocketChannel? _videoChannel;
  WebSocketChannel? _audioChannel;
  WebSocketChannel? _intercomChannel;
  
  // 状态
  bool _isVideoConnected = false;
  bool _isAudioConnected = false;
  bool _isIntercomConnected = false;
  bool _isIntercomActive = false;
  
  // 统计
  int _framesReceived = 0;
  int _audioChunksReceived = 0;
  double _latency = 0.0;
  
  // 客户端ID
  late String _videoClientId;
  late String _audioClientId;
  late String _intercomClientId;
  
  // 订阅
  StreamSubscription? _videoSubscription;
  StreamSubscription? _audioSubscription;
  StreamSubscription? _intercomSubscription;
  
  // 视频帧数据（用于显示状态）
  String _lastFrameTimestamp = '';
  
  // 音频状态
  bool _isMuted = false;
  String _intercomRole = 'speaker';

  @override
  void initState() {
    super.initState();
    _generateClientIds();
    _connectToStreams();
  }

  @override
  void dispose() {
    _disconnectAll();
    super.dispose();
  }

  void _generateClientIds() {
    final uuid = const Uuid();
    _videoClientId = 'video_${uuid.v4().substring(0, 8)}';
    _audioClientId = 'audio_${uuid.v4().substring(0, 8)}';
    _intercomClientId = 'intercom_${uuid.v4().substring(0, 8)}';
  }

  Future<void> _connectToStreams() async {
    await _connectVideoStream();
    await _connectAudioStream();
  }

  Future<void> _connectVideoStream() async {
    try {
      final wsUrl = ApiService.videoStreamWs(widget.deviceId, _videoClientId);
      _videoChannel = WebSocketChannel.connect(Uri.parse(wsUrl));
      
      _videoSubscription = _videoChannel!.stream.listen(
        (message) {
          _handleVideoMessage(message);
        },
        onError: (error) {
          print('视频流错误: $error');
          setState(() {
            _isVideoConnected = false;
          });
        },
        onDone: () {
          setState(() {
            _isVideoConnected = false;
          });
        },
      );

      setState(() {
        _isVideoConnected = true;
      });
      
      // 发送订阅消息
      _videoChannel!.sink.add(jsonEncode({
        'type': 'subscribe',
        'device_id': widget.deviceId,
      }));
      
    } catch (e) {
      print('连接视频流失败: $e');
      setState(() {
        _isVideoConnected = false;
      });
    }
  }

  Future<void> _connectAudioStream() async {
    try {
      final wsUrl = ApiService.audioStreamWs(widget.deviceId, _audioClientId);
      _audioChannel = WebSocketChannel.connect(Uri.parse(wsUrl));
      
      _audioSubscription = _audioChannel!.stream.listen(
        (message) {
          _handleAudioMessage(message);
        },
        onError: (error) {
          print('音频流错误: $error');
          setState(() {
            _isAudioConnected = false;
          });
        },
        onDone: () {
          setState(() {
            _isAudioConnected = false;
          });
        },
      );

      setState(() {
        _isAudioConnected = true;
      });
      
    } catch (e) {
      print('连接音频流失败: $e');
      setState(() {
        _isAudioConnected = false;
      });
    }
  }

  Future<void> _connectIntercom() async {
    try {
      final wsUrl = ApiService.intercomWs(
        widget.deviceId, 
        _intercomClientId,
        role: _intercomRole,
      );
      _intercomChannel = WebSocketChannel.connect(Uri.parse(wsUrl));
      
      _intercomSubscription = _intercomChannel!.stream.listen(
        (message) {
          _handleIntercomMessage(message);
        },
        onError: (error) {
          print('对讲错误: $error');
          setState(() {
            _isIntercomConnected = false;
            _isIntercomActive = false;
          });
        },
        onDone: () {
          setState(() {
            _isIntercomConnected = false;
            _isIntercomActive = false;
          });
        },
      );

      setState(() {
        _isIntercomConnected = true;
        _isIntercomActive = true;
      });
      
    } catch (e) {
      print('连接对讲失败: $e');
      setState(() {
        _isIntercomConnected = false;
        _isIntercomActive = false;
      });
    }
  }

  void _handleVideoMessage(dynamic message) {
    try {
      final data = jsonDecode(message);
      final messageType = data['type'];
      
      if (messageType == 'video_frame') {
        setState(() {
          _framesReceived++;
          _lastFrameTimestamp = DateTime.now().toString().substring(11, 19);
        });
      } else if (messageType == 'heartbeat') {
        // 心跳响应
        _videoChannel!.sink.add(jsonEncode({
          'type': 'heartbeat',
          'timestamp': DateTime.now().millisecondsSinceEpoch,
        }));
      }
    } catch (e) {
      print('处理视频消息失败: $e');
    }
  }

  void _handleAudioMessage(dynamic message) {
    try {
      final data = jsonDecode(message);
      final messageType = data['type'];
      
      if (messageType == 'audio_data') {
        setState(() {
          _audioChunksReceived++;
        });
      }
    } catch (e) {
      print('处理音频消息失败: $e');
    }
  }

  void _handleIntercomMessage(dynamic message) {
    try {
      final data = jsonDecode(message);
      final messageType = data['type'];
      
      if (messageType == 'status') {
        final status = data['data']['status'];
        print('对讲状态: $status');
      }
    } catch (e) {
      print('处理对讲消息失败: $e');
    }
  }

  void _toggleIntercom() {
    if (_isIntercomActive) {
      _disconnectIntercom();
    } else {
      _connectIntercom();
    }
  }

  void _toggleMute() {
    setState(() {
      _isMuted = !_isMuted;
    });
    
    if (_isIntercomConnected) {
      _intercomChannel!.sink.add(jsonEncode({
        'type': 'control',
        'action': _isMuted ? 'mute' : 'unmute',
      }));
    }
  }

  void _switchIntercomRole() {
    setState(() {
      _intercomRole = _intercomRole == 'speaker' ? 'listener' : 'speaker';
    });
    
    if (_isIntercomConnected) {
      _intercomChannel!.sink.add(jsonEncode({
        'type': 'control',
        'action': 'switch_role',
      }));
    }
  }

  void _disconnectIntercom() {
    _intercomSubscription?.cancel();
    _intercomChannel?.sink.close();
    setState(() {
      _isIntercomConnected = false;
      _isIntercomActive = false;
    });
  }

  void _disconnectAll() {
    _videoSubscription?.cancel();
    _audioSubscription?.cancel();
    _intercomSubscription?.cancel();
    
    _videoChannel?.sink.close();
    _audioChannel?.sink.close();
    _intercomChannel?.sink.close();
  }

  void _sendHeartbeat() {
    if (_isVideoConnected) {
      _videoChannel!.sink.add(jsonEncode({
        'type': 'heartbeat',
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      }));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.deviceName} - 实时监控'),
        backgroundColor: Colors.white.withOpacity(0.8),
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(
              _isVideoConnected ? Icons.videocam : Icons.videocam_off,
              color: _isVideoConnected ? Colors.green : Colors.red,
            ),
            onPressed: null,
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _connectToStreams,
            tooltip: '重新连接',
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
              _buildVideoSection(),
              const SizedBox(height: 24),
              _buildAudioSection(),
              const SizedBox(height: 24),
              _buildIntercomSection(),
              const SizedBox(height: 24),
              _buildStatsSection(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildVideoSection() {
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
                Icon(Icons.videocam, color: Colors.blue[700]),
                const SizedBox(width: 8),
                Text(
                  '视频流',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _isVideoConnected ? Colors.green[100] : Colors.red[100],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    _isVideoConnected ? '已连接' : '未连接',
                    style: TextStyle(
                      fontSize: 12,
                      color: _isVideoConnected ? Colors.green[700] : Colors.red[700],
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // 视频显示区域（模拟）
            Container(
              height: 200,
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      _isVideoConnected ? Icons.videocam : Icons.videocam_off,
                      size: 48,
                      color: _isVideoConnected ? Colors.green : Colors.grey,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _isVideoConnected ? '视频流接收中...' : '等待连接...',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                      ),
                    ),
                    if (_lastFrameTimestamp.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        '最后帧: $_lastFrameTimestamp',
                        style: TextStyle(
                          color: Colors.grey[400],
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '帧数: $_framesReceived',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
                Text(
                  '设备ID: ${widget.deviceId}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAudioSection() {
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
                Icon(Icons.mic, color: Colors.green[700]),
                const SizedBox(width: 8),
                Text(
                  '音频流',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _isAudioConnected ? Colors.green[100] : Colors.red[100],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    _isAudioConnected ? '已连接' : '未连接',
                    style: TextStyle(
                      fontSize: 12,
                      color: _isAudioConnected ? Colors.green[700] : Colors.red[700],
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // 音频可视化（模拟）
            Container(
              height: 80,
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(20, (index) {
                    return Container(
                      width: 8,
                      height: 20 + (index % 5) * 10.0,
                      margin: const EdgeInsets.symmetric(horizontal: 2),
                      decoration: BoxDecoration(
                        color: _isAudioConnected ? Colors.green : Colors.grey,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    );
                  }),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '音频块数: $_audioChunksReceived',
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

  Widget _buildIntercomSection() {
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
                Icon(Icons.phone, color: Colors.orange[700]),
                const SizedBox(width: 8),
                Text(
                  '双向语音对讲',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _isIntercomActive ? Colors.green[100] : Colors.grey[100],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    _isIntercomActive ? '通话中' : '未连接',
                    style: TextStyle(
                      fontSize: 12,
                      color: _isIntercomActive ? Colors.green[700] : Colors.grey[700],
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // 角色选择
            Row(
              children: [
                Text(
                  '角色: ',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[700],
                  ),
                ),
                ChoiceChip(
                  label: const Text('说话者'),
                  selected: _intercomRole == 'speaker',
                  onSelected: (selected) {
                    if (selected && !_isIntercomActive) {
                      setState(() {
                        _intercomRole = 'speaker';
                      });
                    }
                  },
                ),
                const SizedBox(width: 8),
                ChoiceChip(
                  label: const Text('听者'),
                  selected: _intercomRole == 'listener',
                  onSelected: (selected) {
                    if (selected && !_isIntercomActive) {
                      setState(() {
                        _intercomRole = 'listener';
                      });
                    }
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),
            // 控制按钮
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _toggleIntercom,
                    icon: Icon(_isIntercomActive ? Icons.phone_disabled : Icons.phone),
                    label: Text(_isIntercomActive ? '挂断' : '开始对讲'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _isIntercomActive ? Colors.red : Colors.green,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                if (_isIntercomActive) ...[
                  const SizedBox(width: 12),
                  ElevatedButton.icon(
                    onPressed: _toggleMute,
                    icon: Icon(_isMuted ? Icons.mic_off : Icons.mic),
                    label: Text(_isMuted ? '取消静音' : '静音'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _isMuted ? Colors.grey : Colors.blue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsSection() {
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
                Icon(Icons.analytics, color: Colors.purple[700]),
                const SizedBox(width: 8),
                Text(
                  '连接统计',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildStatRow('视频连接', _isVideoConnected ? '正常' : '断开'),
            _buildStatRow('音频连接', _isAudioConnected ? '正常' : '断开'),
            _buildStatRow('对讲连接', _isIntercomConnected ? '正常' : '断开'),
            _buildStatRow('接收帧数', '$_framesReceived'),
            _buildStatRow('音频块数', '$_audioChunksReceived'),
            _buildStatRow('视频客户端ID', _videoClientId),
            _buildStatRow('音频客户端ID', _audioClientId),
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
