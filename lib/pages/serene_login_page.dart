import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../generated/l10n.dart';
import '../services/auth_service.dart';
import '../theme/serene_colors.dart';
import '../theme/serene_spacing.dart';
import '../theme/serene_typography.dart';
import '../widgets/glass_widgets.dart';
import 'home_page.dart';

/// Serene Guardian 风格登录页面
/// 完全还原 stitch 项目的 login_page 设计
class SereneLoginPage extends StatefulWidget {
  @override
  _SereneLoginPageState createState() => _SereneLoginPageState();
}

class _SereneLoginPageState extends State<SereneLoginPage> {
  bool isLoading = false;
  bool _obscurePassword = true;
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final AuthService authService = AuthService();
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    if (token != null && token.isNotEmpty) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomePage()),
      );
    }
  }

  Future<void> _handleLogin() async {
    setState(() => isLoading = true);
    String email = emailController.text.trim();
    String password = passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      setState(() {
        errorMessage = S.of(context).error_empty_fields;
        isLoading = false;
      });
      return;
    }

    bool success = await authService.login(email, password);

    if (success) {
      String? token = await authService.getToken();
      String? email = await authService.getEmail();
      String? username = await authService.getUsername();

      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', token ?? '');
      if (email != null) await prefs.setString('email', email);
      if (username != null) await prefs.setString('username', username);

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomePage()),
      );
    } else {
      setState(() {
        errorMessage = S.of(context).error_invalid_credentials;
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // 背景渐变 - 还原 stitch 的 bg-gradient-soft
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFFF3F2FF), // surface-container-low
                  Color(0xFFE4E7FE), // surface-container-high
                  Color(0xFFFFD8BE), // secondary-container
                ],
                stops: [0.0, 0.5, 1.0],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          // 装饰性背景元素 - 还原 stitch 的模糊圆形
          Positioned(
            top: -MediaQuery.of(context).size.height * 0.1,
            left: -MediaQuery.of(context).size.width * 0.1,
            child: Container(
              width: MediaQuery.of(context).size.width * 0.4,
              height: MediaQuery.of(context).size.width * 0.4,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: SereneColors.primaryContainer.withValues(alpha: 0.3),
              ),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 100, sigmaY: 100),
                child: Container(),
              ),
            ),
          ),
          Positioned(
            bottom: -MediaQuery.of(context).size.height * 0.1,
            right: -MediaQuery.of(context).size.width * 0.1,
            child: Container(
              width: MediaQuery.of(context).size.width * 0.5,
              height: MediaQuery.of(context).size.width * 0.5,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: SereneColors.secondaryContainer.withValues(alpha: 0.3),
              ),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 120, sigmaY: 120),
                child: Container(),
              ),
            ),
          ),
          // 登录卡片
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(SereneSpacing.marginMobile),
              child: _buildLoginCard(),
            ),
          ),
          // 加载遮罩
          if (isLoading) _buildLoadingOverlay(),
        ],
      ),
    );
  }

  /// 构建登录卡片 - 还原 stitch 的 glass-card
  Widget _buildLoginCard() {
    return GlassCard(
      padding: const EdgeInsets.all(SereneSpacing.cardPadding),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 头部 - Logo 和标题
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

  /// 构建头部 - 还原 stitch 的 Header 区域
  Widget _buildHeader() {
    return Column(
      children: [
        // Logo - 还原 stitch 的 rounded-2xl (16px)
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            borderRadius: SereneSpacing.borderRadiusLg, // 16px 圆角
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          padding: const EdgeInsets.all(8),
          child: ClipRRect(
            borderRadius: SereneSpacing.borderRadiusLg, // 16px 圆角
            child: Image.asset(
              'lib/assets/icons/app_icon.png',
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  color: SereneColors.primaryContainer,
                  child: const Icon(
                    Icons.child_care,
                    size: 40,
                    color: SereneColors.primary,
                  ),
                );
              },
            ),
          ),
        ),
        const SizedBox(height: SereneSpacing.md),
        // 欢迎标题
        Text(
          S.of(context).welcome_back,
          style: SereneTypography.headlineMedium.copyWith(
            color: SereneColors.onSurface,
          ),
        ),
        const SizedBox(height: SereneSpacing.xs),
        // 副标题
        Text(
          'Login to your nursery',
          style: SereneTypography.bodyMedium.copyWith(
            color: SereneColors.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  /// 构建表单 - 还原 stitch 的 Form 区域
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
        // 邮箱输入框
        _buildEmailField(),
        const SizedBox(height: SereneSpacing.md),
        // 密码输入框
        _buildPasswordField(),
        const SizedBox(height: SereneSpacing.xs),
        // 忘记密码
        Align(
          alignment: Alignment.centerRight,
          child: TextButton(
            onPressed: () {
              // TODO: 实现忘记密码功能
            },
            child: Text(
              'Forgot Password?',
              style: SereneTypography.labelMedium.copyWith(
                color: SereneColors.primary,
              ),
            ),
          ),
        ),
        const SizedBox(height: SereneSpacing.sm),
        // 登录按钮
        _buildLoginButton(),
      ],
    );
  }

  /// 构建邮箱输入框 - 还原 stitch 的 input-field
  /// 包含 focus 时的阴影效果
  Widget _buildEmailField() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: SereneSpacing.inputRadius,
        color: SereneColors.primary.withValues(alpha: 0.05),
        border: Border.all(
          color: SereneColors.outline.withValues(alpha: 0.2),
          width: 1,
        ),
        // 添加 focus 时的阴影效果
        boxShadow: [
          BoxShadow(
            color: SereneColors.primaryContainer.withValues(alpha: 0.2),
            blurRadius: 0,
            spreadRadius: 0,
          ),
        ],
      ),
      child: Row(
        children: [
          Padding(
            padding: const EdgeInsets.only(left: SereneSpacing.md),
            child: Icon(
              Icons.mail_outline,
              color: SereneColors.outline,
              size: 20,
            ),
          ),
          Expanded(
            child: TextField(
              controller: emailController,
              keyboardType: TextInputType.emailAddress,
              style: SereneTypography.bodyMedium.copyWith(
                color: SereneColors.onSurface,
              ),
              decoration: InputDecoration(
                hintText: 'Email address',
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
    );
  }

  /// 构建密码输入框 - 还原 stitch 的 input-field
  /// 包含 focus 时的阴影效果
  Widget _buildPasswordField() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: SereneSpacing.inputRadius,
        color: SereneColors.primary.withValues(alpha: 0.05),
        border: Border.all(
          color: SereneColors.outline.withValues(alpha: 0.2),
          width: 1,
        ),
        // 添加 focus 时的阴影效果
        boxShadow: [
          BoxShadow(
            color: SereneColors.primaryContainer.withValues(alpha: 0.2),
            blurRadius: 0,
            spreadRadius: 0,
          ),
        ],
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
              controller: passwordController,
              obscureText: _obscurePassword,
              style: SereneTypography.bodyMedium.copyWith(
                color: SereneColors.onSurface,
              ),
              decoration: InputDecoration(
                hintText: 'Password',
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
          Padding(
            padding: const EdgeInsets.only(right: SereneSpacing.md),
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _obscurePassword = !_obscurePassword;
                });
              },
              child: Icon(
                _obscurePassword
                    ? Icons.visibility_outlined
                    : Icons.visibility_off_outlined,
                color: SereneColors.outline,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 构建登录按钮 - 还原 stitch 的按钮样式
  /// 包含 shadow-sm 和 active:scale-[0.98] 效果
  Widget _buildLoginButton() {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton(
        onPressed: isLoading ? null : _handleLogin,
        style: ElevatedButton.styleFrom(
          backgroundColor: SereneColors.primary,
          foregroundColor: SereneColors.onPrimary,
          elevation: 2, // 还原 shadow-sm
          shadowColor: SereneColors.primary.withValues(alpha: 0.3),
          shape: RoundedRectangleBorder(
            borderRadius: SereneSpacing.buttonRadius,
          ),
          padding: const EdgeInsets.symmetric(vertical: 12),
        ),
        child: isLoading
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    SereneColors.onPrimary,
                  ),
                ),
              )
            : Text(
                S.of(context).log_in,
                style: SereneTypography.labelLarge.copyWith(
                  color: SereneColors.onPrimary,
                ),
              ),
      ),
    );
  }

  /// 构建底部 - 还原 stitch 的 Footer 区域
  Widget _buildFooter() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          "Don't have an account? ",
          style: SereneTypography.bodySmall.copyWith(
            color: SereneColors.onSurfaceVariant,
          ),
        ),
        GestureDetector(
          onTap: () {
            Navigator.pushNamed(context, '/register');
          },
          child: Text(
            'Register',
            style: SereneTypography.labelLarge.copyWith(
              color: SereneColors.primary,
            ),
          ),
        ),
      ],
    );
  }

  /// 构建加载遮罩 - 还原 stitch 的 loadingOverlay
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
                'Authenticating...',
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
