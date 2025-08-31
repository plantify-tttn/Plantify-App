// models/chat_message.dart
import 'dart:io';
import 'package:hive/hive.dart';

part 'chat_message.g.dart';

@HiveType(typeId: 10) // mỗi model 1 typeId duy nhất
class ChatMessage {
  @HiveField(0)
  final bool isUser;

  @HiveField(1)
  final String? text;

  /// với ảnh: lưu path chứ không lưu trực tiếp File
  @HiveField(2)
  final String? imagePath;

  @HiveField(3)
  final List<String>? options;

  @HiveField(4)
  final DateTime createdAt;

  ChatMessage({
    required this.isUser,
    this.text,
    this.imagePath,
    this.options,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  factory ChatMessage.userText(String t) =>
      ChatMessage(isUser: true, text: t);

  factory ChatMessage.userImage(File f) =>
      ChatMessage(isUser: true, imagePath: f.path);

  factory ChatMessage.bot(String t, {List<String>? options}) =>
      ChatMessage(isUser: false, text: t, options: options);

  factory ChatMessage.botOptions(List<String> opts, {String? text}) =>
      ChatMessage(isUser: false, text: text, options: opts);

  File? get image => imagePath == null ? null : File(imagePath!);
}
