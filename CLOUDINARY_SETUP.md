# 🌐 Hướng dẫn setup Cloudinary cho mangxahoi

## ✅ Đã hoàn thành

### 1. Thông tin Cloudinary

- **Cloud Name**: `dx3xaceda`
- **API Key**: `523266593293361`
- **API Secret**: `Zy6NsZf9aFyfXOAvh6xEOp4x9YE`

### 2. Code đã cập nhật

- ✅ Thêm package `cloudinary_public: ^0.23.1`
- ✅ Tạo `CloudinaryService` mới
- ✅ Cập nhật `RemotePostDatasource` để dùng Cloudinary
- ✅ Xóa dependency `firebase_storage`

---

## 📋 CÒN PHẢI LÀM (5 phút)

### Bước 1: Tạo Upload Preset (BẮT BUỘC!)

1. **Mở Cloudinary Console:**

   - Vào: https://console.cloudinary.com/settings/upload
   - Đăng nhập nếu cần

2. **Scroll xuống "Upload presets"**

3. **Click "Add upload preset"**

4. **Điền thông tin:**

   ```
   Preset name: mangxahoi_preset
   Signing mode: Unsigned ⚠️ (QUAN TRỌNG - chọn Unsigned!)
   Folder: (để trống)
   ```

5. **Click "Save"**

### Tại sao cần Unsigned?

- **Unsigned** cho phép upload trực tiếp từ mobile app không cần backend
- **Signed** yêu cầu API Secret trên server (bảo mật hơn nhưng cần backend)

---

## 🎯 Sau khi tạo preset

### Test app:

```bash
cd d:\TH_Flutter\Buoi1\mangxahoi
flutter run
```

### Upload ảnh test:

1. Đăng nhập vào app
2. Tap nút "+" để upload ảnh
3. Chọn ảnh từ gallery
4. Thêm caption và đăng

### Kiểm tra trong Cloudinary:

1. Vào: https://console.cloudinary.com/console/media_library
2. Click folder `posts/[userId]/`
3. Sẽ thấy ảnh vừa upload!

---

## 🆚 So sánh Firebase Storage vs Cloudinary

### Firebase Storage (CŨ):

- ❌ Free tier chỉ 5GB
- ❌ Cần phải trả phí khi vượt quota
- ❌ Không có auto-optimization
- ❌ Không có CDN mạnh
- ✅ Tích hợp tốt với Firebase

### Cloudinary (MỚI):

- ✅ Free tier 10GB (gấp đôi!)
- ✅ 25 monthly credits miễn phí
- ✅ Tự động optimize ảnh (WebP, resize)
- ✅ CDN toàn cầu (nhanh hơn)
- ✅ Dễ sử dụng
- ✅ Không cần trả phí cho app học tập

---

## 📊 Tính năng Cloudinary

### Tự động optimize:

```dart
// Original URL
https://res.cloudinary.com/dx3xaceda/image/upload/v123/posts/user1/abc.jpg

// Optimized (300x300, auto quality, auto format)
https://res.cloudinary.com/dx3xaceda/image/upload/w_300,h_300,q_auto,f_auto/v123/posts/user1/abc.jpg
```

### Sử dụng trong app:

```dart
// Get optimized image URL
final optimizedUrl = CloudinaryService.getOptimizedUrl(
  originalUrl,
  width: 300,
  height: 300,
  quality: 'auto',
);

// Use in CachedNetworkImage
CachedNetworkImage(imageUrl: optimizedUrl)
```

---

## 🔒 Bảo mật

### API Secret:

- **KHÔNG** commit API Secret lên GitHub
- Chỉ dùng trong backend/server
- Mobile app chỉ cần Cloud Name + Upload Preset (unsigned)

### Upload Preset:

- Unsigned preset cho phép upload không cần authentication
- Có thể giới hạn:
  - File size (max 10MB recommended)
  - File types (jpg, png, gif)
  - Image dimensions
  - Folder structure

### Thiết lập giới hạn (Optional):

