import 'package:flutter/material.dart';
import 'package:plantify/models/post_model.dart';
import 'package:plantify/pages/posts/widgets/post_main.dart';
import 'package:plantify/pages/posts/widgets/user_post.dart';

class PostLayout extends StatelessWidget {
  final PostModel post;
  const PostLayout({super.key, required this.post});

  @override
  Widget build(BuildContext context) {
    return Column(
      key: ValueKey('layout_${post.id}'), 
      children: [
        UserPost(
          key: ValueKey('user_${post.id}'),
          post: post,
        ),
        PostMain(
          key: ValueKey('main_${post.id}'), 
          post: post,
        ),
      ],
    );
  }
}
