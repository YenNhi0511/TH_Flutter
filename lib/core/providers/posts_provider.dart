import 'package:flutter/material.dart';
import 'package:mangxahoi/features/posts/domain/entities/post.dart';
import 'package:mangxahoi/features/posts/data/datasources/remote_post_datasource.dart';

class PostsProvider with ChangeNotifier {
  final RemotePostDatasource _datasource;
  List<Post> _posts = [];
  bool _isLoading = false;
  String? _errorMessage;

  PostsProvider({RemotePostDatasource? datasource})
    : _datasource = datasource ?? RemotePostDatasource();

  List<Post> get posts => _posts;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> loadPosts() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _posts = await _datasource.getPosts();
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> createPost({
    required String userId,
    required String userName,
    required String? userPhotoUrl,
    required String imagePath,
    required String? caption,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _datasource.createPost(
        userId: userId,
        userName: userName,
        userPhotoUrl: userPhotoUrl,
        imagePath: imagePath,
        caption: caption,
      );
      await loadPosts();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> likePost(String postId, String userId) async {
    try {
      // Optimistic update
      final postIndex = _posts.indexWhere((p) => p.id == postId);
      if (postIndex != -1) {
        _posts[postIndex] = _posts[postIndex].copyWith(
          likes: [..._posts[postIndex].likes, userId],
        );
        notifyListeners();
      }

      await _datasource.likePost(postId: postId, userId: userId);
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      // Revert optimistic update
      await loadPosts();
    }
  }

  Future<void> unlikePost(String postId, String userId) async {
    try {
      // Optimistic update
      final postIndex = _posts.indexWhere((p) => p.id == postId);
      if (postIndex != -1) {
        _posts[postIndex] = _posts[postIndex].copyWith(
          likes: _posts[postIndex].likes.where((uid) => uid != userId).toList(),
        );
        notifyListeners();
      }

      await _datasource.unlikePost(postId: postId, userId: userId);
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      // Revert optimistic update
      await loadPosts();
    }
  }

  Future<void> deletePost(String postId, String userId) async {
    try {
      _posts.removeWhere((p) => p.id == postId);
      notifyListeners();

      await _datasource.deletePost(postId);
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      await loadPosts();
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
