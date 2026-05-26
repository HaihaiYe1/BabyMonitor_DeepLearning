import 'package:flutter/material.dart';
import '../pages/data_analysis_page.dart';
import '../pages/faq_page.dart';
import '../pages/home_page.dart';
import '../pages/login_page.dart';
import '../pages/register_page.dart';
import '../pages/account_page.dart';
import '../pages/device_management_page.dart';
import '../pages/support_page.dart';
import '../pages/timing_page.dart';
import '../pages/chat_page.dart';
import '../pages/advice_page.dart';
import '../pages/smart_home_page.dart';
import '../pages/live_monitor_page.dart';
import '../pages/monitoring_dashboard.dart';



class AppRoutes {
  static Map<String, WidgetBuilder> routes = {
    '/login': (context) => LoginPage(),
    '/home': (context) => HomePage(),
    '/register': (context) => RegisterPage(),
    '/account': (context) => AccountPage(),
    '/devices': (context) => DeviceManagementPage(),
    '/support': (context) => SupportPage(),
    '/faq': (context) => FaqPage(),
    '/analysis': (context) => DataAnalysisPage(),
    // timing仅供测试所用
    '/timing': (context) => const TimingPage(),
    // AI Agent对话
    '/chat': (context) => const ChatPage(),
    // 育儿建议
    '/advice': (context) => const AdvicePage(),
    // 智能家居控制
    '/smart-home': (context) => const SmartHomePage(),
    // 监控仪表盘
    '/monitoring': (context) => const MonitoringDashboard(),
  };
}
