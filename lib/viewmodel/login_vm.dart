import 'package:flutter/material.dart';
import 'package:plantify/services/auth_services/login_service.dart';

class LoginVm extends ChangeNotifier{
  final LoginService _loginService = LoginService();
  bool _canLogin = false;

  final _emailController = TextEditingController();
  final _passController = TextEditingController();

  TextEditingController get emailController => _emailController;
  TextEditingController get passController => _passController;

  @override
  void dispose() {
    _emailController.dispose();
    _passController.dispose();
    super.dispose();
  }

  bool get canLogin => _canLogin;
  
  void updateCan(){
    _canLogin = _emailController.text.isNotEmpty && _passController.text.isNotEmpty;
    notifyListeners();
  }

  Future<void> login(BuildContext context) async {
    final result = await _loginService.login(
      email: emailController.text,
      password: passController.text,
    );
    if (!context.mounted) return;
    if (result['success']) {
      final user = result['data']['user'];
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Đăng nhập thành công: ${user['name']}"),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Tài khoản hoặc mật khẩu không đúng"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}