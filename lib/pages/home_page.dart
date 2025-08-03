import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_vlc_player/flutter_vlc_player.dart';
import 'package:my_first_app/pages/vaccine_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../generated/l10n.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';
import '../services/notification_service.dart';
import '../widgets/video_player.dart';
import 'babysleep_page.dart';
import 'data_analysis_page.dart';
import 'development_milestones.dart';
import 'guidance_page.dart';
import 'history_page.dart';
import 'package:my_first_app/widgets/card_widgets.dart';
import 'package:http/http.dart' as http;
import '../widgets/custom_drawer.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0; // 底部导航栏的当前索引
  final PageController _pageController = PageController(); // PageView 控制器

  final List<Widget> _pages = [
    _HomeContent(), // 监控页面
    HistoryPage(),  // 历史记录页面
    // SettingsPage(), // 设置页面
    // ArrangePage(),  //  其他页面
    VaccineSchedulePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: CustomDrawer(), // 侧边栏
      extendBody: true, // 让底部导航栏浮动
      appBar: AppBar(
        title: Text(S.of(context).baby_monitor),
        centerTitle: true,
        automaticallyImplyLeading: false, // 禁止自动生成默认的左侧按钮
        backgroundColor: Colors.white.withOpacity(0.8), // 半透明背景
        elevation: 0, // 去掉阴影
        leading: Builder(
          builder: (context) => IconButton(
            onPressed: () => Scaffold.of(context).openDrawer(), // 打开抽屉
            icon: CircleAvatar(
              radius: 16, // 头像半径，保持原有按钮大小
              backgroundImage: AssetImage('lib/assets/images/v.png'), // 替换为用户头像图片路径
              backgroundColor: Colors.transparent,
            ),
          ),
        ),
      ),
      body: SafeArea(
        bottom: false, // 让底部可以继续渐变
        child: Stack(
          children: [
            // 背景渐变
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color(0xFFE3FDFD),
                    Color(0xFFFFE6FA),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
            // PageView 让页面支持滑动切换，并留出底部导航栏空间
            Padding(
              padding: const EdgeInsets.only(bottom: 70.0), // 预留底部导航栏的空间
              child: PageView(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    _currentIndex = index;
                  });
                },
                children: _pages,
              ),
            ),
            // 这里引用 CardWidgets 组件，并传递 tabItems 配置
            if (_currentIndex == 0) // 仅在 HomePage 显示 CardWidgets
              Positioned(
                bottom: 20,
                left: 0,
                right: 0,
                child: CardWidgets(
                  cardItems: [
                    TabItem(
                      previewImage: 'lib/assets/icons/milestone.png', // 自定义图标路径
                      label: S.of(context).milestones,
                      color: Colors.blue,
                      targetPage: DevelopmentMilestonesPage(),
                    ),
                    TabItem(
                      previewImage: 'lib/assets/icons/guidance.png',
                      label: S.of(context).guide,
                      color: Colors.green,
                      targetPage: GuidancePage(),
                    ),
                    TabItem(
                      previewImage: 'lib/assets/icons/sleep.png',
                      label: S.of(context).sleep,
                      color: Colors.orange,
                      targetPage: SleepPage(),
                    ),
                    TabItem(
                      previewImage: 'lib/assets/icons/statistics.png',
                      label: S.of(context).statistics,
                      color: Colors.purple,
                      targetPage: DataAnalysisPage(),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
      bottomNavigationBar: _buildGlassBottomNavigationBar(),
    );
  }

  // 玻璃拟态底部导航栏
  Widget _buildGlassBottomNavigationBar() {
    return Container(
      padding: const EdgeInsets.only(bottom: 10.0), // 适配安全区域
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20.0)),
        border: Border.all(color: Colors.white.withOpacity(0.3), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: BottomNavigationBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        currentIndex: _currentIndex,
        onTap: (index) {
          _pageController.animateToPage(
            index,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );
        },
        selectedItemColor: Colors.blueAccent,
        unselectedItemColor: Colors.grey,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.videocam),
            label: S.of(context).monitor,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history),
            label: S.of(context).history,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart),
            label: S.of(context).arrange,
          ),
        ],
      ),
    );
  }
}

// Home 页面内容
class _HomeContent extends StatefulWidget {
  @override
  _HomeContentState createState() => _HomeContentState();
}

