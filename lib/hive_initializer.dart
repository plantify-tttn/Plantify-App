import 'package:hive_flutter/adapters.dart';
import 'package:plantify/models/chat_message.dart';
import 'package:plantify/models/comment_model.dart';
import 'package:plantify/models/disease_model.dart';
import 'package:plantify/models/plants_model.dart';
import 'package:plantify/models/post_model.dart';
import 'package:plantify/models/user_model.dart';

Future<void> initHive() async {
  await Hive.initFlutter();
  await Hive.openBox('settings');

  // await Hive.deleteBoxFromDisk('posts');
  // await Hive.deleteBoxFromDisk('favourites');


  // Đăng ký Adapter
  final adapters = [
    () => Hive.registerAdapter(UserModelAdapter()),
    () => Hive.registerAdapter(PostModelAdapter()),
    () => Hive.registerAdapter(PlantModelAdapter()),
    () => Hive.registerAdapter(CommentModelAdapter()),
    () => Hive.registerAdapter(DiseaseModelAdapter()),
    () => Hive.registerAdapter(ChatMessageAdapter())
    // () => Hive.registerAdapter(DiseaseModelAdapter()),
  ];

  for (var register in adapters) {
    register();
  }

  // Mở box
  final openBoxes = [
    () => Hive.openBox<UserModel>('userBox'),
    () => Hive.openBox<PostModel>('posts'),
    () => Hive.openBox<PlantModel>('plants'),
    () => Hive.openBox<CommentModel>('comments'),
    () => Hive.openBox<DiseaseModel>('diseases'),
    () => Hive.openBox<String>('favourites'),
    () => Hive.openBox<ChatMessage>("diagnose_messages")
    // () => Hive.openBox<DiseaseModel>('diseaseBox'),
  ];

  for (var open in openBoxes) {
    await open();
  }
}
