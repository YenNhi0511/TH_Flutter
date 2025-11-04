import 'package:mangxahoi/features/posts/domain/entities/post.dart';
import 'package:mangxahoi/features/posts/domain/repositories/post_repository.dart';

class GetPostsUseCase {
  final PostRepository postRepository;

  GetPostsUseCase(this.postRepository);

  Future<List<Post>> call() async {
    return postRepository.getPosts();
  }
}
