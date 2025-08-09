import 'dart:async';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:plantify/models/user_model.dart';
import 'package:plantify/services/user_service.dart';

class UserVm extends ChangeNotifier {
  static const _boxName = 'userBox';
  static const _userKey = 'currentUser';

  Box<UserModel>? _box;
  Box<UserModel> get box => _box ??= Hive.box<UserModel>(_boxName);

  StreamSubscription<BoxEvent>? _sub;
  UserModel? _user;
  bool _isLoading = false;

  UserModel? get user => _user;
  bool get isLoading => _isLoading;

  // Nên coi là logged in khi có token
  bool get isLoggedIn => (box.get(_userKey)?.accessToken.isNotEmpty ?? false);

  void init() {
    _user = box.get(_userKey);
    notifyListeners();
    _sub = box.watch(key: _userKey).listen((_) {
      _user = box.get(_userKey);
      notifyListeners();
    });
  }

  Future<void> loadUser(String userId, {bool forceRefresh = false}) async {
    _isLoading = true; notifyListeners();
    try {
      _user ??= box.get(_userKey);
      if (forceRefresh || _user == null) {
        final apiUser = await UserService().getUserById(userId);
        // preserve token, đừng dùng hiveSaveUser ở đây
        await UserService.hiveUpsertUserPartial(
          id: apiUser.id,
          name: apiUser.name,
          email: apiUser.email,
          imageUrl: apiUser.imageUrl,
        );
      }
    } catch (e) {
      debugPrint('❌ Lỗi loadUser: $e');
    } finally {
      _isLoading = false; notifyListeners();
    }
    notifyListeners();
  }

  Future<void> updateUser(UserModel updatedUser) async {
    try {
      await UserService().updateUser(updatedUser);
      await UserService.hiveUpsertUserPartial(
        id: updatedUser.id,
        name: updatedUser.name,
        email: updatedUser.email,
        imageUrl: updatedUser.imageUrl,
      );
    } catch (e) {
      debugPrint('❌ Lỗi updateUser: $e');
      rethrow;
    }
  }

  Future<void> logout() async {
    await UserService.hiveDeleteUser();
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}