class _HomeContentState extends State<_HomeContent> {
  String? rtspUrl;
  bool isRtspReady = false;
  bool isLoading = true;
  bool detectionEnabled = false; // 用于控制是否调用检测接口并显示提示
  bool isConnecting = true; // 标记是否正在连接 RTSP 地址
  final NotificationService _notificationService = NotificationService();
  String localVideo = 'lib/assets/videos/jojo_test.mp4'; // 默认播放的视频路径

  @override
  void initState() {
    super.initState();
    _debugCheckToken();
    _fetchDefaultRtsp(); // 直接拉取默认设备的 RTSP 地址
    _loadDetectionSetting();  // 读取 detectionEnabled 设置
    // 初始化通知服务并建立 WebSocket 连接
    _initializeNotificationService();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // 将 fetchDeviceData 移动到 didChangeDependencies 确保 widget 初始化完成
    AuthService().fetchDeviceData(context);
  }

  // 初始化通知服务
  void _initializeNotificationService() async {
    await _notificationService.initialize();
    await _notificationService.initializeWebSocket(); // 在进入页面时默认连接 WebSocket
  }

  // 读取 detectionEnabled 设置
  Future<void> _loadDetectionSetting() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool detectionSetting = prefs.getBool('detection_enabled') ?? false; // 默认值为 false
    setState(() {
      detectionEnabled = detectionSetting;
    });
  }

  // code for testing
  Future<void> _debugCheckToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    print("🔑 [DEBUG] HomeContent.initState() 读取的 Token: $token");

    // 同时验证 AuthService 是否能获取 Token
    String? authServiceToken = await AuthService().getToken();
    print("🔑 [DEBUG] 通过 AuthService.getToken() 获取的 Token: $authServiceToken");
  }
  // code for testing

  // 拉取默认设备的 RTSP 地址
  Future<void> _fetchDefaultRtsp() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      if (token == null) return;

      // 默认获取设备列表中第一个设备
      final response = await http.get(
        Uri.parse(ApiService.deviceList), //  不再传 email
        headers: {'Authorization': 'Bearer $token'},  //  发送 JWT 令牌
      );

      print("服务器响应码: ${response.statusCode}"); // 调试用

      if (response.statusCode == 200) {
        // 解析返回的 JSON 数据
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
      } else {
        print("❌ 获取设备列表失败: ${response.body}");
      }
    } catch (e) {
      print('🚨 异常发生: $e');
    }
  }

  // 获取 RTSP 地址并触发检测
  Future<void> _fetchRtspUrl(String deviceId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token'); // 读取 JWT 令牌

      if (token == null) return;

      final response = await http.get(
        Uri.parse('${ApiService.deviceBase}/$deviceId'), // 获取单个设备信息
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final device = json.decode(response.body);
        setState(() {
          rtspUrl = device['rtsp_url']; // 更新 RTSP 地址
        });
      } else {
        print("❌ 获取设备 RTSP 地址失败: ${response.body}");
      }
    } catch (e) {
      print('🚨 异常发生: $e');
    } finally {
      // 结束加载并取消计时器
      setState(() {
        isLoading = false; // 结束加载
        isConnecting = false; // 确保连接状态更新
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          // 检查 rtspUrl 是否为空
          if (isLoading)
            const CircularProgressIndicator()
          else if (rtspUrl != null && !isConnecting)
            Column(
              children: [
                // 视频播放器部分
                Container(
                  margin: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20.0),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20.0),
                    child: AspectRatio(
                      aspectRatio: 16 / 9, // 视频宽高比
                      child: VideoPlayerWidget(videoUrl: rtspUrl!), // 自定义视频播放器，传递 RTSP 地址
                    ),
                  ),
                ),
                // ✅ 检测状态提示信息
                if (detectionEnabled)
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      "🟢 检测已启用，系统将自动分析视频并发送预警通知。",
                      style: TextStyle(
                        color: Colors.green[700],
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  )
                else if(!detectionEnabled)
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      "🔴 检测未启用，请去设置页面开启。",
                      style: TextStyle(
                        color: Colors.red[700],
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            )
          else
            // 当 RTSP 地址为空时，显示错误信息并播放本地视频
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Text(
                    '未获取到摄像头地址，请检查设备连接。',
                    style: TextStyle(color: Colors.red),
                  ),
                  SizedBox(height: 16.0), // 用于给两部分内容之间留出空间
                  Container(
                    height: 200, // 可以根据需要调整容器大小
                    child: VlcPlayer(
                      controller: VlcPlayerController.asset(localVideo),
                      aspectRatio: 16 / 9, // 设置视频的宽高比
                      virtualDisplay: true, // 启用虚拟显示
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
