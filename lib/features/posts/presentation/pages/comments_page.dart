import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import 'package:mangxahoi/core/providers/auth_provider.dart';
import 'package:mangxahoi/features/posts/data/datasources/remote_post_datasource.dart';
import 'package:mangxahoi/features/posts/domain/entities/post.dart';
import 'package:mangxahoi/features/posts/domain/entities/comment.dart';

/// Instagram-style Comments Page
class CommentsPage extends StatefulWidget {
  final Post post;

  const CommentsPage({super.key, required this.post});

  @override
  State<CommentsPage> createState() => _CommentsPageState();
}

class _CommentsPageState extends State<CommentsPage> {
  final TextEditingController _commentController = TextEditingController();
  final RemotePostDatasource _datasource = RemotePostDatasource();
  bool _isLoading = false;
  bool _isPosting = false;
  List<Comment> _comments = [];

  @override
  void initState() {
    super.initState();
    _loadComments();
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _loadComments() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final comments = await _datasource.getComments(widget.post.id);
      if (mounted) {
        setState(() {
          _comments = comments;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi tải bình luận: ${e.toString()}')),
        );
      }
    }
  }

  Future<void> _postComment() async {
    if (_commentController.text.trim().isEmpty) return;

    final currentUser = context.read<AuthProvider>().currentUser;
    if (currentUser == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Vui lòng đăng nhập')));
      return;
    }

    setState(() {
      _isPosting = true;
    });

    try {
      await _datasource.addComment(
        postId: widget.post.id,
        userId: currentUser.id,
        userName: currentUser.displayName ?? currentUser.email,
        userPhotoUrl: currentUser.photoUrl ?? '',
        text: _commentController.text.trim(),
      );

      _commentController.clear();

      // Reload comments
      await _loadComments();

      if (mounted) {
        setState(() {
          _isPosting = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isPosting = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi đăng bình luận: ${e.toString()}')),
        );
      }
    }
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);

    if (difference.inSeconds < 60) {
      return 'vừa xong';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}p';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d';
    } else {
      return DateFormat('dd/MM/yyyy').format(time);
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = context.watch<AuthProvider>().currentUser;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Bình luận'),
        centerTitle: false,
      ),
      body: Column(
        children: [
          // Post header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: Colors.grey.withValues(alpha: 0.2),
                  width: 0.5,
                ),
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // User avatar
                CircleAvatar(
                  radius: 18,
                  backgroundImage: widget.post.userPhotoUrl != null
                      ? CachedNetworkImageProvider(widget.post.userPhotoUrl!)
                      : null,
                  child: widget.post.userPhotoUrl == null
                      ? const Icon(Icons.person, size: 20)
                      : null,
                ),
                const SizedBox(width: 12),
                // Post info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            widget.post.userName,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            _formatTime(widget.post.createdAt),
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                      if (widget.post.caption != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          widget.post.caption!,
                          style: const TextStyle(fontSize: 14),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Comments list
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _comments.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.comment_outlined,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Chưa có bình luận nào',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Hãy là người đầu tiên bình luận',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    itemCount: _comments.length,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    itemBuilder: (context, index) {
                      final comment = _comments[index];
                      final commentTime = comment.createdAt;
                      return Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Commenter avatar
                            CircleAvatar(
                              radius: 18,
                              backgroundImage: comment.userPhotoUrl.isNotEmpty
                                  ? CachedNetworkImageProvider(
                                      comment.userPhotoUrl,
                                    )
                                  : null,
                              child: comment.userPhotoUrl.isEmpty
                                  ? const Icon(Icons.person, size: 20)
                                  : null,
                            ),
                            const SizedBox(width: 12),
                            // Comment content
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        comment.userName,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 14,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        _formatTime(commentTime),
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    comment.text,
                                    style: const TextStyle(fontSize: 14),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),

          // Comment input
          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              border: Border(
                top: BorderSide(
                  color: Colors.grey.withValues(alpha: 0.2),
                  width: 0.5,
                ),
              ),
            ),
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: Row(
                  children: [
                    // Current user avatar
                    CircleAvatar(
                      radius: 18,
                      backgroundImage: currentUser?.photoUrl != null
                          ? CachedNetworkImageProvider(currentUser!.photoUrl!)
                          : null,
                      child: currentUser?.photoUrl == null
                          ? const Icon(Icons.person, size: 20)
                          : null,
                    ),
                    const SizedBox(width: 12),
                    // Text field
                    Expanded(
                      child: TextField(
                        controller: _commentController,
                        decoration: InputDecoration(
                          hintText: 'Viết bình luận...',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(24),
                            borderSide: BorderSide(
                              color: Colors.grey.withValues(alpha: 0.3),
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(24),
                            borderSide: BorderSide(
                              color: Colors.grey.withValues(alpha: 0.3),
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(24),
                            borderSide: const BorderSide(
                              color: Color(0xFF6366F1),
                            ),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 10,
                          ),
                        ),
                        maxLines: null,
                        textInputAction: TextInputAction.send,
                        onSubmitted: (_) => _postComment(),
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Send button
                    _isPosting
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : IconButton(
                            onPressed: _postComment,
                            icon: Icon(
                              Icons.send,
                              color: _commentController.text.trim().isEmpty
                                  ? Colors.grey
                                  : const Color(0xFF6366F1),
                            ),
                          ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
