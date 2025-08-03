import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // 用于复制功能
import 'package:url_launcher/url_launcher.dart';
import '../generated/l10n.dart';

class SupportPage extends StatefulWidget {
  @override
  _SupportPageState createState() => _SupportPageState();
}

class _SupportPageState extends State<SupportPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    // 初始化 TabController，创建两个标签页面
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose(); // 释放 TabController
    super.dispose();
  }

  // 拨打电话
  Future<void> _launchPhone(String phoneNumber) async {
    final Uri uri = Uri(scheme: 'tel', path: phoneNumber);
    try {
      await launchUrl(uri);
    } catch (e) {
      print('拨号失败: $e');
    }
  }

  void _showEmailDialog(BuildContext context, String email) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('联系邮箱'),
        content: SelectableText(email),
        actions: [
          TextButton(
            onPressed: () {
              Clipboard.setData(ClipboardData(text: email));
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('邮箱地址已复制')),
              );
            },
            child: const Text('复制邮箱'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('关闭'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true, // 使得底部导航栏悬浮
      appBar: AppBar(
        title: Text(S.of(context).support_page_title),
        centerTitle: true,
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white.withOpacity(0.8),
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.blueAccent,
          labelColor: Colors.blueAccent,
          unselectedLabelColor: Colors.grey,
          tabs: [
            Tab(text: S.of(context).faq_tab_title),
            Tab(text: S.of(context).contact_tab_title),
          ],
        ),
      ),
      body: SafeArea(
        bottom: false,
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
            // TabBarView 内容区域
            Padding(
              padding: const EdgeInsets.only(bottom: 70.0), // 留出底部导航栏空间
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildFAQTab(), // 常见问题页面内容
                  _buildContactTab(), // 联系客服页面内容
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  // 常见问题Tab
  Widget _buildFAQTab() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: ListView(
        children: [
          _buildFAQItem(S.of(context).faq_question_1, S.of(context).faq_answer_1),
          _buildFAQItem(S.of(context).faq_question_2, S.of(context).faq_answer_2),
          _buildFAQItem(S.of(context).faq_question_3, S.of(context).faq_answer_3),
        ],
      ),
    );
  }

  // 联系客服Tab
  Widget _buildContactTab() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          _buildContactCard(
            icon: Icons.phone,
            title: S.of(context).contact_phone_title,
            description: S.of(context).contact_phone_description,
            onTap: () => _launchPhone('19553510583'), // 拨号操作
          ),
          const SizedBox(height: 16.0),
          _buildContactCard(
            icon: Icons.email,
            title: S.of(context).contact_email_title,
            description: S.of(context).contact_email_description,
            onTap: () => _showEmailDialog(context, '508942455@qq.com'),
          ),
          const SizedBox(height: 16.0),
          _buildContactCard(
            icon: Icons.chat,
            title: S.of(context).contact_chat_title,
            description: S.of(context).contact_chat_description,
            onTap: () {
              showDialog(
                context: context,
                builder: (_) => AlertDialog(
                  title: const Text('扫码添加微信'),
                  content: Image.asset(
                    'lib/assets/images/Wechat.png',
                    fit: BoxFit.contain,
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('关闭'),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  // 常见问题条目
  Widget _buildFAQItem(String question, String answer) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8.0),
      child: ListTile(
        title: Text(question, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: Text(answer),
        ),
      ),
    );
  }

  // 联系客服的卡片
  Widget _buildContactCard({
    required IconData icon,
    required String title,
    required String description,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12.0),
      child: Card(
        elevation: 5.0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Icon(icon, size: 40.0, color: Colors.blueAccent),
              const SizedBox(width: 16.0),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8.0),
                    Text(description, style: const TextStyle(fontSize: 14.0, color: Colors.grey)),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }
}