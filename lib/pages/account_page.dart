import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';
import '../generated/l10n.dart';
import '../services/auth_service.dart';
import '../theme/serene_design_system.dart';

class AccountPage extends StatefulWidget {
  const AccountPage({super.key});

  @override
  State<AccountPage> createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  File? _avatarImage; // 头像
  String _username = 'User123'; // 默认用户名
  String _email = 'user@example.com'; // 默认邮箱

  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _loadUserData(); // 读取存储的用户数据
  }

  // **加载用户数据**
  Future<void> _loadUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    // 加载头像
    String? avatarPath = prefs.getString('avatar');
    if (avatarPath != null && avatarPath.isNotEmpty) {
      setState(() {
        _avatarImage = File(avatarPath);
      });
    }

    // 加载用户名和邮箱
    setState(() {
      _username =
          prefs.getString('username') ?? 'User123'; // 从 SharedPreferences 加载用户名
      _email = prefs.getString('email') ??
          'user@example.com'; // 从 SharedPreferences 加载邮箱
    });
  }

  // **选择头像并存储**
  Future<void> _getImage() async {
    // 从图库中选择图片
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        // 将选择的图片路径转为 File
        _avatarImage = File(pickedFile.path);
      });

      // 存储头像路径
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('avatar', pickedFile.path);
    }
  }

  // 更改用户名
  void _changeUsername() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        TextEditingController usernameController =
            TextEditingController(text: _username);

        return AlertDialog(
          backgroundColor:
              SereneColors.surfaceContainerLowest.withValues(alpha: 0.92),
          surfaceTintColor: Colors.transparent,
          shape:
              RoundedRectangleBorder(borderRadius: SereneSpacing.dialogRadius),
          title: Text(
            S.of(context).change_username,
            style: SereneTypography.headlineSmall.copyWith(
              color: SereneColors.onSurface,
            ),
          ),
          content: _buildDialogTextField(
            controller: usernameController,
            hintText: S.of(context).enter_new_username,
            icon: Icons.person_outline,
          ),
          actionsPadding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                S.of(context).cancel,
                style: SereneTypography.button.copyWith(
                  color: SereneColors.onSurfaceVariant,
                ),
              ),
            ),
            TextButton(
              onPressed: () async {
                String newUsername = usernameController.text.trim();
                if (newUsername.isEmpty) return;

                // 调用后端 API 修改用户名
                bool success = await AuthService().updateUsername(newUsername);
                if (!mounted || !context.mounted) return;

                if (success) {
                  setState(() {
                    _username = newUsername;
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content:
                            Text(S.of(context).username_updated_successfully)),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content: Text(S.of(context).failed_update_username)),
                  );
                }

                Navigator.of(context).pop();
              },
              child: Text(
                S.of(context).save,
                style: SereneTypography.button.copyWith(
                  color: SereneColors.primary,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  // **修改密码**
  void _changePassword() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        TextEditingController oldPasswordController = TextEditingController();
        TextEditingController newPasswordController = TextEditingController();

        return AlertDialog(
          backgroundColor:
              SereneColors.surfaceContainerLowest.withValues(alpha: 0.92),
          surfaceTintColor: Colors.transparent,
          shape:
              RoundedRectangleBorder(borderRadius: SereneSpacing.dialogRadius),
          title: Text(
            S.of(context).change_password,
            style: SereneTypography.headlineSmall.copyWith(
              color: SereneColors.onSurface,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDialogTextField(
                controller: oldPasswordController,
                hintText: S.of(context).enter_old_password,
                icon: Icons.lock_outline,
                obscureText: true,
              ),
              const SizedBox(height: SereneSpacing.md),
              _buildDialogTextField(
                controller: newPasswordController,
                hintText: S.of(context).enter_new_password,
                icon: Icons.lock_reset,
                obscureText: true,
              ),
            ],
          ),
          actionsPadding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                S.of(context).cancel,
                style: SereneTypography.button.copyWith(
                  color: SereneColors.onSurfaceVariant,
                ),
              ),
            ),
            TextButton(
              onPressed: () async {
                String oldPassword = oldPasswordController.text.trim();
                String newPassword = newPasswordController.text.trim();

                if (oldPassword.isEmpty || newPassword.isEmpty) return;

                bool success = await AuthService()
                    .changePassword(oldPassword, newPassword);
                if (!mounted || !context.mounted) return;

                if (success) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content:
                            Text(S.of(context).password_changed_successfully)),
                  );
                  AuthService().logout(context); // 修改密码成功后自动退出登录
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content: Text(S.of(context).failed_update_password)),
                  );
                }

                Navigator.of(context).pop();
              },
              child: Text(
                S.of(context).save,
                style: SereneTypography.button.copyWith(
                  color: SereneColors.primary,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      backgroundColor: SereneColors.surface,
      appBar: GlassAppBar(
        title: Text(
          S.of(context).account_management,
          style: SereneTypography.headlineSmall.copyWith(
            color: SereneColors.primary,
          ),
        ),
        leading: const SizedBox.shrink(),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: SereneSpacing.sm),
            child: SereneIconButton(
              icon: Icons.edit_outlined,
              iconColor: SereneColors.primary,
              size: 40,
              tooltip: S.of(context).change_username,
              onPressed: _changeUsername,
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
            // 装饰性背景元素 - 还原 stitch 的模糊圆形
            Positioned(
              top: 0,
              right: 0,
              child: Container(
                width: 256,
                height: 256,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: SereneColors.primaryContainer.withValues(alpha: 0.3),
                ),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 60, sigmaY: 60),
                  child: Container(),
                ),
              ),
            ),
            Positioned(
              bottom: 0,
              left: 0,
              child: Container(
                width: 288,
                height: 288,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: SereneColors.secondaryContainer.withValues(alpha: 0.2),
                ),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 60, sigmaY: 60),
                  child: Container(),
                ),
              ),
            ),
            // 主内容
            SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(
                SereneSpacing.marginMobile,
                SereneSpacing.lg,
                SereneSpacing.marginMobile,
                SereneSpacing.xl,
              ),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 640),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildProfileHeader(),
                      const SizedBox(height: SereneSpacing.lg),
                      _buildInfoCards(),
                      const SizedBox(height: SereneSpacing.lg),
                      _buildAccountSection(),
                      const SizedBox(height: SereneSpacing.lg),
                      _buildActionButtons(),
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

  Widget _buildProfileHeader() {
    final ImageProvider avatarProvider = _avatarImage != null
        ? FileImage(_avatarImage!)
        : const AssetImage('lib/assets/images/v.png') as ImageProvider;

    return GlassCard(
      padding: const EdgeInsets.all(SereneSpacing.cardPadding),
      child: Column(
        children: [
          GestureDetector(
            onTap: _getImage,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: SereneColors.surfaceContainer,
                    border: Border.all(color: Colors.white, width: 4),
                    boxShadow: [
                      BoxShadow(
                        color: SereneColors.primary.withValues(alpha: 0.14),
                        blurRadius: 24,
                        offset: const Offset(0, 10),
                      ),
                    ],
                    image: DecorationImage(
                      image: avatarProvider,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                Positioned(
                  right: 2,
                  bottom: 2,
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: SereneColors.primary,
                    ),
                    child: const Icon(
                      Icons.photo_camera_outlined,
                      color: SereneColors.onPrimary,
                      size: 18,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: SereneSpacing.md),
          Text(
            _username,
            style: SereneTypography.headlineLargeMobile.copyWith(
              color: SereneColors.onSurface,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: SereneSpacing.xs),
          Text(
            _email,
            style: SereneTypography.bodyMedium.copyWith(
              color: SereneColors.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  /// 构建信息卡片网格 - 还原 stitch 的 3 列信息卡片
  Widget _buildInfoCards() {
    return Row(
      children: [
        Expanded(
          child: _buildInfoCard(
            icon: Icons.calendar_month,
            label: 'Member Since',
            value: 'Jan 2024',
          ),
        ),
        const SizedBox(width: SereneSpacing.md),
        Expanded(
          child: _buildInfoCard(
            icon: Icons.login,
            label: 'Last Login',
            value: 'Today',
          ),
        ),
        const SizedBox(width: SereneSpacing.md),
        Expanded(
          child: _buildInfoCard(
            icon: Icons.devices,
            label: 'Devices',
            value: '2 Active',
          ),
        ),
      ],
    );
  }

  /// 构建单个信息卡片
  Widget _buildInfoCard({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return GlassCard(
      padding: const EdgeInsets.all(SereneSpacing.cardPadding),
      child: Column(
        children: [
          Icon(
            icon,
            color: SereneColors.primary,
            size: 24,
          ),
          const SizedBox(height: SereneSpacing.xs),
          Text(
            label,
            style: SereneTypography.labelMedium.copyWith(
              color: SereneColors.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: SereneSpacing.xs),
          Text(
            value,
            style: SereneTypography.bodyLarge.copyWith(
              color: SereneColors.onSurface,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Divider(
      height: 1,
      thickness: 1,
      indent: SereneSpacing.cardPadding,
      endIndent: SereneSpacing.cardPadding,
      color: SereneColors.outlineVariant.withValues(alpha: 0.22),
    );
  }

  /// 构建账户信息区域
  Widget _buildAccountSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: SereneSpacing.xs),
          child: Text(
            S.of(context).account_management,
            style: SereneTypography.headlineSmall.copyWith(
              color: SereneColors.onSurface,
            ),
          ),
        ),
        const SizedBox(height: SereneSpacing.sm),
        GlassCard(
          padding: EdgeInsets.zero,
          child: Column(
            children: [
              _buildAccountItem(
                title: S.of(context).username,
                subtitle: _username,
                icon: Icons.person_outline,
                iconColor: SereneColors.primary,
                onTap: _changeUsername,
              ),
              _buildDivider(),
              _buildAccountItem(
                title: S.of(context).email,
                subtitle: _email,
                icon: Icons.email_outlined,
                iconColor: SereneColors.tertiary,
              ),
              _buildDivider(),
              _buildAccountItem(
                title: S.of(context).change_password,
                subtitle: '********',
                icon: Icons.lock_reset,
                iconColor: SereneColors.secondary,
                onTap: _changePassword,
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// 构建操作按钮 - 还原 stitch 的 Change Password 和 Logout 按钮
  Widget _buildActionButtons() {
    return Column(
      children: [
        // Change Password 按钮 - 还原 primary-container 样式
        SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: _changePassword,
            style: ElevatedButton.styleFrom(
              backgroundColor: SereneColors.primaryContainer,
              foregroundColor: SereneColors.onPrimaryContainer,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: SereneSpacing.buttonRadius,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.lock_reset, size: 20),
                const SizedBox(width: SereneSpacing.sm),
                Text(
                  S.of(context).change_password,
                  style: SereneTypography.labelLarge,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: SereneSpacing.md),
        // Logout 按钮 - 还原 error-container 样式
        SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: () => AuthService().logout(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: SereneColors.errorContainer,
              foregroundColor: SereneColors.onErrorContainer,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: SereneSpacing.buttonRadius,
                side: BorderSide(
                  color: SereneColors.error.withValues(alpha: 0.2),
                  width: 1,
                ),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.logout, size: 20),
                const SizedBox(width: SereneSpacing.sm),
                Text(
                  S.of(context).logout,
                  style: SereneTypography.labelLarge,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAccountItem({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color iconColor,
    VoidCallback? onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        splashColor: SereneColors.primaryContainer.withValues(alpha: 0.18),
        highlightColor: Colors.white.withValues(alpha: 0.25),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: SereneSpacing.cardPadding,
            vertical: SereneSpacing.md,
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: iconColor.withValues(alpha: 0.16),
                ),
                child: Icon(icon, color: iconColor, size: 22),
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
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              if (onTap != null)
                const Icon(
                  Icons.chevron_right,
                  color: SereneColors.outline,
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDialogTextField({
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
    bool obscureText = false,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      style: SereneTypography.bodyMedium.copyWith(
        color: SereneColors.onSurface,
      ),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: SereneTypography.bodyMedium.copyWith(
          color: SereneColors.outline,
        ),
        prefixIcon: Icon(icon, color: SereneColors.primary),
        filled: true,
        fillColor: SereneColors.primary.withValues(alpha: 0.05),
        contentPadding: SereneSpacing.inputPadding,
        enabledBorder: OutlineInputBorder(
          borderRadius: SereneSpacing.inputRadius,
          borderSide: BorderSide(
            color: SereneColors.outlineVariant.withValues(alpha: 0.5),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: SereneSpacing.inputRadius,
          borderSide: const BorderSide(color: SereneColors.primary),
        ),
      ),
    );
  }
}
