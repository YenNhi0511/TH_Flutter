# 🚀 Ứng Dụng Mạng Xã Hội Hoàn Chỉnh - Hướng Dẫn Sử Dụng

## ✅ Tình Trạng Build Hiện Tại

### Giao Diện Đã Hoàn Thành

- ✅ **AuthPage** - Đăng Nhập/Đăng Ký (Glassmorphism UI)
- ✅ **FeedPage** - Feed bài viết kiểu Instagram
- ✅ **UploadPage** - Đăng bài mới với hình ảnh
- ✅ **ProfilePage** - Trang cá nhân người dùng
- ✅ **SearchPage** - Tìm kiếm người dùng
- ✅ **MainApp** - Bottom Navigation đầy đủ
- ✅ **PostCard** - Widget hiển thị bài viết Instagram-style

### Backend Đã Hoàn Thành

- ✅ Firebase Authentication (Email/Password)
- ✅ Firestore Database (Users, Posts, Comments)
- ✅ Firebase Storage (Profile Photos, Post Images)
- ✅ AuthProvider - Quản lý trạng thái đăng nhập
- ✅ PostsProvider - Quản lý trạng thái bài viết
- ✅ RemoteAuthDatasource - Firebase Auth operations
- ✅ RemoteUserDatasource - Quản lý users
- ✅ RemotePostDatasource - Quản lý posts & comments
- ✅ AuthRepositoryImpl - Business logic authentication

### Chức Năng Đã Hoàn Thành

- ✅ Đăng ký tài khoản mới
- ✅ Đăng nhập bằng email/password
- ✅ Đăng xuất
- ✅ Xem feed bài viết
- ✅ Đăng bài mới (upload ảnh + caption)
- ✅ Like/Unlike bài viết
- ✅ Xem số lượng lượt thích
- ✅ Xem trang cá nhân
- ✅ Xem bài viết của user
- ✅ Tìm kiếm người dùng
- ✅ Pull-to-refresh feed
- ✅ Time-ago formatting (vừa xong, 1p, 1h, 1d, etc)
- ✅ Error handling & Vietnamese messages

---

## 🎨 Giao Diện Chi Tiết

### 1. Auth Screen (Đăng Nhập/Đăng Ký)

```
┌─────────────────────────────┐
│    Chia Sẻ Ảnh              │  ← Tiêu đề
│                              │
│  [Đăng Nhập | Đăng Ký] Tabs │  ← Chuyển đổi
│                              │
│  Email:    [input field]     │
│  Password: [input field]     │
│  Name:     [input field] (chỉ signup)
│                              │
│  [    Đăng Nhập/Ký    ]     │
│                              │
│  Hoặc: [Facebook] [Google]  │
└─────────────────────────────┘
```

### 2. Feed Screen (Trang Chủ)

```
┌─────────────────────────────┐
│ Chia Sẻ Ảnh  💓  💬  📨     │ ← Header
├─────────────────────────────┤
│ [Avatar] Người Dùng  2h      │ ⋮ ← Menu
├─────────────────────────────┤
│                              │
│      [    Ảnh Bài Viết   ]  │
│                              │
├─────────────────────────────┤
│ ❤️   💬   📤      📌         │ ← Tương tác
│ 325 lượt thích               │
│ người_dùng Chú thích bài...  │
│ Xem tất cả 12 bình luận      │
└─────────────────────────────┘
  [Pull to refresh]
```

### 3. Upload Screen

```
┌─────────────────────────────┐
│ Đăng Bài Mới                │ ← Header
├─────────────────────────────┤
│                              │
│      [   Chọn Ảnh   ]       │
│      📷 Camera  🖼️ Thư viện  │
│                              │
├─────────────────────────────┤
│ Viết chú thích...            │ ← Caption input
│ [                        ]  │
│                              │
│ [    Đăng Bài    ]          │ ← Upload button
└─────────────────────────────┘
```

### 4. Profile Screen

