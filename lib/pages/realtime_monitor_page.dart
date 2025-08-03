import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_vlc_player/flutter_vlc_player.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:flutter/services.dart';

class RealtimeMonitorPage extends StatefulWidget {
  final String video_rtspUrl;  // 接收传递的 rtspUrl

  RealtimeMonitorPage({required this.video_rtspUrl});

  @override
  _RealtimeMonitorPageState createState() => _RealtimeMonitorPageState();
}

class _RealtimeMonitorPageState extends State<RealtimeMonitorPage> {
  late VlcPlayerController _vlcController;
  late StreamSubscription<AccelerometerEvent> _accelerometerSubscription;

  @override
  void initState() {
    super.initState();
    // 使用传递的 rtspUrl 初始化 VlcPlayerController
    _vlcController = VlcPlayerController.network(
      widget.video_rtspUrl, // 传入的视频地址
      autoPlay: true, // 自动播放
      options: VlcPlayerOptions(),
    );

    // 确保状态栏和导航栏显示
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: SystemUiOverlay.values);
  }

  @override
  void dispose() {
    // 取消加速度计的监听
    _accelerometerSubscription.cancel();
    // 停止播放器
    _vlcController.stopRendererScanning();
    _vlcController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // 背景渐变
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFFE3FDFD), // 淡蓝色
                  Color(0xFFFFE6FA), // 淡粉色
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            width: double.infinity,  // 填充整个屏幕
            height: double.infinity, // 填充整个屏幕
          ),
          // 视频播放器部分
          Center(
            child: VlcPlayer(
              controller: _vlcController,
              aspectRatio: 16 / 9,  // 设置为16:9比例
              placeholder: Center(child: CircularProgressIndicator()), // 加载中
            ),
          ),
        ],
      ),
    );
  }
}