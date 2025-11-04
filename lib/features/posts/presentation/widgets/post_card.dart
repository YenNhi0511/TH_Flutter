import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:mangxahoi/features/posts/domain/entities/post.dart';
import 'package:mangxahoi/core/providers/posts_provider.dart';

class PostCard extends StatefulWidget {
  final Post post;
  final String currentUserId;

  const PostCard({super.key, required this.post, required this.currentUserId});

  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> {
  late bool _isLiked;
  late int _likeCount;
  late int _commentCount;

  @override
  void initState() {
    super.initState();
    _isLiked = widget.post.isLikedByUser(widget.currentUserId);
    _likeCount = widget.post.likes.length;
    _commentCount = widget.post.commentCount ?? 0;
  }

  Future<void> toggleLike() async {
    final postsProvider = context.read<PostsProvider>();

    setState(() {
      if (_isLiked) {
        _isLiked = false;
        _likeCount--;
      } else {
        _isLiked = true;
        _likeCount++;
      }
    });

    if (_isLiked) {
      postsProvider.likePost(widget.post.id, widget.currentUserId);
    } else {
      postsProvider.unlikePost(widget.post.id, widget.currentUserId);
    }
  }

  Future<void> deletePost() async {
    if (widget.post.userId != widget.currentUserId) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Bạn không có quyền xóa bài viết này')),
      );
      return;
    }

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xóa bài viết'),
        content: const Text('Bạn có chắc muốn xóa bài viết này?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Xóa'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      context.read<PostsProvider>().deletePost(
        widget.post.id,
        widget.post.userId,
      );
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Đã xóa bài viết')));
      }
    }
  }

  String getTimeAgo(DateTime createdAt) {
    final difference = DateTime.now().difference(createdAt);

    if (difference.inSeconds < 60) {
      return 'vừa xong';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}p';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d';
    } else {
      return DateFormat('dd/MM/yyyy').format(createdAt);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(
          bottom: BorderSide(
            color: Colors.grey.withValues(alpha: 0.1),
            width: 1,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header - User info
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    // Avatar
                    CircleAvatar(
                      radius: 20,
                      backgroundImage: widget.post.userPhotoUrl != null
                          ? CachedNetworkImageProvider(
                              widget.post.userPhotoUrl!,
                            )
                          : null,
                      child: widget.post.userPhotoUrl == null
                          ? const Icon(Icons.person)
                          : null,
                    ),
                    const SizedBox(width: 12),
                    // Username & time
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.post.userName,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        Text(
                          getTimeAgo(widget.post.createdAt),
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                // Menu button
                if (widget.post.userId == widget.currentUserId)
                  PopupMenuButton(
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        child: const Row(
                          children: [
                            Icon(Icons.delete, size: 20),
                            SizedBox(width: 10),
                            Text('Xóa'),
                          ],
                        ),
                        onTap: deletePost,
                      ),
                    ],
                  )
                else
                  IconButton(
                    icon: const Icon(Icons.more_vert),
                    onPressed: () {
                      // TODO: Report post
                    },
                  ),
              ],
            ),
          ),
          // Image
          ClipRRect(
            child: CachedNetworkImage(
              imageUrl: widget.post.imageUrl,
              placeholder: (context, url) => Container(
                height: 300,
                color: Colors.grey[300],
                child: const Center(child: CircularProgressIndicator()),
              ),
              errorWidget: (context, url, error) => Container(
                height: 300,
                color: Colors.grey[300],
                child: const Center(child: Icon(Icons.error)),
              ),
              height: 300,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
          // Actions - Like, Comment, Share
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    // Like button
                    IconButton(
                      icon: Icon(
                        _isLiked ? Icons.favorite : Icons.favorite_border,
                        color: _isLiked ? Colors.red : Colors.grey,
                      ),
                      onPressed: toggleLike,
                    ),
                    // Comment button
                    IconButton(
                      icon: const Icon(Icons.comment_outlined),
                      onPressed: () {
                        // TODO: Show comments
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Comment feature coming soon'),
                          ),
                        );
                      },
                    ),
                    // Share button
                    IconButton(
                      icon: const Icon(Icons.share_outlined),
                      onPressed: () {
                        // TODO: Share post
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Share feature coming soon'),
                          ),
                        );
                      },
                    ),
                  ],
                ),
                // Save button
                IconButton(
                  icon: const Icon(Icons.bookmark_border),
                  onPressed: () {
                    // TODO: Save post
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Save feature coming soon')),
                    );
                  },
                ),
              ],
            ),
          ),
          // Like count
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            child: Text(
              '$_likeCount lượt thích',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
          ),
          const SizedBox(height: 4),
          // Caption
          if (widget.post.caption != null && widget.post.caption!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              child: RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: widget.post.userName,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                        fontSize: 14,
                      ),
                    ),
                    const TextSpan(text: ' '),
                    TextSpan(
                      text: widget.post.caption,
                      style: const TextStyle(color: Colors.black, fontSize: 14),
                    ),
                  ],
                ),
              ),
            ),
          const SizedBox(height: 4),
          // Comment preview
          if (_commentCount > 0)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              child: GestureDetector(
                onTap: () {
                  // TODO: Show all comments
                },
                child: Text(
                  'Xem tất cả $_commentCount bình luận',
                  style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                ),
              ),
            ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}
