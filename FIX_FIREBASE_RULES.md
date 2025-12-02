# 🔥 Hướng dẫn sửa lỗi Firebase Permission Denied

## ⚠️ VẤN ĐỀ

App hiện tại bị lỗi **PERMISSION_DENIED** từ Firebase Firestore và Storage vì Security Rules quá nghiêm ngặt, không cho phép user đã đăng nhập truy cập dữ liệu.

### Lỗi trong terminal:

```
W/Firestore: Listen for Query failed: Status{code=PERMISSION_DENIED,
description=Missing or insufficient permissions., cause=null}
```

### Triệu chứng:

- ❌ Trang chủ (Feed) trống, hiện "Có lỗi xảy ra"
- ❌ Upload ảnh báo "Vui lòng đăng nhập" dù đã đăng nhập
- ❌ Trang hồ sơ cá nhân báo "Vui lòng đăng nhập" dù đã đăng nhập
- ✅ Đăng nhập/Đăng ký hoạt động bình thường (Firebase Auth OK)

---

## ✅ GIẢI PHÁP - Sửa Firebase Security Rules

### Bước 1: Mở Firebase Console

1. Truy cập: https://console.firebase.google.com/
2. Chọn project: **mangxahoi-f31f1**
3. Đăng nhập bằng Google account (nếu chưa)

---

### Bước 2: Sửa Firestore Database Rules

#### 2.1. Vào Firestore Database

- Sidebar bên trái → Click **Firestore Database**
- Hoặc direct link: https://console.firebase.google.com/project/mangxahoi-f31f1/firestore

#### 2.2. Chọn tab Rules

- Click tab **Rules** (ở giữa màn hình)
- Bạn sẽ thấy rules hiện tại

#### 2.3. Thay thế Rules

**Xóa toàn bộ** nội dung cũ và paste code mới này:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {

    // User documents - Chỉ user đó mới sửa được
    match /users/{userId} {
      allow read: if request.auth != null;
      allow write: if request.auth != null && request.auth.uid == userId;
    }

    // Posts - Tất cả user đã đăng nhập có thể đọc
    match /posts/{postId} {
      allow read: if request.auth != null;
      allow create: if request.auth != null && request.auth.uid == request.resource.data.userId;
      allow update: if request.auth != null; // Cho phép like/unlike
      allow delete: if request.auth != null && request.auth.uid == resource.data.userId;

      // Comments subcollection
      match /comments/{commentId} {
        allow read: if request.auth != null;
        allow create: if request.auth != null;
        allow delete: if request.auth != null && request.auth.uid == resource.data.userId;
      }
    }
  }
}
```

#### 2.4. Publish Rules

- Click nút **Publish** (màu xanh, góc trên bên phải)
- Chờ vài giây cho đến khi thông báo "Rules published successfully"

---

### Bước 3: Sửa Firebase Storage Rules

#### 3.1. Vào Storage

- Sidebar bên trái → Click **Storage**
- Hoặc direct link: https://console.firebase.google.com/project/mangxahoi-f31f1/storage

#### 3.2. Chọn tab Rules

- Click tab **Rules** (ở giữa màn hình)

#### 3.3. Thay thế Rules

**Xóa toàn bộ** nội dung cũ và paste code mới này:

```javascript
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {

    // Post images - User chỉ upload vào folder của mình
    match /posts/{userId}/{allPaths=**} {
      allow read: if request.auth != null;
      allow write: if request.auth != null && request.auth.uid == userId;
    }

    // Profile photos
    match /profile_photos/{userId}/{allPaths=**} {
      allow read: if request.auth != null;
      allow write: if request.auth != null && request.auth.uid == userId;
    }
  }
}
```

#### 3.4. Publish Rules

- Click nút **Publish** (màu xanh, góc trên bên phải)
- Chờ vài giây cho đến khi thông báo "Rules published successfully"

---

### Bước 4: Restart App

Sau khi publish cả 2 rules (Firestore + Storage):

1. **Stop app** trong terminal (nếu đang chạy)
2. **Chạy lại app:**

   ```bash
   cd d:\TH_Flutter\Buoi1\mangxahoi
   flutter run
   ```

3. **Đăng nhập lại** vào app (nếu cần)

---

## 🎯 Kết quả mong đợi

Sau khi sửa rules:

- ✅ **Feed Page:** Hiển thị danh sách posts (nếu có)
- ✅ **Upload Page:** Upload ảnh thành công, không báo "Vui lòng đăng nhập"
- ✅ **Profile Page:** Hiển thị thông tin user và posts của user đó
- ✅ **Comments:** Có thể xem và thêm comments
- ✅ **Like/Unlike:** Hoạt động bình thường

---

## 🔍 Kiểm tra Rules đã được apply

### Cách 1: Check trong Firebase Console

1. Vào **Firestore Database → Rules**
2. Kiểm tra ngày giờ "Last published" phải là thời gian vừa publish
3. Rules phải giống với code đã paste ở trên

### Cách 2: Test trong app

1. Đăng nhập vào app
2. Vào Feed page → Nếu thấy "Có lỗi xảy ra" thì rules chưa được apply
3. Thử upload 1 ảnh → Nếu upload thành công = Rules OK!

---

## ⚙️ Giải thích Rules

### Firestore Rules:

```javascript
// User chỉ đọc và sửa document của chính mình
match /users/{userId} {
  allow read: if request.auth != null;           // Bất kỳ ai đã login
  allow write: if request.auth.uid == userId;    // Chỉ chính user đó
}

