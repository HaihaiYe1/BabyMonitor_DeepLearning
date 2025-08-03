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
  };
}
