import 'package:mangxahoi/features/posts/domain/repositories/post_repository.dart';

class CreatePostUseCase {
  final PostRepository postRepository;

  CreatePostUseCase(this.postRepository);

  Future<void> call({
    required String userId,
    required String imagePath,
    required String caption,
  }) async {
    return postRepository.createPost(
      userId: userId,
      imagePath: imagePath,
      caption: caption,
    );
  }
}
