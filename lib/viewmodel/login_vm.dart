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

      final token = (result['accessToken'] ?? '').toString();
      final userJson = Map<String, dynamic>.from(result['user'] ?? {});
      if (token.isEmpty || userJson.isEmpty) {
        _isLogin = false;
        notifyListeners();
        return false;
      }

      // Gộp token vào user và LƯU MÀ KHÔNG LÀM RƠI TOKEN CŨ
      final userModel = UserModel.fromJson({
        ...userJson,
        'accessToken': token,
      });


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