import 'package:flutter/material.dart';
import 'package:plantify/pages/home/home_header.dart';
import 'package:plantify/pages/posts/craete_post.dart';
import 'package:plantify/pages/posts/post_list.dart';
import 'package:plantify/services/user_service.dart';
import 'package:plantify/viewmodel/user_vm.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Future<void> _onRefresh() async {
    final saved = UserService.hiveGetUser(); // lấy user vừa lưu
      if (saved != null) {
        await context.read<UserVm>().loadUser(saved.id, forceRefresh: true);
      }
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _onRefresh,
      child: ListView(
        padding: EdgeInsets.zero,
        physics: const AlwaysScrollableScrollPhysics(), // kéo được dù ít nội dung
        children: const [
          SizedBox(height: 42),
          HomeHeader(),
          SizedBox(height: 0),
          CraetePost(),
          SizedBox(height: 10),
          PostList(),
          SizedBox(height: 60),
        ],
      ),
    );
  }
}
