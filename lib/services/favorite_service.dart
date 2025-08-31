import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:hive/hive.dart';

class FavouriteLocal {
  static const _boxName = 'favourites';
  static Box<String> get _box => Hive.box<String>(_boxName);
  static bool isLoved(String postId) => _box.containsKey(postId);
  static Future<void> add(String postId) => _box.put(postId, postId);
  static Future<void> remove(String postId) => _box.delete(postId);
}

class FavoriteService {
  static final String baseUrl = dotenv.env['BASE_URL'] ?? "";

  /// POST /favourite/{postId}
  /// Return:
  /// - true  => after op, post is loved (server trả 'data')
  /// - false => after op, post is not loved (server không có 'data')
  /// - null  => request failed (giữ nguyên UI nếu muốn)
  static Future<bool?> toggleByResponse(String postId, String token) async {
    final res = await http.post(
      Uri.parse('$baseUrl/posts/like/$postId'),
      headers: {
        "Authorization": "Bearer $token",
        "Accept": "application/json",
      },
    );

    if (res.statusCode < 200 || res.statusCode >= 300) return null;

    Map<String, dynamic>? json;
    try {
      json = jsonDecode(utf8.decode(res.bodyBytes)) as Map<String, dynamic>;
    } catch (_) {}

    final hasData = json != null && json['data'] != null;

    // cập nhật Hive theo kết quả server
    if (hasData) {
      await FavouriteLocal.add(postId);    // now loved
      return true;
    } else {
      await FavouriteLocal.remove(postId); // now un-loved
      return false;
    }
  }
}
