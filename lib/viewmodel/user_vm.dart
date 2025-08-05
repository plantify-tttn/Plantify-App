import 'package:flutter/material.dart';
import 'package:plantify/models/user_model.dart';
import 'package:plantify/services/user_service.dart';

class UserVm extends ChangeNotifier {
  UserModel? _user;
  bool _isLoading = false;

  UserModel? get user => _user;
  bool get isLoading => _isLoading;
  bool get isLoggedIn => UserService.isLoggedIn();

  // 🟢 Load từ Hive, nếu chưa có thì gọi API
  Future<void> loadUser(String userId) async {
    _isLoading = true;
    notifyListeners();

    // Thử lấy từ Hive
    _user = UserService.hiveGetUser();

    // Nếu Hive chưa có, hoặc muốn đảm bảo mới nhất thì lấy từ API
    try {
      final apiUser = await UserService().getUserById(userId);
      if (_user == null || _user!.toJson().toString() != apiUser.toJson().toString()) {
        _user = apiUser;
        await UserService.hiveSaveUser(apiUser); // Cập nhật Hive
      }
    } catch (e) {
      debugPrint("❌ Lỗi loadUser: $e");
    }

    _isLoading = false;
    notifyListeners();
  }
  
  // 🔄 Cập nhật user (dùng khi user chỉnh sửa thông tin)
  Future<void> updateUser(UserModel updatedUser) async {
    _user = updatedUser;
    await UserService().updateUser(updatedUser);
    await UserService.hiveSaveUser(updatedUser);
    notifyListeners();
  }

  // 🚪 Đăng xuất
  Future<void> logout() async {
    _user = null;
    await UserService.hiveDeleteUser();
    notifyListeners();
  }
}
