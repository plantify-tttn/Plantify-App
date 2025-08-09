import 'package:hive/hive.dart';
part 'user_model.g.dart';
@HiveType(typeId: 1)
class UserModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final String imageUrl;

  @HiveField(3)
  final String email;

  @HiveField(4) // 🔢 thêm field mới
  final String accessToken;

  UserModel({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.email,
    required this.accessToken,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'].toString(),
      name: json['name'] ?? 'No name',
      imageUrl: json['imageUrl'] ?? 'https://cdn-icons-png.flaticon.com/512/8792/8792047.png',
      email: json['email'] ?? '',
      accessToken: json['accessToken'] ?? '', // thêm ở đây
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "name": name,
      "imageUrl": imageUrl,
      "email": email,
      "accessToken": accessToken,
    };
  }

  // ✅ tiện cho UI cập nhật
  UserModel copyWith({
    String? id,
    String? name,
    String? imageUrl,
    String? email,
    String? accessToken,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      imageUrl: imageUrl ?? this.imageUrl,
      email: email ?? this.email,
      accessToken: accessToken ?? this.accessToken,
    );
  }
}
