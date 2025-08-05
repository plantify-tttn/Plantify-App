import 'package:flutter/material.dart';
import 'package:plantify/services/auth_services/register_service.dart';

class RegisterVm extends ChangeNotifier {
  final RegisterService _registerService = RegisterService();
  bool _canRegister = false;
  bool _isRegister = false;

  bool get isRegister => _isRegister;
  // Controllers
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passController = TextEditingController();
  final _rePassController = TextEditingController();

  // Getters để UI truy cập
  TextEditingController get usernameController => _usernameController;
  TextEditingController get emailController => _emailController;
  TextEditingController get passController => _passController;
  TextEditingController get rePassController => _rePassController;

  // Validation flags
  bool _isEmailValid = false;
  bool _isPassValid = false;
  bool _isRePassValid = false;
  bool _isUsernameValid = false;

  // Getters
  bool get isEmailValid => _isEmailValid;
  bool get isPassValid => _isPassValid;
  bool get isRePassValid => _isRePassValid;
  bool get isUsernameValid => _isUsernameValid;

  // Validation status & error text
  String? _emailError;
  String? _passError;
  String? _rePassError;
  String? _usernameError;

  String? get emailError => _emailError;
  String? get passError => _passError;
  String? get rePassError => _rePassError;
  String? get usernameError => _usernameError;


  // Combine all validations to enable "Register" button
  bool get canRegister => _canRegister;

  void updateCan(){
    _canRegister = _isEmailValid && _isPassValid && _isRePassValid && _isUsernameValid;
    notifyListeners();
  }
  // Validate logic
  void validateEmail(String value) {
    final trimmed = value.trim();
    final regex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (trimmed.isEmpty) {
      _emailError = 'Vui lòng nhập email';
      _isEmailValid = false;
    } else if (!regex.hasMatch(trimmed)) {
      _emailError = 'Email không hợp lệ';
      _isEmailValid = false;
    } else {
      _emailError = null;
      _isEmailValid = true;
    }
    updateCan();
  }

  void validatePassword(String value) {
    if (value.length < 6) {
      _passError = 'Mật khẩu phải có ít nhất 6 ký tự';
      _isPassValid = false;
    } else {
      _passError = null;
      _isPassValid = true;
    }
    // Gọi lại rePass để cập nhật so khớp
    validateRePassword(_rePassController.text);
  }

  void validateRePassword(String value) {
    if (value != _passController.text) {
      _rePassError = 'Mật khẩu không khớp';
      _isRePassValid = false;
    } else {
      _rePassError = null;
      _isRePassValid = true;
    }
    updateCan();
  }

  void validateUsername(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) {
      _usernameError = 'Tên người dùng không được để trống';
      _isUsernameValid = false;
    } else if (trimmed.length < 3) {
      _usernameError = 'Tên người dùng phải có ít nhất 3 ký tự';
      _isUsernameValid = false;
    } else {
      _usernameError = null;
      _isUsernameValid = true;
    }
    updateCan();
  }


  // Dispose các controller khi không dùng nữa
  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passController.dispose();
    _rePassController.dispose();
    super.dispose();
  }

  Future<void> register(BuildContext context) async{
    final result = await _registerService.register(
      username: usernameController.text,
      email: emailController.text,
      password: passController.text,
    );
    if (!context.mounted) return;
    if (result['success']) {
      final user = result['data']['user'];
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Đăng ký thành công: ${user['name']}"),
          backgroundColor: Colors.green,
        ),
      );
      _isRegister = true;
      notifyListeners();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Tài khoản đã tồn tại"),
          backgroundColor: Colors.red,
        ),
      );
      _isRegister = false;
      notifyListeners();
    }
  }
}
