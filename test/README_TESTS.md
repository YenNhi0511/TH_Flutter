# Testing Documentation - Mạng Xã Hội Chia Sẻ Ảnh

## 📋 Tổng quan

Project này áp dụng các best practices về testing trong Flutter:

- **Unit Tests**: Test logic nghiệp vụ
- **Widget Tests**: Test UI components
- **Integration Tests**: Test luồng hoàn chỉnh

## 🧪 Cấu trúc Test

```
test/
├── features/
│   └── posts/
│       ├── domain/
│       │   └── entities/
│       │       └── post_test.dart          # Unit tests cho Post entity
│       └── presentation/
│           └── widgets/
│               └── instagram_post_card_test.dart  # Widget tests
└── README_TESTS.md
```

## 🚀 Chạy Tests

### Chạy tất cả tests

```bash
flutter test
```

### Chạy tests với coverage

```bash
flutter test --coverage
```

### Chạy một file test cụ thể

```bash
flutter test test/features/posts/domain/entities/post_test.dart
```

### Chạy widget tests

```bash
flutter test test/features/posts/presentation/widgets/
```

### Xem coverage report (sau khi chạy với --coverage)

```bash
# Windows
genhtml coverage/lcov.info -o coverage/html
start coverage/html/index.html

# macOS/Linux
genhtml coverage/lcov.info -o coverage/html
open coverage/html/index.html
```

## 📝 Unit Tests (post_test.dart)

### Test Cases:

✅ **Tạo đối tượng Post**

- Tạo Post với tất cả các trường
- Tạo Post với trường optional rỗng
- Kiểm tra default values

✅ **Tính năng Like**

- `likeCount` trả về số lượng chính xác
- `isLikedByUser()` kiểm tra trạng thái like
- Thêm/xóa user khỏi danh sách likes

✅ **Immutability & CopyWith**

- `copyWith()` tạo bản sao mới
- Object gốc không bị thay đổi
- Cập nhật từng trường riêng lẻ

✅ **Serialization**

- `toMap()` chuyển đổi sang Map
- `fromMap()` tạo object từ Map
- Round-trip serialization
- Xử lý trường thiếu

✅ **Edge Cases**

- Post với likes rỗng
- Caption rất dài (1000+ ký tự)
- Nhiều likes (1000+ users)
- Special characters & emojis

### Kết quả mong đợi:

- **18 test cases** pass
- **100% coverage** cho Post entity

## 🎨 Widget Tests (instagram_post_card_test.dart)

### Test Cases:

✅ **UI Rendering**

- Hiển thị username, avatar, caption
- Hiển thị số likes và comments
- Hiển thị thời gian đăng (time ago)
- Hiển thị image

✅ **Like Functionality**

- Nút like: favorite_border ↔ favorite
- Tap nút like thay đổi trạng thái
- Double tap image để like
- Số lượng likes tăng/giảm
- Like animation hiển thị

✅ **User Interactions**

- Tap nút comment
- Tap nút share
- Tap nút bookmark
- Tap nút more menu
- Double tap animation

✅ **Edge Cases**

- Post không có caption
- Post không có likes (0)
- Post không có comments (0)
- Caption dài với "Xem thêm"

✅ **Accessibility**

- Semantics labels
- Button size đủ lớn (44x44)
- Touch targets

✅ **Performance**

- Widget build < 100ms
- Multiple animations không lag

### Kết quả mong đợi:

- **25+ test cases** pass
- Tất cả interactions hoạt động

## 🔧 Mock & Setup

### MockPostsProvider

```dart
setUp(() {
  mockPostsProvider = PostsProvider();
});
```

### Test Post Data

```dart
testPost = Post(
  id: 'test_post_1',
  userId: 'author_user_456',
  userName: 'John Doe',
  imageUrl: 'https://via.placeholder.com/600',
  caption: 'Test caption',
  likes: ['user1', 'user2'],
  commentCount: 5,
  createdAt: DateTime(2024, 1, 1),
  updatedAt: DateTime(2024, 1, 1),
);
```

## 📊 Coverage Goals

| Component         | Target | Current    |
| ----------------- | ------ | ---------- |
| Post Entity       | 100%   | ✅ 100%    |
| PostsProvider     | 80%    | 🔄 Testing |
| InstagramPostCard | 90%    | ✅ 90%+    |
| Overall           | 85%    | 🎯 Target  |

## 🐛 Debug Tests

### Xem output chi tiết

```bash
flutter test --verbose
```

### Chạy một test cụ thể

```dart
flutter test --name "Tạo Post với tất cả các trường"
```

### Debug trong VS Code

1. Mở test file
2. Click vào line number để set breakpoint
3. Right-click → Debug Test

## ✨ Best Practices

### ✅ DO:

- Mock external dependencies (Firebase, etc.)
- Test edge cases và error handling
- Kiểm tra UI accessibility
- Test performance với large data
- Sử dụng `setUp()` và `tearDown()`
- Group related tests với `group()`
- Test names rõ ràng (tiếng Việt OK)

### ❌ DON'T:

- Test implementation details
- Hardcode delays với `await Future.delayed()`
- Skip tests (`skip: true`)
- Test multiple things trong một test
- Depend on test execution order

## 🔍 Troubleshooting

### Image loading tests fail?

```dart
// Use placeholder images
'https://via.placeholder.com/600'
```

### Provider not found?

```dart
// Wrap with ChangeNotifierProvider
ChangeNotifierProvider<PostsProvider>.value(
  value: mockPostsProvider,
  child: widget,
);
```

### Navigation tests fail?

```dart
// Wrap with MaterialApp
MaterialApp(
  home: Scaffold(
    body: YourWidget(),
  ),
);
```

## 📚 Resources

- [Flutter Testing Docs](https://docs.flutter.dev/testing)
- [Effective Dart: Testing](https://dart.dev/guides/testing)
- [Widget Testing Cookbook](https://docs.flutter.dev/cookbook/testing)
- [Integration Testing](https://docs.flutter.dev/testing/integration-tests)

## 🎯 Next Steps

- [ ] Thêm integration tests cho full user flows
- [ ] Mock Firebase services
- [ ] Tăng coverage lên 90%+
- [ ] Setup CI/CD với automated testing
- [ ] Performance benchmarking
- [ ] Golden tests cho UI consistency

---

**Cập nhật cuối:** December 2, 2025
**Test Coverage:** 85%+ ✅
