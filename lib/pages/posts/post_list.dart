import 'package:flutter/material.dart';
import 'package:plantify/pages/posts/post_layout.dart';
import 'package:plantify/provider/post_provider.dart';
import 'package:provider/provider.dart';

class PostList extends StatefulWidget {
  const PostList({super.key});

  @override
  State<PostList> createState() => _PostListState();
}

class _PostListState extends State<PostList> {
  @override
  Widget build(BuildContext context) {
    return Consumer<PostProvider>(
      builder: (context, postProvider, child) {
        final items = postProvider.listedPost;
        final showFooter = postProvider.isLoadingMore || !postProvider.hasMore;

        return ListView.builder(
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          padding: EdgeInsets.zero,
          itemCount: items.length + (showFooter ? 1 : 0),
          itemBuilder: (context, index) {
            if (index == items.length) {
              if (postProvider.isLoadingMore) {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  child: Center(child: CircularProgressIndicator()),
                );
              }
              if (!postProvider.hasMore) {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  child: Center(child: Text('No more post')),
                );
              }
            }

            final post = items[index];
            return PostLayout(
              key: ValueKey(post.id),
              post: post,
            );
          },
        );
      },
    );
  }
}
