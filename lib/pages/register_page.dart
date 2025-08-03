import 'package:flutter/material.dart';
import '../generated/l10n.dart';
import '../utils/constants.dart';
import '../services/auth_service.dart';

class RegisterPage extends StatefulWidget {
  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController usernameController = TextEditingController();  // 新增用户名控制器
  final AuthService authService = AuthService();

  bool isLoading = false;
  String? errorMessage;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // 背景
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.silverGrey, AppColors.lightSilver],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          // 内容部分
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // 标题
                  Text(
                  S.of(context).create_account,
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryText, // 主文本颜色
                    ),
                  ),
                  const SizedBox(height: 20),
                  // 错误提示
                  if (errorMessage != null)
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        errorMessage!,
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                  // 表单容器
                  _buildGlassMorphismContainer(
                    child: Column(
                      children: [
                        // 用户名输入框
                        _buildTextField(
                          controller: usernameController,
                          hintText: S.of(context).username_hint,
                          obscureText: false,
                        ),
                        const SizedBox(height: 12),
                        // 邮箱输入框
                        _buildTextField(
                          controller: emailController,
                          hintText: S.of(context).email,
                          obscureText: false,
                        ),
                        const SizedBox(height: 12),
                        // 密码输入框
                        _buildTextField(
                          controller: passwordController,
                          hintText: S.of(context).password,
                          obscureText: true,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  // 注册按钮
                  _buildActionButton(
                    text: isLoading ? S.of(context).registering : S.of(context).register,
                    onPressed: isLoading ? null : _handleRegister,
                  ),
                  const SizedBox(height: 20),
                  // 返回登录
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(
                      S.of(context).already_have_account,
                      style: TextStyle(color: AppColors.primaryText),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 处理注册逻辑
  Future<void> _handleRegister() async {
    setState(() => isLoading = true);
    String email = emailController.text.trim();
    String password = passwordController.text.trim();
    String username = usernameController.text.trim().isEmpty ? 'User123' : usernameController.text.trim();  // 默认为 User123

    if (email.isEmpty || password.isEmpty) {
      setState(() {
        errorMessage = S.of(context).error_empty_fields;
        isLoading = false;
      });
      return;
    }

    bool success = await authService.register(email, password, username);
    if (success) {
      Navigator.pushNamed(context, '/home');
    } else {
      setState(() {
        errorMessage = S.of(context).error_registration_failed;
        isLoading = false;
      });
    }

    setState(() => isLoading = false);
  }

  /// 玻璃拟态容器
  Widget _buildGlassMorphismContainer({required Widget child}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2), // 半透明背景
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withOpacity(0.4), // 半透明边框
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1), // 柔和阴影
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: child,
    );
  }

  /// 通用输入框
  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    required bool obscureText,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(color: AppColors.secondaryText), // 提示文字颜色
        filled: true,
        fillColor: Colors.white.withOpacity(0.5), // 输入框背景色
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  /// 通用按钮
  Widget _buildActionButton({
    required String text,
    required VoidCallback? onPressed,
  }) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white.withOpacity(0.7), // 按钮背景色
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
        shadowColor: Colors.black.withOpacity(0.2), // 按钮阴影
        elevation: 5,
      ),
      onPressed: onPressed,
      child: Text(
        text,
        style: TextStyle(
          color: AppColors.primaryText, // 按钮文字颜色
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}