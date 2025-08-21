import 'package:flutter/material.dart';
import 'package:plantify/models/user_model.dart';
import 'package:plantify/services/auth_services/login_service.dart';
import 'package:plantify/services/user_service.dart';

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

  Future<bool> login() async {
    try {
      final result = await _loginService.login(
        email: emailController.text.trim(),
        password: passController.text,
      );
      final id = (result['id'] ?? 'currentUser');
      final name  = (result['user'] ?? result['name'] ?? '').toString();
      final token = (result['access_token'] ?? '').toString();
      final imageUrl = (result['imageUrl'] as String?) ??
        'https://cdn-icons-png.flaticon.com/512/8792/8792047.png';
      var email = (result['email'] ?? '').toString();

      final userModel = UserModel(
        id: id,
        name: name,
        imageUrl: imageUrl,
        email: email,
        accessToken: token,
      );
      if (token.isEmpty || name.isEmpty) {
        _isLogin = false;
        notifyListeners();
        return false;
      }

      // dùng hàm preserve token (như bạn đã thêm hiveUpsertUserPartial)
      await UserService.hiveSaveUser(userModel); 
      _isLogin = true;
      notifyListeners();
      return true;
    } catch (e) {
      _isLogin = false;
      notifyListeners();
      return false;
    }
  }
}