```
┌─────────────────────────────┐
│ Hồ Sơ              🚪        │ ← Header + Logout
├─────────────────────────────┤
│        [Avatar]              │
│    Tên Người Dùng           │
│    Tiểu sử nếu có           │
│                              │
│  125 Bài viết │ 500 Followers │ 200 Đang theo  │
│                              │
│  [ Chỉnh Sửa Hồ Sơ ]       │
├─────────────────────────────┤
│ [Bài viết] [Đã lưu]         │ ← Tabs
├─────────────────────────────┤
│ [Ảnh] [Ảnh] [Ảnh]           │ ← Grid bài viết
│ [Ảnh] [Ảnh] [Ảnh]           │
│ [Ảnh] [Ảnh]                 │
└─────────────────────────────┘
```

### 5. Search Screen

```
┌─────────────────────────────┐
│ Tìm Kiếm                    │
├─────────────────────────────┤
│ 🔍 Tìm kiếm người dùng...  │ ← Search bar
├─────────────────────────────┤
│ [Avatar] Người Dùng 1       │
│ Tiểu sử người dùng...       │ [Xem]
│                              │
│ [Avatar] Người Dùng 2       │
│ Tiểu sử người dùng...       │ [Xem]
│                              │
│ [Avatar] Người Dùng 3       │
│ Tiểu sử người dùng...       │ [Xem]
└─────────────────────────────┘
```

### 6. Bottom Navigation

```
┌─────────────────────────────┐
│       [Content Area]        │
├─────────────────────────────┤
│ 🏠    ➕    🔍    👤        │ ← Bottom Nav
│Feed  Upload Search Profile  │
└─────────────────────────────┘
```

---

## 📱 Các File Chính

### Presentation Layer (Giao Diện)

```
lib/features/
├── auth/presentation/pages/
│   ├── auth_page.dart            (Đăng nhập/Đăng ký)
│   ├── profile_page.dart         (Trang cá nhân)
│   └── search_page.dart          (Tìm kiếm người dùng)
├── posts/presentation/
│   ├── pages/
│   │   ├── feed_page.dart        (Feed bài viết)
│   │   └── upload_page.dart      (Đăng bài)
│   └── widgets/
│       └── post_card.dart        (Widget hiển thị bài viết)
└── presentation/pages/
    └── main_app.dart             (Bottom Navigation)
```

### Business Logic (State Management)

```
lib/core/providers/
├── auth_provider.dart            (AuthProvider - Quản lý auth)
└── posts_provider.dart           (PostsProvider - Quản lý posts)
```

### Data Layer (Firebase)

```
lib/features/
├── auth/data/
│   ├── datasources/
│   │   ├── remote_auth_datasource.dart
│   │   └── remote_user_datasource.dart
│   └── repositories/
│       └── auth_repository_impl.dart
└── posts/data/
    └── datasources/
        └── remote_post_datasource.dart
```

### Domain Layer (Models)

```
lib/features/
├── auth/domain/
│   ├── entities/
│   │   └── user.dart
│   ├── repositories/
│   │   └── auth_repository.dart
│   └── usecases/
│       └── sign_up_usecase.dart
└── posts/domain/
    ├── entities/
    │   ├── post.dart
    │   └── comment.dart
    └── repositories/
        └── post_repository.dart (nếu cần)
```

---

## 🔥 Cấu Hình Firebase

### Firestore Collections

#### Users Collection

```
users/{userId}
├── id: string
├── email: string
├── displayName: string
├── photoUrl: string
├── bio: string
├── createdAt: timestamp
├── postsCount: number
├── followersCount: number
├── followingCount: number
├── followers: array [userId1, userId2, ...]
└── following: array [userId1, userId2, ...]
```

#### Posts Collection

```
posts/{postId}
├── id: string
├── userId: string
├── userName: string
├── userPhotoUrl: string
├── imageUrl: string
├── caption: string
├── likes: array [userId1, userId2, ...]  (Danh sách user đã like)
├── commentCount: number
├── createdAt: timestamp
├── updatedAt: timestamp
└── comments (subcollection)
    ├── {commentId}
    │   ├── id: string
    │   ├── postId: string
    │   ├── userId: string
    │   ├── userName: string
    │   ├── userPhotoUrl: string
    │   ├── text: string
    │   └── createdAt: timestamp
```

