import 'package:hive/hive.dart';

part 'favorite_model.g.dart';

@HiveType(typeId: 11) // 🔢 nhớ không trùng với model khác
class FavoriteModel extends HiveObject {
  @HiveField(0)
  final String postId;

  FavoriteModel({required this.postId});

  // JSON (nếu còn dùng REST)
  factory FavoriteModel.fromJson(Map<String, dynamic> json) {
    return FavoriteModel(postId: json['postId']);
  }

  Map<String, dynamic> toJson() => {
        'postId': postId,
      };
}
