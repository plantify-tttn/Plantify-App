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
  final String _token = getToken();

  /// Lấy thông tin người dùng theo ID
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
  Future<String> getImagesByToken() async{
    final url = Uri.parse('$baseUrl/auth/profile');
    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $_token',
      },
    );
    if (response.statusCode != 201 && response.statusCode != 200) {
      throw Exception(
          'Cập nhật thất bại: ${response.statusCode} ${response.body}');
    }

    final data = jsonDecode(response.body);
    return data['imageUrl'];
  }

  /// Lấy danh sách tất cả người dùng
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

  /// Cập nhật thông tin người dùng
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

  /// Xoá người dùng
  Future<void> deleteUser(String id) async {
    final url = Uri.parse('$baseUrl/users/$id');
    final response = await http.delete(url);

    if (response.statusCode != 200) {
      throw Exception('Xoá thất bại');
    }
  }

  Future<String> uploadAvatar(File file, {String? token}) async {
    final uri =
        Uri.parse('$baseUrl/files/upload'); // đổi endpoint theo BE của bạn
    final req = http.MultipartRequest('POST', uri)
      ..files.add(await http.MultipartFile.fromPath(
        'avatar', // đổi 'avatar' đúng tên field file trên BE
        file.path,
        filename: p.basename(file.path),
      ));

    final t = token ?? _token;
    if (t.isNotEmpty) {
      req.headers['Authorization'] = 'Bearer $t';
    }

    final res = await req.send();
    final body = await res.stream.bytesToString();
    if (res.statusCode != 200 && res.statusCode != 201) {
      throw Exception('Upload avatar thất bại (${res.statusCode}): $body');
    }
    final json = jsonDecode(body) as Map<String, dynamic>;
    // BE của bạn trả key nào thì lấy key đó (ví dụ 'url' hoặc 'imageUrl')
    return (json['url'] ?? json['imageUrl'] ?? '').toString();
  }

  /// Cập nhật profile (không gửi accessToken trong body)
  Future<UserModel> updateProfile({
    required String token,
    String? name,
    String? email,
    File? file,
  }) async {
    final url = Uri.parse('$baseUrl/auth/update-profile');
    http.Response res;

    if (file != null) {
      // ===== Multipart (có file) =====
      final req = http.MultipartRequest('PUT', url);

      if (name != null && name.isNotEmpty) req.fields['name'] = name;
      if (email != null && email.isNotEmpty) req.fields['email'] = email;

      // Tên field file đổi cho đúng với BE (vd: 'avatar' / 'image' / 'file')
      req.files.add(
        await http.MultipartFile.fromPath(
          'image',
          file.path,
          filename: p.basename(file.path),
        ),
      );

      req.headers['Authorization'] = 'Bearer $token';
      req.headers['Accept'] = 'application/json';

      final streamed = await req.send();
      res = await http.Response.fromStream(streamed);
    } else {
      // ===== JSON (không có file) =====
      final body = <String, dynamic>{};
      if (name != null && name.isNotEmpty) body['name'] = name;
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

    if (res.statusCode != 200 && res.statusCode != 201) {
      throw Exception('Cập nhật thất bại: ${res.statusCode} ${res.body}');
    }
    final imageUrl = await getEmailByToken(token);

    await hiveUpsertUserPartial(
      name: name,
      imageUrl: imageUrl,
      email: email,
      accessToken: token, // lưu token mới nếu có
    ); // đồng bộ lại Hive
    final user = hiveGetUser();
    return user!;
  }

  /// One-shot: nếu có chọn ảnh mới -> upload, rồi update profile
  Future<UserModel> updateProfileWithOptionalAvatar({
    String? name,
    String? email,
    File? newAvatar,
  }) async {
    final token = _token;

    return await updateProfile(
      token: token,
      name: name,
      email: email,
      file: newAvatar,
    );
  }

  static const String _boxName = 'userBox';
  static const String _userKey = 'currentUser';

  // ✅ Lưu user
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
    await box.put(user.id, user); // key là user.id
  }

  // ✅ Lấy user
  static UserModel? hiveGetUser() {
    final box = Hive.box<UserModel>(_boxName);
    return box.get(_userKey);
  }

  static UserModel? hiveGetUserById(String userId) {
    final box = Hive.box<UserModel>('userBox');
    try {
      return box.get(userId); // lấy theo key userId
    } catch (e) {
      debugPrint('❌ Lỗi khi tìm user trong Hive: $e');
      return null;
    }
  }

  // ✅ Xoá user khi logout
  static Future<void> hiveDeleteUser() async {
    final box = Hive.box<UserModel>(_boxName);
    await box.delete(_userKey);
  }

  // ✅ Kiểm tra đã login chưa
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
    String? accessToken, // có thể null nếu BE không trả
  }) async {
    final box = Hive.box<UserModel>(_boxName);
    final current = box.get(_userKey);

    if (current == null) {
      // Chưa có -> tạo mới, nhưng cần đảm bảo non-null (dùng fallback)
      final newUser = UserModel(
        id: id ?? '',
        name: (name?.trim().isNotEmpty == true) ? name! : 'No name',
        imageUrl: (imageUrl?.trim().isNotEmpty == true)
            ? imageUrl!
            : 'https://cdn-icons-png.flaticon.com/512/8792/8792047.png',
        email: email ?? '',
        accessToken: accessToken ?? '', // fallback rỗng
      );
      await box.put(_userKey, newUser);
      return;
    }

    // Đã có -> merge: chỉ cập nhật khi giá trị mới KHÁC null & KHÔNG rỗng
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