// Posts: Ai cũng đọc được, nhưng chỉ owner mới xóa được
match /posts/{postId} {
  allow read: if request.auth != null;           // Ai đã login cũng xem được
  allow create: if request.auth.uid == request.resource.data.userId; // Tạo post với userId của mình
  allow update: if request.auth != null;         // Cho phép like (bất kỳ ai)
  allow delete: if request.auth.uid == resource.data.userId; // Chỉ owner mới xóa
}
```

### Storage Rules:

```javascript
// User chỉ upload vào folder có tên = userId của mình
match /posts/{userId}/{allPaths=**} {
  allow read: if request.auth != null;           // Ai cũng xem được
  allow write: if request.auth.uid == userId;    // Chỉ upload vào folder của mình
}
```

---

## 🚨 Nếu vẫn lỗi

### 1. Clear app data:

```bash
flutter clean
flutter pub get
flutter run
```

### 2. Kiểm tra user đã đăng nhập:

- Vào Profile page → Phải thấy email user
- Nếu không thấy → Logout và login lại

### 3. Check Firebase Console:

- Vào **Authentication** → Tab **Users**
- Phải có user đã đăng ký
- Copy UID của user

### 4. Check Firestore data:

- Vào **Firestore Database** → Tab **Data**
- Nếu chưa có collection `posts` → Tạo 1 post mới trong app
- Check xem post có field `userId` khớp với UID không

### 5. Check logs:

```bash
flutter run --verbose
```

- Tìm dòng có `PERMISSION_DENIED`
- Nếu vẫn có = Rules chưa được apply đúng

---

## 📝 Files đã tạo

Đã tạo 2 files rules local (để backup):

1. `firestore.rules` - Firestore Database rules
2. `storage.rules` - Firebase Storage rules

**Lưu ý:** Files này chỉ để tham khảo. Phải sửa trực tiếp trên Firebase Console mới có hiệu lực!

---

## ✅ Checklist

- [ ] Đã mở Firebase Console
- [ ] Đã vào Firestore Database → Rules
- [ ] Đã paste rules mới cho Firestore
- [ ] Đã click Publish cho Firestore
- [ ] Đã vào Storage → Rules
- [ ] Đã paste rules mới cho Storage
- [ ] Đã click Publish cho Storage
- [ ] Đã restart app
- [ ] App đã hoạt động bình thường

---

## 🎉 Kết luận

Sau khi hoàn thành các bước trên, app **mangxahoi** sẽ hoạt động đầy đủ:

- Feed hiển thị posts
- Upload ảnh thành công
- Profile hiển thị đúng
- Comments hoạt động
- Like/Unlike hoạt động

**App Instagram-style của bạn đã sẵn sàng! 🚀**
