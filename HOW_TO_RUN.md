# ▶️ Hướng Dẫn Chạy Ứng Dụng

## 🚀 Chạy Ứng Dụng

### Bước 1: Chuẩn Bị Môi Trường

```bash
# Kiểm tra Flutter
flutter doctor

# Cập nhật dependencies
flutter pub get
```

### Bước 2: Chạy Trên Emulator/Device

```bash
# Chạy debug
flutter run

# Chạy release
flutter run --release

# Chạy web
flutter run -d chrome
```

### Bước 3: Build APK

```bash
# Debug APK
flutter build apk

# Release APK
flutter build apk --release

# Output: build/app/outputs/flutter-apk/app-release.apk
```

---

## 🔥 Firebase Setup (Nếu Chưa Có)

### 1. Tạo Firebase Project

```
1. Go to: https://console.firebase.google.com
2. Click "Create Project"
3. Name: "Chia Sẻ Ảnh" (or any name)
4. Follow wizard to complete
```

### 2. Add Android App

```
1. In Firebase Console → Add App → Android
2. Bundle ID: com.example.mangxahoi
3. Download google-services.json
4. Copy to: android/app/
```

### 3. Add iOS App (Optional)

```
1. In Firebase Console → Add App → iOS
2. Bundle ID: com.example.mangxahoi
3. Download GoogleService-Info.plist
4. Add to Xcode project
```

### 4. Enable Authentication

```
1. Firebase Console → Authentication
2. Click "Get Started"
3. Enable "Email/Password"
4. Click "Save"
```

### 5. Create Firestore Database

```
1. Firebase Console → Firestore Database
2. Click "Create Database"
3. Choose "Start in Production Mode"
4. Select region (asia-southeast1 recommended)
5. Wait for creation to complete
```

### 6. Update Firestore Rules

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

### 7. Enable Cloud Storage

```
1. Firebase Console → Storage
2. Click "Get Started"
3. Choose "Start in Production Mode"
4. Select same region as Firestore
```

### 8. Update Storage Rules

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

## 📋 Debug & Troubleshooting

### Issue 1: flutter: App không chạy

```bash
# Clean build
flutter clean
flutter pub get
flutter run
```

### Issue 2: Firebase connection failed

```bash
# Verify:
1. google-services.json in android/app/
2. Internet connection active
3. Firebase rules not blocking access
4. Check logcat: adb logcat | grep Firebase
```

### Issue 3: Images not loading

```bash
# Check:
1. Storage security rules allow read: if true
2. Image URL is valid
3. Firebase Storage quota not exceeded
4. Network connection stable
```

### Issue 4: Build error

```bash
# Fix:
flutter pub clean
rm -rf .dart_tool
flutter pub get
flutter run
```

---

## 🧪 Testing

### Test Signup

```
1. Run app
2. Click "Đăng Ký"
3. Enter: test@example.com, password123, TestUser
4. Click "Đăng Ký"
5. Should see FeedPage
```

### Test Upload

```
1. Click "Đăng Bài"
2. Select any image
3. Write caption
4. Click "Đăng Bài"
5. Should appear in feed
```

### Test Like

```
1. In feed, click heart icon
2. Should turn red and count increase
3. Click again to unlike
4. Should turn gray and count decrease
```

### Test Profile

```
1. Click Profile tab
2. Should show your info
3. Should show your posts in grid
4. Should show followers/following counts
```

### Test Search

```
1. Click Search tab
2. Type a name
3. Should show results
4. Click "Xem" to view profile
```

---

## 💡 Tips & Tricks

### Hot Reload

```bash
# Press 'r' during flutter run
# Code changes apply immediately (mostly)
```

### Hot Restart

```bash
# Press 'R' during flutter run
# Full app restart (slower, but more reliable)
```

### Device Testing

```bash
# List devices
flutter devices

# Run on specific device
flutter run -d <device_id>
```

### Logging

```dart
// In code
print('Debug: $variable');
debugPrint('Debug: $variable');

// View in terminal
flutter run | grep "Debug:"
```

### Firebase Console Debugging

```
1. Go to: console.firebase.google.com
2. Firestore → Check collections created
3. Storage → Check uploaded images
4. Authentication → Check registered users
```

---

## 📊 Performance Monitoring

### Check Performance

```bash
# Use DevTools
flutter pub global activate devtools
devtools

# Or use in-app
flutter run

# Press 'w' during run to open DevTools
```

### Monitor Memory

```bash
# In DevTools:
1. Open Memory tab
2. Take heap snapshots
3. Look for memory leaks
4. Check large objects
```

### Profile Build

```bash
flutter run --profile

# This gives you better performance insights
# while still having debugging info
```

---

## 🎯 Next Steps

### After First Run

```
1. ✅ Verify Firebase connection
2. ✅ Test all 5 main screens
3. ✅ Try signup/login
4. ✅ Upload a test post
5. ✅ Like/Unlike a post
6. ✅ Search for users
```

### For Production

```
1. ⚠️ Change app ID (com.example.mangxahoi)
2. ⚠️ Update app name
3. ⚠️ Add app icon & splash screen
4. ⚠️ Enable Firebase email verification
5. ⚠️ Setup Firebase backups
6. ⚠️ Deploy to Play Store / App Store
```

---

## 🔐 Security Checklist

Before going to production:

- [ ] Firebase rules restrict user access ✅
- [ ] Images have public read-only access ✅
- [ ] No sensitive data in localStorage
- [ ] Email verification enabled
- [ ] Rate limiting configured
- [ ] Backups enabled
- [ ] Monitoring alerts setup
- [ ] Privacy policy written
- [ ] Terms of service written

---

## 📚 Commands Summary

```bash
# Development
flutter run                    # Run debug
flutter run --profile        # Run profiled
flutter run --release        # Run optimized

# Build
flutter build apk            # Build APK
flutter build apk --release # Build release APK
flutter build ios           # Build iOS
flutter build web           # Build web

# Maintenance
flutter clean              # Clean build
flutter pub get           # Get dependencies
flutter pub upgrade       # Upgrade dependencies
flutter doctor            # Check setup
flutter analyze          # Analyze code
flutter format .         # Format code

# Debug
flutter devices          # List devices
flutter logs            # View logs
devtools                # Open DevTools
```

---

**Ready to Launch! 🎉**

Nếu gặp vấn đề gì, hãy:

1. Kiểm tra `flutter doctor`
2. Đọc lại error message cẩn thận
3. Xem Firebase Console logs
4. Xóa build cache: `flutter clean`
5. Cài lại dependencies: `flutter pub get`
