import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../generated/l10n.dart';
import '../providers/device_provider.dart';
import '../models/device_model.dart';
import '../services/auth_service.dart';
import '../theme/serene_colors.dart';
import '../theme/serene_spacing.dart';
import '../theme/serene_typography.dart';
import '../widgets/glass_widgets.dart';
import '../widgets/serene_widgets.dart';
import 'device_binding_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DeviceManagementPage extends ConsumerStatefulWidget {
  @override
  _DeviceManagementPageState createState() => _DeviceManagementPageState();
}

class _DeviceManagementPageState extends ConsumerState<DeviceManagementPage> {
  @override
  void initState() {
    super.initState();
    AuthService().fetchDeviceData(context);
    _fetchDevices();
  }

  /// 从 SharedPreferences 获取 token 并向后端请求设备列表
  Future<void> _fetchDevices() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token != null) {
      ref.read(cameraProvider.notifier).fetchDevicesByToken(token);
    } else {
      debugPrint("用户未登录或Token不存在");
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
    final deviceList = ref.watch(cameraProvider);

    return Scaffold(
      extendBody: true,
      backgroundColor: SereneColors.surface,
      appBar: GlassAppBar(
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: SereneColors.primary.withValues(alpha: 0.2),
                width: 2,
              ),
            ),
            child: CircleAvatar(
              radius: 16,
              backgroundImage: AssetImage('lib/assets/images/v.png'),
              backgroundColor: Colors.transparent,
            ),
          ),
        ),
        title: Text(
          S.of(context).device_management,
          style: SereneTypography.headlineMedium.copyWith(
            color: SereneColors.primary,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: SereneSpacing.sm),
            child: SereneIconButton(
              icon: Icons.add,
              iconColor: SereneColors.primary,
              size: 40,
              tooltip: S.of(context).add_device,
              onPressed: () => _navigateToDeviceBindingPage(),
            ),
          ),
        ],
      ),
      body: SafeArea(
        bottom: false,
        child: Stack(
          children: [
            // 背景色
            Container(
              color: SereneColors.surface,
            ),
            // 设备列表
            deviceList.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.videocam_off_outlined,
                          size: 64,
                          color: SereneColors.onSurfaceVariant,
                        ),
                        const SizedBox(height: SereneSpacing.md),
                        Text(
                          S.of(context).loading_devices,
                          style: SereneTypography.bodyLarge.copyWith(
                            color: SereneColors.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  )
                : SingleChildScrollView(
                    padding: const EdgeInsets.all(SereneSpacing.marginMobile),
                    child: _buildDeviceGrid(deviceList),
                  ),
          ],
        ),
      ),
    );
  }

  /// 构建设备网格 - 还原 stitch 的网格布局
  Widget _buildDeviceGrid(List<Device> deviceList) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: _getCrossAxisCount(context),
        crossAxisSpacing: SereneSpacing.md,
        mainAxisSpacing: SereneSpacing.md,
        childAspectRatio: 0.85,
      ),
      itemCount: deviceList.length + 1, // +1 for add device card
      itemBuilder: (context, index) {
        if (index < deviceList.length) {
          return _buildDeviceCard(deviceList[index]);
        } else {
          return _buildAddDeviceCard();
        }
      },
    );
  }

  /// 获取网格列数
  int _getCrossAxisCount(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width > 1200) return 3;
    if (width > 600) return 2;
    return 1;
  }

  /// 构建设备卡片 - 还原 stitch 的毛玻璃卡片样式
  Widget _buildDeviceCard(Device device) {
    final isOnline = device.status.toLowerCase() == 'online';

    return GlassCard(
      padding: const EdgeInsets.all(SereneSpacing.cardPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 状态徽章和操作按钮
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // 状态徽章
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.8),
                  borderRadius: SereneSpacing.chipRadius,
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.4),
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isOnline
                            ? SereneColors.safe
                            : SereneColors.outline,
                      ),
                    ),
                    const SizedBox(width: SereneSpacing.xs),
                    Text(
                      isOnline ? 'Online' : 'Offline',
                      style: SereneTypography.labelMedium.copyWith(
                        color: SereneColors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              // 操作按钮
              Row(
                children: [
                  _buildActionButton(
                    icon: Icons.edit_outlined,
                    onTap: () => _navigateToDeviceBindingPage(device: device),
                  ),
                  const SizedBox(width: SereneSpacing.xs),
                  _buildActionButton(
                    icon: Icons.delete_outline,
                    onTap: () {
                      // TODO: 实现删除功能
                    },
                    isError: true,
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: SereneSpacing.md),
          // 设备缩略图
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(SereneSpacing.radiusLg),
                color: SereneColors.surfaceContainerHigh,
              ),
              child: isOnline
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(SereneSpacing.radiusLg),
                      child: Image.asset(
                        'lib/assets/images/v.png',
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return _buildOfflinePlaceholder();
                        },
                      ),
                    )
                  : _buildOfflinePlaceholder(),
            ),
          ),
          const SizedBox(height: SereneSpacing.md),
          // 设备信息
          Text(
            device.name,
            style: SereneTypography.headlineSmall.copyWith(
              color: SereneColors.onSurface,
            ),
          ),
          const SizedBox(height: SereneSpacing.xs),
          Row(
            children: [
              Icon(
                Icons.router_outlined,
                size: 16,
                color: SereneColors.onSurfaceVariant,
              ),
              const SizedBox(width: SereneSpacing.xs),
              Text(
                'IP: ${device.ip}',
                style: SereneTypography.bodySmall.copyWith(
                  color: SereneColors.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// 构建操作按钮
  Widget _buildActionButton({
    required IconData icon,
    required VoidCallback onTap,
    bool isError = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white.withValues(alpha: 0.6),
        ),
        child: Icon(
          icon,
          size: 18,
          color: isError ? SereneColors.error : SereneColors.onSurfaceVariant,
        ),
      ),
    );
  }

  /// 构建离线占位符
  Widget _buildOfflinePlaceholder() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.videocam_off_outlined,
          size: 48,
          color: SereneColors.outline,
        ),
        const SizedBox(height: SereneSpacing.sm),
        Text(
          'Camera Offline',
          style: SereneTypography.labelMedium.copyWith(
            color: SereneColors.outline,
          ),
        ),
      ],
    );
  }

  /// 构建添加设备卡片 - 还原 stitch 的虚线边框卡片
  Widget _buildAddDeviceCard() {
    return GestureDetector(
      onTap: () => _navigateToDeviceBindingPage(),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(SereneSpacing.radiusXl),
          border: Border.all(
            color: SereneColors.primary.withValues(alpha: 0.3),
            width: 2,
            style: BorderStyle.solid,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: SereneColors.primaryContainer,
              ),
              child: const Icon(
                Icons.add,
                size: 32,
                color: SereneColors.onPrimaryContainer,
              ),
            ),
            const SizedBox(height: SereneSpacing.md),
            Text(
              S.of(context).add_device,
              style: SereneTypography.headlineSmall.copyWith(
                color: SereneColors.primary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: SereneSpacing.sm),
            Text(
              'Connect another camera to your network',
              style: SereneTypography.bodySmall.copyWith(
                color: SereneColors.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}