### Security Rules

**Firestore Rules:**

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

**Storage Rules:**

```javascript
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

## 🎯 Chức Năng Chính

### 1. Hệ Thống Xác Thực (Authentication)

- **Đăng Ký:** Tạo tài khoản mới bằng email + password + tên
- **Đăng Nhập:** Xác thực tài khoản với email + password
- **Đăng Xuất:** Logout và xóa session
- **Session Persistence:** Tự động đăng nhập nếu còn session

### 2. Bài Viết (Posts)

- **Xem Feed:** Pull-to-refresh, load bài viết từ Firestore
- **Đăng Bài:** Chọn ảnh từ camera/thư viện + viết caption
- **Like/Unlike:** Cập nhật danh sách like realtime
- **Xóa Bài:** Chỉ người đăng mới có thể xóa
- **Bình Luận:** (UI sẵn sàng, logic comment được implement ở datasource)

### 3. Hồ Sơ Người Dùng (Profile)

- **Xem Hồ Sơ:** Avatar, bio, số lượng bài/followers/following
- **Xem Bài Viết:** Grid bài viết của user
- **Theo Dõi:** (UI sẵn sàng, logic được implement ở datasource)
- **Chỉnh Sửa:** (UI sẵn sàng cho phát triển sau)

### 4. Tìm Kiếm (Search)

- **Tìm Người:** Tìm user bằng tên
- **Xem Profile:** Click user để xem hồ sơ

---

## 🚀 Cách Sử Dụng

### 1. Lần Đầu Sử Dụng

```
1. Chạy ứng dụng: flutter run
2. Nhấn "Đăng Ký"
3. Điền: email, password, tên người dùng
4. Nhấn "Đăng Ký"
5. Tự động chuyển đến Feed
```

### 2. Đăng Bài Mới

```
1. Nhấn tab "Đăng Bài"
2. Nhấn "📷 Camera" hoặc "🖼️ Thư viện" để chọn ảnh
3. Điền chú thích (optional)
4. Nhấn "Đăng Bài"
5. Bài viết xuất hiện ở Feed
```

### 3. Tương Tác Với Bài Viết

```
1. Nhấn ❤️ để like
2. Nhấn 💬 để comment (sắp có)
3. Nhấn 📤 để share (sắp có)
4. Nhấn 📌 để lưu (sắp có)
```

### 4. Xem Trang Cá Nhân

```
1. Nhấn tab "👤 Hồ Sơ"
2. Xem số liệu: bài viết, followers, following
3. Xem grid bài viết dưới
4. Nhấn "🚪 Logout" để đăng xuất
```

### 5. Tìm Người

```
1. Nhấn tab "🔍 Tìm Kiếm"
2. Gõ tên người muốn tìm
3. Nhấn "Xem" để xem hồ sơ (sắp có)
```

---

## ⚙️ Quy Trình Kỹ Thuật

### User Registration Flow

```
User Input (Email, Password, Name)
    ↓
AuthProvider.signUp()
    ↓
AuthRepositoryImpl.signUp()
    ↓
RemoteAuthDatasource.signUp()
    ↓
Firebase Auth - createUserWithEmailAndPassword()
    ↓
RemoteUserDatasource.createUser() - Create Firestore Document
    ↓
Profile Updated in UI ✅
```

### Post Upload Flow

```
User Select Image + Write Caption
    ↓
UploadPage.uploadPost()
    ↓
PostsProvider.createPost()
    ↓
RemotePostDatasource.createPost()
    ↓
Firebase Storage - Upload Image
    ↓
Get Download URL
    ↓
Firestore - Create Post Document
    ↓
Update User postsCount
    ↓
Feed Refreshed ✅
```

### Like Flow (Optimistic Update)

```
User Tap Like Button
    ↓
UI Update Immediately (Optimistic)
    ↓
PostsProvider.likePost() - Async
    ↓
