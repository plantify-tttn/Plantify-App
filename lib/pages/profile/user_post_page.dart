import 'package:flutter/material.dart';
import 'package:plantify/pages/posts/user_post_list.dart';

class UserPostPage extends StatefulWidget {
  const UserPostPage({super.key});
  @override
  State<UserPostPage> createState() => _UserPostPageState();
}

class _UserPostPageState extends State<UserPostPage> {
  final ScrollController _scrollController = ScrollController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Scrollbar(
        controller: _scrollController,
        thumbVisibility: true, 
        interactive: true,
        child: ListView(
          controller: _scrollController,
          padding: EdgeInsets.zero,
          physics: const AlwaysScrollableScrollPhysics(), 
          children: [
            const SizedBox(height: 42),
            const UserPostList(),
            const SizedBox(height: 60),
          ],
        ),
      ),
    );
  }
}
