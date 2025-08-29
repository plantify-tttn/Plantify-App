import 'dart:io';
import 'package:flutter/material.dart';
import 'package:plantify/models/post_model.dart';
import 'package:plantify/services/post_service.dart';
import 'package:plantify/services/user_service.dart';

class PostProvider extends ChangeNotifier {

  final Map<String, (List<PostModel> data,)> _cache = {};

  String _key(int page) =>
      'p=$page';
  String _uKey(int page) => 'p=$page';

  final _service = PostService();
  final List<PostModel> _listedPost = [];
  List<PostModel> get listedPost => _listedPost;
  final List<PostModel> _ulistedPost = [];
  List<PostModel> get ulistedPost => _ulistedPost;
  final List<PostModel> _posts = [];
  int _currentPage = 1;
  bool _isLoadingMore = false;
  bool get isLoadingMore => _isLoadingMore;
  bool _isLoading = false;
  bool get isLoading => _isLoading;
  bool hasMore = true;


  Future<void> getPosts({
    bool force = false
  }) async {
    final key = _key(1);
    if (force) {
      _cache.remove(key);
      hasMore = true;
      _currentPage = 1;
      notifyListeners();
    }
    final cached = _cache[key];
    List<PostModel> data;
    if (cached != null) {
      data = cached.$1;
    }
    _isLoading = true;
    notifyListeners();
    try{
      data = await _service.fetchAndSavePosts();
      _apply(data);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  Future<void> getUPosts({
    bool force = false
  }) async {
    try{
      final token = UserService.getToken();
      final data = await _service.fetchUPosts(token: token);
      _ulistedPost
        ..clear()
        ..addAll(data);
      notifyListeners();
    } finally {
    }
  }
  Future<void> loadMorePost() async{
    if (!hasMore || isLoadingMore) return;
    _isLoadingMore = true;
    final nextPage = _currentPage + 1;
    final key = _key(nextPage);
    final cached = _cache[key];
    List<PostModel> data;
    if (cached != null) {
      data = cached.$1;
    }
    try{
      data = await _service.fetchAndSavePosts(
        page: nextPage
      );
      if (data.isEmpty) {
        hasMore = false;
      } else {
        _currentPage = nextPage;
        _append(data);
      }
    } finally{
      _isLoadingMore = false;
      notifyListeners();
    }
  }
  Future<void> craetePost({
    required String content,
    required File image,
  }) async {
    try{
      final token = await UserService.getToken();
      await PostService().createPost(
        content: content, 
        image: image, 
        token: token
      );
      await getPosts(force: true);
    }finally{
    }
  }

  void _apply(List<PostModel> data) {
    _posts
      ..clear()
      ..addAll(data);
    _listedPost
      ..clear()
      ..addAll(_posts);
    notifyListeners();
  }

  void _append(List<PostModel> data) {
    _posts.addAll(data);
    _listedPost
      ..clear()
      ..addAll(_posts);
    notifyListeners();
  }
}