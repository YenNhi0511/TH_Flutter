# Instagram-Style Social Media App - Complete Build Guide

## 🚀 Current Status: FOUNDATION COMPLETE ✅

**What's Done:**

- ✅ Firebase datasources (Auth, Users, Posts, Comments)
- ✅ Repository implementations with error handling
- ✅ User & Post entities with complete fields
- ✅ Comment entity for discussions
- ✅ Auth Provider with state management
- ✅ Zero build errors
- ✅ Clean Architecture fully implemented

**Remaining Tasks:**

- 🔨 Posts Provider for state management
- 🔨 Feed UI pages (Home, Profile, Search, Upload)
- 🔨 Bottom Navigation setup
- 🔨 Like/Comment UI components
- 🔨 Follow system UI
- 🔨 Testing & optimization

---

## 📋 Step-by-Step Implementation Guide

### PHASE 1: Complete Posts Provider (30 mins)

Create `lib/core/providers/posts_provider.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:mangxahoi/features/posts/data/datasources/remote_post_datasource.dart';
import 'package:mangxahoi/features/posts/domain/entities/post.dart';
import 'package:mangxahoi/features/posts/domain/entities/comment.dart';

class PostsProvider with ChangeNotifier {
  final RemotePostDatasource _datasource = RemotePostDatasource();
  List<Post> _posts = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<Post> get posts => _posts;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> loadPosts() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _posts = await _datasource.getPosts();
    } catch (e) {
      _errorMessage = e.toString();
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
    }
  }

  Future<void> likePost(String postId, String userId) async {
    try {
      await _datasource.likePost(postId: postId, userId: userId);
      // Update local state
      final index = _posts.indexWhere((p) => p.id == postId);
      if (index != -1) {
        final post = _posts[index];
        _posts[index] = post.copyWith(
          likes: [...post.likes, userId],
        );
        notifyListeners();
      }
    } catch (e) {
      _errorMessage = e.toString();
    }
  }

  Future<void> unlikePost(String postId, String userId) async {
    try {
      await _datasource.unlikePost(postId: postId, userId: userId);
      // Update local state
      final index = _posts.indexWhere((p) => p.id == postId);
      if (index != -1) {
        final post = _posts[index];
        final newLikes = post.likes.where((id) => id != userId).toList();
        _posts[index] = post.copyWith(likes: newLikes);
        notifyListeners();
      }
    } catch (e) {
      _errorMessage = e.toString();
    }
  }
}
```

### PHASE 2: Create Modern Feed UI (45 mins)

**Create `lib/features/posts/presentation/pages/feed_page.dart`:**

Replace current HomePage with a proper Instagram-style feed:

```dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mangxahoi/core/providers/auth_provider.dart';
import 'package:mangxahoi/core/providers/posts_provider.dart';
import 'package:cached_network_image/cached_network_image.dart';

class FeedPage extends StatefulWidget {
  const FeedPage({super.key});

  @override
  State<FeedPage> createState() => _FeedPageState();
}

class _FeedPageState extends State<FeedPage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(
      () => context.read<PostsProvider>().loadPosts(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Chia Sẻ Ảnh',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        elevation: 0,
        backgroundColor: Colors.white,
      ),
      body: Consumer<PostsProvider>(
        builder: (context, postsProvider, _) {
          if (postsProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (postsProvider.posts.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.image, size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  const Text('Không có bài viết nào'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => postsProvider.loadPosts(),
                    child: const Text('Tải lại'),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () => postsProvider.loadPosts(),
            child: ListView.builder(
              itemCount: postsProvider.posts.length,
              itemBuilder: (context, index) {
                final post = postsProvider.posts[index];
                return _PostCard(post: post);
              },
            ),
          );
        },
      ),
    );
  }
}

class _PostCard extends StatelessWidget {
  final Post post;

  const _PostCard({required this.post});

  @override
  Widget build(BuildContext context) {
    final currentUser = context.read<AuthProvider>().currentUser;
    final isLiked = post.isLikedByUser(currentUser?.id ?? '');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // User info header
        Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundImage: post.userPhotoUrl != null
                    ? CachedNetworkImageProvider(post.userPhotoUrl!)
                    : null,
                child: post.userPhotoUrl == null
                    ? const Icon(Icons.person)
                    : null,
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    post.userName,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  Text(
                    _timeAgo(post.createdAt),
                    style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              const Icon(Icons.more_horiz),
            ],
          ),
        ),

        // Image
        CachedNetworkImage(
          imageUrl: post.imageUrl,
          width: double.infinity,
          height: 400,
          fit: BoxFit.cover,
          placeholder: (context, url) =>
              const Center(child: CircularProgressIndicator()),
          errorWidget: (context, url, error) =>
              const Icon(Icons.error),
        ),

        // Like and comment buttons
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
          child: Row(
            children: [
              GestureDetector(
                onTap: () {
                  if (isLiked) {
                    context.read<PostsProvider>().unlikePost(
                          post.id,
                          currentUser?.id ?? '',
                        );
                  } else {
                    context.read<PostsProvider>().likePost(
                          post.id,
                          currentUser?.id ?? '',
                        );
                  }
                },
                child: Icon(
                  isLiked ? Icons.favorite : Icons.favorite_border,
                  color: isLiked ? Colors.red : Colors.black,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              const Icon(Icons.comment_outlined, size: 28),
              const SizedBox(width: 16),
              const Icon(Icons.send_outlined, size: 28),
            ],
          ),
        ),

        // Like count
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text(
            '${post.likeCount} likes',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),

        // Caption
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: post.userName,
                  style: const TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextSpan(
                  text: ' ${post.caption}',
                  style: const TextStyle(color: Colors.black),
                ),
              ],
            ),
          ),
        ),

        // Comment count
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          child: Text(
            'View all ${post.commentCount} comments',
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 12,
            ),
          ),
        ),
        const Divider(),
      ],
    );
  }

  String _timeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inSeconds < 60) {
      return 'now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d';
    } else {
      return '${(difference.inDays / 7).floor()}w';
    }
  }
}
```

