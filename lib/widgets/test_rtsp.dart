import 'dart:io';

Future<bool> testRTSPConnection(String rtspUrl) async {
  try {
    // 提取 RTSP URL 的主机名和端口
    final uri = Uri.parse(rtspUrl);
    final host = uri.host;
    final port = uri.port;

    // 尝试与 RTSP 服务建立 TCP 连接
    final socket = await Socket.connect(host, port, timeout: Duration(seconds: 30));

    // 如果连接成功，关闭 socket
    socket.destroy();

    print("✅ RTSP 连接成功");
    return true;
  } catch (e) {
    print("❌ RTSP 连接失败: $e");
    return false;
  }
}