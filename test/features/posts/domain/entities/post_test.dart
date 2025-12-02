import 'package:flutter_test/flutter_test.dart';
import 'package:mangxahoi/features/posts/domain/entities/post.dart';

/// Unit Tests cho Post Entity
/// Test các logic nghiệp vụ: tạo đối tượng Post, like, copyWith, serialization
void main() {
  group('Post Entity Tests', () {
    late Post testPost;
    final testDate = DateTime(2024, 1, 1, 12, 0, 0);

    setUp(() {
      testPost = Post(
        id: 'post1',
        userId: 'user1',
        userName: 'Test User',
        userPhotoUrl: 'https://example.com/photo.jpg',
        imageUrl: 'https://example.com/image.jpg',
        caption: 'Test caption',
        likes: ['user2', 'user3'],
        commentCount: 5,
        createdAt: testDate,
        updatedAt: testDate,
      );
    });

    test('Tạo Post với tất cả các trường', () {
      expect(testPost.id, 'post1');
      expect(testPost.userId, 'user1');
      expect(testPost.userName, 'Test User');
      expect(testPost.userPhotoUrl, 'https://example.com/photo.jpg');
      expect(testPost.imageUrl, 'https://example.com/image.jpg');
      expect(testPost.caption, 'Test caption');
      expect(testPost.likes, ['user2', 'user3']);
      expect(testPost.commentCount, 5);
      expect(testPost.createdAt, testDate);
      expect(testPost.updatedAt, testDate);
    });

    test('Tạo Post với các trường optional rỗng', () {
      final minimalPost = Post(
        id: 'post2',
        userId: 'user2',
        userName: 'Minimal User',
        imageUrl: 'https://example.com/minimal.jpg',
        createdAt: testDate,
        updatedAt: testDate,
      );

      expect(minimalPost.userPhotoUrl, isNull);
      expect(minimalPost.caption, isNull);
      expect(minimalPost.likes, isEmpty);
      expect(minimalPost.commentCount, 0);
    });

    test('likeCount trả về số lượng likes chính xác', () {
      expect(testPost.likeCount, 2);

      final postWithNoLikes = Post(
        id: 'post3',
        userId: 'user3',
        userName: 'No Likes User',
        imageUrl: 'https://example.com/nolikes.jpg',
        createdAt: testDate,
        updatedAt: testDate,
      );

      expect(postWithNoLikes.likeCount, 0);
    });

    test('isLikedByUser trả về true khi user đã like', () {
      expect(testPost.isLikedByUser('user2'), isTrue);
      expect(testPost.isLikedByUser('user3'), isTrue);
    });

    test('isLikedByUser trả về false khi user chưa like', () {
      expect(testPost.isLikedByUser('user1'), isFalse);
      expect(testPost.isLikedByUser('user999'), isFalse);
    });

    test('copyWith tạo bản sao với các trường được cập nhật', () {
      final updatedPost = testPost.copyWith(
        caption: 'Updated caption',
        commentCount: 10,
      );

      expect(updatedPost.id, testPost.id);
      expect(updatedPost.userId, testPost.userId);
      expect(updatedPost.caption, 'Updated caption');
      expect(updatedPost.commentCount, 10);
      expect(updatedPost.likes, testPost.likes);
    });

    test('copyWith thêm user vào likes', () {
      final likedPost = testPost.copyWith(likes: [...testPost.likes, 'user4']);

      expect(likedPost.likes, ['user2', 'user3', 'user4']);
      expect(likedPost.likeCount, 3);
      expect(likedPost.isLikedByUser('user4'), isTrue);
    });

    test('copyWith xóa user khỏi likes', () {
      final unlikedPost = testPost.copyWith(
        likes: ['user3'], // Remove user2
      );

      expect(unlikedPost.likes, ['user3']);
      expect(unlikedPost.likeCount, 1);
      expect(unlikedPost.isLikedByUser('user2'), isFalse);
    });

    test('toMap chuyển đổi Post thành Map chính xác', () {
      final map = testPost.toMap();

      expect(map['id'], 'post1');
      expect(map['userId'], 'user1');
      expect(map['userName'], 'Test User');
      expect(map['userPhotoUrl'], 'https://example.com/photo.jpg');
      expect(map['imageUrl'], 'https://example.com/image.jpg');
      expect(map['caption'], 'Test caption');
      expect(map['likes'], ['user2', 'user3']);
      expect(map['commentCount'], 5);
      expect(map['createdAt'], testDate.toIso8601String());
      expect(map['updatedAt'], testDate.toIso8601String());
    });

    test('fromMap tạo Post từ Map chính xác', () {
      final map = {
        'id': 'post4',
        'userId': 'user4',
        'userName': 'From Map User',
        'userPhotoUrl': 'https://example.com/frommap.jpg',
        'imageUrl': 'https://example.com/frommap_image.jpg',
        'caption': 'From map caption',
        'likes': ['user5', 'user6', 'user7'],
        'commentCount': 15,
        'createdAt': testDate.toIso8601String(),
        'updatedAt': testDate.toIso8601String(),
      };

      final post = Post.fromMap(map);

      expect(post.id, 'post4');
      expect(post.userId, 'user4');
      expect(post.userName, 'From Map User');
      expect(post.userPhotoUrl, 'https://example.com/frommap.jpg');
      expect(post.imageUrl, 'https://example.com/frommap_image.jpg');
      expect(post.caption, 'From map caption');
      expect(post.likes, ['user5', 'user6', 'user7']);
      expect(post.commentCount, 15);
      expect(post.createdAt, testDate);
      expect(post.updatedAt, testDate);
    });

    test('fromMap xử lý Map với trường thiếu', () {
      final incompleteMap = {
        'id': 'post5',
        'userId': 'user5',
        'imageUrl': 'https://example.com/incomplete.jpg',
      };

      final post = Post.fromMap(incompleteMap);

      expect(post.id, 'post5');
      expect(post.userId, 'user5');
      expect(post.userName, 'Unknown'); // Default value
      expect(post.userPhotoUrl, isNull);
      expect(post.imageUrl, 'https://example.com/incomplete.jpg');
      expect(post.caption, isNull);
      expect(post.likes, isEmpty);
      expect(post.commentCount, 0);
      expect(post.createdAt, isA<DateTime>());
      expect(post.updatedAt, isA<DateTime>());
    });

    test('toMap và fromMap round-trip serialization', () {
      final map = testPost.toMap();
      final reconstructedPost = Post.fromMap(map);

      expect(reconstructedPost.id, testPost.id);
      expect(reconstructedPost.userId, testPost.userId);
      expect(reconstructedPost.userName, testPost.userName);
      expect(reconstructedPost.userPhotoUrl, testPost.userPhotoUrl);
      expect(reconstructedPost.imageUrl, testPost.imageUrl);
      expect(reconstructedPost.caption, testPost.caption);
      expect(reconstructedPost.likes, testPost.likes);
      expect(reconstructedPost.commentCount, testPost.commentCount);
      expect(reconstructedPost.createdAt, testPost.createdAt);
      expect(reconstructedPost.updatedAt, testPost.updatedAt);
    });

    test('Kiểm tra immutability - copyWith không thay đổi object gốc', () {
      final originalLikes = List<String>.from(testPost.likes);
      final originalCaption = testPost.caption;

      testPost.copyWith(caption: 'New caption', likes: ['user999']);

      // Original post không thay đổi
      expect(testPost.caption, originalCaption);
      expect(testPost.likes, originalLikes);
    });
  });

  group('Post Edge Cases', () {
    final testDate = DateTime(2024, 1, 1);

    test('Post với likes list rỗng', () {
      final post = Post(
        id: 'empty',
        userId: 'user',
        userName: 'User',
        imageUrl: 'image.jpg',
        likes: [],
        createdAt: testDate,
        updatedAt: testDate,
      );

      expect(post.likes, isEmpty);
      expect(post.likeCount, 0);
      expect(post.isLikedByUser('anyone'), isFalse);
    });

    test('Post với caption rất dài', () {
      final longCaption = 'A' * 1000;
      final post = Post(
        id: 'long',
        userId: 'user',
        userName: 'User',
        imageUrl: 'image.jpg',
        caption: longCaption,
        createdAt: testDate,
        updatedAt: testDate,
      );

      expect(post.caption, longCaption);
      expect(post.caption!.length, 1000);
    });

    test('Post với nhiều likes', () {
      final manyLikes = List.generate(1000, (i) => 'user$i');
      final post = Post(
        id: 'popular',
        userId: 'user',
        userName: 'User',
        imageUrl: 'image.jpg',
        likes: manyLikes,
        createdAt: testDate,
        updatedAt: testDate,
      );

      expect(post.likeCount, 1000);
      expect(post.isLikedByUser('user500'), isTrue);
      expect(post.isLikedByUser('user9999'), isFalse);
    });

    test('Post với special characters trong caption', () {
      final specialCaption = '🎉 Hello! @user #hashtag 👍 line\nbreak';
      final post = Post(
        id: 'special',
        userId: 'user',
        userName: 'User',
        imageUrl: 'image.jpg',
        caption: specialCaption,
        createdAt: testDate,
        updatedAt: testDate,
      );

      expect(post.caption, specialCaption);
    });
  });
}
