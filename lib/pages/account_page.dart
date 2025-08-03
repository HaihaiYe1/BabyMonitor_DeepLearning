import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';
import '../generated/l10n.dart';
import '../services/auth_service.dart';

class AccountPage extends StatefulWidget {
  @override
  _AccountPageState createState() => _AccountPageState();
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
      _username = prefs.getString('username') ?? 'User123';  // 从 SharedPreferences 加载用户名
      _email = prefs.getString('email') ?? 'user@example.com';  // 从 SharedPreferences 加载邮箱
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
        title: Text(S.of(context).change_username),
        content: TextField(
          controller: usernameController,
          decoration: InputDecoration(hintText: S.of(context).enter_new_username),
        ),
        actions: [
          TextButton(
            onPressed: () async {
              String newUsername = usernameController.text.trim();
              if (newUsername.isEmpty) return;

                // 调用后端 API 修改用户名
                bool success = await AuthService().updateUsername(newUsername);
                if (success) {
                  setState(() {
                    _username = newUsername;
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(S.of(context).username_updated_successfully)),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(S.of(context).failed_update_username)),
                  );
                }

                Navigator.of(context).pop();
              },
              child: Text(S.of(context).save),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(S.of(context).cancel),
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
          title: Text(S.of(context).change_password),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: oldPasswordController,
                decoration: InputDecoration(hintText: S.of(context).enter_old_password),
                obscureText: true,
              ),
              SizedBox(height: 10),
              TextField(
                controller: newPasswordController,
                decoration: InputDecoration(hintText: S.of(context).enter_new_password),
                obscureText: true,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () async {
                String oldPassword = oldPasswordController.text.trim();
                String newPassword = newPasswordController.text.trim();

                if (oldPassword.isEmpty || newPassword.isEmpty) return;

                bool success = await AuthService().changePassword(oldPassword, newPassword);
                if (success) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(S.of(context).password_changed_successfully)),
                  );
                  AuthService().logout(context); // 修改密码成功后自动退出登录
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(S.of(context).failed_update_password)),
                  );
                }

                Navigator.of(context).pop();
              },
              child: Text(S.of(context).save),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(S.of(context).cancel),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true, // 让底部导航栏浮动
      appBar: AppBar(
        title: Text(S.of(context).account_management),
        centerTitle: true,
        automaticallyImplyLeading: false, // 删除返回键
        backgroundColor: Colors.white.withOpacity(0.8), // 半透明背景
        elevation: 0, // 去掉阴影
      ),
      body: SafeArea(
        bottom: false, // 让底部可以继续渐变
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
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: SingleChildScrollView( // 添加滚动视图
                physics: AlwaysScrollableScrollPhysics(), // 确保始终可滚动
                child: Column(
                  children: [
                    GestureDetector(
                      onTap: _getImage,
                      child: CircleAvatar(
                        radius: 60,
                        backgroundColor: Colors.blueAccent,
                        backgroundImage: _avatarImage != null
                            ? FileImage(_avatarImage!)
                            : AssetImage('lib/assets/images/v.png')
                                as ImageProvider,
                        child: _avatarImage == null
                            ? Icon(
                                Icons.camera_alt,
                                color: Colors.white,
                                size: 30,
                              )
                            : null,
                      ),
                    ),
                    SizedBox(height: 20),
                    _buildCardItem(
                      title: S.of(context).username,
                      subtitle: _username,
                      icon: Icons.edit,
                      onTap: _changeUsername,
                    ),
                    SizedBox(height: 16),
                    _buildCardItem(
                      title: S.of(context).email,
                      subtitle: _email,
                      icon: Icons.email,
                    ),
                    SizedBox(height: 16),
                    _buildCardItem(
                      title: S.of(context).change_password,
                      subtitle: '********',
                      icon: Icons.lock,
                      onTap: _changePassword,
                    ),
                    SizedBox(height: 40),
                    ElevatedButton(
                      onPressed: () => AuthService().logout(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.redAccent,
                        padding: EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Text(
                        S.of(context).logout,
                        style: TextStyle(fontSize: 18, color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 卡片样式的 ListTile
  Widget _buildCardItem({
    required String title,
    required String subtitle,
    required IconData icon,
    VoidCallback? onTap,
  }) {
    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        title: Text(title, style: TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle),
        trailing: Icon(icon),
        onTap: onTap,
      ),
    );
  }
}
