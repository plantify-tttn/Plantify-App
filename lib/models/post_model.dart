import 'package:hive/hive.dart';

part 'post_model.g.dart';

@HiveType(typeId: 2)
class PostModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String userid;

  @HiveField(2)
  final String content;

  @HiveField(3)
  final String imageurl;

  @HiveField(4)
  final int loveCount;

  @HiveField(5)
  final int commentCount;

  @HiveField(6)
  final String created_at;

  PostModel({
    required this.id,
    required this.userid,
    required this.content,
    required this.imageurl,
    required this.loveCount,
    required this.commentCount,
    required this.created_at,
  });

  factory PostModel.fromJson(Map<String, dynamic> json) {
    return PostModel(
      id: json['id'],
      userid: (json['userid'] ?? '').toString(),
      content: (json['content'] ?? '') as String,
      imageurl: (json['imageurl'] ?? '') as String,
      loveCount: (json['loveCount'] ?? 0) as int,
      commentCount: (json['commentCount'] ?? 0) as int,
      created_at: (json['created_at'] ?? '').toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userid': userid,
      'content': content,
      'imageurl': imageurl,
      'loveCount': loveCount,
      'commentCount': commentCount,
      'created_at': created_at,
    };
  }
}
