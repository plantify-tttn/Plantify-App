import 'package:flutter/material.dart';
import 'package:plantify/pages/posts/widgets/post_main.dart';
import 'package:plantify/pages/posts/widgets/user_post.dart';

class PostLayout extends StatelessWidget {
  const PostLayout({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        UserPost(),
        PostMain(),
      ],
    );
  }
}