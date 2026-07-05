import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../generated/l10n.dart';
import '../models/device_model.dart';
import '../providers/device_provider.dart';
import '../widgets/test_rtsp.dart';
import '../widgets/video_player.dart';
import '../theme/serene_colors.dart';
import '../theme/serene_spacing.dart';
import '../theme/serene_typography.dart';
import '../widgets/glass_widgets.dart';
import '../widgets/serene_widgets.dart';

class DeviceBindingPage extends ConsumerStatefulWidget {
  final Device? device;

  DeviceBindingPage({Key? key, this.device}) : super(key: key);

  @override
  _DeviceBindingPageState createState() => _DeviceBindingPageState();
}

class _DeviceBindingPageState extends ConsumerState<DeviceBindingPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _ipController = TextEditingController();
  final _rtspController = TextEditingController();
  final _emailController = TextEditingController();
  bool _showPlayer = false;
  bool _isTesting = false;

  @override
  void initState() {
    super.initState();
    if (widget.device != null) {
      _nameController.text = widget.device!.name;
      _ipController.text = widget.device!.ip;
      _rtspController.text = widget.device!.rtspUrl;
      _emailController.text = widget.device!.email;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _ipController.dispose();
    _rtspController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
              color: SereneColors.surfaceVariant.withValues(alpha: 0.5),
            ),
            child: const Icon(
              Icons.close,
              color: SereneColors.onSurfaceVariant,
            ),
          ),
        ),
        title: Text(
          widget.device == null ? 'Add Device' : 'Edit Device',
          style: SereneTypography.headlineSmall.copyWith(
            color: SereneColors.primary,
            fontWeight: FontWeight.w800,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: SereneSpacing.sm),
            child: GestureDetector(
              onTap: _saveDevice,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: SereneColors.primaryContainer.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(SereneSpacing.radiusXl),
                ),
                child: Text(
                  'Save',
                  style: SereneTypography.labelLarge.copyWith(
                    color: SereneColors.primary,
                  ),
                ),
              ),
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
            // 主内容
            SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(
                SereneSpacing.marginMobile,
                SereneSpacing.lg,
                SereneSpacing.marginMobile,
                SereneSpacing.xl,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 标题区域
                  _buildHeader(),
                  const SizedBox(height: SereneSpacing.lg),
                  // 表单区域
                  _buildFormSection(),
                  const SizedBox(height: SereneSpacing.lg),
                  // 视频预览区域
                  _buildVideoPreview(),
                  const SizedBox(height: SereneSpacing.lg),
                  // 底部按钮
                  _buildBottomButtons(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 构建标题区域
  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Connect New Monitor',
          style: SereneTypography.headlineMedium.copyWith(
            color: SereneColors.onSurface,
          ),
        ),
        const SizedBox(height: SereneSpacing.xs),
        Text(
          'Enter the details below to pair your Serene Guardian compatible device.',
          style: SereneTypography.bodyMedium.copyWith(
            color: SereneColors.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  /// 构建表单区域
  Widget _buildFormSection() {
    return GlassCard(
      padding: const EdgeInsets.all(SereneSpacing.cardPadding),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Device Name
            _buildInputField(
              controller: _nameController,
              label: 'Device Name',
              hintText: 'e.g., Nursery Cam',
              icon: Icons.devices_outlined,
            ),
            const SizedBox(height: SereneSpacing.md),
            // IP Address
            _buildInputField(
              controller: _ipController,
              label: 'IP Address',
              hintText: '192.168.1.x',
              icon: Icons.wifi_outlined,
            ),
            const SizedBox(height: SereneSpacing.md),
            // RTSP URL
            _buildInputField(
              controller: _rtspController,
              label: 'RTSP URL',
              hintText: 'rtsp://admin:password@ip/stream',
              icon: Icons.videocam_outlined,
              helperText: "Consult your camera's manual for the specific RTSP path.",
            ),
            const SizedBox(height: SereneSpacing.md),
            // Associated Email
            _buildInputField(
              controller: _emailController,
              label: 'Associated Email (Optional)',
              hintText: 'parent@example.com',
              icon: Icons.email_outlined,
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: SereneSpacing.lg),
            // Test Stream Button
            _buildTestButton(),
          ],
        ),
      ),
    );
  }

  /// 构建输入框
  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required String hintText,
    required IconData icon,
    TextInputType? keyboardType,
    String? helperText,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: SereneTypography.labelMedium.copyWith(
            color: SereneColors.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: SereneSpacing.xs),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(SereneSpacing.radiusDefault),
            color: SereneColors.primary.withValues(alpha: 0.05),
            border: Border.all(
              color: SereneColors.outline.withValues(alpha: 0.2),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Padding(
                padding: const EdgeInsets.only(left: SereneSpacing.md),
                child: Icon(
                  icon,
                  color: SereneColors.outline,
                  size: 20,
                ),
              ),
              Expanded(
                child: TextField(
                  controller: controller,
                  keyboardType: keyboardType,
                  style: SereneTypography.bodyMedium.copyWith(
                    color: SereneColors.onSurface,
                  ),
                  decoration: InputDecoration(
                    hintText: hintText,
                    hintStyle: SereneTypography.bodyMedium.copyWith(
                      color: SereneColors.outlineVariant,
                    ),
                    border: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: SereneSpacing.sm,
                      vertical: SereneSpacing.md,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        if (helperText != null) ...[
          const SizedBox(height: SereneSpacing.xs),
          Padding(
            padding: const EdgeInsets.only(left: SereneSpacing.xs),
            child: Text(
              helperText,
              style: SereneTypography.bodySmall.copyWith(
                color: SereneColors.onSurfaceVariant.withValues(alpha: 0.7),
              ),
            ),
          ),
        ],
      ],
    );
  }

  /// 构建测试按钮
  Widget _buildTestButton() {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton(
        onPressed: _isTesting ? null : _testConnection,
        style: ElevatedButton.styleFrom(
          backgroundColor: SereneColors.secondaryContainer,
          foregroundColor: SereneColors.onSecondaryContainer,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(SereneSpacing.radiusDefault),
          ),
        ),
        child: _isTesting
            ? SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: SereneColors.onSecondaryContainer,
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.play_circle_outlined, size: 20),
                  const SizedBox(width: SereneSpacing.sm),
                  Text(
                    'Test Stream Connection',
                    style: SereneTypography.labelLarge,
                  ),
                ],
              ),
      ),
    );
  }

  /// 构建视频预览区域
  Widget _buildVideoPreview() {
    return GlassCard(
      padding: EdgeInsets.zero,
      child: AspectRatio(
        aspectRatio: 16 / 9,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(SereneSpacing.radiusXl),
          child: _showPlayer
              ? VideoPlayerWidget(videoUrl: _rtspController.text)
              : Container(
                  color: SereneColors.surfaceContainerHigh.withValues(alpha: 0.3),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.videocam_off_outlined,
                        size: 48,
                        color: SereneColors.onSurfaceVariant.withValues(alpha: 0.3),
                      ),
                      const SizedBox(height: SereneSpacing.sm),
                      Text(
                        'Preview will appear here',
                        style: SereneTypography.bodyMedium.copyWith(
                          color: SereneColors.onSurfaceVariant.withValues(alpha: 0.6),
                        ),
                      ),
                    ],
                  ),
                ),
        ),
      ),
    );
  }

  /// 构建底部按钮
  Widget _buildBottomButtons() {
    return Row(
      children: [
        // 取消按钮
        Expanded(
          child: SizedBox(
            height: 56,
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white.withValues(alpha: 0.4),
                foregroundColor: SereneColors.primary,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(SereneSpacing.radiusLg),
                  side: BorderSide(
                    color: Colors.white,
                    width: 1,
                  ),
                ),
              ),
              child: Text(
                'Cancel',
                style: SereneTypography.labelLarge,
              ),
            ),
          ),
        ),
        const SizedBox(width: SereneSpacing.md),
        // 保存按钮
        Expanded(
          child: SizedBox(
            height: 56,
            child: ElevatedButton(
              onPressed: _saveDevice,
              style: ElevatedButton.styleFrom(
                backgroundColor: SereneColors.primaryContainer,
                foregroundColor: SereneColors.onPrimaryContainer,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(SereneSpacing.radiusLg),
                ),
              ),
              child: Text(
                'Save Device',
                style: SereneTypography.labelLarge,
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// 测试连接
  Future<void> _testConnection() async {
    if (_rtspController.text.isEmpty) return;

    setState(() => _isTesting = true);

    try {
      bool isConnected = await testRTSPConnection(_rtspController.text);
      setState(() => _showPlayer = isConnected);

      _showResultDialog(
        isConnected ? 'Connection Success' : 'Connection Failed',
        isConnected
            ? 'RTSP stream connected successfully.'
            : 'Failed to connect to RTSP stream. Please check the URL and try again.',
      );
    } catch (e) {
      _showResultDialog('Error', 'An error occurred: $e');
    } finally {
      setState(() => _isTesting = false);
    }
  }

  /// 保存设备
  void _saveDevice() {
    if (_formKey.currentState!.validate()) {
      final deviceNotifier = ref.read(cameraProvider.notifier);
      final device = Device(
        id: widget.device?.id ?? DateTime.now().toIso8601String(),
        name: _nameController.text,
        ip: _ipController.text,
        status: widget.device?.status ?? 'offline',
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
  }

  /// 显示结果对话框
  void _showResultDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: SereneColors.surfaceContainerLowest,
        shape: RoundedRectangleBorder(
          borderRadius: SereneSpacing.dialogRadius,
        ),
        title: Text(
          title,
          style: SereneTypography.headlineSmall.copyWith(
            color: SereneColors.onSurface,
          ),
        ),
        content: Text(
          message,
          style: SereneTypography.bodyMedium.copyWith(
            color: SereneColors.onSurfaceVariant,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Close',
              style: SereneTypography.labelLarge.copyWith(
                color: SereneColors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
