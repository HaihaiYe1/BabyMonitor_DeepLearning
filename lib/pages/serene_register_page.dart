import 'dart:ui';
import 'package:flutter/material.dart';
import '../generated/l10n.dart';
import '../services/auth_service.dart';
import '../theme/serene_colors.dart';
import '../theme/serene_spacing.dart';
import '../theme/serene_typography.dart';
import '../widgets/glass_widgets.dart';

/// Serene Guardian 风格注册页面
/// 完全还原 stitch 项目的 register_page 设计
class SereneRegisterPage extends StatefulWidget {
  @override
  _SereneRegisterPageState createState() => _SereneRegisterPageState();
}

class _SereneRegisterPageState extends State<SereneRegisterPage> {
  bool isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();
  final AuthService authService = AuthService();
  String? errorMessage;

  Future<void> _handleRegister() async {
    setState(() => isLoading = true);
    String username = usernameController.text.trim();
    String email = emailController.text.trim();
    String password = passwordController.text.trim();
    String confirmPassword = confirmPasswordController.text.trim();

    if (username.isEmpty || email.isEmpty || password.isEmpty || confirmPassword.isEmpty) {
      setState(() {
        errorMessage = S.of(context).error_empty_fields;
        isLoading = false;
      });
      return;
    }

    if (password != confirmPassword) {
      setState(() {
        errorMessage = 'Passwords do not match';
        isLoading = false;
      });
      return;
    }

    bool success = await authService.register(username, email, password);

    if (success) {
      Navigator.pushReplacementNamed(context, '/login');
    } else {
      setState(() {
        errorMessage = 'Registration failed. Please try again.';
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // 背景色 - 还原 stitch 的 bg-background
          Container(
            color: SereneColors.surface,
          ),
          // 装饰性背景元素 - 添加浮动动画效果
          Positioned(
            top: -MediaQuery.of(context).size.height * 0.1,
            left: -MediaQuery.of(context).size.width * 0.1,
            child: Container(
              width: MediaQuery.of(context).size.width * 0.5,
              height: MediaQuery.of(context).size.width * 0.5,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: SereneColors.primaryContainer.withValues(alpha: 0.4),
              ),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 80, sigmaY: 80),
                child: Container(),
              ),
            ),
          ),
          Positioned(
            bottom: -MediaQuery.of(context).size.height * 0.2,
            right: -MediaQuery.of(context).size.width * 0.1,
            child: Container(
              width: MediaQuery.of(context).size.width * 0.6,
              height: MediaQuery.of(context).size.width * 0.6,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: SereneColors.secondaryContainer.withValues(alpha: 0.3),
              ),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 100, sigmaY: 100),
                child: Container(),
              ),
            ),
          ),
          // 注册卡片
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(SereneSpacing.marginMobile),
              child: _buildRegisterCard(),
            ),
          ),
          // 加载遮罩
          if (isLoading) _buildLoadingOverlay(),
        ],
      ),
    );
  }

  Widget _buildRegisterCard() {
    return GlassCard(
      padding: const EdgeInsets.all(SereneSpacing.cardPadding),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 头部
          _buildHeader(),
          const SizedBox(height: SereneSpacing.lg),
          // 表单
          _buildForm(),
          const SizedBox(height: SereneSpacing.lg),
          // 底部
          _buildFooter(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        // Logo - 还原 stitch 的圆形 Logo
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: SereneColors.primaryContainer.withValues(alpha: 0.3),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(32),
            child: Image.asset(
              'lib/assets/icons/app_icon.png',
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  color: SereneColors.primaryContainer,
                  child: const Icon(
                    Icons.child_care,
                    size: 32,
                    color: SereneColors.primary,
                  ),
                );
              },
            ),
          ),
        ),
        const SizedBox(height: SereneSpacing.md),
        // 标题 - 还原 stitch 的响应式标题
        Text(
          'Create Account',
          style: SereneTypography.headlineLarge.copyWith(
            color: SereneColors.onSurface,
          ),
        ),
        const SizedBox(height: SereneSpacing.xs),
        // 副标题
        Text(
          'Join the nursery',
          style: SereneTypography.bodyMedium.copyWith(
            color: SereneColors.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  Widget _buildForm() {
    return Column(
      children: [
        // 错误信息
        if (errorMessage != null && errorMessage!.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: SereneSpacing.md),
            child: Container(
              padding: const EdgeInsets.all(SereneSpacing.sm),
              decoration: BoxDecoration(
                color: SereneColors.errorContainer,
                borderRadius: SereneSpacing.borderRadiusMd,
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.error_outline,
                    color: SereneColors.error,
                    size: 20,
                  ),
                  const SizedBox(width: SereneSpacing.sm),
                  Expanded(
                    child: Text(
                      errorMessage!,
                      style: SereneTypography.bodySmall.copyWith(
                        color: SereneColors.onErrorContainer,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        // 用户名输入框
        _buildInputField(
          controller: usernameController,
          hintText: 'Username',
          icon: Icons.person_outline,
          keyboardType: TextInputType.name,
        ),
        const SizedBox(height: SereneSpacing.md),
        // 邮箱输入框
        _buildInputField(
          controller: emailController,
          hintText: 'Email address',
          icon: Icons.mail_outline,
          keyboardType: TextInputType.emailAddress,
        ),
        const SizedBox(height: SereneSpacing.md),
        // 密码输入框
        _buildPasswordField(
          controller: passwordController,
          hintText: 'Password',
          obscureText: _obscurePassword,
          onToggle: () {
            setState(() {
              _obscurePassword = !_obscurePassword;
            });
          },
        ),
        const SizedBox(height: SereneSpacing.md),
        // 确认密码输入框
        _buildPasswordField(
          controller: confirmPasswordController,
          hintText: 'Confirm Password',
          obscureText: _obscureConfirmPassword,
          onToggle: () {
            setState(() {
              _obscureConfirmPassword = !_obscureConfirmPassword;
            });
          },
        ),
        const SizedBox(height: SereneSpacing.lg),
        // 注册按钮
        _buildRegisterButton(),
      ],
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
    TextInputType? keyboardType,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: SereneSpacing.borderRadiusMd, // 12px 圆角
        color: SereneColors.primary.withValues(alpha: 0.05),
        border: Border.all(
          color: SereneColors.outlineVariant, // 使用 outline-variant
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
                  vertical: 14, // 还原 py-3
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String hintText,
    required bool obscureText,
    required VoidCallback onToggle,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: SereneSpacing.borderRadiusMd, // 12px 圆角
        color: SereneColors.primary.withValues(alpha: 0.05),
        border: Border.all(
          color: SereneColors.outlineVariant, // 使用 outline-variant
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Padding(
            padding: const EdgeInsets.only(left: SereneSpacing.md),
            child: Icon(
              Icons.lock_outline,
              color: SereneColors.outline,
              size: 20,
            ),
          ),
          Expanded(
            child: TextField(
              controller: controller,
              obscureText: obscureText,
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
                  vertical: 14, // 还原 py-3
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: SereneSpacing.md),
            child: GestureDetector(
              onTap: onToggle,
              child: Icon(
                obscureText
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
                color: SereneColors.outline,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRegisterButton() {
    return SizedBox(
      width: double.infinity,
      height: 56, // 还原 py-4
      child: ElevatedButton(
        onPressed: isLoading ? null : _handleRegister,
        style: ElevatedButton.styleFrom(
          backgroundColor: SereneColors.primaryContainer, // 还原 bg-primary-container
          foregroundColor: Colors.white, // 还原 text-[#ffffff]
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: SereneSpacing.buttonRadius,
          ),
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
        child: isLoading
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    Colors.white,
                  ),
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Register',
                    style: SereneTypography.labelLarge.copyWith(
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Icon(
                    Icons.arrow_forward,
                    size: 20,
                    color: Colors.white,
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildFooter() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Already have an account? ',
          style: SereneTypography.bodySmall.copyWith(
            color: SereneColors.onSurfaceVariant,
          ),
        ),
        GestureDetector(
          onTap: () {
            Navigator.pushReplacementNamed(context, '/login');
          },
          child: Text(
            'Login',
            style: SereneTypography.labelLarge.copyWith(
              color: SereneColors.primary,
              decoration: TextDecoration.underline,
              decorationColor: SereneColors.primary,
              decorationThickness: 2,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLoadingOverlay() {
    return Container(
      color: Colors.white.withValues(alpha: 0.6),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 3,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    SereneColors.primary,
                  ),
                ),
              ),
              const SizedBox(height: SereneSpacing.sm),
              Text(
                'Creating account...',
                style: SereneTypography.bodySmall.copyWith(
                  color: SereneColors.primary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