RemotePostDatasource.likePost()
    ↓
Firestore FieldValue.arrayUnion(userId) - Add to likes array
    ↓
Sync Complete ✅
(If error: Revert UI and reload)
```

---

## 🎨 Design System

### Color Palette

- **Primary:** `#6366F1` (Indigo)
- **Secondary:** `#3B82F6` (Blue)
- **Accent:** `#06B6D4` (Cyan)
- **Background:** White / Dark Mode

### Typography

- **Heading:** 24px, Bold (Tên người dùng)
- **Title:** 18px, Bold (Section titles)
- **Body:** 14px, Regular (Post captions)
- **Caption:** 12px, Light (Timestamps)

### Spacing

- **Padding:** 16px (standard)
- **Margin:** 12-16px (between cards)
- **Gap:** 8-12px (between elements)

### Border Radius

- **Buttons:** 12px
- **Cards:** 16px
- **Avatars:** Circular (50px radius)

---

## 📊 Performance Optimizations

1. **Optimistic Updates:** Like/Unlike update UI immediately
2. **Lazy Loading:** Feed loads posts on demand
3. **Caching:** CachedNetworkImage caches images
4. **IndexedStack:** Bottom nav maintains state
5. **FieldValue:** Atomic Firestore updates

---

## 🐛 Known Limitations & TODOs

### Implemented ✅

- Authentication (Email/Password)
- Posts CRUD (Create, Read, Delete)
- Like system
- User profiles
- Search users
- Feed with refresh
- Image upload to Firebase Storage

### Partially Implemented 🔨

- Comments (Datasource ready, UI in progress)
- Follow system (Datasource ready, UI pending)

### TODO (Sắp Có) ⏳

- Comments UI & full flow
- Follow/Unfollow functionality
- Direct messages
- Notifications
- Share posts
- Save posts (Bookmarks)
- Edit profile bio & photos
- Hashtags
- Stories
- Reels
- Offline support

---

## 🔐 Security Notes

1. **Firebase Auth:** Email verification recommended
2. **Firestore Rules:** Already restrictive (user can only edit own data)
3. **Storage:** Only owner can upload to their folder
4. **Input Validation:** Implement client-side validation
5. **Rate Limiting:** Firebase provides built-in rate limiting

---

## 📱 Testing Checklist

- [ ] Sign up works correctly
- [ ] Login persists session
- [ ] Logout clears session
- [ ] Upload image successfully
- [ ] Like/Unlike works
- [ ] Feed refreshes
- [ ] Profile shows correct data
- [ ] Search finds users
- [ ] No crash on errors
- [ ] Network errors handled gracefully
- [ ] Images load properly
- [ ] Time formatting correct (vừa xong, 1p, etc)
- [ ] Bottom nav doesn't lose state

---

## 🚀 Deployment

### APK Build

```bash
flutter build apk --release
```

### Web Build

```bash
flutter build web --release
```

### iOS Build

```bash
flutter build ios --release
```

Output sẽ ở:

- **APK:** `build/app/outputs/flutter-apk/app-release.apk`
- **Web:** `build/web/`
- **iOS:** `build/ios/ipa/`

---

## 📞 Troubleshooting

### Issue: Firebase connection failed

- [ ] Check Firebase credentials
- [ ] Verify internet connection
- [ ] Check Firestore rules

### Issue: Images not loading

- [ ] Check Firebase Storage rules
- [ ] Verify URL is correct
- [ ] Check image file size

### Issue: App crashes

- [ ] Check logcat/console
- [ ] Run `flutter doctor`
- [ ] Rebuild: `flutter clean && flutter pub get`

---

## 🎓 Học Thêm

- **Firebase Docs:** https://firebase.google.com/docs
- **Flutter Docs:** https://flutter.dev/docs
- **Provider Package:** https://pub.dev/packages/provider
- **Material Design:** https://m3.material.io

---

**Hoàn thành tại:** 2024
**Status:** 🟢 Đang Chạy - Sẵn Sàng Phát Triển Thêm
**App Version:** 1.0.0
