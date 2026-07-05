import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:uuid/uuid.dart';
import '../services/api_service.dart';
import '../theme/serene_colors.dart';
import '../theme/serene_spacing.dart';
import '../theme/serene_typography.dart';
import '../widgets/glass_widgets.dart';
import '../widgets/serene_widgets.dart';

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
          debugPrint('Video stream error: $error');
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
      debugPrint('Failed to connect video stream: $e');
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
          debugPrint('Audio stream error: $error');
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
      debugPrint('Failed to connect audio stream: $e');
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
          debugPrint('Intercom error: $error');
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
      debugPrint('Failed to connect intercom: $e');
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
        _videoChannel!.sink.add(jsonEncode({
          'type': 'heartbeat',
          'timestamp': DateTime.now().millisecondsSinceEpoch,
        }));
      }
    } catch (e) {
      debugPrint('Failed to handle video message: $e');
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
      debugPrint('Failed to handle audio message: $e');
    }
  }

  void _handleIntercomMessage(dynamic message) {
    try {
      final data = jsonDecode(message);
      final messageType = data['type'];
      
      if (messageType == 'status') {
        final status = data['data']['status'];
        debugPrint('Intercom status: $status');
      }
    } catch (e) {
      debugPrint('Failed to handle intercom message: $e');
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
          '${widget.deviceName} - Live Monitor',
          style: SereneTypography.headlineSmall.copyWith(
            color: SereneColors.primary,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: SereneSpacing.sm),
            child: Row(
              children: [
                // 视频连接状态
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _isVideoConnected ? SereneColors.safe : SereneColors.error,
                  ),
                ),
                const SizedBox(width: 8),
                // 刷新按钮
                SereneIconButton(
                  icon: Icons.refresh,
                  iconColor: SereneColors.onSurfaceVariant,
                  size: 40,
                  tooltip: 'Reconnect',
                  onPressed: _connectToStreams,
                ),
              ],
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
                  // 视频区域
                  _buildVideoSection(),
                  const SizedBox(height: SereneSpacing.lg),
                  // 对讲区域
                  _buildIntercomSection(),
                  const SizedBox(height: SereneSpacing.lg),
                  // 流统计
                  _buildStreamStats(),
                  const SizedBox(height: SereneSpacing.lg),
                  // 音频区域
                  _buildAudioSection(),
                  const SizedBox(height: SereneSpacing.lg),
                  // 连接统计
                  _buildStatsSection(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 构建视频区域
  Widget _buildVideoSection() {
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
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      _isVideoConnected ? Icons.videocam : Icons.videocam_off,
                      size: 64,
                      color: _isVideoConnected ? SereneColors.safe : SereneColors.onSurfaceVariant,
                    ),
                    const SizedBox(height: SereneSpacing.sm),
                    Text(
                      _isVideoConnected ? 'Receiving video stream...' : 'Waiting for connection...',
                      style: SereneTypography.bodyMedium.copyWith(
                        color: SereneColors.onSurfaceVariant,
                      ),
                    ),
                    if (_lastFrameTimestamp.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        'Last frame: $_lastFrameTimestamp',
                        style: SereneTypography.bodySmall.copyWith(
                          color: SereneColors.outline,
                        ),
                      ),
                    ],
                  ],
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
                          color: _isVideoConnected ? SereneColors.safe : SereneColors.error,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        _isVideoConnected ? 'LIVE' : 'OFFLINE',
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
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Intercom',
                style: SereneTypography.headlineSmall.copyWith(
                  color: SereneColors.onSurface,
                ),
              ),
              const SizedBox(width: SereneSpacing.sm),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: _isIntercomActive
                      ? SereneColors.safe.withValues(alpha: 0.2)
                      : SereneColors.surfaceVariant,
                  borderRadius: BorderRadius.circular(SereneSpacing.radiusXl),
                ),
                child: Text(
                  _isIntercomActive ? 'Connected' : 'Disconnected',
                  style: SereneTypography.labelMedium.copyWith(
                    color: _isIntercomActive ? SereneColors.safe : SereneColors.onSurfaceVariant,
                  ),
                ),
              ),
            ],
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
              if (!_isIntercomActive) {
                _connectIntercom();
              }
            },
            onTapUp: (_) {
              // 保持连接
            },
            child: Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _isIntercomActive
                    ? SereneColors.primary
                    : SereneColors.primaryContainer,
                boxShadow: [
                  BoxShadow(
                    color: (_isIntercomActive ? SereneColors.primary : SereneColors.primaryContainer)
                        .withValues(alpha: 0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Icon(
                Icons.mic,
                size: 48,
                color: _isIntercomActive
                    ? SereneColors.onPrimary
                    : SereneColors.onPrimaryContainer,
              ),
            ),
          ),
          const SizedBox(height: SereneSpacing.md),
          Text(
            _isIntercomActive ? 'Connected' : 'Push to Talk',
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
                _buildStatItem('Latency', '${_latency.toStringAsFixed(0)}ms'),
                _buildStatItem('Frames', '$_framesReceived'),
                _buildStatItem('Audio', '$_audioChunksReceived'),
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

  /// 构建音频区域
  Widget _buildAudioSection() {
    return GlassCard(
      padding: const EdgeInsets.all(SereneSpacing.cardPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.mic, color: SereneColors.safe, size: 20),
              const SizedBox(width: SereneSpacing.sm),
              Text(
                'Audio Stream',
                style: SereneTypography.headlineSmall.copyWith(
                  color: SereneColors.onSurface,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: _isAudioConnected
                      ? SereneColors.safe.withValues(alpha: 0.2)
                      : SereneColors.error.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(SereneSpacing.radiusXl),
                ),
                child: Text(
                  _isAudioConnected ? 'Connected' : 'Disconnected',
                  style: SereneTypography.labelMedium.copyWith(
                    color: _isAudioConnected ? SereneColors.safe : SereneColors.error,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: SereneSpacing.md),
          // 音频可视化
          Container(
            height: 80,
            decoration: BoxDecoration(
              color: SereneColors.surfaceContainerLow,
              borderRadius: BorderRadius.circular(SereneSpacing.radiusMd),
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
                      color: _isAudioConnected ? SereneColors.safe : SereneColors.outlineVariant,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  );
                }),
              ),
            ),
          ),
          const SizedBox(height: SereneSpacing.sm),
          Text(
            'Audio chunks: $_audioChunksReceived',
            style: SereneTypography.bodySmall.copyWith(
              color: SereneColors.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  /// 构建统计区域
  Widget _buildStatsSection() {
    return GlassCard(
      padding: const EdgeInsets.all(SereneSpacing.cardPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.analytics, color: SereneColors.primary, size: 20),
              const SizedBox(width: SereneSpacing.sm),
              Text(
                'Connection Statistics',
                style: SereneTypography.headlineSmall.copyWith(
                  color: SereneColors.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: SereneSpacing.md),
          _buildStatRow('Video Connection', _isVideoConnected ? 'Normal' : 'Disconnected'),
          _buildStatRow('Audio Connection', _isAudioConnected ? 'Normal' : 'Disconnected'),
          _buildStatRow('Intercom Connection', _isIntercomConnected ? 'Normal' : 'Disconnected'),
          _buildStatRow('Frames Received', '$_framesReceived'),
          _buildStatRow('Audio Chunks', '$_audioChunksReceived'),
          _buildStatRow('Video Client ID', _videoClientId),
          _buildStatRow('Audio Client ID', _audioClientId),
        ],
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
}
