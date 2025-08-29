import 'package:flutter/material.dart';
import 'package:plantify/pages/posts/post_layout.dart';
import 'package:plantify/provider/post_provider.dart';
import 'package:provider/provider.dart';

class UserPostList extends StatefulWidget {
  const UserPostList({super.key});

  @override
  State<UserPostList> createState() => _UserPostListState();
}

class _UserPostListState extends State<UserPostList> {
   @override
  void initState() {
    super.initState();
    // Defer to post-frame so notifyListeners won't run during build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<PostProvider>().getUPosts();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<PostProvider>(
      builder: (context, postProvider, child){
        return ListView.builder(
          physics: NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          padding: EdgeInsets.zero,
          itemCount: postProvider.ulistedPost.length,
          itemBuilder: (context, index){
            final len = postProvider.ulistedPost.length;
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
            final post = postProvider.ulistedPost[index];
            return PostLayout(post: post,);
          }
        );
      }
    );
  }
}
