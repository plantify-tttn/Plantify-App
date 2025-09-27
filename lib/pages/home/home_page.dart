import 'package:flutter/material.dart';
import 'package:plantify/pages/home/home_header.dart';
import 'package:plantify/pages/posts/craete_post.dart';
import 'package:plantify/pages/posts/post_list.dart';
import 'package:plantify/provider/post_provider.dart';
import 'package:plantify/provider/user_vm.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _onRefresh() async {
    await context.read<UserVm>().getAllUsers();
    await context.read<PostProvider>().getPosts(force: true);
  }

  Future<void> _loadMore() async {
    try {
      await context.read<PostProvider>().loadMorePost();
    } finally {}
  }

  void _onScroll() {
    const double epsilon = 24.0;
    final position = _scrollController.position;
    if (position.pixels >= position.maxScrollExtent - epsilon) {
      _loadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _onRefresh,
      child: Scrollbar(
        controller: _scrollController,
        thumbVisibility: true, 
        interactive: true,
        child: ListView(
          controller: _scrollController,
          padding: EdgeInsets.zero,
          physics:
              const AlwaysScrollableScrollPhysics(),
          children: [
            const SizedBox(height: 42),
            const HomeHeader(),
            const SizedBox(height: 0),
            const CreatePost(),
            const SizedBox(height: 10),
            const PostList(),
            const SizedBox(height: 60),
          ],
        ),
      ),
    );
  }
}
