import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as p;
import 'package:plantify/models/user_model.dart';

class UserService {
  final String baseUrl = dotenv.env['BASE_URL'] ?? "";
  String? get _tokenOrNull {
  final u = Hive.box<UserModel>('userBox').get('currentUser');
  final t = u?.accessToken ?? '';
  return t.isNotEmpty ? t : null;
}

  Future<UserModel> getUserById(String id) async {
    final box = Hive.box<UserModel>('userBox');
    for (final key in box.keys) {
      final user = box.get(key);
      debugPrint('🔹 [$key] ${user?.name} | ${user?.email} | ${user?.id}');
    }
    try {
      final user = hiveGetUserById(id);

      if (user == null) {
        throw Exception('❌ Không tìm thấy người dùng với id: $id');
      }

      return user;
    } catch (e, stackTrace) {
      debugPrint('❌ [getUserById] Lỗi khi lấy user với id: $id');
      debugPrint('🔍 Lỗi: $e');
      debugPrint('📌 StackTrace: $stackTrace');
      return UserModel.empty();
    }
  }

  Future<String> getEmailByToken(String token) async {
    final url = Uri.parse('$baseUrl/auth/profile');
    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
    if (response.statusCode != 201 && response.statusCode != 200) {
      throw Exception(
          'Cập nhật thất bại: ${response.statusCode} ${response.body}');
    }

    final data = jsonDecode(response.body);
    return data['email'];
  }
  Future<String?> getImagesByToken() async {
    final t = _tokenOrNull;
    if (t == null) throw Exception('Missing token');

    final url = Uri.parse('$baseUrl/auth/profile');
    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $t',
        'Accept': 'application/json',
      },
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('Cập nhật thất bại: ${response.statusCode} ${response.body}');
    }

    final data = jsonDecode(utf8.decode(response.bodyBytes));
    final dynamic raw = data['imageurl'] ??
                        data['imageUrl'] ??
                        data['image_url'] ??
                        data['avatar'] ??
                        data['image'];

    if (raw is String && raw.trim().isNotEmpty) return raw.trim();
    return null; 
  }

  Future<List<UserModel>> getAllUsers() async {
    final url = Uri.parse('$baseUrl/auth/all-users');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final decoded = jsonDecode(utf8.decode(response.bodyBytes));
      final List list =
          decoded is List ? decoded : (decoded['users'] as List? ?? const []);
      return list
          .map((e) => UserModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } else {
      throw Exception('Lỗi khi lấy danh sách người dùng');
    }
  }

  Future<void> updateUser(UserModel user) async {
    final url = Uri.parse('$baseUrl/users/${user.id}');
    final response = await http.put(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(user.toJson()),
    );

    if (response.statusCode != 200) {
      throw Exception('Cập nhật thất bại');
    }
  }

  Future<void> deleteUser(String id) async {
    final url = Uri.parse('$baseUrl/users/$id');
    final response = await http.delete(url);

    if (response.statusCode != 200) {
      throw Exception('Xoá thất bại');
    }
  }

  Future<UpdateProfileResult> updateProfile({
  required String token,
  String? name,
  String? email,
  File? file,
}) async {
  print('=== u: $name, e: $email, f: $file');
  final url = Uri.parse('$baseUrl/auth/update-profile');
  http.Response res;

  if (file != null) {
    final req = http.MultipartRequest('PUT', url);
    if (name != null && name.isNotEmpty) req.fields['username'] = name;
    if (email != null && email.isNotEmpty) req.fields['email'] = email;

    req.files.add(await http.MultipartFile.fromPath(
      'image',
      file.path,
      filename: p.basename(file.path),
    ));

    req.headers['Authorization'] = 'Bearer $token';
    req.headers['Accept'] = 'application/json';

    final streamed = await req.send();
    res = await http.Response.fromStream(streamed);
  } else {
    final body = <String, dynamic>{};
    if (name != null && name.isNotEmpty) body['username'] = name;
    if (email != null && email.isNotEmpty) body['email'] = email;

    res = await http.put(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      },
      body: jsonEncode(body),
    );
  }

  final ok = res.statusCode >= 200 && res.statusCode < 300;

  if (ok) {
    final imageUrl = await getImagesByToken();
    await hiveUpsertUserPartial(
      name: name,
      imageUrl: imageUrl,
      email: email,
      accessToken: token,
    );
  }

  final user = hiveGetUser();
  if (user == null) {
    throw Exception('No local user after update');
  }

  return UpdateProfileResult(ok: ok, user: user);
}

  Future<UpdateProfileResult> updateProfileWithOptionalAvatar({
    String? name,
    String? email,
    File? newAvatar,
  }) async {
    final t = _tokenOrNull;
  if (t == null) throw Exception('Missing token');
    return await updateProfile(
      token: t,
      name: name,
      email: email,
      file: newAvatar,
    );
  }

  static const String _boxName = 'userBox';
  static const String _userKey = 'currentUser';

  static Future<void> hiveSaveUser(UserModel user) async {
    final box = Hive.box<UserModel>(_boxName);
    await box.put(_userKey, user);
  }

  static Future<void> hiveSaveAllUser(UserModel user) async {
    final box = Hive.box<UserModel>(_boxName);
    await box.put(user.id.toString(), user);
  }

  static Future<void> hiveSaveUserById(UserModel user) async {
    final box = Hive.box<UserModel>('userBox');
    await box.put(user.id, user); 
  }

  static UserModel? hiveGetUser() {
    final box = Hive.box<UserModel>(_boxName);
    return box.get(_userKey);
  }

  static UserModel? hiveGetUserById(String userId) {
    final box = Hive.box<UserModel>('userBox');
    try {
      return box.get(userId); 
    } catch (e) {
      debugPrint('❌ Lỗi khi tìm user trong Hive: $e');
      return null;
    }
  }

  static Future<void> hiveDeleteUser() async {
    final box = Hive.box<UserModel>(_boxName);
    await box.delete(_userKey);
  }

  static bool isLoggedIn() {
    final box = Hive.box<UserModel>(_boxName);
    return box.containsKey(_userKey);
  }

  static String getToken() {
    final box = Hive.box<UserModel>(_boxName);
    final user = box.get(_userKey);

    if (user != null && user.accessToken.isNotEmpty) {
      return user.accessToken;
    } else {
      throw Exception('Token not found in Hive');
    }
  }

  static Future<void> hiveUpsertUserPartial({
    String? id,
    String? name,
    String? imageUrl,
    String? email,
    String? accessToken, 
  }) async {
    final box = Hive.box<UserModel>(_boxName);
    final current = box.get(_userKey);

    if (current == null) {
      final newUser = UserModel(
        id: id ?? '',
        name: (name?.trim().isNotEmpty == true) ? name! : 'No name',
        imageUrl: (imageUrl?.trim().isNotEmpty == true)
            ? imageUrl!
            : 'https://cdn-icons-png.flaticon.com/512/8792/8792047.png',
        email: email ?? '',
        accessToken: accessToken ?? '',
      );
      await box.put(_userKey, newUser);
      return;
    }

    final merged = current.copyWith(
      id: (id != null && id.isNotEmpty) ? id : current.id,
      name: (name != null && name.trim().isNotEmpty) ? name : current.name,
      imageUrl: (imageUrl != null && imageUrl.trim().isNotEmpty)
          ? imageUrl
          : current.imageUrl,
      email: (email != null && email.trim().isNotEmpty) ? email : current.email,
      accessToken: (accessToken != null && accessToken.isNotEmpty)
          ? accessToken
          : current.accessToken,
    );

    await box.put(_userKey, merged);
  }
}

class JwtUtil {
  static bool isExpired(String token) {
    try {
      final parts = token.split('.');
      if (parts.length != 3) return true; 
      final payload = jsonDecode(
        utf8.decode(base64Url.decode(base64Url.normalize(parts[1]))),
      ) as Map<String, dynamic>;
      final exp = payload['exp'];
      if (exp is! int) return true;
      final expiresAt = DateTime.fromMillisecondsSinceEpoch(exp * 1000);
      return DateTime.now().isAfter(expiresAt);
    } catch (_) {
      return true; 
    }
  }

  static final String _baseUrl = dotenv.env['BASE_URL'] ?? "";

  static Future<bool> validateRemote(String token) async {
    try {
      final res = await http.get(
        Uri.parse("$_baseUrl/auth/profile"),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      return res.statusCode >= 200 && res.statusCode < 300;
    } catch (_) {
      return false;
    }
  }
}


class UpdateProfileResult {
  final bool ok;
  final UserModel user;
  UpdateProfileResult({required this.ok, required this.user});
}