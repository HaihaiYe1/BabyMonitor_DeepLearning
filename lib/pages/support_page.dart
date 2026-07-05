import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import '../generated/l10n.dart';
import '../theme/serene_colors.dart';
import '../theme/serene_spacing.dart';
import '../theme/serene_typography.dart';
import '../widgets/glass_widgets.dart';
import '../widgets/serene_widgets.dart';

class SupportPage extends StatefulWidget {
  @override
  _SupportPageState createState() => _SupportPageState();
}

class _SupportPageState extends State<SupportPage> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _messageController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _messageController.dispose();
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

  // 打开邮箱
  Future<void> _launchEmail(String email) async {
    final Uri uri = Uri(scheme: 'mailto', path: email);
    try {
      await launchUrl(uri);
    } catch (e) {
      print('打开邮箱失败: $e');
    }
  }

  // 复制到剪贴板
  void _copyToClipboard(String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('已复制到剪贴板'),
        backgroundColor: SereneColors.primary,
      ),
    );
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
          'Serene Guardian',
          style: SereneTypography.headlineMedium.copyWith(
            color: SereneColors.primary,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: SereneSpacing.sm),
            child: SereneIconButton(
              icon: Icons.settings_outlined,
              iconColor: SereneColors.primary,
              size: 40,
              tooltip: 'Settings',
              onPressed: () {
                // TODO: 打开设置页面
              },
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
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 900),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 标题区域
                      _buildHeader(),
                      const SizedBox(height: SereneSpacing.lg),
                      // 两列网格布局
                      _buildContentGrid(),
                    ],
                  ),
                ),
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
          'Help & Support',
          style: SereneTypography.headlineLarge.copyWith(
            color: SereneColors.primary,
          ),
        ),
        const SizedBox(height: SereneSpacing.xs),
        Text(
          "We're here to help you and your baby rest easy.",
          style: SereneTypography.bodyLarge.copyWith(
            color: SereneColors.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  /// 构建内容网格
  Widget _buildContentGrid() {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth > 600) {
          // 桌面端：两列布局
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: _buildContactCard()),
              const SizedBox(width: SereneSpacing.lg),
              Expanded(child: _buildFeedbackForm()),
            ],
          );
        } else {
          // 移动端：单列布局
          return Column(
            children: [
              _buildContactCard(),
              const SizedBox(height: SereneSpacing.lg),
              _buildFeedbackForm(),
            ],
          );
        }
      },
    );
  }

  /// 构建联系卡片
  Widget _buildContactCard() {
    return GlassCard(
      padding: const EdgeInsets.all(SereneSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Contact Us',
            style: SereneTypography.headlineSmall.copyWith(
              color: SereneColors.primary,
            ),
          ),
          const SizedBox(height: SereneSpacing.sm),
          Text(
            'Reach out to our support team directly.',
            style: SereneTypography.bodyMedium.copyWith(
              color: SereneColors.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: SereneSpacing.lg),
          // Email Support
          _buildContactItem(
            icon: Icons.mail_outline,
            title: 'Email Support',
            subtitle: 'support@babyapp.com',
            onTap: () => _launchEmail('support@babyapp.com'),
            onCopy: () => _copyToClipboard('support@babyapp.com'),
          ),
          const SizedBox(height: SereneSpacing.md),
          // Phone Support
          _buildContactItem(
            icon: Icons.phone_in_talk_outlined,
            title: 'Phone Support',
            subtitle: '+1 800-BABY',
            onTap: () => _launchPhone('18002229'),
            onCopy: () => _copyToClipboard('+1 800-BABY'),
          ),
          const SizedBox(height: SereneSpacing.lg),
          // Browse FAQ 链接
          GestureDetector(
            onTap: () {
              // TODO: 导航到FAQ页面
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Browse FAQ',
                  style: SereneTypography.labelLarge.copyWith(
                    color: SereneColors.primary,
                  ),
                ),
                Icon(
                  Icons.arrow_forward,
                  size: 20,
                  color: SereneColors.primary,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 构建联系项目
  Widget _buildContactItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    required VoidCallback onCopy,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(SereneSpacing.md),
        decoration: BoxDecoration(
          color: SereneColors.surfaceContainerLow,
          borderRadius: BorderRadius.circular(SereneSpacing.radiusMd),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: SereneColors.primaryContainer,
              ),
              child: Icon(
                icon,
                size: 24,
                color: SereneColors.onPrimaryContainer,
              ),
            ),
            const SizedBox(width: SereneSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: SereneTypography.labelLarge.copyWith(
                      color: SereneColors.onSurface,
                    ),
                  ),
                  const SizedBox(height: SereneSpacing.xs),
                  Text(
                    subtitle,
                    style: SereneTypography.bodySmall.copyWith(
                      color: SereneColors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            GestureDetector(
              onTap: onCopy,
              child: Icon(
                Icons.content_copy_outlined,
                size: 20,
                color: SereneColors.outline,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 构建反馈表单
  Widget _buildFeedbackForm() {
    return GlassCard(
      padding: const EdgeInsets.all(SereneSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Send Feedback',
            style: SereneTypography.headlineSmall.copyWith(
              color: SereneColors.primary,
            ),
          ),
          const SizedBox(height: SereneSpacing.sm),
          Text(
            'Have a suggestion or need help? Send us a message.',
            style: SereneTypography.bodyMedium.copyWith(
              color: SereneColors.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: SereneSpacing.lg),
          // Name 输入框
          _buildInputField(
            controller: _nameController,
            label: 'Name',
            hintText: 'Your Name',
            icon: Icons.person_outline,
          ),
          const SizedBox(height: SereneSpacing.md),
          // Email 输入框
          _buildInputField(
            controller: _emailController,
            label: 'Email',
            hintText: 'your.email@example.com',
            icon: Icons.email_outlined,
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: SereneSpacing.md),
          // Message 输入框
          _buildInputField(
            controller: _messageController,
            label: 'Message',
            hintText: 'How can we help?',
            icon: Icons.message_outlined,
            maxLines: 4,
          ),
          const SizedBox(height: SereneSpacing.lg),
          // Send Message 按钮
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: () {
                // TODO: 发送反馈
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('感谢您的反馈！'),
                    backgroundColor: SereneColors.primary,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: SereneColors.primary,
                foregroundColor: SereneColors.onPrimary,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: SereneSpacing.buttonRadius,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Send Message',
                    style: SereneTypography.labelLarge.copyWith(
                      color: SereneColors.onPrimary,
                    ),
                  ),
                  const SizedBox(width: SereneSpacing.sm),
                  const Icon(Icons.send, size: 18),
                ],
              ),
            ),
          ),
        ],
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
    int maxLines = 1,
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
          child: TextField(
            controller: controller,
            keyboardType: keyboardType,
            maxLines: maxLines,
            style: SereneTypography.bodyMedium.copyWith(
              color: SereneColors.onSurface,
            ),
            decoration: InputDecoration(
              hintText: hintText,
              hintStyle: SereneTypography.bodyMedium.copyWith(
                color: SereneColors.outlineVariant,
              ),
              prefixIcon: maxLines == 1
                  ? Icon(icon, color: SereneColors.outline, size: 20)
                  : null,
              border: InputBorder.none,
              focusedBorder: InputBorder.none,
              contentPadding: const EdgeInsets.all(SereneSpacing.md),
            ),
          ),
        ),
      ],
    );
  }
}