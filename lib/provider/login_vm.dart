import 'package:flutter/material.dart';
import 'package:plantify/models/user_model.dart';
import 'package:plantify/services/auth_services/login_service.dart';
import 'package:plantify/services/user_service.dart';

class LoginVm extends ChangeNotifier {
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

  void updateCan() {
    _canLogin =
        _emailController.text.isNotEmpty && _passController.text.isNotEmpty;
    notifyListeners();
  }

  Future<String> login() async {
    try {
      final result = await _loginService.login(
        email: emailController.text.trim(),
        password: passController.text,
      );
      final id = (result['id'] ?? 'currentUser');
      final name = (result['user'] ?? result['name'] ?? '').toString();
      final token = (result['access_token'] ?? '').toString();
      final imageUrl = (result['imageUrl'] as String?) ??
          'https://cdn-icons-png.flaticon.com/512/8792/8792047.png';
      final _email;
      if (token.isEmpty || name.isEmpty) {
        _isLogin = false;
        notifyListeners();
        return 'token hoac ten rong';
      }
      if (token !='') {
        print('===== t');
        _email = await UserService().getEmailByToken(token);
        //_email = (result['email'] ?? '').toString();
        print('====== s');
      } else {
        _email = (result['email'] ?? '').toString();
      }

      final userModel = UserModel(
        id: id,
        name: name,
        imageUrl: imageUrl,
        email: _email,
        accessToken: token,
      );
      print('===== t');
      await UserService.hiveSaveUser(userModel);
      print('====== s');

      _isLogin = true;
      notifyListeners();
      return 'ok';
    } catch (e) {
      _isLogin = false;
      notifyListeners();
      return '$e';
    }
  }
}
