import 'package:flutter/material.dart';

// 可自定义的 CardWidgets 组件
class CardWidgets extends StatelessWidget {
  final List<dynamic> cardItems; // 支持多种类型的数据（TabItem 或 DeviceCardItem）

  // 构造函数，接收多个 TabItem 或 DeviceCardItem 配置
  CardWidgets({required this.cardItems});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(), // 禁用内部滚动
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2, // 两列
          crossAxisSpacing: 16.0,
          mainAxisSpacing: 16.0,
        ),
        itemCount: cardItems.length,
        itemBuilder: (context, index) {
          final cardItem = cardItems[index];

          // 判断传入的是什么类型的数据
          if (cardItem is TabItem) {
            return _buildTabItem(context, cardItem);
          } else if (cardItem is DeviceCardItem) {
            return _buildDeviceCard(context, cardItem);
          } else {
            return SizedBox(); // 如果传入了未知类型，返回空
          }
        },
      ),
    );
  }

  // Tab 按钮构建函数
  Widget _buildTabItem(BuildContext context, TabItem tabItem) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => tabItem.targetPage),
        );
      },
      borderRadius: BorderRadius.circular(12.0),
      child: Container(
        margin: const EdgeInsets.all(8.0),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.2),
          borderRadius: BorderRadius.circular(12.0),
          border: Border.all(color: Colors.white.withOpacity(0.3), width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              tabItem.previewImage, // 使用传入的预览图
              height: 60.0,
              width: 60.0,
            ),
            const SizedBox(height: 8.0),
            Text(
              tabItem.label,
              style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold, color: tabItem.color),
            ),
          ],
        ),
      ),
    );
  }

  // 设备卡片构建函数
  Widget _buildDeviceCard(BuildContext context, DeviceCardItem deviceCardItem) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => deviceCardItem.targetPage),
        );
      },
      borderRadius: BorderRadius.circular(12.0),
      child: Container(
        margin: const EdgeInsets.all(8.0),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.2),
          borderRadius: BorderRadius.circular(12.0),
          border: Border.all(color: Colors.white.withOpacity(0.3), width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              deviceCardItem.deviceName,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8.0),
            Text(
              'IP: ${deviceCardItem.deviceIP}',
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 8.0),
            Text(
              '状态: ${deviceCardItem.deviceStatus}',
              style: TextStyle(fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}

// TabItem 模型，包含每个 Tab 的数据
class TabItem {
  final String previewImage; // 预览图路径
  final String label; // 标签文字
  final Color color; // 标签颜色
  final Widget targetPage; // 点击后跳转的目标页面

  TabItem({
    required this.previewImage,
    required this.label,
    required this.color,
    required this.targetPage,
  });
}

// 设备卡片模型
class DeviceCardItem {
  final String deviceName; // 设备名称
  final String deviceIP; // 设备 IP
  final String deviceStatus; // 设备状态
  final Widget targetPage; // 点击后跳转的目标页面

  DeviceCardItem({
    required this.deviceName,
    required this.deviceIP,
    required this.deviceStatus,
    required this.targetPage,
  });
}