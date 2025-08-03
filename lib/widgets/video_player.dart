import 'package:flutter/material.dart';
import 'package:flutter_vlc_player/flutter_vlc_player.dart';
import 'package:my_first_app/pages/realtime_monitor_page.dart'; // 导入全屏页面

class VideoPlayerWidget extends StatefulWidget {
  final String videoUrl; // 传入视频地址
  VideoPlayerWidget({required this.videoUrl});

  @override
  _VideoPlayerWidgetState createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends State<VideoPlayerWidget> {
  late VlcPlayerController _vlcController;
  bool _isPlaying = true;
  bool _showControls = false; // 控制显示/隐藏按钮
  late Future<void> _hideControlsFuture;

  @override
  void initState() {
    super.initState();
    _vlcController = VlcPlayerController.network(
      widget.videoUrl, // 传入的视频地址
      autoPlay: true, // 自动播放
      options: VlcPlayerOptions(),
    );

    _hideControlsFuture = Future.delayed(Duration(seconds: 2), () {
      setState(() {
        _showControls = false; // 2秒后自动隐藏控件
      });
    });
  }

  @override
  void dispose() {
    // 在页面销毁时销毁播放器控制器
    _vlcController.stopRendererScanning();
    _vlcController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _onTap,
      child: Container(
        color: Colors.black, // 视频背景色
        child: Stack(
          alignment: Alignment.bottomCenter,
          children: [
            VlcPlayer(
              controller: _vlcController,
              aspectRatio: 16 / 9,
              placeholder: Center(child: CircularProgressIndicator()), // 加载中
            ),
            if (_showControls) _buildControls(context), // 控制栏
          ],
        ),
      ),
    );
  }

  // 处理点击事件，显示控件并重置隐藏定时器
  void _onTap() {
    if (!mounted) return; // 检查是否仍然挂载
    setState(() {
      _showControls = true; // 点击时显示控件
    });

    // 2秒后自动隐藏控件
    _hideControlsFuture = Future.delayed(Duration(seconds: 2), () {
      if (!mounted) return; // 检查是否仍然挂载
      setState(() {
        _showControls = false;
      });
    });
  }

  // 控制播放、音量和全屏的按钮
  Widget _buildControls(BuildContext context) {
    return Positioned(
      bottom: 10, // 按钮位置靠近进度条下方
      left: 10, // 靠左对齐
      right: 10, // 添加右边距，避免按钮和屏幕边缘太靠近
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween, // 两端对齐
        children: [
          // 播放/暂停按钮
          IconButton(
            icon: Icon(
              _isPlaying ? Icons.pause : Icons.play_arrow,
              color: Colors.white,
            ),
            onPressed: () {
              setState(() {
                if (_isPlaying) {
                  _vlcController.pause();
                } else {
                  _vlcController.play();
                }
                _isPlaying = !_isPlaying;
              });
            },
          ),
          // 音量进度条
          Row(
            children: [
              Icon(
                _vlcController.value.volume > 0 ? Icons.volume_up : Icons.volume_off,
                color: Colors.white,
              ),
              SizedBox(width: 10),
              // 音量滑块
              Slider(
                value: _vlcController.value.volume.toDouble(),
                min: 0,
                max: 100,
                activeColor: Colors.white,
                inactiveColor: Colors.grey,
                onChanged: (value) {
                  setState(() {
                    _vlcController.setVolume(value.toInt());
                  });
                },
              ),
            ],
          ),
          // 全屏按钮
          IconButton(
            icon: Icon(Icons.fullscreen, color: Colors.white),
            onPressed: () {
              // 在跳转到全屏页面之前销毁当前播放器
              _vlcController.dispose(); // 销毁当前播放器

              // 跳转到全屏页面，并传递 videoUrl
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => RealtimeMonitorPage(
                    video_rtspUrl: widget.videoUrl,  // 传递视频地址
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}