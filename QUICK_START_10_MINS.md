# Social Media App - Quick Start (10 mins)

## ✅ What's Already Done

```
✅ Database schemas (User, Post, Comment)
✅ Firebase integration (Auth, Firestore, Storage)
✅ All datasources created
✅ Repository implementations complete
✅ Auth provider with login/signup
✅ Zero build errors
✅ Ready for UI implementation
```

---

## 🚀 Next 3 Quick Steps

### Step 1: Add Provider Package (1 min)

```bash
cd d:\TH_Flutter\Buoi1\mangxahoi
flutter pub add provider
```

### Step 2: Create Posts Provider (5 mins)

Copy the `PostsProvider` code from `COMPLETE_BUILD_GUIDE.md` and create:

```
lib/core/providers/posts_provider.dart
```

### Step 3: Update Main App (3 mins)

Update `lib/main.dart` to initialize Provider:

```dart
import 'package:provider/provider.dart';
import 'package:mangxahoi/core/providers/auth_provider.dart';
import 'package:mangxahoi/core/providers/posts_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => PostsProvider()),
      ],
      child: MaterialApp(
        title: 'Chia Sẻ Ảnh',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF6366F1),
            brightness: Brightness.light,
          ),
          useMaterial3: true,
        ),
        darkTheme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF6366F1),
            brightness: Brightness.dark,
          ),
          useMaterial3: true,
        ),
        themeMode: ThemeMode.system,
        home: StreamBuilder<User?>(
          stream: FirebaseAuth.instance.authStateChanges(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }

            if (snapshot.hasData) {
              return const MainApp();  // Create this next
            }

            return const AuthPage();
          },
        ),
      ),
    );
  }
}
```

---

## 🎯 What to Build Next (in order)

1. **MainApp** (Bottom Navigation) - 15 mins

   - FeedPage tab
   - UploadPage tab
   - ProfilePage tab
   - SearchPage tab

2. **FeedPage** - 30 mins

   - Display posts from `PostsProvider`
   - Like/Unlike buttons
   - Show comments count

3. **UploadPage** - 25 mins

   - Image picker
   - Caption input
   - Upload button

4. **ProfilePage** - 25 mins

   - User info display
   - User's posts grid
   - Follow/Unfollow button

5. **SearchPage** - 15 mins
   - Search input
   - User list results
   - Profile links

---

## 📋 Detailed Implementation Steps

### Create MainApp (lib/features/presentation/pages/main_app.dart)

```dart
import 'package:flutter/material.dart';
import 'package:mangxahoi/features/posts/presentation/pages/feed_page.dart';
import 'package:mangxahoi/features/auth/presentation/pages/profile_page.dart';

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const FeedPage(),
    const UploadPage(),
    const SearchPage(),
    const ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Feed'),
          BottomNavigationBarItem(icon: Icon(Icons.add_circle_outline), label: 'Upload'),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Search'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}
```

### Create FeedPage (lib/features/posts/presentation/pages/feed_page.dart)

See full code in `COMPLETE_BUILD_GUIDE.md` file

### Create UploadPage (lib/features/posts/presentation/pages/upload_page.dart)

```dart
class UploadPage extends StatefulWidget {
  const UploadPage({super.key});

  @override
  State<UploadPage> createState() => _UploadPageState();
}

class _UploadPageState extends State<UploadPage> {
  File? _selectedImage;
  final _captionController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    // Similar pattern to HomePage
    // 1. Show image picker
    // 2. Display preview
    // 3. Input caption
    // 4. Upload button
    // 5. Call PostsProvider.createPost()
  }
}
```

---

## 🔥 Firebase Console Final Setup

### Security Rules for Firestore

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
      allow create: if request.auth.uid != null;
      allow update, delete: if request.auth.uid == resource.data.userId;
      match /comments/{commentId} {
        allow read: if true;
        allow create: if request.auth.uid != null;
        allow delete: if request.auth.uid == resource.data.userId;
      }
    }
  }
}
```

### Storage Rules

```
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    match /profile_photos/{userId}/{allPaths=**} {
      allow read: if true;
      allow write: if request.auth.uid == userId;
    }
    match /posts/{userId}/{allPaths=**} {
      allow read: if true;
      allow write: if request.auth.uid == userId;
    }
  }
}
```

---

## ✅ Testing Checklist

Before deploying:

- [ ] Sign up works
- [ ] Login works
- [ ] Can upload image
- [ ] Image appears in feed
- [ ] Can like/unlike posts
- [ ] Can comment on posts
- [ ] Can follow/unfollow users
- [ ] Profile page shows user info
- [ ] Search finds users
- [ ] Pull-to-refresh works
- [ ] No crashes or errors
- [ ] Images load properly
- [ ] Navigation between tabs works

---

## 🎯 Total Time Estimate

- Provider setup: 10 mins ✅
- MainApp + Navigation: 15 mins
- FeedPage: 30 mins
- UploadPage: 25 mins
- ProfilePage: 25 mins
- SearchPage: 15 mins
- Testing & fixes: 20 mins

**Total: ~2 hours** for a complete Instagram-style social media app!

---

## 📞 Common Issues & Solutions

**Q: Images not loading?**
A: Check Firebase Storage rules, ensure images URL is accessible

**Q: Provider not updating UI?**
A: Make sure to call `notifyListeners()` after state changes

**Q: Posts not appearing?**
A: Check Firestore database rules, ensure posts collection exists

**Q: Following users not working?**
A: Verify user document has `followers` and `following` arrays

---

**Ready to build? Start with Step 1 now!** 🚀
