import 'package:mangxahoi/features/posts/domain/entities/post.dart';

abstract class PostRepository {
  Future<void> createPost({
    required String userId,
    required String imagePath,
    required String caption,
  });

  Future<List<Post>> getPosts();

  Future<void> deletePost({required String postId});

  Future<void> likePost({required String postId});

  Future<void> unlikePost({required String postId});
}
