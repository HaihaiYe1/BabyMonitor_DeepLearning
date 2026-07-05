import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../generated/l10n.dart';
import '../utils/constants.dart';
import '../services/auth_service.dart';
import 'home_page.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool isLoading = false; // 是否正在加载
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final AuthService authService = AuthService();
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _initDebug();
  }

  Future<void> _initDebug() async {
    await debugSharedPreferences();
    await testSharedPreferences();
    await _checkLoginStatus();
  }

// 测试用
  Future<void> debugSharedPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    print("📌 Debug SharedPreferences: ${prefs.getKeys()}");
    print("📌 Token: ${prefs.getString('token')}");
    print("📌 Email: ${prefs.getString('email')}");
    print("📌 Username: ${prefs.getString('username')}");
  }

  Future<void> testSharedPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('test_key', 'TestValue');
    String? testValue = prefs.getString('test_key');
    print("🟢 Test SharedPreferences Value: $testValue");
  }
// 测试用


  Future<void> _checkLoginStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    print("Token from SharedPreferences: $token"); // 打印 token
    // 也调用 authService.getToken() 试试
    String? authToken = await authService.getToken();
    print("🔍 Token retrieved using authService.getToken(): $authToken");


    if (token != null && token.isNotEmpty) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomePage()),
      );
    }
  }

  // 处理登录
  Future<void> _handleLogin() async {
    setState(() => isLoading = true); // 显示加载状态
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
      // 获取并打印 token、email、username
      String? token = await authService.getToken();
      String? email = await authService.getEmail(); // 如果你有存邮箱
      String? username = await authService.getUsername(); // 如果你有存用户名

      SharedPreferences prefs = await SharedPreferences.getInstance();

      // ✅ 确保写入完成
      await prefs.setString('token', token ?? '');
      if (email != null) await prefs.setString('email', email);
      if (username != null) await prefs.setString('username', username);

      print("✅ Token successfully saved: ${prefs.getString('token')}");

      // 再跳转
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
          // 渐变背景
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.silverGrey, // 银灰色渐变
                  AppColors.lightSilver,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          // 玻璃拟态卡片
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: GlassMorphismContainer(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // 欢迎标题
                    Text(
                      S.of(context).welcome_back,
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryText, // 主文本颜色
                      ),
                    ),
                    const SizedBox(height: 20),
                    // 仅当 errorMessage 不为空时显示
                    Visibility(
                      visible: errorMessage != null && errorMessage!.isNotEmpty,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          errorMessage ?? '',
                          style: const TextStyle(color: Colors.red),
                        ),
                      ),
                    ),
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
                    const SizedBox(height: 20),
                    // 登录按钮
                    _buildActionButton(
                      text: S.of(context).log_in,
                      onPressed: isLoading ? null : _handleLogin, // 防止重复点击
                      isLoading: isLoading, // 传递加载状态
                    ),
                    const SizedBox(height: 20),
                    // 注册按钮
                    _buildActionButton(
                      text: S.of(context).register,
                      onPressed: () {
                        Navigator.pushNamed(context, '/register');
                      },
                      isLoading: false, // 注册按钮无需 loading 状态
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 构建通用输入框
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
        hintStyle: TextStyle(color: AppColors.secondaryText), // 提示文本颜色
        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.8), // 半透明白色背景
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  /// 构建通用按钮
  Widget _buildActionButton({
    required String text,
    required VoidCallback? onPressed,
    required bool isLoading,
  }) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.silverGrey, // 按钮背景色
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        minimumSize: const Size(200, 50),
        elevation: 3, // 按钮阴影
      ),
      onPressed: onPressed,
      child: isLoading
          ? const CircularProgressIndicator(color: Colors.white) // 加载动画
          : Text(
              text,
              style: TextStyle(
                color: AppColors.primaryText,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
    );
  }
}

/// GlassMorphism 组件
class GlassMorphismContainer extends StatelessWidget {
  final Widget child;

  const GlassMorphismContainer({
    Key? key,
    required this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15), // 玻璃效果的半透明背景
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.3), width: 1.5), // 边框
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.2), // 柔和灰色阴影
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: child,
    );
  }
}