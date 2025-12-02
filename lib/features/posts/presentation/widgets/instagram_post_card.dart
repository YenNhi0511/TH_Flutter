import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:mangxahoi/features/posts/domain/entities/post.dart';
import 'package:mangxahoi/core/providers/posts_provider.dart';
import 'package:mangxahoi/features/posts/presentation/pages/comments_page.dart';

/// Instagram-style enhanced PostCard with animations and better UX
class InstagramPostCard extends StatefulWidget {
  final Post post;
  final String currentUserId;

  const InstagramPostCard({
    super.key,
    required this.post,
    required this.currentUserId,
  });

  @override
  State<InstagramPostCard> createState() => _InstagramPostCardState();
}

class _InstagramPostCardState extends State<InstagramPostCard>
    with SingleTickerProviderStateMixin {
  late bool _isLiked;
  late int _likeCount;
  late AnimationController _likeAnimationController;
  late Animation<double> _likeAnimation;
  bool _showHeartAnimation = false;

  @override
  void initState() {
    super.initState();
    _isLiked = widget.post.isLikedByUser(widget.currentUserId);
    _likeCount = widget.post.likes.length;

    // Setup like animation
    _likeAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _likeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _likeAnimationController,
        curve: Curves.elasticOut,
      ),
    );
  }

  @override
  void dispose() {
    _likeAnimationController.dispose();
    super.dispose();
  }

  Future<void> _toggleLike() async {
    final postsProvider = context.read<PostsProvider>();

    setState(() {
      if (_isLiked) {
        _isLiked = false;
        _likeCount--;
      } else {
        _isLiked = true;
        _likeCount++;
        // Show heart animation
        _showHeartAnimation = true;
        _likeAnimationController.forward().then((_) {
          Future.delayed(const Duration(milliseconds: 400), () {
            if (mounted) {
              setState(() {
                _showHeartAnimation = false;
              });
              _likeAnimationController.reset();
            }
          });
        });
      }
    });

    if (_isLiked) {
      postsProvider.likePost(widget.post.id, widget.currentUserId);
    } else {
      postsProvider.unlikePost(widget.post.id, widget.currentUserId);
    }
  }

  Future<void> _deletePost() async {
    if (widget.post.userId != widget.currentUserId) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Bạn không có quyền xóa bài viết này'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Xóa bài viết'),
        content: const Text('Bạn có chắc muốn xóa bài viết này không?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Xóa'),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      context.read<PostsProvider>().deletePost(
        widget.post.id,
        widget.post.userId,
      );
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Đã xóa bài viết'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  String _getTimeAgo(DateTime createdAt) {
    final difference = DateTime.now().difference(createdAt);

    if (difference.inSeconds < 60) {
      return 'vừa xong';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} phút trước';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} giờ trước';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} ngày trước';
    } else if (difference.inDays < 30) {
      final weeks = (difference.inDays / 7).floor();
      return '$weeks tuần trước';
    } else {
      return DateFormat('dd/MM/yyyy').format(createdAt);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        border: Border(
          bottom: BorderSide(
            color: Colors.grey.withValues(alpha: 0.2),
            width: 0.5,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header - User info
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Row(
              children: [
                // Avatar with gradient border (Instagram story-like)
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [
                        Colors.purple.shade400,
                        Colors.pink.shade400,
                        Colors.orange.shade400,
                      ],
                    ),
                  ),
                  padding: const EdgeInsets.all(2),
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Theme.of(context).scaffoldBackgroundColor,
                    ),
                    padding: const EdgeInsets.all(2),
                    child: CircleAvatar(
                      radius: 16,
                      backgroundImage: widget.post.userPhotoUrl != null
                          ? CachedNetworkImageProvider(
                              widget.post.userPhotoUrl!,
                            )
                          : null,
                      child: widget.post.userPhotoUrl == null
                          ? const Icon(Icons.person, size: 18)
                          : null,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                // Username & location
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.post.userName,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                      if (widget.post.caption != null &&
                          widget.post.caption!.isNotEmpty)
                        Text(
                          'Photo',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey[600],
                          ),
                        ),
                    ],
                  ),
                ),
                // More options
                IconButton(
                  icon: const Icon(Icons.more_vert, size: 20),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  onPressed: () {
                    showModalBottomSheet(
                      context: context,
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(16),
                        ),
                      ),
                      builder: (context) => SafeArea(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (widget.post.userId == widget.currentUserId) ...[
                              ListTile(
                                leading: const Icon(
                                  Icons.delete,
                                  color: Colors.red,
                                ),
                                title: const Text(
                                  'Xóa',
                                  style: TextStyle(color: Colors.red),
                                ),
                                onTap: () {
                                  Navigator.pop(context);
                                  _deletePost();
                                },
                              ),
                              ListTile(
                                leading: const Icon(Icons.edit),
                                title: const Text('Chỉnh sửa'),
                                onTap: () {
                                  Navigator.pop(context);
                                  // TODO: Implement edit
                                },
                              ),
                            ] else ...[
                              ListTile(
                                leading: const Icon(
                                  Icons.report,
                                  color: Colors.red,
                                ),
                                title: const Text('Báo cáo'),
                                onTap: () {
                                  Navigator.pop(context);
                                  // TODO: Implement report
                                },
                              ),
                              ListTile(
                                leading: const Icon(Icons.block),
                                title: const Text('Chặn'),
                                onTap: () {
                                  Navigator.pop(context);
                                  // TODO: Implement block
                                },
                              ),
                            ],
                            ListTile(
                              leading: const Icon(Icons.link),
                              title: const Text('Sao chép liên kết'),
                              onTap: () {
                                Navigator.pop(context);
                                // TODO: Implement copy link
                              },
                            ),
                            const SizedBox(height: 8),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),

          // Image with double-tap to like
          GestureDetector(
            onDoubleTap: () {
              if (!_isLiked) {
                _toggleLike();
              }
            },
            child: Stack(
              alignment: Alignment.center,
              children: [
                CachedNetworkImage(
                  imageUrl: widget.post.imageUrl,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(
                    height: 400,
                    color: Colors.grey[300],
                    child: const Center(
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  ),
                  errorWidget: (context, url, error) => Container(
                    height: 400,
                    color: Colors.grey[300],
                    child: const Icon(Icons.error, color: Colors.red),
                  ),
                ),
                // Heart animation overlay
                if (_showHeartAnimation)
                  ScaleTransition(
                    scale: _likeAnimation,
                    child: const Icon(
                      Icons.favorite,
                      size: 100,
                      color: Colors.white,
                    ),
                  ),
              ],
            ),
          ),

          // Actions - Like, Comment, Share, Save
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Row(
              children: [
                // Like button with animation
                IconButton(
                  icon: Icon(
                    _isLiked ? Icons.favorite : Icons.favorite_border,
                    color: _isLiked ? Colors.red : Colors.black,
                    size: 28,
                  ),
                  onPressed: _toggleLike,
                ),
                // Comment button
                IconButton(
                  icon: const Icon(Icons.mode_comment_outlined, size: 26),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CommentsPage(post: widget.post),
                      ),
                    );
                  },
                ),
                // Share button
                IconButton(
                  icon: const Icon(Icons.send_outlined, size: 26),
                  onPressed: () {
                    // TODO: Implement share
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Tính năng chia sẻ sắp ra mắt'),
                        duration: Duration(seconds: 1),
                      ),
                    );
                  },
                ),
                const Spacer(),
                // Save button
                IconButton(
                  icon: const Icon(Icons.bookmark_border, size: 26),
                  onPressed: () {
                    // TODO: Implement save
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Đã lưu bài viết'),
                        duration: Duration(seconds: 1),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),

          // Like count
          if (_likeCount > 0)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: Text(
                '$_likeCount lượt thích',
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ),

          // Caption
          if (widget.post.caption != null && widget.post.caption!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
              child: RichText(
                text: TextSpan(
                  style: DefaultTextStyle.of(context).style,
                  children: [
                    TextSpan(
                      text: widget.post.userName,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                    const TextSpan(text: ' '),
                    TextSpan(
                      text: widget.post.caption,
                      style: const TextStyle(fontSize: 14),
                    ),
                  ],
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),

          // View all comments
          if (widget.post.commentCount > 0)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
              child: GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CommentsPage(post: widget.post),
                    ),
                  );
                },
                child: Text(
                  'Xem tất cả ${widget.post.commentCount} bình luận',
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
              ),
            ),

          // Time ago
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
            child: Text(
              _getTimeAgo(widget.post.createdAt).toUpperCase(),
              style: TextStyle(
                fontSize: 10,
                color: Colors.grey[600],
                letterSpacing: 0.2,
              ),
            ),
          ),

          const SizedBox(height: 8),
        ],
      ),
    );
  }
}
