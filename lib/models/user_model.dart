import 'package:hive/hive.dart';

part 'user_model.g.dart';

@HiveType(typeId: 1) // 🔢 mỗi model 1 typeId khác nhau
class UserModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final String imageUrl;

  @HiveField(3)
  final String email;

  UserModel({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.email,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'].toString(),
      name: json['name'] ?? 'No name',
      imageUrl: json['imageUrl'] ??
          'https://cdn-icons-png.flaticon.com/512/8792/8792047.png',
      email: json['email'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "name": name,
      "imageUrl": imageUrl,
      "email": email,
    };
  }
}
