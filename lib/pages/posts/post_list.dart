import 'package:flutter/material.dart';
import 'package:plantify/models/post_model.dart';
import 'package:plantify/pages/posts/post_layout.dart';
import 'package:plantify/services/post_service.dart';

class PostList extends StatefulWidget {
  const PostList({super.key});

  @override
  State<PostList> createState() => _PostListState();
}

class _PostListState extends State<PostList> {
  final PostService postService = PostService();
  late Future<List<PostModel>> futurePosts;

  @override
  void initState() {
    super.initState();
    futurePosts = postService.getPosts(); // 👈 gọi GET API khi khởi tạo
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<PostModel>>(
      future: futurePosts,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Lỗi: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('Không có bài viết nào.'));
        }

        final posts = snapshot.data!;
        return ListView.builder(
          physics: NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          padding: EdgeInsets.zero,
          itemCount: posts.length,
          itemBuilder: (context, index){
            final post = posts[index];
            return PostLayout(post: post,);
          }
        );
      },
    );
  }
}
