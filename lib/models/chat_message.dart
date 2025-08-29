import 'dart:io';

class ChatMessage {
  final String? text;
  final File? image;
  final bool isUser;
  final DateTime time;

  ChatMessage._({this.text, this.image, required this.isUser, required this.time});

  factory ChatMessage.userText(String text) =>
      ChatMessage._(text: text, isUser: true, time: DateTime.now());

  factory ChatMessage.userImage(File image) =>
      ChatMessage._(image: image, isUser: true, time: DateTime.now());

  factory ChatMessage.bot(String text) =>
      ChatMessage._(text: text, isUser: false, time: DateTime.now());
}
