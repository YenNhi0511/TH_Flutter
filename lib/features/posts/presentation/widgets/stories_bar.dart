import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

/// Instagram-style Stories horizontal bar
class StoriesBar extends StatelessWidget {
  final String currentUserId;
  final String? currentUserPhoto;
  final String currentUserName;

  const StoriesBar({
    super.key,
    required this.currentUserId,
    this.currentUserPhoto,
    required this.currentUserName,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
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
          // Your story (add new)
          _StoryItem(
            userName: 'Story của bạn',
            userPhoto: currentUserPhoto,
            isYourStory: true,
            hasStory: false,
            onTap: () {
              // TODO: Navigate to create story
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Tính năng Story sắp ra mắt'),
                  duration: Duration(seconds: 1),
                ),
              );
            },
          ),
          // Mock stories from other users
          ..._getMockStories().map(
            (story) => _StoryItem(
              userName: story['name'] as String,
              userPhoto: story['photo'] as String?,
              hasStory: true,
              onTap: () {
                // TODO: View story
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Xem story của ${story['name']}'),
                    duration: const Duration(seconds: 1),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  List<Map<String, dynamic>> _getMockStories() {
    // Mock data - replace with real data from Firestore
    return [
      {'name': 'user_1', 'photo': null},
      {'name': 'user_2', 'photo': null},
      {'name': 'user_3', 'photo': null},
      {'name': 'user_4', 'photo': null},
      {'name': 'user_5', 'photo': null},
    ];
  }
}

class _StoryItem extends StatelessWidget {
  final String userName;
  final String? userPhoto;
  final bool isYourStory;
  final bool hasStory;
  final VoidCallback onTap;

  const _StoryItem({
    required this.userName,
    this.userPhoto,
    this.isYourStory = false,
    this.hasStory = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 70,
        margin: const EdgeInsets.symmetric(horizontal: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              children: [
                // Story circle with gradient border
                Container(
                  width: 66,
                  height: 66,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: hasStory
                        ? LinearGradient(
                            colors: [
                              Colors.purple.shade400,
                              Colors.pink.shade400,
                              Colors.orange.shade400,
                            ],
                            begin: Alignment.topRight,
                            end: Alignment.bottomLeft,
                          )
                        : null,
                    border: !hasStory
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
                      backgroundImage: userPhoto != null
                          ? CachedNetworkImageProvider(userPhoto!)
                          : null,
                      child: userPhoto == null
                          ? const Icon(Icons.person, size: 30)
                          : null,
                    ),
                  ),
                ),
                // Add icon for your story
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
