import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../generated/l10n.dart';
import '../providers/device_provider.dart';
import '../models/device_model.dart';
import '../services/auth_service.dart';
import '../widgets/card_widgets.dart';
import 'device_binding_page.dart'; // 设备绑定页面
import '../widgets/card_widgets.dart'; // 设备卡片组件
import 'package:shared_preferences/shared_preferences.dart'; // 导入 SharedPreferences

class DeviceManagementPage extends ConsumerStatefulWidget {
  @override
  _DeviceManagementPageState createState() => _DeviceManagementPageState();
}

class _DeviceManagementPageState extends ConsumerState<DeviceManagementPage> {
  @override
  void initState() {
    super.initState();

    // 检查 token 是否过期，如果过期弹出重新登录对话框
    AuthService().fetchDeviceData(context);

    _fetchDevices();
  }

  /// 从 SharedPreferences 获取 token 并向后端请求设备列表
  Future<void> _fetchDevices() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token != null) {
      print("📦 读取到的 Token: $token");
      // 假设你在 provider 中实现了支持 token 的方法（后端根据 token 自动识别用户身份）
      ref.read(cameraProvider.notifier).fetchDevicesByToken(token);
    } else {
      print("⚠️ 用户未登录或 Token 不存在");
    }
  }

  /// 跳转到设备绑定页面
  void _navigateToDeviceBindingPage({Device? device}) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DeviceBindingPage(device: device),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final deviceList = ref.watch(cameraProvider); // 监听设备数据

    return Scaffold(
      appBar: AppBar(
        title: Text(S.of(context).device_management),
        centerTitle: true,
        backgroundColor: Colors.white.withOpacity(0.8),
        elevation: 0,
      ),
      body: SafeArea(
        bottom: false,
        child: Stack(
          children: [
            // 背景渐变
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFFE3FDFD), Color(0xFFFFE6FA)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
            // 设备列表
            Positioned(
              top: 16.0,
              left: 16.0,
              right: 16.0,
              child: deviceList.isEmpty
                  ? Center(child: Text(S.of(context).loading_devices)) // 加载状态
                  : CardWidgets(
                      cardItems: deviceList.map((device) {
                        return DeviceCardItem(
                          deviceName: device.name,
                          deviceIP: device.ip,
                          deviceStatus: device.status,
                          targetPage: DeviceBindingPage(device: device),
                        );
                      }).toList(),
                    ),
            ),
            // 添加设备按钮
            Positioned(
              right: 16.0,
              bottom: 16.0,
              child: FloatingActionButton(
                onPressed: () => _navigateToDeviceBindingPage(),
                child: const Icon(Icons.add),
                backgroundColor: Colors.blue,
                tooltip: S.of(context).add_device,
              ),
            ),
          ],
        ),
      ),
    );
  }
}