### PHASE 3: Create Upload Page (30 mins)

**Create `lib/features/posts/presentation/pages/upload_page.dart`**

### PHASE 4: Create User Profile Page (40 mins)

**Create `lib/features/auth/presentation/pages/profile_page.dart`**

### PHASE 5: Create Bottom Navigation (20 mins)

**Create `lib/features/presentation/pages/main_app.dart`** with BottomNavigationBar connecting:

- Feed (home)
- Upload (add)
- Profile (account)
- Search (explore)

### PHASE 6: Update Main App Routing

Update `main.dart` to show MainApp instead of HomePage/AuthPage

---

## 🔧 Setup Instructions for Completion

### Install Provider Package

```bash
flutter pub add provider
```

### Update pubspec.yaml imports

### Create the remaining pages following the templates above

### Firebase Console Setup

1. Set Firestore security rules:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /users/{userId} {
      allow read: if true;
      allow write: if request.auth.uid == userId;
    }
    match /posts/{postId} {
      allow read: if true;
      allow create, update: if request.auth.uid == resource.data.userId;
      allow delete: if request.auth.uid == resource.data.userId;

      match /comments/{commentId} {
        allow read: if true;
        allow create, update: if request.auth.uid == resource.data.userId;
        allow delete: if request.auth.uid == resource.data.userId;
      }
    }
  }
}
```

---

## ✅ Completion Checklist

Phase 1: Posts Provider Setup

- [ ] Create PostsProvider
- [ ] Add to main.dart with MultiProvider

Phase 2: Feed UI

- [ ] Create FeedPage with post listing
- [ ] Implement like/unlike functionality
- [ ] Add image loading with cached_network_image

Phase 3: Upload Page

- [ ] Image picker integration
- [ ] Caption input
- [ ] Upload to Firebase Storage

Phase 4: User Profile

- [ ] Display user info
- [ ] Show user's posts
- [ ] Follow/Unfollow buttons
- [ ] Edit profile

Phase 5: Navigation

- [ ] Bottom nav bar
- [ ] Route between screens
- [ ] Update main auth routing

Phase 6: Final Touches

- [ ] Search functionality
- [ ] Comments display
- [ ] Like animations
- [ ] Pull-to-refresh

---

## 📱 Expected Features After Completion

✅ User Authentication (Sign up, Login, Logout)
✅ Create Posts with images & captions
✅ Like/Unlike posts
✅ Comment on posts
✅ View user profiles
✅ Follow/Unfollow users
✅ Search for users
✅ View feed of followed users' posts
✅ Edit profile information
✅ Upload profile photos

---

## 🎨 UI/UX Guidelines

**Colors:**

- Primary: #6366F1 (Indigo)
- Secondary: #3B82F6 (Blue)
- Accent: #06B6D4 (Cyan)

**Typography:**

- Headlines: Bold, 24pt+
- Body: Regular, 14-16pt
- Captions: 12pt, Grey

**Spacing:**

- 8px grid system
- 12-16px padding for containers
- 8px gap between elements

---

## 🚀 After Implementation

1. **Test all features** with real Firebase project
2. **Optimize performance** with image caching
3. **Add error handling** for network issues
4. **Test with multiple users** to verify follow/unfollow
5. **Deploy to TestFlight/Play Store** when ready

---

## 📞 Next Steps

1. Run `flutter pub add provider`
2. Create PostsProvider (copy code above)
3. Create FeedPage (copy code above)
4. Create UploadPage following same pattern
5. Create ProfilePage with user info
6. Create MainApp with BottomNavigationBar
7. Update main.dart routing
8. Test with Firebase

**Time Estimate: 4-6 hours for complete implementation**

Good luck! Your Instagram-style social media app will be complete! 🎉📱
