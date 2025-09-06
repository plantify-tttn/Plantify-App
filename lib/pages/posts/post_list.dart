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
      builder: (context, postProvider, child){
        return ListView.builder(
          physics: NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          padding: EdgeInsets.zero,
          itemCount: postProvider.listedPost.length + (postProvider.isLoadingMore || !postProvider.hasMore ? 1 : 0),
          itemBuilder: (context, index){
            final len = postProvider.listedPost.length;
            if (index == len) {
              if (postProvider.isLoadingMore) {
                return CircularProgressIndicator();
              }
              if (!postProvider.hasMore) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Center(child: Text('No more post')),
                );
              }
            }
            final post = postProvider.listedPost[index];
            return PostLayout(post: post,);
          }
        );
      }
    );
  }
}
