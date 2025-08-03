import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../generated/l10n.dart';
import '../models/device_model.dart';
import '../providers/device_provider.dart';
import 'package:my_first_app/widgets/test_rtsp.dart'; // RTSP 测试组件
import 'package:flutter_vlc_player/flutter_vlc_player.dart'; // VLC 播放器
import 'package:my_first_app/widgets/video_player.dart'; // 视频播放器组件

class DeviceBindingPage extends ConsumerStatefulWidget {
  final Device? device; // 设备对象

  DeviceBindingPage({Key? key, this.device}) : super(key: key);

  @override
  _DeviceBindingPageState createState() => _DeviceBindingPageState();
}

class _DeviceBindingPageState extends ConsumerState<DeviceBindingPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _ipController = TextEditingController();
  final _statusController = TextEditingController();
  final _rtspController = TextEditingController();
  final _emailController = TextEditingController();
  VlcPlayerController? _vlcPlayerController;
  bool _showPlayer = false; // 是否显示 VLC 播放器

  @override
  void initState() {
    super.initState();
    if (widget.device != null) {
      _nameController.text = widget.device!.name;
      _ipController.text = widget.device!.ip;
      _statusController.text = widget.device!.status;
      _rtspController.text = widget.device!.rtspUrl;
      _emailController.text = widget.device!.email;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _ipController.dispose();
    _statusController.dispose();
    _rtspController.dispose();
    _emailController.dispose();
    _vlcPlayerController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.device == null ? S.of(context).bind_device : S.of(context).edit_device),
        centerTitle: true,
        backgroundColor: Colors.white.withOpacity(0.9),
        elevation: 0,
      ),
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFFE3FDFD), Color(0xFFFFE6FA)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    _buildCardItem(
                        title: S.of(context).device_name,
                        subtitle: _nameController.text.isEmpty ? S.of(context).not_set : _nameController.text,
                        icon: Icons.devices,
                        onTap: () => _editTextField(_nameController, S.of(context).device_name)),
                    _buildCardItem(
                        title: S.of(context).device_ip,
                        subtitle: _ipController.text,
                        icon: Icons.wifi,
                        onTap: () => _editTextField(_ipController, S.of(context).device_ip)),
                    _buildCardItem(
                        title: S.of(context).device_status,
                        subtitle: _statusController.text,
                        icon: Icons.info,
                        onTap: () => _editTextField(_statusController, S.of(context).device_status)),
                    _buildCardItem(
                        title: S.of(context).rtsp_address,
                        subtitle: _rtspController.text,
                        icon: Icons.videocam,
                        onTap: () => _editTextField(_rtspController, S.of(context).rtsp_address)),
                    _buildCardItem(
                        title: S.of(context).bind_email,
                        subtitle: _emailController.text,
                        icon: Icons.email),
                    const SizedBox(height: 16.0),
                    _buildTestButton(),
                    const SizedBox(height: 16.0),
                    _buildSaveOrDeleteButton(),
                    const SizedBox(height: 16.0),
                    if (_showPlayer) VideoPlayerWidget(videoUrl: _rtspController.text),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// **卡片项组件**
  Widget _buildCardItem({
    required String title,
    required String subtitle,
    required IconData icon,
    VoidCallback? onTap,
  }) {
    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        title: Text(title, style: TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle.isEmpty ? S.of(context).not_set : subtitle),
        trailing: Icon(icon),
        onTap: onTap,
      ),
    );
  }

  /// **编辑文本框**
  void _editTextField(TextEditingController controller, String title) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(title),
          content: TextField(
            controller: controller,
            decoration: InputDecoration(hintText: S.of(context).enter_text(title)),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(S.of(context).cancel),
            ),
            TextButton(
              onPressed: () {
                setState(() {});
                Navigator.pop(context);
              },
              child: Text(S.of(context).save),
            ),
          ],
        );
      },
    );
  }

  /// **测试 RTSP 连接**
  Widget _buildTestButton() {
    return ElevatedButton(
      onPressed: () async {
        if (_rtspController.text.isEmpty) return;
        bool isConnected = await testRTSPConnection(_rtspController.text);
        setState(() => _showPlayer = isConnected);
        // 连接成功后显示播放器
        _showDialog(
          isConnected ? S.of(context).connection_success : S.of(context).connection_failed,
          isConnected ? S.of(context).rtsp_connection_success : S.of(context).rtsp_connection_failed,
        );
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      ),
      child: Text(S.of(context).test_rtsp_connection),
    );
  }

  /// **保存 / 删除 按钮**
  Widget _buildSaveOrDeleteButton() {
    return ElevatedButton(
      onPressed: () {
        if (_formKey.currentState!.validate()) {
          final deviceNotifier = ref.read(cameraProvider.notifier);
          final device = Device(
            id: widget.device?.id ?? DateTime.now().toIso8601String(),
            name: _nameController.text,
            ip: _ipController.text,
            status: _statusController.text,
            rtspUrl: _rtspController.text,
            email: _emailController.text,
            lastActive: DateTime.now(),
          );

          if (widget.device == null) {
            deviceNotifier.addDevice(device);
          } else {
            deviceNotifier.updateDevice(device);
          }

          Navigator.pop(context);
        }
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      ),
      child: Text(widget.device == null ? S.of(context).save : S.of(context).update_device),
    );
  }

  /// **显示对话框**
  void _showDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text(S.of(context).close))
        ],
      ),
    );
  }
}
