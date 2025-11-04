import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mangxahoi/core/providers/posts_provider.dart';
import 'package:mangxahoi/core/providers/auth_provider.dart';
import 'package:mangxahoi/features/posts/presentation/widgets/post_card.dart';

class FeedPage extends StatefulWidget {
  const FeedPage({super.key});

  @override
  State<FeedPage> createState() => _FeedPageState();
}

class _FeedPageState extends State<FeedPage> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PostsProvider>().loadPosts();
    });
  }

  Future<void> _onRefresh() async {
    await context.read<PostsProvider>().loadPosts();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Chia Sẻ Ảnh',
          style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
        ),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.favorite_border),
            onPressed: () {
              // TODO: Show notifications
            },
          ),
          IconButton(
            icon: const Icon(Icons.send),
            onPressed: () {
              // TODO: Show messages
            },
          ),
        ],
      ),
      body: Consumer<PostsProvider>(
        builder: (context, postsProvider, child) {
          if (postsProvider.isLoading && postsProvider.posts.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (postsProvider.posts.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.image_not_supported,
                    size: 80,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Không có bài viết nào',
                    style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: _onRefresh,
            child: ListView.builder(
              controller: _scrollController,
              itemCount: postsProvider.posts.length,
              itemBuilder: (context, index) {
                final post = postsProvider.posts[index];
                return PostCard(
                  post: post,
                  currentUserId:
                      context.read<AuthProvider>().currentUser?.id ?? '',
                );
              },
            ),
          );
        },
      ),
    );
  }
}
