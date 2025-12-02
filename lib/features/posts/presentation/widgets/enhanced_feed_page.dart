import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mangxahoi/core/providers/posts_provider.dart';
import 'package:mangxahoi/core/providers/auth_provider.dart';
import 'package:mangxahoi/features/posts/presentation/widgets/instagram_post_card.dart';
import 'package:mangxahoi/features/posts/presentation/widgets/stories_bar.dart';
// Import the new components (make sure to create these files)
// import 'package:mangxahoi/features/posts/presentation/widgets/instagram_post_card.dart';
// import 'package:mangxahoi/features/posts/presentation/widgets/stories_bar.dart';

/// Enhanced Feed Page with Instagram-style UI
class EnhancedFeedPage extends StatefulWidget {
  const EnhancedFeedPage({super.key});

  @override
  State<EnhancedFeedPage> createState() => _EnhancedFeedPageState();
}

class _EnhancedFeedPageState extends State<EnhancedFeedPage> {
  final ScrollController _scrollController = ScrollController();
  bool _showAppBarTitle = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PostsProvider>().loadPosts();
    });

    // Show/hide app bar title based on scroll
    _scrollController.addListener(() {
      if (_scrollController.offset > 50 && !_showAppBarTitle) {
        setState(() {
          _showAppBarTitle = true;
        });
      } else if (_scrollController.offset <= 50 && _showAppBarTitle) {
        setState(() {
          _showAppBarTitle = false;
        });
      }
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
    final currentUser = context.watch<AuthProvider>().currentUser;

    return Scaffold(
      // Instagram-style app bar
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Instagram',
          style: TextStyle(
            fontFamily: 'Cursive',
            fontSize: 28,
            fontWeight: FontWeight.w400,
            color: Colors.black,
          ),
        ),
        actions: [
          // Notifications
          IconButton(
            icon: Stack(
              children: [
                const Icon(
                  Icons.favorite_border,
                  size: 28,
                  color: Colors.black,
                ),
                // Notification badge
                Positioned(
                  top: 0,
                  right: 0,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: Color(0xFFFF3B5C),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ],
            ),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Row(
                    children: [
                      Icon(Icons.info_outline, color: Colors.white),
                      SizedBox(width: 8),
                      Text('Tính năng thông báo sắp ra mắt'),
                    ],
                  ),
                  backgroundColor: Colors.black87,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  duration: const Duration(seconds: 2),
                ),
              );
            },
          ),
          // Direct messages
          IconButton(
            icon: Stack(
              children: [
                const Icon(Icons.send_outlined, size: 28, color: Colors.black),
                // Message badge
                Positioned(
                  top: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: const BoxDecoration(
                      color: Color(0xFFFF3B5C),
                      shape: BoxShape.circle,
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 16,
                      minHeight: 16,
                    ),
                    child: const Text(
                      '3',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ],
            ),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Row(
                    children: [
                      Icon(Icons.info_outline, color: Colors.white),
                      SizedBox(width: 8),
                      Text('Tính năng tin nhắn sắp ra mắt'),
                    ],
                  ),
                  backgroundColor: Colors.black87,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  duration: const Duration(seconds: 2),
                ),
              );
            },
          ),
          const SizedBox(width: 8),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(0.5),
          child: Container(color: Colors.grey[300], height: 0.5),
        ),
      ),

      body: Consumer<PostsProvider>(
        builder: (context, postsProvider, child) {
          if (postsProvider.isLoading && postsProvider.posts.isEmpty) {
            return const Center(
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Color(0xFF0095F6),
              ),
            );
          }

          if (postsProvider.errorMessage != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.red[50],
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.error_outline,
                      size: 48,
                      color: Colors.red[400],
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Có lỗi xảy ra',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 40),
                    child: Text(
                      postsProvider.errorMessage!,
                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () => postsProvider.loadPosts(),
                    icon: const Icon(Icons.refresh),
                    label: const Text('Thử lại'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0095F6),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }

          if (postsProvider.posts.isEmpty) {
            return RefreshIndicator(
              onRefresh: _onRefresh,
              color: const Color(0xFF0095F6),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: SizedBox(
                  height: MediaQuery.of(context).size.height - 200,
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(30),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.grey[300]!,
                              width: 3,
                            ),
                          ),
                          child: Icon(
                            Icons.camera_alt_outlined,
                            size: 60,
                            color: Colors.grey[400],
                          ),
                        ),
                        const SizedBox(height: 24),
                        const Text(
                          'Chưa có bài viết nào',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w600,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Hãy đăng bài đầu tiên của bạn',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 32),
                        Container(
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [
                                Color(0xFF833AB4),
                                Color(0xFFE1306C),
                                Color(0xFFFD1D1D),
                                Color(0xFFF77737),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: ElevatedButton.icon(
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: const Row(
                                    children: [
                                      Icon(
                                        Icons.arrow_downward,
                                        color: Colors.white,
                                      ),
                                      SizedBox(width: 8),
                                      Text('Nhấn nút + ở dưới để đăng bài'),
                                    ],
                                  ),
                                  backgroundColor: Colors.black87,
                                  behavior: SnackBarBehavior.floating,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  duration: const Duration(seconds: 2),
                                ),
                              );
                            },
                            icon: const Icon(
                              Icons.add_photo_alternate,
                              color: Colors.white,
                            ),
                            label: const Text(
                              'Đăng bài mới',
                              style: TextStyle(color: Colors.white),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 12,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: _onRefresh,
            child: CustomScrollView(
              controller: _scrollController,
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                // Stories section (would use StoriesBar widget)
                SliverToBoxAdapter(
                  child: Container(
                    height: 110,
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: Theme.of(context).scaffoldBackgroundColor,
                      border: Border(
                        bottom: BorderSide(
                          color: Colors.grey.withValues(alpha: 0.2),
                          width: 0.5,
                        ),
                      ),
                    ),
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      children: [
                        // Your story placeholder
                        _buildStoryItem(
                          context,
                          'Story của bạn',
                          currentUser?.photoUrl,
                          isYourStory: true,
                        ),
                        // Mock stories
                        _buildStoryItem(context, 'user_1', null),
                        _buildStoryItem(context, 'user_2', null),
                        _buildStoryItem(context, 'user_3', null),
                        _buildStoryItem(context, 'user_4', null),
                        _buildStoryItem(context, 'user_5', null),
                      ],
                    ),
                  ),
                ),

                // Posts list using InstagramPostCard
                SliverList(
                  delegate: SliverChildBuilderDelegate((context, index) {
                    final post = postsProvider.posts[index];
                    return InstagramPostCard(
                      post: post,
                      currentUserId: currentUser?.id ?? '',
                    );
                  }, childCount: postsProvider.posts.length),
                ),

                // Loading indicator at bottom
                if (postsProvider.isLoading)
                  const SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.all(20),
                      child: Center(
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    ),
                  ),

                // Bottom padding
                const SliverToBoxAdapter(child: SizedBox(height: 80)),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildStoryItem(
    BuildContext context,
    String userName,
    String? userPhoto, {
    bool isYourStory = false,
  }) {
    return GestureDetector(
      onTap: () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Xem story của $userName'),
            duration: const Duration(seconds: 1),
          ),
        );
      },
      child: Container(
        width: 70,
        margin: const EdgeInsets.symmetric(horizontal: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              children: [
                Container(
                  width: 66,
                  height: 66,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: !isYourStory
                        ? LinearGradient(
                            colors: [
                              Colors.purple.shade400,
                              Colors.pink.shade400,
                              Colors.orange.shade400,
                            ],
                          )
                        : null,
                    border: isYourStory
                        ? Border.all(
                            color: Colors.grey.withValues(alpha: 0.3),
                            width: 2,
                          )
                        : null,
                  ),
                  padding: const EdgeInsets.all(2.5),
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Theme.of(context).scaffoldBackgroundColor,
                    ),
                    padding: const EdgeInsets.all(2),
                    child: CircleAvatar(
                      radius: 28,
                      child: const Icon(Icons.person, size: 30),
                    ),
                  ),
                ),
                if (isYourStory)
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        color: Colors.blue,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Theme.of(context).scaffoldBackgroundColor,
                          width: 2,
                        ),
                      ),
                      child: const Icon(
                        Icons.add,
                        size: 12,
                        color: Colors.white,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              userName,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 12),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
