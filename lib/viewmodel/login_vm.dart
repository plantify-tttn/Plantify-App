import 'package:flutter/material.dart';
import 'package:plantify/models/user_model.dart';
import 'package:plantify/services/auth_services/login_service.dart';
import 'package:plantify/services/user_service.dart';
import 'package:plantify/viewmodel/user_vm.dart';
import 'package:provider/provider.dart';

class LoginVm extends ChangeNotifier{
  final LoginService _loginService = LoginService();
  bool _canLogin = false;
  bool _isLogin = false;

  final _emailController = TextEditingController();
  final _passController = TextEditingController();

  TextEditingController get emailController => _emailController;
  TextEditingController get passController => _passController;
  bool get isLogin => _isLogin;

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
    try {
      final result = await _loginService.login(
        email: emailController.text,
        password: passController.text,
      );

      if (!context.mounted) return;

      if (result['login'] == true) {
        final userMap = result['user'];
        final userModel = UserModel.fromJson(userMap);
        await UserService.hiveSaveUser(userModel);
        final userVm = Provider.of<UserVm>(context, listen: false);
        userVm.loadUser(userModel.id);
        if(!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("✅ Đăng nhập thành công: ${userModel.name}"),
            backgroundColor: Colors.green,
          ),
        );
        _isLogin = true;
        notifyListeners();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("❌ Tài khoản hoặc mật khẩu không đúng"),
            backgroundColor: Colors.red,
          ),
        );

        _isLogin = false;
        notifyListeners();
      }
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("❌ Tài khoản hoặc mật khẩu không đúng"),
          backgroundColor: Colors.red,
        ),
      );
      _isLogin = false;
      notifyListeners();
    }
  }
}