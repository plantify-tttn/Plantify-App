import 'package:hive/hive.dart';
part 'post_model.g.dart';

@HiveType(typeId: 2)
class PostModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String userid; // store as String

  @HiveField(2)
  final String content;

  @HiveField(3)
  final String imageurl;

  @HiveField(4)
  final int likeCount; // ✅ rename

  @HiveField(5)
  final int commentCount;

  @HiveField(6)
  final String created_at;

  // (Optional) nếu muốn lưu tên người dùng
  @HiveField(7)
  final String? username;

  PostModel({
    required this.id,
    required this.userid,
    required this.content,
    required this.imageurl,
    required this.likeCount,
    required this.commentCount,
    required this.created_at,
    this.username,
  });

  factory PostModel.fromJson(Map<String, dynamic> json) {
    return PostModel(
      id: (json['id'] ?? '').toString(),
      userid: (json['userid'] ?? json['userId'] ?? '').toString(),
      content: (json['content'] ?? '') as String,
      // chấp nhận cả imageurl / imageUrl
      imageurl: (json['imageurl'] ?? json['imageUrl'] ?? '') as String,
      // API dùng likeCount; fallback loveCount cho an toàn
      likeCount: (json['likeCount'] ?? json['loveCount'] ?? 0) as int,
      commentCount: (json['commentCount'] ?? 0) as int,
      created_at: (json['created_at'] ?? '').toString(),
      // lấy username từ 2 chỗ có thể xuất hiện
      username: (json['userName'] ??
                (json['users'] is Map ? (json['users']['username']) : null))
              ?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userid': userid,
      'content': content,
      'imageurl': imageurl,
      'likeCount': likeCount,
      'commentCount': commentCount,
      'created_at': created_at,
      'username': username,
    };
  }
}