1. Vào Upload Preset settings
2. Scroll xuống "Upload Manipulations"
3. Set:
   - Max file size: 10 MB
   - Allowed formats: jpg, png, jpeg
   - Max width: 2000px
   - Max height: 2000px

---

## 📝 Code changes

### Đã thay đổi:

#### 1. pubspec.yaml

```yaml
# Removed:
# firebase_storage: ^12.3.0

# Added:
http: ^1.1.0
cloudinary_public: ^0.23.1
```

#### 2. CloudinaryService (NEW)

```dart
// lib/core/services/cloudinary_service.dart
class CloudinaryService {
  static const String _cloudName = 'dx3xaceda';
  static const String _uploadPreset = 'mangxahoi_preset';

  Future<String> uploadImage({
    required String imagePath,
    required String folder,
    required String userId,
  }) async {
    final response = await _cloudinary.uploadFile(
      CloudinaryFile.fromFile(
        imagePath,
        folder: '$folder/$userId',
        resourceType: CloudinaryResourceType.Image,
      ),
    );
    return response.secureUrl;
  }
}
```

#### 3. RemotePostDatasource

```dart
// Old:
final ref = _storage.ref().child('posts/$userId/$postId.jpg');
await ref.putFile(File(imagePath));
final imageUrl = await ref.getDownloadURL();

// New:
final imageUrl = await _cloudinary.uploadImage(
  imagePath: imagePath,
  folder: 'posts',
  userId: userId,
);
```

---

## 🐛 Troubleshooting

### Lỗi: "Upload preset not found"

**Giải pháp:**

- Kiểm tra preset name = `mangxahoi_preset` (chính xác)
- Preset phải là **Unsigned**
- Reload lại app sau khi tạo preset

### Lỗi: "Upload failed"

**Giải pháp:**

- Check internet connection
- Verify Cloud Name = `dx3xaceda`
- Check preset đã được tạo và enabled

### Lỗi: "Invalid signature"

**Giải pháp:**

- Đổi preset sang **Unsigned** mode
- Không cần API Secret cho unsigned preset

### Ảnh upload chậm

**Giải pháp:**

- Cloudinary upload trực tiếp, không qua Firebase
- Check network speed
- Có thể resize ảnh trước khi upload (giảm file size)

---

## 📱 Cấu trúc folder trong Cloudinary

```
mangxahoi (Cloud Name: dx3xaceda)
├── posts/
│   ├── user_id_1/
│   │   ├── abc123.jpg
│   │   ├── def456.jpg
│   │   └── ...
│   ├── user_id_2/
│   │   └── ...
│   └── ...
└── (future: profile_photos/, stories/, etc.)
```

---

## 🎉 Lợi ích khi chuyển sang Cloudinary

1. **Tiết kiệm chi phí**: 10GB miễn phí vs 5GB Firebase
2. **Performance tốt hơn**: CDN toàn cầu, auto-optimize
3. **Dễ quản lý**: Dashboard trực quan, search ảnh dễ dàng
4. **Tự động optimize**: WebP, lazy loading, responsive images
5. **Không giới hạn bandwidth** trong free tier (Firebase có giới hạn)

---

## ✅ Checklist

- [x] Tạo tài khoản Cloudinary
- [x] Lấy Cloud Name, API Key, API Secret
- [x] Cập nhật code với Cloud Name
- [x] Thêm packages: `cloudinary_public`, `http`
- [x] Tạo `CloudinaryService`
- [x] Cập nhật `RemotePostDatasource`
- [ ] **Tạo Upload Preset `mangxahoi_preset` (Unsigned)** ⚠️ ĐANG CHỜ
- [ ] Test upload ảnh trong app
- [ ] Verify ảnh xuất hiện trong Cloudinary Dashboard

---

## 📞 Next Steps

1. **Tạo upload preset** như hướng dẫn ở trên
2. **Chạy app**: `flutter run`
3. **Test upload** ảnh
4. **Kiểm tra** trong Cloudinary Media Library

Sau khi tạo preset xong, báo tôi để test app nhé! 🚀
